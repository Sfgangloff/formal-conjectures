#!/usr/bin/env node
/**
 * Metadata-integrity validator for the Formal Conjectures website.
 *
 * Checks that the JSON produced by `lake exe extract_names` is internally
 * consistent and matches the metadata schema the website assumes. This is
 * the first in a planned series of validators (see issue tracker); for now
 * it covers AMS subject classification codes only.
 *
 * Checks performed:
 *   1. The JS-side AMS map (site/lib/ams.js) matches the constructors of the
 *      `AMS` inductive in FormalConjectures/Util/Attributes/AMS.lean. This
 *      guards against drift between the two ends of the pipeline.
 *   2. Every problem's `subjects` field is an array of stringified
 *      non-negative integers, each of which is in the allowed MSC2020 set.
 *
 * Usage:
 *   node scripts/validate_metadata.js [path/to/conjectures.json]
 *
 * Exits 0 if all checks pass, 1 on validation failures, 2 on usage errors.
 */

'use strict';

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const DEFAULT_INPUT = path.join(REPO_ROOT, 'site', 'data', 'conjectures.json');
const AMS_LEAN = path.join(
  REPO_ROOT, 'FormalConjectures', 'Util', 'Attributes', 'AMS.lean',
);
const AMS_JS = path.join(REPO_ROOT, 'site', 'lib', 'ams.js');

const { AMS_SUBJECTS } = require(AMS_JS);

/**
 * Parse the AMS inductive in AMS.lean and return the set of declared codes.
 * The inductive lists one constructor `| «N»` per allowed MSC2020 code; we
 * scan the body up to the trailing `deriving` clause.
 */
function loadCanonicalAMSCodesFromLean(leanFilePath) {
  const src = fs.readFileSync(leanFilePath, 'utf8');
  const start = src.indexOf('inductive AMS');
  if (start === -1) {
    throw new Error(`Could not locate 'inductive AMS' in ${leanFilePath}`);
  }
  const end = src.indexOf('deriving', start);
  if (end === -1) {
    throw new Error(`Could not locate end of inductive AMS in ${leanFilePath}`);
  }
  const body = src.slice(start, end);
  const codes = new Set();
  const re = /\|\s*«(\d+)»/g;
  let m;
  while ((m = re.exec(body)) !== null) {
    codes.add(parseInt(m[1], 10));
  }
  if (codes.size === 0) {
    throw new Error(`No constructors parsed from inductive AMS in ${leanFilePath}`);
  }
  return codes;
}

function checkAMSMapMatchesLean(amsMap, leanCodes) {
  const jsCodes = new Set(Object.keys(amsMap).map((k) => parseInt(k, 10)));
  const inJsNotLean = [...jsCodes].filter((c) => !leanCodes.has(c)).sort((a, b) => a - b);
  const inLeanNotJs = [...leanCodes].filter((c) => !jsCodes.has(c)).sort((a, b) => a - b);
  const errors = [];
  if (inJsNotLean.length > 0) {
    errors.push(
      `site/lib/ams.js declares codes not present in AMS.lean: ${inJsNotLean.join(', ')}`,
    );
  }
  if (inLeanNotJs.length > 0) {
    errors.push(
      `AMS.lean declares codes not present in site/lib/ams.js: ${inLeanNotJs.join(', ')}`,
    );
  }
  return errors;
}

function checkProblemSubjects(problems, allowedCodes) {
  const errors = [];
  for (const p of problems) {
    const id = p.theorem || '<unknown theorem>';
    const subjects = p.subjects;
    if (subjects === undefined) continue;
    if (!Array.isArray(subjects)) {
      const got = subjects === null ? 'null' : typeof subjects;
      errors.push(`${id}: "subjects" must be an array, got ${got}`);
      continue;
    }
    for (const code of subjects) {
      // Require canonical decimal: "0" or a digit string with no leading zero.
      // Leading zeros would be silently normalized by parseInt and could mask
      // an extractor bug that emits e.g. "05" instead of "5".
      if (typeof code !== 'string' || !/^(0|[1-9]\d*)$/.test(code)) {
        errors.push(
          `${id}: AMS code ${JSON.stringify(code)} is not a canonical non-negative integer string`,
        );
        continue;
      }
      const n = parseInt(code, 10);
      if (!allowedCodes.has(n)) {
        errors.push(
          `${id}: AMS code "${code}" is not in the allowed MSC2020 set ` +
          `(see FormalConjectures/Util/Attributes/AMS.lean)`,
        );
      }
    }
  }
  return errors;
}

function reportErrors(label, errors) {
  if (errors.length === 0) return false;
  console.error(`${label} FAILED with ${errors.length} error(s):`);
  for (const e of errors) console.error(`  - ${e}`);
  return true;
}

function main(argv) {
  const inputPath = argv[2] || DEFAULT_INPUT;

  if (!fs.existsSync(inputPath)) {
    console.error(`Error: ${inputPath} not found.`);
    process.exit(2);
  }
  if (!fs.existsSync(AMS_LEAN)) {
    console.error(`Error: ${AMS_LEAN} not found.`);
    process.exit(2);
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
  } catch (e) {
    console.error(`Error: failed to parse ${inputPath}: ${e.message}`);
    process.exit(2);
  }
  const problems = parsed.problems;
  if (!Array.isArray(problems) || problems.length === 0) {
    console.error(
      `Error: ${inputPath} contains no "problems" array or it is empty.`,
    );
    process.exit(2);
  }

  let leanCodes;
  try {
    leanCodes = loadCanonicalAMSCodesFromLean(AMS_LEAN);
  } catch (e) {
    console.error(`Error: ${e.message}`);
    process.exit(2);
  }

  let failed = false;
  failed = reportErrors(
    'AMS map drift check (site/lib/ams.js vs AMS.lean)',
    checkAMSMapMatchesLean(AMS_SUBJECTS, leanCodes),
  ) || failed;
  failed = reportErrors(
    'AMS code validation (conjectures.json)',
    checkProblemSubjects(problems, leanCodes),
  ) || failed;

  if (failed) process.exit(1);

  console.log(
    `Metadata integrity OK: ${problems.length} problems checked, ` +
    `${leanCodes.size} canonical AMS codes.`,
  );
}

if (require.main === module) main(process.argv);

module.exports = {
  loadCanonicalAMSCodesFromLean,
  checkAMSMapMatchesLean,
  checkProblemSubjects,
};
