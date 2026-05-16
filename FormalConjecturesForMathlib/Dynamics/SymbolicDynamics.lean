/-
Copyright 2026 The Formal Conjectures Authors.

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
module

public import Mathlib.Topology.Constructions
public import Mathlib.Topology.Separation.Basic
public import Mathlib.Logic.Function.Conjugate

/-!
# Symbolic dynamics: support for the factor-universal cellular automata problem

This file collects the definitions and basic API used by
`FormalConjectures/Other/UniversalCellularAutomaton.lean` (Hochman's
factor-universal CA problem). It has **two clearly separated parts**:

* **Part 1 — `namespace SymbolicDynamics.FullShift` (COPIED FROM MATHLIB).**
  Copied verbatim (statements and proofs) from Mathlib's
  `Mathlib/Dynamics/SymbolicDynamics/Basic.lean` (authored by Silvère Gangloff,
  © 2025). That Mathlib file additionally develops cylinders, patterns,
  forbidden sets, subshifts and languages; only the shift API is reproduced
  here. It is **not** available at this repository's pinned Mathlib
  (`v4.27.0`); it was added to Mathlib later. When the Mathlib pin is bumped
  past the release that introduces that file, delete Part 1 and
  `public import Mathlib.Dynamics.SymbolicDynamics.Basic` instead.

* **Part 2 — `namespace FactorUniversalCA` (NOT IN MATHLIB).** The bespoke
  notions for Hochman's problem: shift-equivariance, cellular automata, factor
  maps, and factor-universality. None of these are in Mathlib's symbolic
  dynamics development.
-/

@[expose] public section

/-
════════════════════════════════════════════════════════════════════════════════
  PART 1 — COPIED FROM MATHLIB, NOT ORIGINAL TO THIS REPOSITORY
  Source: Mathlib/Dynamics/SymbolicDynamics/Basic.lean
          (Silvère Gangloff, © 2025). Reproduced from the `ShiftDefinition`
          section. Sole adaptation: explicit `to_additive` names are supplied
          (`shift`, `shift_apply`, `shift_zero`, `shift_add`,
          `continuous_shift`) so the additive API matches upstream's intended
          names under this repository's pinned toolchain (whose `to_additive`
          would otherwise auto-name them `addShift…`). Statements and proofs are
          unchanged. Do not extend this block: add new material to Part 2.
════════════════════════════════════════════════════════════════════════════════
-/

namespace SymbolicDynamics

namespace FullShift

/-! ## Full shift and shift action -/

section ShiftDefinition

variable {A G : Type*} [Monoid G]

/-- The **left-translation shift** on configurations.

We call *configuration* an element of `G → A`.

Given a configuration `x : G → A` and an element `g : G` of the monoid, the shifted configuration
`mulShift g x` is defined by `(mulShift g x) h = x (g * h)`.

Intuitively, this moves the whole configuration "in the direction of `g`": the value
at position `h` in the shifted configuration is the value that was at position
`g * h` in the original one.

For example, if `G = ℤ` (with addition) and `A = {0, 1}`, then
`mulShift 1 x` is the sequence obtained from `x` by shifting every symbol one
step to the left. -/
@[to_additive shift /-- The **left-translation shift** on configurations, in additive notation.

We call *configuration* an element of `G → A`.

Given a configuration `x : G → A` and an element `g : G` of the additive monoid,
the shifted configuration `shift g x` is defined by `(shift g x) h = x (g + h)`.

Intuitively, this moves the whole configuration "in the direction of `g`": the value
at position `h` in the shifted configuration is the value that was at position
`g + h` in the original one.

For example, if `G = ℤ` and `A = {0, 1}`, then
`shift 1 x` is the sequence obtained from `x` by shifting every symbol one
step to the left. -/]
def mulShift (g : G) (x : G → A) : G → A :=
  fun h => x (g * h)

@[to_additive (attr := simp) shift_apply] lemma mulShift_apply (g : G) (x : G → A) (h : G) :
    mulShift g x h = x (g * h) := rfl

@[to_additive (attr := simp) shift_zero] lemma mulShift_one (x : G → A) :
    mulShift (1 : G) x = x := by
  ext h; simp [mulShift]

/-- Composition of left-translation shifts corresponds to multiplication in the monoid `G`. -/
@[to_additive shift_add] lemma mulShift_mul (g₁ g₂ : G) (x : G → A) :
    mulShift (g₁ * g₂) x = mulShift g₂ (mulShift g₁ x) := by
  ext h; simp [mulShift, mul_assoc]

variable [TopologicalSpace A]

/-- The left-translation shift is continuous. -/
@[to_additive (attr := fun_prop) continuous_shift] lemma continuous_mulShift (g : G) :
    Continuous (mulShift (A := A) g) := by
  -- coordinate projections are continuous; composition preserves continuity
  unfold mulShift
  fun_prop

end ShiftDefinition

end FullShift

end SymbolicDynamics

/-
════════════════════════════════════════════════════════════════════════════════
  PART 2 — ORIGINAL FORMALISATION (NOT IN MATHLIB)
  Shift-equivariance, cellular automata, factor maps and factor-universality.
  Built on top of the `shift` API copied in Part 1.
════════════════════════════════════════════════════════════════════════════════
-/

namespace FactorUniversalCA

open SymbolicDynamics.FullShift

/-- A self-map `f` of the full shift `A^(ℤ^d)` is *shift-equivariant* if it
commutes with every translation: `f (shift v x) = shift v (f x)`. -/
def IsShiftEquivariant {d : ℕ} {A : Type}
    (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A) : Prop :=
  ∀ (v : Fin d → ℤ) (x : (Fin d → ℤ) → A), f (shift v x) = shift v (f x)

/-- `f` is a *cellular automaton* on `A^(ℤ^d)`: a continuous, shift-equivariant
self-map of the configuration space. By the Curtis–Hedlund–Lyndon theorem this
is equivalent to `f` being given by a local rule on a finite neighbourhood.
Continuity is with respect to the product topology on `(Fin d → ℤ) → A`. -/
def IsCellularAutomaton {d : ℕ} {A : Type} [TopologicalSpace A]
    (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A) : Prop :=
  Continuous f ∧ IsShiftEquivariant f

/-- The identity map is a cellular automaton. -/
theorem isCellularAutomaton_id {d : ℕ} {A : Type} [TopologicalSpace A] :
    IsCellularAutomaton (id : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A) :=
  ⟨continuous_id, fun _ _ => rfl⟩

/-- `g : B^(ℤ^k) → B^(ℤ^k)` is a *factor* of `f : A^(ℤ^d) → A^(ℤ^d)` if there
is a continuous surjection `π : A^(ℤ^d) → B^(ℤ^k)` with `π ∘ f = g ∘ π`. Note
that `π` is **not** required to commute with the spatial shifts. -/
def IsFactor {d k : ℕ} {A B : Type} [TopologicalSpace A] [TopologicalSpace B]
    (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A)
    (g : ((Fin k → ℤ) → B) → (Fin k → ℤ) → B) : Prop :=
  ∃ π : ((Fin d → ℤ) → A) → (Fin k → ℤ) → B,
    Continuous π ∧ Function.Surjective π ∧ Function.Semiconj π f g

/-- Every cellular automaton is a factor of itself (via the identity map). -/
theorem isFactor_self {d : ℕ} {A : Type} [TopologicalSpace A]
    (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A) : IsFactor f f :=
  ⟨id, continuous_id, Function.surjective_id, fun _ => rfl⟩

/-- Class predicate selecting **all** cellular automata (used for the plain
variant of the problem). -/
def anyCA {k : ℕ} {B : Type}
    (_g : ((Fin k → ℤ) → B) → (Fin k → ℤ) → B) : Prop := True

/-- Class predicate selecting the **injective** cellular automata. -/
def InjectiveCA {k : ℕ} {B : Type}
    (g : ((Fin k → ℤ) → B) → (Fin k → ℤ) → B) : Prop := Function.Injective g

/-- Class predicate selecting the **surjective** cellular automata. -/
def SurjectiveCA {k : ℕ} {B : Type}
    (g : ((Fin k → ℤ) → B) → (Fin k → ℤ) → B) : Prop := Function.Surjective g

/-- `f : A^(ℤ^d) → A^(ℤ^d)` is *factor-universal for the class `restrict`* if
every cellular automaton `g` (over any dimension `k` and any finite, nonempty
alphabet `B`) lying in the class `restrict` is a factor of `f`. -/
def IsFactorUniversal {d : ℕ} {A : Type} [Fintype A] [Nonempty A]
    [TopologicalSpace A] [DiscreteTopology A]
    (restrict : ∀ {k : ℕ} {B : Type},
      (((Fin k → ℤ) → B) → (Fin k → ℤ) → B) → Prop)
    (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A) : Prop :=
  ∀ (k : ℕ) (B : Type) [Fintype B] [Nonempty B] [TopologicalSpace B]
    [DiscreteTopology B] (g : ((Fin k → ℤ) → B) → (Fin k → ℤ) → B),
    IsCellularAutomaton g → restrict g → IsFactor f g

end FactorUniversalCA
