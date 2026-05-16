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

import FormalConjectures.Util.ProblemImports

/-!
# Are there factor-universal cellular automata?

A *cellular automaton* (CA) on the full shift $A^{\mathbb{Z}^d}$ over a finite
alphabet $A$ is a continuous, shift-equivariant self-map
$f : A^{\mathbb{Z}^d} \to A^{\mathbb{Z}^d}$ (Curtis–Hedlund–Lyndon
characterisation).

A CA $g : B^{\mathbb{Z}^k} \to B^{\mathbb{Z}^k}$ is a *factor* of
$f : A^{\mathbb{Z}^d} \to A^{\mathbb{Z}^d}$ if there is a continuous onto map
$\pi : A^{\mathbb{Z}^d} \to B^{\mathbb{Z}^k}$ with $\pi \circ f = g \circ \pi$.
Following Hochman, the factor map $\pi$ is **not** required to commute with the
spatial shifts, even when $d = k$: requiring this would make the entropy of the
shift an obstruction, whereas multidimensional SFTs of infinite entropy show the
entropy of the CA itself poses no obstruction.

**Problem (Hochman).** Is there a CA $f$ such that every other CA $g$ (over any
dimension and any finite alphabet) is a factor of $f$? Hochman conjectures that
the answer is *negative*. The analogous questions for injective CA and for
surjective CA are also open; a universal surjective CA would reduce the
long-open periodic-points problem for surjective CA to a single system.

*Reference:* Michael Hochman, *Are there factor-universal CA?*,
[problem note](https://math.huji.ac.il/~mhochman/problems/universal-CA.pdf).

The supporting definitions (`IsCellularAutomaton`, `IsFactor`,
`IsFactorUniversal`, …) live in
`FormalConjecturesForMathlib/Dynamics/SymbolicDynamics.lean`, split into two
parts: the shift API copied from Mathlib's
`Mathlib/Dynamics/SymbolicDynamics/Basic.lean` (not available at the pinned
Mathlib `v4.27.0`), and the bespoke cellular-automaton notions (not in Mathlib).
-/

namespace FactorUniversalCA

/-- **Hochman's problem.** Is there a factor-universal cellular automaton, i.e.
a CA `f : A^(ℤ^d) → A^(ℤ^d)` (over some dimension `d` and some finite, nonempty
alphabet `A`) such that every cellular automaton is a factor of `f`?

Hochman conjectures the answer is *negative*. -/
@[category research open, AMS 37 68]
theorem factor_universal_CA :
    answer(sorry) ↔
      ∃ (d : ℕ) (A : Type) (_ : Fintype A) (_ : Nonempty A)
        (_ : TopologicalSpace A) (_ : DiscreteTopology A)
        (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A),
        IsCellularAutomaton f ∧ IsFactorUniversal anyCA f := by
  sorry

/-- The analogous question for **injective** cellular automata: is there an
injective CA `f` such that every injective CA is a factor of `f`? -/
@[category research open, AMS 37 68]
theorem factor_universal_injective_CA :
    answer(sorry) ↔
      ∃ (d : ℕ) (A : Type) (_ : Fintype A) (_ : Nonempty A)
        (_ : TopologicalSpace A) (_ : DiscreteTopology A)
        (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A),
        IsCellularAutomaton f ∧ Function.Injective f ∧
          IsFactorUniversal InjectiveCA f := by
  sorry

/-- The analogous question for **surjective** cellular automata: is there a
surjective CA `f` such that every surjective CA is a factor of `f`? Since the
periodic-points problem for surjective CA has been open for a long time, either
there is no such `f`, or it will be hard to identify. -/
@[category research open, AMS 37 68]
theorem factor_universal_surjective_CA :
    answer(sorry) ↔
      ∃ (d : ℕ) (A : Type) (_ : Fintype A) (_ : Nonempty A)
        (_ : TopologicalSpace A) (_ : DiscreteTopology A)
        (f : ((Fin d → ℤ) → A) → (Fin d → ℤ) → A),
        IsCellularAutomaton f ∧ Function.Surjective f ∧
          IsFactorUniversal SurjectiveCA f := by
  sorry

end FactorUniversalCA
