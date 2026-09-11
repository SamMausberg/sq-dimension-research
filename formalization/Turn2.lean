import SQDC

/-!
UNVERIFIED SOURCE. `lake --version` returned command-not-found in this runtime.
Pinned Mathlib: 2631d1cc8c2ace6c6a900425d6e5d2b5963966e9.
The statements below are the manuscript's finite lemmas L1--L4.
They are not a formalization of the entire rectangle learner or counting theorem.
-/
noncomputable section
open scoped BigOperators
namespace SQDC.Turn2

variable {X : Type*} [Fintype X] [DecidableEq X]

-- L1: owner assigns each point to at most one peeled set.
def assembled {t : ℕ} (owner : X → Option (Fin t))
    (color : Fin t → Bool) (fallback : X → Bool) : X → Bool :=
  fun x => match owner x with
    | none => fallback x
    | some i => color i

def wrongMass {t : ℕ} (D : SQDC.FinDist X) (h : X → Bool)
    (owner : X → Option (Fin t)) (color : Fin t → Bool) (i : Fin t) : ℝ :=
  ∑ x, if owner x = some i then
    D.mass x * (if color i = h x then 0 else 1) else 0

def residualMass {t : ℕ} (D : SQDC.FinDist X)
    (owner : X → Option (Fin t)) : ℝ :=
  ∑ x, if owner x = none then D.mass x else 0

theorem L1_peeling_error {t : ℕ} (D : SQDC.FinDist X) (h : X → Bool)
    (owner : X → Option (Fin t)) (color : Fin t → Bool)
    (fallback : X → Bool) :
    SQDC.loss D h (assembled owner color fallback) ≤
      (∑ i, wrongMass D h owner color i) + residualMass D owner := by
  classical
  unfold SQDC.loss wrongMass residualMass
  rw [Finset.sum_comm, ← Finset.sum_add_distrib]
  apply Finset.sum_le_sum
  intro x hx
  cases ho : owner x with
  | none =>
      by_cases hh : fallback x = h x
      · simp [assembled, ho, hh, D.nonneg x]
      · simp [assembled, ho, hh]
  | some i =>
      simp [assembled, ho]

theorem L1_peeling_budget {t : ℕ} (D : SQDC.FinDist X) (h : X → Bool)
    (owner : X → Option (Fin t)) (color : Fin t → Bool)
    (fallback : X → Bool) (τ u : ℝ)
    (hw : ∀ i, wrongMass D h owner color i ≤ 3 * τ)
    (hu : residualMass D owner ≤ u) :
    SQDC.loss D h (assembled owner color fallback) ≤ (t : ℝ) * (3 * τ) + u := by
  have hs : (∑ i, wrongMass D h owner color i) ≤ (t : ℝ) * (3 * τ) := by
    calc
      _ ≤ ∑ _i : Fin t, 3 * τ := Finset.sum_le_sum (fun i _ => hw i)
      _ = _ := by simp
  exact (L1_peeling_error D h owner color fallback).trans (add_le_add hs hu)

-- L2: normalized target weight can increase only up to one.
theorem L2_elimination_potential (p b : ℕ → ℝ) (R : ℕ)
    (hp : ∀ t ≤ R, 0 < p t)
    (hp_one : p R ≤ 1)
    (hb : ∀ t < R, 0 ≤ b t ∧ b t < 1)
    (step : ∀ t < R, p (t + 1) = p t / (1 - b t)) :
    (∑ t ∈ Finset.range R, b t) ≤ -Real.log (p 0) := by
  have inc : ∀ t < R, b t ≤ Real.log (p (t + 1)) - Real.log (p t) := by
    intro t ht
    have htR : t ≤ R := Nat.le_of_lt ht
    have hden : 0 < 1 - b t := sub_pos.mpr (hb t ht).2
    have hlog : Real.log (1 - b t) ≤ (1 - b t) - 1 :=
      Real.log_le_sub_one_of_pos hden
    rw [step t ht, Real.log_div (ne_of_gt (hp t htR)) (ne_of_gt hden)]
    linarith
  have telescoping : ∀ k ≤ R,
      (∑ t ∈ Finset.range k, b t) ≤ Real.log (p k) - Real.log (p 0) := by
    intro k
    induction k with
    | zero => intro _; simp
    | succ k ih =>
        intro hk
        have hkR : k < R := Nat.lt_of_lt_of_le (Nat.lt_succ_self k) hk
        have hprev := ih (Nat.le_of_lt hkR)
        have hnext := inc k hkR
        rw [Finset.sum_range_succ]
        linarith
  have hend : Real.log (p R) ≤ 0 := Real.log_nonpos (le_of_lt (hp R le_rfl)) hp_one
  have hall := telescoping R le_rfl
  linarith

-- L3: false-to-true flips cannot destroy an all-true rectangle.
def MonotoneFlips {I J : Type*} (F A : I → J → Bool) : Prop :=
  ∀ i j, F i j = true → A i j = true

def PositiveRectangle {I J : Type*} (F : I → J → Bool)
    (S : Set I) (T : Set J) : Prop :=
  ∀ i ∈ S, ∀ j ∈ T, F i j = true

theorem L3_preserves_positive_rectangle {I J : Type*}
    (F A : I → J → Bool) (S : Set I) (T : Set J)
    (hflip : MonotoneFlips F A) (hrect : PositiveRectangle F S T) :
    PositiveRectangle A S T := by
  intro i hi j hj
  exact hflip i j (hrect i hi j hj)

-- L4: two distinct integer affine lines have at most one common point.
theorem L4_two_grid_lines (a b c d x y x' y' : ℤ)
    (hdistinct : (a,b) ≠ (c,d))
    (h1 : y = a * x + b) (h2 : y = c * x + d)
    (h3 : y' = a * x' + b) (h4 : y' = c * x' + d) :
    x = x' ∧ y = y' := by
  have hac : a ≠ c := by
    intro heq
    have hbd : b = d := by
      rw [heq] at h1
      linarith
    exact hdistinct (Prod.ext heq hbd)
  have hp : (a - c) * (x - x') = 0 := by nlinarith
  have hxx : x = x' := by
    rcases mul_eq_zero.mp hp with ha | hx
    · exact False.elim (hac (sub_eq_zero.mp ha))
    · exact sub_eq_zero.mp hx
  constructor
  · exact hxx
  · rw [h1, h3, hxx]

#print axioms L1_peeling_error
#print axioms L1_peeling_budget
#print axioms L2_elimination_potential
#print axioms L3_preserves_positive_rectangle
#print axioms L4_two_grid_lines
end SQDC.Turn2
