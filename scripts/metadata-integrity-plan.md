# Metadata integrity checks — rollout plan

The website at <https://google-deepmind.github.io/formal-conjectures> consumes
structured metadata extracted from the Lean source by `lake exe extract_names`
into `site/data/conjectures.json`. Many invariants the site implicitly depends
on are not currently validated in CI. This document tracks the incremental
rollout of `scripts/validate_metadata.js`, wired into
`.github/workflows/build-and-docs.yml` immediately after extraction so that any
PR or push to `main` fails fast on metadata inconsistency.

## Checks

- [x] **AMS codes** — every `subjects` entry is a canonical non-negative
  integer string and belongs to the allowed MSC2020 set; the JS-side AMS map
  (`site/lib/ams.js`) is cross-checked against the constructors of the `AMS`
  inductive in `FormalConjectures/Util/Attributes/AMS.lean` to catch drift
  between the two ends of the pipeline.
- [ ] **Categories** — every `category` value belongs to the allowed set
  (`research open`, `research solved`, `textbook`, `test`, `API`) and matches
  the `CATEGORY_META` map consumed by `site/build.js`.
- [ ] **`formal_proof` URLs** — `formalProofLink` is a syntactically valid URL
  when `formalProofKind` is set, and absent when it isn't; `formalProofKind`
  is one of the values produced by `formalProofKindToString`.
- [ ] **Duplicate identifiers / slugs** — no two entries share the same
  `theorem` name or the same generated browse slug.
- [ ] **Extraction completeness** — every `.lean` file under
  `FormalConjectures/` (excluding `Util/`) contributes at least one extracted
  entry, or is explicitly listed as expected to contribute none.
- [ ] **Source collections** — every collection produced by `getCollection`
  in `site/build.js` is present in the `SOURCE_COLLECTIONS` map (no
  `'Unknown'` fallbacks in the deployed data).
- [ ] **Generated browse links** — every URL emitted by `moduleToGitHubURL`
  and `moduleToSourceURL` resolves to a real on-disk path or generated output.

## Conventions

Each check above lands as its own small PR that:

- adds a focused validation function in `scripts/validate_metadata.js` and
  wires it into `main()` next to the existing checks;
- reuses the existing `Validate conjectures metadata` workflow step (added in
  PR1) — no new CI jobs;
- documents the edge cases exercised in the PR description.

The exit-code contract of `scripts/validate_metadata.js` is shared across
checks: `0` on success, `1` on per-entry validation failures, `2` on usage or
environment errors (missing input, malformed Lean source, etc.).
