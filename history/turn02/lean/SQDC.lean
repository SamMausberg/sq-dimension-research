import Mathlib

/-!
UNCOMPILED SOURCE DRAFT. This environment has no Lean/Lake installation.
No theorem in this file is being reported as compiler-verified.
Mathematical counterparts: Lemma 1's finite counting consequence, Theorem 2's
algebraic consequence, and the elementary ReLU identity used in Proposition 8.
The spectral and adaptive-coupling proofs of Theorems 1--2 are NOT formalized.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace SQDC

abbrev Hyp (X : Type*) := X → Bool

def labelValue (b : Bool) : ℝ := if b then 1 else -1

structure FinDist (X : Type*) [Fintype X] where
  mass : X → ℝ
  nonneg : ∀ x, 0 ≤ mass x
  total : ∑ x, mass x = 1

variable {X : Type*} [Fintype X]

def expectation (D : FinDist X) (f : X → ℝ) : ℝ :=
  ∑ x, D.mass x * f x

def loss (D : FinDist X) (h g : Hyp X) : ℝ :=
  ∑ x, D.mass x * (if g x = h x then 0 else 1)

def correlation (D : FinDist X) (h g : Hyp X) : ℝ :=
  expectation D (fun x => labelValue (h x) * labelValue (g x))

structure SQQuery (X : Type*) where
  value : X → Bool → ℝ
  bounded : ∀ x y, |value x y| ≤ 1

def queryMean (D : FinDist X) (h : Hyp X) (q : SQQuery X) : ℝ :=
  expectation D (fun x => q.value x (h x))

abbrev History (X : Type*) := List (SQQuery X × ℝ)
abbrev Oracle (X : Type*) := History X → SQQuery X → ℝ

def ValidOracle (D : FinDist X) (h : Hyp X) (τ : ℝ)
    (O : Oracle X) : Prop :=
  ∀ hist q, |O hist q - queryMean D h q| ≤ τ

/-- Exactly m queries; an at-most-m algorithm is padded with zero queries. -/
inductive SQTree (X : Type*) : ℕ → Type _ where
  | leaf (g : Hyp X) : SQTree X 0
  | node {m : ℕ} (q : SQQuery X) (next : ℝ → SQTree X m) : SQTree X (m + 1)

def runTree : {m : ℕ} → SQTree X m → Oracle X → History X → Hyp X
  | 0, .leaf g, _, _ => g
  | _ + 1, .node q next, O, hist =>
      let v := O hist q
      runTree (next v) O (hist ++ [(q, v)])

def DeterministicLearns (H : Finset (Hyp X)) {m : ℕ}
    (A : SQTree X m) (τ ε : ℝ) : Prop :=
  ∀ (D : FinDist X) (h : Hyp X), h ∈ H →
    ∀ O : Oracle X, ValidOracle D h τ O →
      loss D h (runTree A O []) ≤ ε

/-- An arbitrary private seed distribution, not a finite-seed restriction.
Integrability of each output-loss random variable is required explicitly. -/
def RandomizedLearns (H : Finset (Hyp X)) {m : ℕ}
    {Ω : Type*} [MeasurableSpace Ω]
    (P : Measure Ω) [IsProbabilityMeasure P]
    (A : Ω → SQTree X m) (τ ε : ℝ) : Prop :=
  ∀ (D : FinDist X) (h : Hyp X), h ∈ H →
    ∀ O : Oracle X, ValidOracle D h τ O →
      Integrable (fun ω => loss D h (runTree (A ω) O [])) P ∧
      (∫ ω, loss D h (runTree (A ω) O []) ∂P) ≤ ε

/-- Strict homogeneous realization: zero inner products are excluded. -/
def EmbedsAt (H : Finset (Hyp X)) (d : ℕ) : Prop :=
  ∃ φ : X → Fin d → ℝ,
    ∀ h ∈ H, ∃ w : Fin d → ℝ,
      ∀ x, 0 < labelValue (h x) * (∑ i, w i * φ x i)

/-- Finite X admits the coordinate embedding, so the defining set is nonempty
mathematically. That existence proof is not yet formalized in this draft. -/
def dc (H : Finset (Hyp X)) : ℕ := sInf {d | EmbedsAt H d}

def marginalPart (q : SQQuery X) (x : X) : ℝ :=
  (q.value x true + q.value x false) / 2

def labelPart (q : SQQuery X) (x : X) : ℝ :=
  (q.value x true - q.value x false) / 2

theorem query_decomposition (q : SQQuery X) (x : X) (y : Bool) :
    q.value x y = marginalPart q x + labelValue y * labelPart q x := by
  cases y <;> simp [marginalPart, labelPart, labelValue] <;> ring

/-- Lemma 1, counting consequence. The upstream Gram/operator-norm bound
is the explicit hypothesis `energy`, not a hidden formalized result. -/
theorem finite_energy_count {ι : Type*} [Fintype ι]
    (c : ι → ℝ) (τ Λ : ℝ) (hτ : 0 ≤ τ)
    (energy : (∑ i, (c i) ^ 2) ≤ Λ) :
    ((Finset.univ.filter (fun i => τ < |c i|)).card : ℝ) * τ ^ 2 ≤ Λ := by
  classical
  let A : Finset ι := Finset.univ.filter (fun i => τ < |c i|)
  have pointwise : ∀ i ∈ A, τ ^ 2 ≤ (c i) ^ 2 := by
    intro i hi
    have hlt : τ < |c i| := (Finset.mem_filter.mp hi).2
    have ha : 0 ≤ |c i| := abs_nonneg (c i)
    have hs : |c i| ^ 2 = (c i) ^ 2 := sq_abs (c i)
    have hp : 0 ≤ (|c i| - τ) * (|c i| + τ) :=
      mul_nonneg (sub_nonneg.mpr hlt.le) (add_nonneg ha hτ)
    nlinarith
  have subset : A ⊆ (Finset.univ : Finset ι) := Finset.subset_univ A
  calc
    ((Finset.univ.filter (fun i => τ < |c i|)).card : ℝ) * τ ^ 2
        = ∑ i ∈ A, τ ^ 2 := by simp [A]
    _ ≤ ∑ i ∈ A, (c i) ^ 2 := Finset.sum_le_sum pointwise
    _ ≤ ∑ i, (c i) ^ 2 :=
      Finset.sum_le_sum_of_subset_of_nonneg subset
        (by intro i _ _; exact sq_nonneg (c i))
    _ ≤ Λ := energy

/-- Theorem 2, algebraic consequence, with precisely the displayed hypothesis.
This does NOT assert that the SQ-coupling premise has been formalized. -/
theorem barrier_algebra (α R M : ℝ) (hR : 0 ≤ R)
    (hα : (1 / 2 : ℝ) ≤ α)
    (hbarrier : α * R ≤ Real.sqrt R + M) :
    R ≤ 4 + 4 * M := by
  have hs : (Real.sqrt R) ^ 2 = R := Real.sq_sqrt hR
  have hquarter : Real.sqrt R ≤ R / 4 + 1 := by
    nlinarith [sq_nonneg (Real.sqrt R - 2)]
  have hhalf : R / 2 ≤ α * R := by
    nlinarith [mul_nonneg (sub_nonneg.mpr hα) hR]
  linarith

/-- Elementary scalar identity underlying Proposition 8. -/
theorem relu_odd_part (z : ℝ) : max z 0 - max (-z) 0 = z := by
  by_cases hz : 0 ≤ z
  · simp [max_eq_left hz, max_eq_right (neg_nonpos.mpr hz)]
  · have hzn : z ≤ 0 := le_of_not_ge hz
    have hn : 0 ≤ -z := neg_nonneg.mpr hzn
    simp [max_eq_right hzn, max_eq_left hn]

#print axioms finite_energy_count
#print axioms barrier_algebra
#print axioms relu_odd_part

end SQDC
