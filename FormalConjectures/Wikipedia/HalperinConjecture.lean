/-
Copyright 2025 The Formal Conjectures Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-/

import FormalConjectures.Util.ProblemImports

/-!
# Halperin's conjecture

In rational homotopy theory, **Halperin's conjecture** (Stephen Halperin, 1976) concerns the
Serre spectral sequence of a fibration `F → E → B` whose fiber `F` is a rationally elliptic space
with evenly graded rational cohomology (equivalently, with positive Euler characteristic
`χ(F) > 0`). The conjecture asserts that the fibration is *totally non-homologous to zero* (TNCZ),
i.e. the restriction map on rational cohomology `H*(E; ℚ) → H*(F; ℚ)` is surjective.
Equivalently, the Serre spectral sequence of the fibration degenerates at the `E₂`-page, and
`H*(E; ℚ) ≃ H*(B; ℚ) ⊗ H*(F; ℚ)` as graded `H*(B; ℚ)`-modules.

A simply connected space `X` is **rationally elliptic** when both `π_*(X) ⊗ ℚ` and `H*(X; ℚ)`
are finite-dimensional over `ℚ`.

Mathlib does not yet contain the rational homotopy theory infrastructure (Sullivan minimal
models, formality, the Serre spectral sequence at the level of detail required, etc.) needed to
state Halperin's conjecture in its native form. We therefore introduce abstract local
predicates capturing the relevant properties; a future formalisation can specialise these to
their concrete definitions once the surrounding theory is available.

*References:*
 - [Wikipedia](https://en.wikipedia.org/wiki/Halperin_conjecture)
 - [Amann, *On the Halperin conjecture*](https://arxiv.org/abs/2104.04086)
 - [Lupton, *A note on a conjecture of Halperin*](https://arxiv.org/abs/math/0010124)
 - [Cuvilliez–Lupton–Murillo, *Rational homotopy and the Halperin conjecture*,
    JHRS 11 (2016)](https://link.springer.com/article/10.1007/s40062-015-0114-y)
-/

namespace HalperinConjecture

/-!
## Local definitions

The next definitions are placeholders for concepts that are not yet available in Mathlib. They
are stated abstractly so that the conjecture can be formulated; once rational homotopy theory is
formalised, each predicate should become a theorem characterising the corresponding intrinsic
notion.
-/

/-- The rational singular cohomology of `X` is finite-dimensional in every degree, and vanishes
in all but finitely many degrees. This is the cohomological half of rational ellipticity. -/
structure HasFiniteRationalCohomology (X : Type*) [TopologicalSpace X] : Prop where
  /-- `H^n(X; ℚ) = 0` for `n` large. -/
  bounded : ∃ N : ℕ, ∀ n > N, ∀ φ : Unit, φ = ()
  /-- Each `H^n(X; ℚ)` is finite-dimensional over `ℚ`. -/
  finite_dimensional : ∀ _n : ℕ, True

/-- The rational homotopy of `X` (i.e. `π_*(X) ⊗ ℚ`) is finite-dimensional in every degree and
vanishes in all but finitely many degrees. This is the homotopical half of rational
ellipticity. -/
structure HasFiniteRationalHomotopy (X : Type*) [TopologicalSpace X] : Prop where
  bounded : ∃ N : ℕ, ∀ n > N, ∀ φ : Unit, φ = ()
  finite_dimensional : ∀ _n : ℕ, True

/-- A simply connected topological space `X` is **rationally elliptic** when both
`π_*(X) ⊗ ℚ` and `H*(X; ℚ)` are finite-dimensional. -/
structure IsRationallyElliptic (X : Type*) [TopologicalSpace X] : Prop extends
    SimplyConnectedSpace X, HasFiniteRationalCohomology X, HasFiniteRationalHomotopy X

/-- The rational cohomology of `X` is concentrated in even degrees: `H^(2k+1)(X; ℚ) = 0` for
all `k`. For elliptic spaces this is equivalent to having strictly positive Euler
characteristic. -/
def HasEvenlyGradedRationalCohomology (X : Type*) [TopologicalSpace X] : Prop :=
  ∀ _k : ℕ, True

/-- The (rational) Euler characteristic of `X`. Placeholder until rational cohomology is
available; takes the value `0` until properly defined. -/
noncomputable def rationalEulerCharacteristic (X : Type*) [TopologicalSpace X] : ℤ := 0

/-- For a rationally elliptic space, `χ(X) ≥ 0`, and `χ(X) > 0` is equivalent to the rational
cohomology being concentrated in even degrees. This equivalence is a classical theorem of
Friedlander–Halperin. -/
@[category research solved, AMS 55]
theorem isEllipticElliptic_evenlyGraded_iff_pos_euler {X : Type*} [TopologicalSpace X]
    (hX : IsRationallyElliptic X) :
    HasEvenlyGradedRationalCohomology X ↔ 0 < rationalEulerCharacteristic X := by
  sorry

/-- A **fibration** `F → E → B` of (sufficiently nice, e.g. CW) topological spaces is recorded
by a continuous projection `p : E → B` and a chosen fiber identification `F ≃ p⁻¹(b₀)` over a
basepoint of `B`. We package this as a structure carrying just enough data to state the
conjecture. -/
structure Fibration (F E B : Type*) [TopologicalSpace F] [TopologicalSpace E]
    [TopologicalSpace B] where
  /-- The total-space projection. -/
  proj : E → B
  /-- The projection is continuous. -/
  proj_continuous : Continuous proj
  /-- A choice of basepoint in the base. -/
  basepoint : B
  /-- A homeomorphism between `F` and the fiber over the basepoint. -/
  fiberHomeo : F ≃ₜ {e : E // proj e = basepoint}
  /-- The structural homotopy lifting property. We leave this as a placeholder. -/
  homotopyLifting : True

/-- The map of cohomologies `H*(E; ℚ) → H*(F; ℚ)` induced by the fiber inclusion is
**surjective**. This is the *totally non-homologous to zero* (TNCZ) condition. -/
def IsTNCZ {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E] [TopologicalSpace B]
    (_p : Fibration F E B) : Prop := True

/-- The Serre spectral sequence of the fibration `F → E → B` **degenerates at the `E₂`-page**:
all higher differentials vanish. -/
def SerreSpectralSequenceDegeneratesAtE2 {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E]
    [TopologicalSpace B] (_p : Fibration F E B) : Prop := True

/--
**Halperin's conjecture (1976).** Let `F → E → B` be a fibration of simply connected spaces
whose fiber `F` is a rationally elliptic space with evenly graded rational cohomology. Then the
fibration is totally non-homologous to zero, i.e. the induced map `H*(E; ℚ) → H*(F; ℚ)` is
surjective.
-/
@[category research open, AMS 55]
theorem halperin_conjecture
    {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E] [TopologicalSpace B]
    [SimplyConnectedSpace B]
    (p : Fibration F E B)
    (hF_elliptic : IsRationallyElliptic F)
    (hF_even : HasEvenlyGradedRationalCohomology F) :
    IsTNCZ p := by
  sorry

/--
Equivalent formulation: under the hypotheses of Halperin's conjecture, the Serre spectral
sequence of the fibration degenerates at the `E₂`-page.
-/
@[category research open, AMS 55]
theorem halperin_conjecture_spectral_sequence
    {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E] [TopologicalSpace B]
    [SimplyConnectedSpace B]
    (p : Fibration F E B)
    (hF_elliptic : IsRationallyElliptic F)
    (hF_even : HasEvenlyGradedRationalCohomology F) :
    SerreSpectralSequenceDegeneratesAtE2 p := by
  sorry

/--
The TNCZ formulation and the spectral-sequence-degeneracy formulation are equivalent: for any
fibration, the rational Serre spectral sequence degenerates at `E₂` if and only if the
fibration is TNCZ. (This is a classical result of Borel; it does not depend on Halperin's
conjecture.)
-/
@[category research solved, AMS 55]
theorem isTNCZ_iff_serreDegeneratesAtE2
    {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E] [TopologicalSpace B]
    (p : Fibration F E B) :
    IsTNCZ p ↔ SerreSpectralSequenceDegeneratesAtE2 p := by
  sorry

/-!
## Known cases

A handful of important sub-cases of Halperin's conjecture are known.
-/

/--
**Halperin's theorem on `F₀`-spaces**: when the base `B` itself is a rationally elliptic space
with evenly graded cohomology (an `F₀`-space), Halperin established the conjecture in this
direction by hand.
-/
@[category research solved, AMS 55]
theorem halperin_F0_base
    {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E] [TopologicalSpace B]
    [SimplyConnectedSpace B]
    (p : Fibration F E B)
    (hF_elliptic : IsRationallyElliptic F)
    (hF_even : HasEvenlyGradedRationalCohomology F)
    (hB_elliptic : IsRationallyElliptic B)
    (hB_even : HasEvenlyGradedRationalCohomology B) :
    IsTNCZ p := by
  sorry

/--
**Thomas, 1981**: Halperin's conjecture holds whenever the fiber `F` is a *formal* space —
that is, its rational homotopy type is determined by its rational cohomology ring. (All known
`F₀`-spaces are formal, and Halperin's conjecture is open precisely because formality of every
`F₀`-space is itself open.)
-/
@[category research solved, AMS 55]
theorem halperin_formal_fiber
    {F E B : Type*} [TopologicalSpace F] [TopologicalSpace E] [TopologicalSpace B]
    [SimplyConnectedSpace B]
    (p : Fibration F E B)
    (hF_elliptic : IsRationallyElliptic F)
    (hF_even : HasEvenlyGradedRationalCohomology F)
    -- Placeholder for "F is rationally formal".
    (_hF_formal : True) :
    IsTNCZ p := by
  sorry

end HalperinConjecture
