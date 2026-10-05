import SQDC.Basic
import Mathlib.Algebra.Order.Star.Real
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.LocallyConvex.Separation
import Mathlib.Order.CompletePartialOrder

/-!
# The rectangle learner: parameters, valid answers and progress

Correspondence with Theorem *Rectangle learner* (`thm:rectangle`), Lemma *Pointwise
coverage* (`lem:mixture`), the algorithm of Section `sec:rectangle` (`alg:rectify`), and
Appendix `app:rectangle` ("Proof of the rectangle learning theorem"). Throughout,
`r = 1/ρ` with `ρ ≥ 1` (that is, `0 < r ≤ 1`) and `0 < ε < 1/4`. A valid answer `â` to a
query with true value `a` is any real with `|â - a| ≤ τ`, both endpoints included.

Parameters `eq:rectparams1`, `eq:rectparams2`: `peelCap` is `P`, `tol` is `τ`,
`chargeBound` is `B`, `roundBudget` is `R`.

Valid answers and the two updates:
* `tau_small`: `eq:tau-small`.
* `active_mass`: `eq:active-mass`.
* `accepted_mass`: `eq:accepted-mass`.
* `large_proposal_accepted`, `rejected_small`: "every proposal with `a ≥ 3r/4` is
  accepted".
* `labelling_error`, `disagreeMass_eq_zero`, `elimination_retains_target`: a labelling
  step has error `w ≤ 3τ`; an elimination never removes the target.

Deterministic bounds on total progress:
* `labelling_contracts`, `massOf_sdiff`, `labelling_steps_le`: at most `P` labelling
  steps.
* `peel_error` (`eq:peel-error`), `stop_residual`, `normal_loss_arith`
  (`eq:normal-loss`), `loss_assembled_le`, `normal_loss`: the loss at a normal stop is at most `ε/2`
  (disjoint labelled sets: the loss is at most the wrong masses plus the residual).
* `le_neg_log_one_sub`, `elim_charge_of_potential`, `elim_charge`: `eq:elim-charge`
  (through the normalized target weight).
* `peel_charge`: `eq:peel-charge`, including "a step removing all remaining points is
  the last step".
* `total_charge`: `eq:total-charge` for an arbitrary run of the state updates
  (`RoundStep`), obtained by applying `peel_charge` and `elim_charge` to the whole run.

Expected progress and the query budget:
* `expected_ab_ge`, `coverage_expected_ab`: "Integrating `eq:pointwise` against `D`
  conditioned on `U` gives `E[ab | current history] ≥ r`".
* `drift`, `round_drift`: `eq:drift-app`, with the outcome of every proposal chosen
  adversarially after the rectangle is seen; `round_drift` combines it with the law of
  `pointwise_coverage` on the current state.
* `exp_neg_le_chord`, `exp_drift_finite`, `exp_drift_measure`: the convexity step and
  `E[e^{-G}] ≤ 1 - r/8 ≤ e^{-r/8}`, both for a finitely supported law and for an
  arbitrary probability measure (Bochner integrals).
* `ProgressTree`, `ProgressTree.exponential_potential` (`eq:exponential-potential`),
  `ProgressTree.prob_total_le_bound`, `prob_total_le_chargeBound`: iterated conditional
  expectation and Markov's inequality for a finitely branching process with conditional
  drift `r/4` in every round, giving `Pr[Σ G ≤ B] ≤ e^{B-rR/8} ≤ ε/2`.
* `budget_tail`: `e^{B-rR/8} ≤ ε/2`; `query_count`: at most three queries per round give
  the worst-case budget `3R+1`; `expected_loss_le`: the final combination "expected loss
  at most `ε`".
* `rectanglebound_explicit`: the parameter formulas behind `eq:rectanglebound` with
  explicit constants, `3R+1 ≤ 124ρ(ln K + ln(1/ε))` and `τ ≥ ε/(288ρ ln(1/ε))` (the
  constants are ours; see "Not formalized" below for the learner itself).

Pointwise coverage:
* `pointwise_coverage`: Lemma `lem:mixture`, proved by the finite separation argument for
  `eq:mixture-lp` (Mathlib's `geometric_hahn_banach_compact_closed`). The law is a
  probability vector on triples `(S,T,c)` supported on monochromatic rectangles inside
  `U × V`. Nonemptiness of `U` and `V` is not needed.

Not formalized:
* The assembled algorithm as a randomized `SQTree` and the end-to-end statement that it
  satisfies `RandomizedLearns` (`eq:learnmodel`) with the stated `m` and `τ`. The steps
  above are the paper's steps; their composition into one execution model is not done.
  In particular `ProgressTree` is an abstract finitely branching process: the paper's
  identification of a run against a deterministic adaptive valid oracle with such a
  tree (branches are the rectangle choices drawn from the law of `pointwise_coverage`,
  progress is `progress` of the resulting outcome, and `G = 1` after normal
  termination) is not proved here.
* Randomized oracles (handled in the paper by conditioning on their randomness) and the
  constructibility remarks about rational feasible points of `eq:mixture-lp`.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace SQDC.RectangleLearner

/-! ### Parameters `eq:rectparams1`, `eq:rectparams2` -/

/-- `P = 1 + ⌈4r⁻¹ ln(8/ε)⌉`. -/
def peelCap (r ε : ℝ) : ℕ := 1 + ⌈4 * r⁻¹ * Real.log (8 / ε)⌉₊

/-- `τ = ε/(24P)`. -/
def tol (r ε : ℝ) : ℝ := ε / (24 * peelCap r ε)

/-- `B = ln K + ln(8/ε) + 1`. -/
def chargeBound (K : ℕ) (ε : ℝ) : ℝ := Real.log K + Real.log (8 / ε) + 1

/-- `R = ⌈8r⁻¹(B + ln(2/ε))⌉`. -/
def roundBudget (r : ℝ) (K : ℕ) (ε : ℝ) : ℕ :=
  ⌈8 * r⁻¹ * (chargeBound K ε + Real.log (2 / ε))⌉₊

theorem one_lt_log_four : 1 < Real.log 4 := by
  rw [Real.lt_log_iff_exp_lt (by norm_num)]
  have := Real.exp_one_lt_d9
  norm_num at this ⊢
  linarith

/-- For `0 < ε < 1/4`: `ln(8/ε) > ln 32 > 1`. -/
theorem one_lt_log_eight_div {ε : ℝ} (hε0 : 0 < ε) (hε1 : ε < 1 / 4) :
    Real.log 32 < Real.log (8 / ε) ∧ 1 < Real.log 32 := by
  constructor
  · exact Real.log_lt_log (by norm_num) (by rw [lt_div_iff₀ hε0]; linarith)
  · calc (1 : ℝ) < Real.log 4 := one_lt_log_four
      _ < Real.log 32 := Real.log_lt_log (by norm_num) (by norm_num)

theorem peelCap_ge {r ε : ℝ} : 1 + 4 * r⁻¹ * Real.log (8 / ε) ≤ (peelCap r ε : ℝ) := by
  unfold peelCap
  push_cast
  linarith [Nat.le_ceil (4 * r⁻¹ * Real.log (8 / ε))]

theorem one_le_peelCap (r ε : ℝ) : 1 ≤ peelCap r ε := by unfold peelCap; omega

theorem tol_pos {r ε : ℝ} (hε0 : 0 < ε) : 0 < tol r ε := by
  unfold tol
  have : (1 : ℝ) ≤ peelCap r ε := by exact_mod_cast one_le_peelCap r ε
  positivity

/-- `eq:tau-small`: "`τ ≤ ε/8`, `τ ≤ rε/64`. Indeed, `P ≥ 4r⁻¹ ln(8/ε)` and
`ln(8/ε) > ln 32`." Only `0 < r` is used (the paper has `0 < r ≤ 1`). -/
theorem tau_small {r ε : ℝ} (hr0 : 0 < r) (hε0 : 0 < ε) (hε1 : ε < 1 / 4) :
    tol r ε ≤ ε / 8 ∧ tol r ε ≤ r * ε / 64 := by
  have hP := peelCap_ge (r := r) (ε := ε)
  obtain ⟨h32, h1⟩ := one_lt_log_eight_div hε0 hε1
  have hlog0 : 0 ≤ Real.log (8 / ε) := by linarith
  have hnn : 0 ≤ 4 * r⁻¹ * Real.log (8 / ε) :=
    mul_nonneg (mul_nonneg (by norm_num) (inv_nonneg.mpr hr0.le)) hlog0
  have hPpos : (0 : ℝ) < peelCap r ε := by linarith
  unfold tol
  constructor
  · rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    have h8 : (8 : ℝ) ≤ 24 * peelCap r ε := by linarith
    nlinarith [mul_le_mul_of_nonneg_left h8 hε0.le]
  · -- `24 P r ≥ 96 ln(8/ε) > 64`
    have hPr : 4 * Real.log (8 / ε) ≤ peelCap r ε * r := by
      have : 4 * r⁻¹ * Real.log (8 / ε) * r = 4 * Real.log (8 / ε) := by field_simp
      nlinarith
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    nlinarith

/-! ### Valid answers and the two updates (Appendix `app:rectangle`) -/

section answers

variable {r ε τ : ℝ}

/-- `eq:active-mass`: "Since the algorithm did not stop, `u > ε/4 - τ ≥ ε/8`,
`τ/u ≤ r/8`." The algorithm stops when the residual estimate `û` is at most `ε/4`. -/
theorem active_mass (hr0 : 0 < r) (hτε : τ ≤ ε / 8) (hτr : τ ≤ r * ε / 64) {u uhat : ℝ}
    (hu : |uhat - u| ≤ τ) (hgo : ε / 4 < uhat) :
    ε / 4 - τ < u ∧ ε / 8 ≤ ε / 4 - τ ∧ τ / u ≤ r / 8 := by
  have h1 := (abs_le.mp hu).2
  have hτ0 : 0 ≤ τ := (abs_nonneg _).trans hu
  refine ⟨by linarith, by linarith, ?_⟩
  have hu0 : 0 < u := by linarith
  have hεu : ε / 8 ≤ u := by linarith
  rw [div_le_iff₀ hu0]
  have : r * (ε / 8) ≤ r * u := mul_le_mul_of_nonneg_left hεu hr0.le
  linarith

/-- `eq:accepted-mass`: "If the proposal is accepted, then `ŝ ≥ rû/2`, and therefore
`s ≥ ru/2 - (1+r/2)τ`. Using `r ≤ 1` and `eq:active-mass`, we obtain
`a ≥ r/2 - (1+r/2)r/8 ≥ 5r/16 ≥ r/4`", where `a = s/u`. -/
theorem accepted_mass (hr0 : 0 < r) (hr1 : r ≤ 1) (hτε : τ ≤ ε / 8)
    (hτr : τ ≤ r * ε / 64) {u s uhat shat : ℝ} (hu : |uhat - u| ≤ τ)
    (hs : |shat - s| ≤ τ) (hgo : ε / 4 < uhat) (hacc : r / 2 * uhat ≤ shat) :
    r * u / 2 - (1 + r / 2) * τ ≤ s ∧ r / 2 - (1 + r / 2) * (r / 8) ≤ s / u ∧
      5 * r / 16 ≤ r / 2 - (1 + r / 2) * (r / 8) ∧ r / 4 ≤ 5 * r / 16 := by
  obtain ⟨hu', -, hτu⟩ := active_mass hr0 hτε hτr hu hgo
  have hτ0 : 0 ≤ τ := (abs_nonneg _).trans hu
  have hu0 : 0 < u := by linarith
  have hs1 := (abs_le.mp hs).2
  have hu1 := (abs_le.mp hu).1
  have hmono : r / 2 * (u - τ) ≤ r / 2 * uhat :=
    mul_le_mul_of_nonneg_left (by linarith) (by linarith)
  have hsl : r * u / 2 - (1 + r / 2) * τ ≤ s := by
    have e1 : r / 2 * (u - τ) = r * u / 2 - r / 2 * τ := by ring
    have e2 : (1 + r / 2) * τ = τ + r / 2 * τ := by ring
    rw [e1] at hmono; rw [e2]; linarith
  refine ⟨hsl, ?_, by nlinarith, by linarith⟩
  have : s / u ≥ r / 2 - (1 + r / 2) * (τ / u) := by
    rw [ge_iff_le, le_div_iff₀ hu0]
    have e : (r / 2 - (1 + r / 2) * (τ / u)) * u = r * u / 2 - (1 + r / 2) * τ := by
      field_simp
    linarith
  have : (1 + r / 2) * (τ / u) ≤ (1 + r / 2) * (r / 8) :=
    mul_le_mul_of_nonneg_left hτu (by linarith)
  linarith

/-- "Conversely, if `a ≥ 3r/4`, then even the least favorable answers obey
`ŝ - rû/2 ≥ (a-r/2)u - (1+r/2)τ ≥ ru/4 - 3ru/16 = ru/16 > 0`. Every such proposal is
accepted." -/
theorem large_proposal_accepted (hr0 : 0 < r) (hr1 : r ≤ 1) (hτε : τ ≤ ε / 8)
    (hτr : τ ≤ r * ε / 64) {u s uhat shat : ℝ} (hu : |uhat - u| ≤ τ)
    (hs : |shat - s| ≤ τ) (hgo : ε / 4 < uhat) (ha : 3 * r / 4 ≤ s / u) :
    (s / u - r / 2) * u - (1 + r / 2) * τ ≤ shat - r * uhat / 2 ∧
      r * u / 4 - 3 * r * u / 16 ≤ (s / u - r / 2) * u - (1 + r / 2) * τ ∧
      r * u / 4 - 3 * r * u / 16 = r * u / 16 ∧ 0 < r * u / 16 ∧ r / 2 * uhat ≤ shat := by
  obtain ⟨hu', -, hτu⟩ := active_mass hr0 hτε hτr hu hgo
  have hτ0 : 0 ≤ τ := (abs_nonneg _).trans hu
  have hu0 : 0 < u := by linarith
  have hs1 := (abs_le.mp hs).1
  have hu2 := (abs_le.mp hu).2
  have hsu : s / u * u = s := by field_simp
  have h1 : (s / u - r / 2) * u - (1 + r / 2) * τ ≤ shat - r * uhat / 2 := by
    have : (s / u - r / 2) * u = s - r * u / 2 := by rw [sub_mul, hsu]; ring
    rw [this]; nlinarith
  have hτ' : τ ≤ r / 8 * u := by rwa [div_le_iff₀ hu0] at hτu
  have h2 : r * u / 4 - 3 * r * u / 16 ≤ (s / u - r / 2) * u - (1 + r / 2) * τ := by
    have h3 : r / 4 * u ≤ (s / u - r / 2) * u :=
      mul_le_mul_of_nonneg_right (by linarith) hu0.le
    have h4 : (1 + r / 2) * τ ≤ 3 * r * u / 16 := by nlinarith
    nlinarith
  have h5 : 0 < r * u / 16 := by positivity
  exact ⟨h1, h2, by ring, h5, by linarith⟩

/-- The contrapositive used in `drift`: "Rejection is possible only when `a < 3r/4`." -/
theorem rejected_small (hr0 : 0 < r) (hr1 : r ≤ 1) (hτε : τ ≤ ε / 8)
    (hτr : τ ≤ r * ε / 64) {u s uhat shat : ℝ} (hu : |uhat - u| ≤ τ)
    (hs : |shat - s| ≤ τ) (hgo : ε / 4 < uhat) (hrej : shat < r / 2 * uhat) :
    s / u < 3 * r / 4 := by
  by_contra h
  have := (large_proposal_accepted hr0 hr1 hτε hτr hu hs hgo (not_lt.mp h)).2.2.2.2
  linarith

/-- The disagreement mass `w = D(S ∩ {h ≠ c})`. -/
def disagreeMass {X : Type*} [Fintype X] (D : FinDist X) (h : Hyp X) (S : Finset X)
    (c : Bool) : ℝ :=
  D.massOf (S.filter fun x => h x ≠ c)

/-- "When `ŵ ≤ 2τ`, the labelling step incurs error `w ≤ 3τ`." -/
theorem labelling_error {w what : ℝ} (hw : |what - w| ≤ τ) (hlab : what ≤ 2 * τ) :
    w ≤ 3 * τ := by
  have := (abs_le.mp hw).1
  linarith

/-- Monochromaticity of `S × T` with color `c` gives `w = 0` for every target in `T`. -/
theorem disagreeMass_eq_zero {X ι : Type*} [Fintype X] {H : ι → Hyp X} {S : Finset X}
    {T : Finset ι} {c : Bool} (hmono : Monochromatic H S T c) {i : ι} (hi : i ∈ T)
    (D : FinDist X) : disagreeMass D (H i) S c = 0 := by
  unfold disagreeMass FinDist.massOf
  refine Finset.sum_eq_zero fun x hx => ?_
  obtain ⟨hxS, hne⟩ := Finset.mem_filter.mp hx
  exact absurd (hmono x hxS i hi) hne

/-- "When `ŵ > 2τ`, the target cannot lie in `T`: monochromaticity would then give
`w = 0` and `ŵ ≤ τ`. Thus every elimination retains the target and leaves `V`
nonempty." -/
theorem elimination_retains_target {X ι : Type*} [Fintype X] [DecidableEq ι]
    {H : ι → Hyp X} {S : Finset X} {T V : Finset ι} {c : Bool}
    (hmono : Monochromatic H S T c) (D : FinDist X) {istar : ι} (hV : istar ∈ V)
    {what : ℝ} (hw : |what - disagreeMass D (H istar) S c| ≤ τ) (helim : 2 * τ < what) :
    istar ∉ T ∧ istar ∈ V \ T ∧ (V \ T).Nonempty := by
  have hτ0 : 0 ≤ τ := (abs_nonneg _).trans hw
  have hnot : istar ∉ T := by
    intro hT
    rw [disagreeMass_eq_zero hmono hT D, sub_zero] at hw
    have := (abs_le.mp hw).2
    linarith
  exact ⟨hnot, Finset.mem_sdiff.mpr ⟨hV, hnot⟩, ⟨istar, Finset.mem_sdiff.mpr ⟨hV, hnot⟩⟩⟩

end answers

/-! ### Deterministic bounds on total progress -/

/-- A labelling step with `a = s/u ≥ r/4` leaves residual mass `u - s ≤ (1-r/4)u`. -/
theorem labelling_contracts {r u s : ℝ} (hu : 0 < u) (ha : r / 4 ≤ s / u) :
    u - s ≤ (1 - r / 4) * u := by
  rw [le_div_iff₀ hu] at ha
  nlinarith

/-- Labelling removes `S ⊆ U` from the residual: `D(U \ S) = D(U) - D(S)`. -/
theorem massOf_sdiff {X : Type*} [Fintype X] [DecidableEq X] (D : FinDist X)
    {S U : Finset X} (hSU : S ⊆ U) : D.massOf (U \ S) = D.massOf U - D.massOf S := by
  unfold FinDist.massOf
  rw [Finset.sum_sdiff_eq_sub hSU]

/-- "There are at most `P` labelling steps. Before the `j`th such step,
`eq:accepted-mass` implies `ε/8 ≤ u ≤ (1-r/4)^{j-1} ≤ e^{-(j-1)r/4}`. Consequently
`j ≤ 1 + 4r⁻¹ ln(8/ε) ≤ P`." Here `u k` is the residual mass before the `k`th labelling
step (`k ≥ 1`); `u 1 ≤ 1`, and each labelling step contracts the residual by
`labelling_contracts` while other steps leave it unchanged. -/
theorem labelling_steps_le {r ε : ℝ} (hr0 : 0 < r) (hr1 : r ≤ 1) (hε0 : 0 < ε)
    (u : ℕ → ℝ) (hu1 : u 1 ≤ 1) {j : ℕ} (hj : 1 ≤ j)
    (hstep : ∀ k, 1 ≤ k → k < j → u (k + 1) ≤ (1 - r / 4) * u k)
    (hmass : ε / 8 ≤ u j) :
    u j ≤ (1 - r / 4) ^ (j - 1) ∧
      (1 - r / 4) ^ (j - 1) ≤ Real.exp (-(((j - 1 : ℕ) : ℝ) * r / 4)) ∧
      (j : ℝ) ≤ 1 + 4 * r⁻¹ * Real.log (8 / ε) ∧ j ≤ peelCap r ε := by
  have hq0 : 0 ≤ 1 - r / 4 := by linarith
  have hpow : ∀ k, 1 ≤ k → k ≤ j → u k ≤ (1 - r / 4) ^ (k - 1) := by
    intro k hk1 hkj
    induction k with
    | zero => omega
    | succ k ih =>
      rcases Nat.eq_zero_or_pos k with rfl | hk
      · simpa using hu1
      · have := ih hk (by omega)
        calc u (k + 1) ≤ (1 - r / 4) * u k := hstep k hk (by omega)
          _ ≤ (1 - r / 4) * (1 - r / 4) ^ (k - 1) := mul_le_mul_of_nonneg_left this hq0
          _ = (1 - r / 4) ^ (k + 1 - 1) := by
              rw [← pow_succ']; congr 1; omega
  have h1 := hpow j hj le_rfl
  have h2 : (1 - r / 4) ^ (j - 1) ≤ Real.exp (-(((j - 1 : ℕ) : ℝ) * r / 4)) := by
    have hb : 1 - r / 4 ≤ Real.exp (-(r / 4)) := by
      have := Real.add_one_le_exp (-(r / 4)); linarith
    calc (1 - r / 4) ^ (j - 1) ≤ Real.exp (-(r / 4)) ^ (j - 1) :=
          pow_le_pow_left₀ hq0 hb _
      _ = Real.exp (-(((j - 1 : ℕ) : ℝ) * r / 4)) := by
          rw [← Real.exp_nat_mul]; ring_nf
  have h3 : (j : ℝ) ≤ 1 + 4 * r⁻¹ * Real.log (8 / ε) := by
    have hle : ε / 8 ≤ Real.exp (-(((j - 1 : ℕ) : ℝ) * r / 4)) := hmass.trans (h1.trans h2)
    have hlog : Real.log (ε / 8) ≤ -(((j - 1 : ℕ) : ℝ) * r / 4) := by
      rw [← Real.log_exp (-(((j - 1 : ℕ) : ℝ) * r / 4))]
      exact Real.log_le_log (by positivity) hle
    have e : Real.log (ε / 8) = -Real.log (8 / ε) := by
      rw [← Real.log_inv, inv_div]
    rw [e] at hlog
    have hjr : (((j - 1 : ℕ) : ℝ)) * r ≤ 4 * Real.log (8 / ε) := by linarith
    have hcast : (((j - 1 : ℕ) : ℝ)) = (j : ℝ) - 1 := by
      rw [Nat.cast_sub hj]; simp
    rw [hcast] at hjr
    have : (j : ℝ) - 1 ≤ 4 * r⁻¹ * Real.log (8 / ε) := by
      rw [mul_comm 4 r⁻¹, mul_assoc, ← div_eq_inv_mul, le_div_iff₀ hr0]
      linarith
    linarith
  refine ⟨h1, h2, h3, ?_⟩
  have : (j : ℝ) ≤ peelCap r ε := h3.trans peelCap_ge
  exact_mod_cast this

/-- `eq:peel-error`: `3Pτ = ε/8`. -/
theorem peel_error (r ε : ℝ) : 3 * (peelCap r ε : ℝ) * tol r ε = ε / 8 := by
  unfold tol
  have : (0 : ℝ) < peelCap r ε := by exact_mod_cast one_le_peelCap r ε
  field_simp
  ring

/-- "At an ordinary stop, the residual mass is at most `ε/4+τ`": the stop rule
`û ≤ ε/4` with a valid answer `|û - u| ≤ τ`. -/
theorem stop_residual {ε τ u uhat : ℝ} (hu : |uhat - u| ≤ τ) (hstop : uhat ≤ ε / 4) :
    u ≤ ε / 4 + τ := by
  have := (abs_le.mp hu).1
  linarith

/-- `eq:normal-loss`: `ε/8 + ε/4 + τ ≤ ε/2`. -/
theorem normal_loss_arith {ε τ : ℝ} (hτε : τ ≤ ε / 8) : ε / 8 + ε / 4 + τ ≤ ε / 2 := by
  linarith

section assembly

variable {X : Type*} [Fintype X]

/-- The final predictor: `owner x = some i` means that `x` was labelled at the `i`th
labelling step, with color `color i`; unlabelled points get `fallback` (`+1` in the
paper). The labelled sets are disjoint by construction. -/
def assembled {t : ℕ} (owner : X → Option (Fin t)) (color : Fin t → Bool)
    (fallback : Hyp X) : Hyp X :=
  fun x => match owner x with
    | none => fallback x
    | some i => color i

/-- The `i`th labelled set. -/
def labelledSet {t : ℕ} (owner : X → Option (Fin t)) (i : Fin t) : Finset X :=
  Finset.univ.filter fun x => owner x = some i

/-- The residual (never labelled) set. -/
def residualSet {t : ℕ} (owner : X → Option (Fin t)) : Finset X :=
  Finset.univ.filter fun x => owner x = none

/-- The final loss is at most the sum of the disagreement masses of the labelled sets
plus the residual mass ("The labelled sets are disjoint, so their total error is at
most ..."). -/
theorem loss_assembled_le {t : ℕ} (D : FinDist X) (h : Hyp X) (owner : X → Option (Fin t))
    (color : Fin t → Bool) (fallback : Hyp X) :
    loss D h (assembled owner color fallback) ≤
      (∑ i, disagreeMass D h (labelledSet owner i) (color i)) +
        D.massOf (residualSet owner) := by
  classical
  unfold loss disagreeMass labelledSet residualSet FinDist.massOf
  simp_rw [Finset.filter_filter, Finset.sum_filter]
  rw [Finset.sum_comm, ← Finset.sum_add_distrib]
  refine Finset.sum_le_sum fun x _ => ?_
  cases ho : owner x with
  | none =>
    simp only [assembled, ho, reduceCtorEq, false_and, ite_false, Finset.sum_const_zero,
      zero_add, ite_true]
    split_ifs <;> linarith [D.nonneg x]
  | some i =>
    simp only [assembled, ho, reduceCtorEq, ite_false, add_zero, Option.some.injEq]
    by_cases hc : color i = h x
    · simp only [hc, ite_true, mul_zero]
      exact Finset.sum_nonneg fun j _ => by split_ifs <;> linarith [D.nonneg x]
    · simp only [hc, ite_false, mul_one]
      calc D.mass x = if (i = i ∧ h x ≠ color i) then D.mass x else 0 := by
            rw [ite_eq_left ⟨rfl, Ne.symm hc⟩]
        _ ≤ ∑ j, if (i = j ∧ h x ≠ color j) then D.mass x else 0 :=
            Finset.single_le_sum (f := fun j => if (i = j ∧ h x ≠ color j)
              then D.mass x else 0) (fun j _ => by split_ifs <;> linarith [D.nonneg x])
              (Finset.mem_univ i)

/-- `eq:peel-error` and `eq:normal-loss` combined: with at most `P` labelled sets, each
of disagreement mass at most `3τ` (`labelling_error`), and residual mass at most
`ε/4 + τ` ("At an ordinary stop, the residual mass is at most `ε/4+τ`. An empty
residual contributes no error."), the final loss is at most `ε/2`. -/
theorem normal_loss {r ε : ℝ} (hr0 : 0 < r) (hε0 : 0 < ε) (hε1 : ε < 1 / 4) {t : ℕ}
    (ht : t ≤ peelCap r ε) (D : FinDist X) (h : Hyp X) (owner : X → Option (Fin t))
    (color : Fin t → Bool) (fallback : Hyp X)
    (hw : ∀ i, disagreeMass D h (labelledSet owner i) (color i) ≤ 3 * tol r ε)
    (hres : D.massOf (residualSet owner) ≤ ε / 4 + tol r ε) :
    loss D h (assembled owner color fallback) ≤ ε / 2 := by
  have hsum : (∑ i, disagreeMass D h (labelledSet owner i) (color i)) ≤ ε / 8 := by
    calc (∑ i, disagreeMass D h (labelledSet owner i) (color i))
        ≤ ∑ _i : Fin t, 3 * tol r ε := Finset.sum_le_sum fun i _ => hw i
      _ = (t : ℝ) * (3 * tol r ε) := by simp
      _ ≤ (peelCap r ε : ℝ) * (3 * tol r ε) :=
          mul_le_mul_of_nonneg_right (by exact_mod_cast ht)
            (by have := tol_pos (r := r) hε0; positivity)
      _ = ε / 8 := by rw [← peel_error r ε]; ring
  have := loss_assembled_le D h owner color fallback
  have hτ := (tau_small hr0 hε0 hε1).1
  linarith [normal_loss_arith (ε := ε) hτ]

end assembly

/-! ### Elimination and labelling charges -/

/-- `b ≤ -ln(1-b)` for `b < 1`. -/
theorem le_neg_log_one_sub {b : ℝ} (hb : b < 1) : b ≤ -Real.log (1 - b) := by
  have := Real.log_le_sub_one_of_pos (sub_pos.mpr hb)
  linarith

/-- The potential form of `eq:elim-charge`: a positive
weight `p` that starts at `1/K`, is multiplied by `1/(1-b_t)` at each step, and ends at
most one satisfies `Σ b_t ≤ Σ -ln(1-b_t) ≤ ln K`. -/
theorem elim_charge_of_potential (p b : ℕ → ℝ) (n K : ℕ) (hp : ∀ t ≤ n, 0 < p t)
    (hp0 : p 0 = 1 / K) (hpn : p n ≤ 1) (hb : ∀ t < n, b t < 1)
    (step : ∀ t < n, p (t + 1) = p t / (1 - b t)) :
    ∑ t ∈ Finset.range n, b t ≤ ∑ t ∈ Finset.range n, -Real.log (1 - b t) ∧
      ∑ t ∈ Finset.range n, -Real.log (1 - b t) ≤ Real.log K := by
  refine ⟨Finset.sum_le_sum fun t ht => le_neg_log_one_sub (hb t (Finset.mem_range.mp ht)), ?_⟩
  have hinc : ∀ t ∈ Finset.range n,
      -Real.log (1 - b t) = Real.log (p (t + 1)) - Real.log (p t) := by
    intro t ht
    have ht' := Finset.mem_range.mp ht
    rw [step t ht', Real.log_div (hp t ht'.le).ne' (sub_pos.mpr (hb t ht')).ne']
    ring
  rw [Finset.sum_congr rfl hinc, Finset.sum_range_sub (fun t => Real.log (p t)), hp0,
    one_div, Real.log_inv]
  have := Real.log_nonpos (hp n le_rfl).le hpn
  linarith

/-- `eq:elim-charge`: "For an elimination with row fraction `b`, the uniform target
weight is multiplied by `1/(1-b)`. Since it starts at `1/K` and cannot exceed one,
`Σ b ≤ Σ -ln(1-b) ≤ ln K`. Here `b < 1`, because the target is retained." The
surviving sets `V t` start at all `K` rows; step `t` removes `T t ⊆ V t` (a step with
`T t = ∅` is a step that is not an elimination); the target `istar` is never removed
(`elimination_retains_target`). -/
theorem elim_charge {ι : Type*} [Fintype ι] [DecidableEq ι] (V T : ℕ → Finset ι) (n : ℕ)
    (istar : ι) (hV0 : V 0 = Finset.univ) (hT : ∀ t < n, T t ⊆ V t)
    (hV : ∀ t < n, V (t + 1) = V t \ T t) (htarget : ∀ t ≤ n, istar ∈ V t) :
    (∀ t < n, ((T t).card : ℝ) / (V t).card < 1) ∧
    ∑ t ∈ Finset.range n, ((T t).card : ℝ) / (V t).card ≤
        ∑ t ∈ Finset.range n, -Real.log (1 - ((T t).card : ℝ) / (V t).card) ∧
      ∑ t ∈ Finset.range n, -Real.log (1 - ((T t).card : ℝ) / (V t).card) ≤
        Real.log (Fintype.card ι) := by
  have hVpos : ∀ t ≤ n, (0 : ℝ) < (V t).card := fun t ht => by
    exact_mod_cast Finset.card_pos.mpr ⟨istar, htarget t ht⟩
  have hcard : ∀ t < n, ((V (t + 1)).card : ℝ) = (V t).card - (T t).card := by
    intro t ht
    rw [hV t ht, Finset.card_sdiff_of_subset (hT t ht),
      Nat.cast_sub (Finset.card_le_card (hT t ht))]
  have hb : ∀ t < n, ((T t).card : ℝ) / (V t).card < 1 := by
    intro t ht
    rw [div_lt_one (hVpos t ht.le)]
    have := hVpos (t + 1) ht
    rw [hcard t ht] at this
    linarith
  obtain ⟨h1, h2⟩ := elim_charge_of_potential (fun t => 1 / ((V t).card : ℝ))
    (fun t => ((T t).card : ℝ) / (V t).card) n (Fintype.card ι)
    (fun t ht => by have := hVpos t ht; positivity) (by simp [hV0])
    (by
      have := hVpos n le_rfl
      rw [div_le_one this]
      exact_mod_cast Finset.card_pos.mpr ⟨istar, htarget n le_rfl⟩)
    hb
    (by
      intro t ht
      have hv := hVpos t ht.le
      have hv' := hVpos (t + 1) ht
      rw [hcard t ht] at hv' ⊢
      field_simp)
  exact ⟨hb, h1, h2⟩

/-- `eq:peel-charge`: "For the labelling steps, exclude the last one. The residual masses
telescope through all preceding steps, and the mass just before the last is at least
`ε/8`. Hence `Σ_{all but last} a ≤ Σ -ln(1-a) ≤ ln(8/ε)`. Adding the last charge, which
is at most one, gives `Σ a ≤ ln(8/ε) + 1`. If a step removes all remaining points, it is
necessarily the last step, so no logarithm of zero occurs. With no labelling steps the
inequality is immediate." Here `u k` is the residual mass before step `k`,
`u (k+1) = u k (1 - a k)`; the first conjunct is the claim that only the last step can
have `a = 1`. -/
theorem peel_charge {ε : ℝ} (hε0 : 0 < ε) (hε1 : ε < 1 / 4) (u a : ℕ → ℝ) (n : ℕ)
    (hu0 : u 0 ≤ 1) (ha : ∀ k < n, 0 ≤ a k ∧ a k ≤ 1)
    (hstep : ∀ k < n, u (k + 1) = u k * (1 - a k)) (hlast : 0 < n → ε / 8 ≤ u (n - 1)) :
    (∀ k < n - 1, a k < 1) ∧
      ∑ k ∈ Finset.range (n - 1), a k ≤ ∑ k ∈ Finset.range (n - 1), -Real.log (1 - a k) ∧
      ∑ k ∈ Finset.range (n - 1), -Real.log (1 - a k) ≤ Real.log (8 / ε) ∧
      ∑ k ∈ Finset.range n, a k ≤ Real.log (8 / ε) + 1 := by
  have hlog0 : 0 ≤ Real.log (8 / ε) :=
    Real.log_nonneg (by rw [le_div_iff₀ hε0]; linarith)
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp only [zero_tsub, Finset.range_zero, Finset.sum_empty, not_lt_zero, false_imp_iff,
      implies_true, le_refl, true_and]
    exact ⟨hlog0, by linarith⟩
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  simp only [add_tsub_cancel_right]
  have hum : ε / 8 ≤ u m := by simpa using hlast hn
  -- all residual masses up to step `m` are positive
  have hpos : ∀ k ≤ m, 0 < u k := by
    intro k hk
    by_contra hneg'
    have hneg : u k ≤ 0 := not_lt.mp hneg'
    have hprop : ∀ d, k + d ≤ m → u (k + d) ≤ 0 := by
      intro d
      induction d with
      | zero => intro _; simpa using hneg
      | succ d ih =>
        intro hd
        have hlt : k + d < m + 1 := by omega
        rw [← add_assoc, hstep (k + d) hlt]
        exact mul_nonpos_of_nonpos_of_nonneg (ih (by omega)) (by linarith [(ha _ hlt).2])
    have := hprop (m - k) (by omega)
    rw [Nat.add_sub_cancel' hk] at this
    linarith
  have hlt1 : ∀ k < m, a k < 1 := by
    intro k hk
    have h1 := hpos (k + 1) hk
    have h0 := hpos k hk.le
    rw [hstep k (by omega)] at h1
    have : 0 < 1 - a k := (pos_iff_pos_of_mul_pos h1).mp h0
    linarith
  have hinc : ∀ k ∈ Finset.range m,
      -Real.log (1 - a k) = Real.log (u k) - Real.log (u (k + 1)) := by
    intro k hk
    have hk' := Finset.mem_range.mp hk
    rw [hstep k (by omega), Real.log_mul (hpos k hk'.le).ne' (sub_pos.mpr (hlt1 k hk')).ne']
    ring
  have htel : ∑ k ∈ Finset.range m, -Real.log (1 - a k) = Real.log (u 0) - Real.log (u m) := by
    rw [Finset.sum_congr rfl hinc, Finset.sum_range_sub' (fun k => Real.log (u k))]
  have hlog_u0 : Real.log (u 0) ≤ 0 := Real.log_nonpos (hpos 0 (Nat.zero_le _)).le hu0
  have hlog_um : Real.log (ε / 8) ≤ Real.log (u m) := Real.log_le_log (by positivity) hum
  have e : Real.log (ε / 8) = -Real.log (8 / ε) := by rw [← Real.log_inv, inv_div]
  have hA : ∑ k ∈ Finset.range m, a k ≤ ∑ k ∈ Finset.range m, -Real.log (1 - a k) :=
    Finset.sum_le_sum fun k hk => le_neg_log_one_sub (hlt1 k (Finset.mem_range.mp hk))
  have hB : ∑ k ∈ Finset.range m, -Real.log (1 - a k) ≤ Real.log (8 / ε) := by
    rw [htel]; linarith
  refine ⟨hlt1, hA, hB, ?_⟩
  rw [Finset.sum_range_succ]
  linarith [(ha m (by omega)).2]

/-! ### The total charge along a run -/

/-- The three outcomes of a round with a proposal. -/
inductive Outcome
  | label
  | elim
  | reject
  deriving DecidableEq

/-- The progress `G_t`: `a` on a labelling step, `b` on an elimination, `0` on a
rejected proposal. -/
def progress : Outcome → ℝ → ℝ → ℝ
  | .label, a, _ => a
  | .elim, _, b => b
  | .reject, _, _ => 0

/-- One round of the algorithm on the sets `(U, V)`: the outcome `o` with rectangle
`S × T` turns `(U, V)` into `(U', V')`. -/
def RoundStep {X ι : Type*} [DecidableEq X] [DecidableEq ι] (o : Outcome)
    (U : Finset X) (V : Finset ι) (S : Finset X) (T : Finset ι) (U' : Finset X)
    (V' : Finset ι) : Prop :=
  match o with
  | .label => S ⊆ U ∧ U' = U \ S ∧ V' = V
  | .elim => T ⊆ V ∧ U' = U ∧ V' = V \ T
  | .reject => U' = U ∧ V' = V

/-- `eq:total-charge`: "Equations `eq:elim-charge` and `eq:peel-charge` show that,
before normal termination, `Σ_t G_t ≤ B`. The bound holds for every realized history."
The run has `n` rounds that did not stop, so each began with residual mass at least
`ε/8` (`active_mass`); the surviving sets start at all `K` rows, and the target is
retained throughout (`elimination_retains_target`). The proof applies `peel_charge` and
`elim_charge` to the whole run, with zero charge on steps of the other kinds. -/
theorem total_charge {X ι : Type*} [Fintype X] [DecidableEq X] [Fintype ι] [DecidableEq ι]
    (D : FinDist X) {ε : ℝ} (hε0 : 0 < ε) (hε1 : ε < 1 / 4) (n : ℕ) (o : ℕ → Outcome)
    (U S : ℕ → Finset X) (V T : ℕ → Finset ι) (istar : ι) (hV0 : V 0 = Finset.univ)
    (hrun : ∀ t < n, RoundStep (o t) (U t) (V t) (S t) (T t) (U (t + 1)) (V (t + 1)))
    (hactive : ∀ t < n, ε / 8 ≤ D.massOf (U t)) (htarget : ∀ t ≤ n, istar ∈ V t) :
    ∑ t ∈ Finset.range n,
        progress (o t) (D.massOf (S t) / D.massOf (U t)) (((T t).card : ℝ) / (V t).card) ≤
      chargeBound (Fintype.card ι) ε := by
  -- labelling charges, extended by zero
  set a : ℕ → ℝ := fun t => if o t = .label then D.massOf (S t) / D.massOf (U t) else 0
  set T' : ℕ → Finset ι := fun t => if o t = .elim then T t else ∅
  have hUpos : ∀ t < n, 0 < D.massOf (U t) := fun t ht => by linarith [hactive t ht]
  have ha : ∀ k < n, 0 ≤ a k ∧ a k ≤ 1 := by
    intro k hk
    simp only [a]
    split_ifs with h
    · have hr := hrun k hk
      rw [h] at hr
      exact ⟨div_nonneg (D.massOf_nonneg _) (D.massOf_nonneg _),
        (div_le_one (hUpos k hk)).mpr (Finset.sum_le_sum_of_subset_of_nonneg hr.1
          fun x _ _ => D.nonneg x)⟩
    · exact ⟨le_rfl, zero_le_one⟩
  have hstepU : ∀ k < n, D.massOf (U (k + 1)) = D.massOf (U k) * (1 - a k) := by
    intro k hk
    have hr := hrun k hk
    simp only [a]
    cases ho : o k with
    | label =>
      rw [ho] at hr
      simp only [RoundStep] at hr
      rw [hr.2.1, massOf_sdiff D hr.1]
      simp only [↓reduceIte]
      field_simp [(hUpos k hk).ne']
    | elim =>
      rw [ho] at hr; simp only [RoundStep] at hr
      rw [hr.2.1]; simp
    | reject =>
      rw [ho] at hr; simp only [RoundStep] at hr
      rw [hr.1]; simp
  have hlab := peel_charge hε0 hε1 (fun t => D.massOf (U t)) a n (D.massOf_le_one _) ha
    hstepU (fun hn => hactive (n - 1) (by omega))
  have hT' : ∀ t < n, T' t ⊆ V t := by
    intro t ht
    simp only [T']
    split_ifs with h
    · have hr := hrun t ht; rw [h] at hr; exact hr.1
    · exact Finset.empty_subset _
  have hV' : ∀ t < n, V (t + 1) = V t \ T' t := by
    intro t ht
    have hr := hrun t ht
    simp only [T']
    cases ho : o t with
    | label => rw [ho] at hr; simp only [RoundStep] at hr; simp [hr.2.2]
    | elim => rw [ho] at hr; simp only [RoundStep] at hr; simp [hr.2.2]
    | reject => rw [ho] at hr; simp only [RoundStep] at hr; simp [hr.2]
  obtain ⟨-, he1, he2⟩ := elim_charge V T' n istar hV0 hT' hV' htarget
  have hsplit : ∀ t ∈ Finset.range n,
      progress (o t) (D.massOf (S t) / D.massOf (U t)) (((T t).card : ℝ) / (V t).card) =
        a t + ((T' t).card : ℝ) / (V t).card := by
    intro t _
    simp only [a, T']
    cases o t <;> simp [progress]
  rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib]
  unfold chargeBound
  linarith [hlab.2.2.2]

/-! ### Expected progress -/

/-- "Integrating `eq:pointwise` against `D` conditioned on `U` gives
`E[ab | current history] ≥ r`", for a finitely supported law `λ` on proposals `R ∈ s`
with `S_R ⊆ U`, `a_R = D(S_R)/D(U)` and `b_R = ν(T_R)` (given here as `bR`). -/
theorem expected_ab_ge {X α : Type*} [Fintype X] [DecidableEq X] (D : FinDist X)
    {U : Finset X}
    (hU : 0 < D.massOf U) (s : Finset α) (lam : α → ℝ) (S : α → Finset X) (bR : α → ℝ)
    (hS : ∀ R ∈ s, lam R ≠ 0 → S R ⊆ U) {r : ℝ}
    (hcov : ∀ z ∈ U, r ≤ ∑ R ∈ s, lam R * ((if z ∈ S R then 1 else 0) * bR R)) :
    r ≤ ∑ R ∈ s, lam R * ((D.massOf (S R) / D.massOf U) * bR R) := by
  have hDS : ∀ R ∈ s, lam R ≠ 0 →
      D.massOf (S R) = ∑ z ∈ U, D.mass z * (if z ∈ S R then 1 else 0) := by
    intro R hR hR0
    unfold FinDist.massOf
    rw [← Finset.sum_filter_add_sum_filter_not U (· ∈ S R)]
    have e1 : U.filter (· ∈ S R) = S R := by
      ext z; simp only [Finset.mem_filter, and_iff_right_iff_imp]; exact fun hz => hS R hR hR0 hz
    rw [e1, Finset.sum_congr rfl (fun z hz => by
        rw [ite_eq_right (Finset.mem_filter.mp hz).2, mul_zero] :
        ∀ z ∈ U.filter (· ∉ S R), D.mass z * (if z ∈ S R then (1:ℝ) else 0) = 0),
      Finset.sum_const_zero, add_zero]
    exact Finset.sum_congr rfl fun z hz => by rw [ite_eq_left hz, mul_one]
  have key : r * D.massOf U ≤ ∑ R ∈ s, lam R * (D.massOf (S R) * bR R) := by
    calc r * D.massOf U = ∑ z ∈ U, D.mass z * r := by
          unfold FinDist.massOf; rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun z _ => mul_comm _ _
      _ ≤ ∑ z ∈ U, D.mass z * ∑ R ∈ s, lam R * ((if z ∈ S R then 1 else 0) * bR R) :=
          Finset.sum_le_sum fun z hz => mul_le_mul_of_nonneg_left (hcov z hz) (D.nonneg z)
      _ = ∑ R ∈ s, lam R * (D.massOf (S R) * bR R) := by
          simp_rw [Finset.mul_sum]
          rw [Finset.sum_comm]
          refine Finset.sum_congr rfl fun R hR => ?_
          by_cases hR0 : lam R = 0
          · simp [hR0]
          rw [hDS R hR hR0, Finset.sum_mul, Finset.mul_sum]
          exact Finset.sum_congr rfl fun z _ => by ring
  calc r = r * D.massOf U / D.massOf U := by field_simp
    _ ≤ (∑ R ∈ s, lam R * (D.massOf (S R) * bR R)) / D.massOf U :=
        div_le_div_of_nonneg_right key hU.le
    _ = ∑ R ∈ s, lam R * ((D.massOf (S R) / D.massOf U) * bR R) := by
        rw [Finset.sum_div]
        exact Finset.sum_congr rfl fun R _ => by field_simp

/-- `eq:drift-app`: "On acceptance either update has `G_t ≥ ab`, since `a,b ≤ 1`.
Rejection is possible only when `a < 3r/4`, and its contribution to `E[ab]` is at most
`(3r/4)E b ≤ 3r/4`. Therefore `E[G_t | current history] ≥ r/4`. The oracle may select
any allowed mismatch answer after seeing the rectangle." The outcome `o R` for each
proposal `R` is arbitrary (adversarial, chosen after seeing `R`), subject only to
`large_proposal_accepted`: a rejected proposal has `a_R < 3r/4`. -/
theorem drift {α : Type*} (s : Finset α) (lam : α → ℝ) (hlam : ∀ R ∈ s, 0 ≤ lam R)
    (hsum : ∑ R ∈ s, lam R = 1) (a b : α → ℝ)
    (hab : ∀ R ∈ s, 0 ≤ a R ∧ a R ≤ 1 ∧ 0 ≤ b R ∧ b R ≤ 1) {r : ℝ} (hr0 : 0 ≤ r)
    (hcov : r ≤ ∑ R ∈ s, lam R * (a R * b R)) (o : α → Outcome)
    (hrej : ∀ R ∈ s, o R = .reject → a R < 3 * r / 4) :
    r / 4 ≤ ∑ R ∈ s, lam R * progress (o R) (a R) (b R) := by
  have hpt : ∀ R ∈ s, a R * b R - 3 * r / 4 * b R ≤ progress (o R) (a R) (b R) := by
    intro R hR
    obtain ⟨ha0, ha1, hb0, hb1⟩ := hab R hR
    cases ho : o R with
    | label =>
      simp only [progress]
      have : a R * b R ≤ a R := mul_le_of_le_one_right ha0 hb1
      have : 0 ≤ 3 * r / 4 * b R := by positivity
      linarith
    | elim =>
      simp only [progress]
      have : a R * b R ≤ b R := mul_le_of_le_one_left hb0 ha1
      have : 0 ≤ 3 * r / 4 * b R := by positivity
      linarith
    | reject =>
      simp only [progress]
      have := hrej R hR ho
      nlinarith
  have hEb : ∑ R ∈ s, lam R * b R ≤ 1 := by
    calc ∑ R ∈ s, lam R * b R ≤ ∑ R ∈ s, lam R :=
          Finset.sum_le_sum fun R hR => mul_le_of_le_one_right (hlam R hR) (hab R hR).2.2.2
      _ = 1 := hsum
  have hEb0 : 0 ≤ ∑ R ∈ s, lam R * b R :=
    Finset.sum_nonneg fun R hR => mul_nonneg (hlam R hR) (hab R hR).2.2.1
  calc r / 4 ≤ ∑ R ∈ s, lam R * (a R * b R) - 3 * r / 4 * ∑ R ∈ s, lam R * b R := by
        nlinarith
    _ = ∑ R ∈ s, lam R * (a R * b R - 3 * r / 4 * b R) := by
        rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun R _ => by ring
    _ ≤ ∑ R ∈ s, lam R * progress (o R) (a R) (b R) :=
        Finset.sum_le_sum fun R hR => mul_le_mul_of_nonneg_left (hpt R hR) (hlam R hR)

/-! ### The exponential potential -/

/-- "Since `0 ≤ G_t ≤ 1`, convexity gives `e^{-G_t} ≤ 1 - (1-e^{-1})G_t`." -/
theorem exp_neg_le_chord {G : ℝ} (h0 : 0 ≤ G) (h1 : G ≤ 1) :
    Real.exp (-G) ≤ 1 - (1 - Real.exp (-1)) * G := by
  have := convexOn_exp.2 (Set.mem_univ 0) (Set.mem_univ (-1)) (sub_nonneg.mpr h1) h0
    (by ring : (1 - G) + G = 1)
  simp only [smul_eq_mul, mul_zero, zero_add, Real.exp_zero, mul_one, mul_neg] at this
  linarith

theorem half_le_one_sub_exp_neg_one : 1 / 2 ≤ 1 - Real.exp (-1) := by
  have h : Real.exp 1 > 2 := by have := Real.exp_one_gt_d9; norm_num at this ⊢; linarith
  have : Real.exp (-1) < 1 / 2 := by
    rw [Real.exp_neg, inv_lt_comm₀ (Real.exp_pos 1) (by norm_num)]
    norm_num; linarith
  linarith

/-- "`E[e^{-G_t} | past] ≤ 1 - r/8 ≤ e^{-r/8}`", for a finitely supported law (the
law of the rectangle choice in one round). -/
theorem exp_drift_finite {α : Type*} (s : Finset α) (w : α → ℝ) (hw : ∀ i ∈ s, 0 ≤ w i)
    (hsum : ∑ i ∈ s, w i = 1) (G : α → ℝ) (hG : ∀ i ∈ s, 0 ≤ G i ∧ G i ≤ 1) {r : ℝ}
    (hr : 0 ≤ r) (hdrift : r / 4 ≤ ∑ i ∈ s, w i * G i) :
    ∑ i ∈ s, w i * Real.exp (-G i) ≤ 1 - r / 8 ∧ 1 - r / 8 ≤ Real.exp (-(r / 8)) := by
  have hc := half_le_one_sub_exp_neg_one
  refine ⟨?_, by linarith [Real.add_one_le_exp (-(r / 8))]⟩
  calc ∑ i ∈ s, w i * Real.exp (-G i)
      ≤ ∑ i ∈ s, w i * (1 - (1 - Real.exp (-1)) * G i) :=
        Finset.sum_le_sum fun i hi =>
          mul_le_mul_of_nonneg_left (exp_neg_le_chord (hG i hi).1 (hG i hi).2) (hw i hi)
    _ = ∑ i ∈ s, w i - (1 - Real.exp (-1)) * ∑ i ∈ s, w i * G i := by
        rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun i _ => by ring
    _ ≤ 1 - r / 8 := by rw [hsum]; nlinarith

/-- The same step for an arbitrary probability measure. -/
theorem exp_drift_measure {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω)
    [IsProbabilityMeasure P] {G : Ω → ℝ} (hint : Integrable G P)
    (hG : ∀ ω, 0 ≤ G ω ∧ G ω ≤ 1) {r : ℝ} (hr : 0 ≤ r) (hdrift : r / 4 ≤ ∫ ω, G ω ∂P) :
    ∫ ω, Real.exp (-G ω) ∂P ≤ 1 - r / 8 ∧ 1 - r / 8 ≤ Real.exp (-(r / 8)) := by
  have hc := half_le_one_sub_exp_neg_one
  refine ⟨?_, by linarith [Real.add_one_le_exp (-(r / 8))]⟩
  have hexp : Integrable (fun ω => Real.exp (-G ω)) P := by
    refine Integrable.mono' (integrable_const (1 : ℝ))
      (Real.continuous_exp.comp_aestronglyMeasurable hint.1.neg) ?_
    refine Filter.Eventually.of_forall fun ω => ?_
    rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
    exact Real.exp_le_one_iff.mpr (by linarith [(hG ω).1])
  have hlin : Integrable (fun ω => 1 - (1 - Real.exp (-1)) * G ω) P :=
    (integrable_const 1).sub (hint.const_mul _)
  calc ∫ ω, Real.exp (-G ω) ∂P ≤ ∫ ω, (1 - (1 - Real.exp (-1)) * G ω) ∂P :=
        integral_mono hexp hlin fun ω => exp_neg_le_chord (hG ω).1 (hG ω).2
    _ = 1 - (1 - Real.exp (-1)) * ∫ ω, G ω ∂P := by
        rw [integral_sub (integrable_const 1) (hint.const_mul _), integral_const_mul]
        simp
    _ ≤ 1 - r / 8 := by nlinarith

/-- A finitely branching randomized process of depth `n`: in each round a finitely
supported law on `k` branches, each carrying a progress value `G`. A branch is a choice
of rectangle; its progress is determined by the (deterministic, adaptive) valid oracle's
answers, and after normal termination a round has the single branch `G = 1`. -/
inductive ProgressTree : ℕ → Type
  | done : ProgressTree 0
  | round {n : ℕ} (k : ℕ) (w : Fin k → ℝ) (G : Fin k → ℝ) (next : Fin k → ProgressTree n) :
      ProgressTree (n + 1)

namespace ProgressTree

/-- `E exp(-Σ_t G_t)`. -/
def expPotential : {n : ℕ} → ProgressTree n → ℝ
  | 0, .done => 1
  | _ + 1, .round _ w G next => ∑ i, w i * Real.exp (-G i) * expPotential (next i)

/-- `Pr[Σ_t G_t ≤ c]`. -/
def probTotalLE : {n : ℕ} → ProgressTree n → ℝ → ℝ
  | 0, .done, c => if 0 ≤ c then 1 else 0
  | _ + 1, .round _ w G next, c => ∑ i, w i * probTotalLE (next i) (c - G i)

/-- Every round is a probability law with progress in `[0,1]` and conditional drift
`E[G_t | past] ≥ r/4` (`eq:drift-app`). -/
def Drift (r : ℝ) : {n : ℕ} → ProgressTree n → Prop
  | 0, .done => True
  | _ + 1, .round _ w G next =>
      (∀ i, 0 ≤ w i) ∧ ∑ i, w i = 1 ∧ (∀ i, 0 ≤ G i ∧ G i ≤ 1) ∧
        r / 4 ≤ ∑ i, w i * G i ∧ ∀ i, Drift r (next i)

theorem expPotential_nonneg : ∀ {n : ℕ} (T : ProgressTree n) {r : ℝ}, Drift r T →
    0 ≤ expPotential T
  | 0, .done, _, _ => by simp [expPotential]
  | _ + 1, .round k w G next, r, hT => by
      obtain ⟨hw, -, -, -, hnext⟩ := hT
      simp only [expPotential]
      exact Finset.sum_nonneg fun i _ =>
        mul_nonneg (mul_nonneg (hw i) (Real.exp_pos _).le) (expPotential_nonneg _ (hnext i))

/-- `eq:exponential-potential`: "Iterating conditional expectation gives
`E exp(-Σ_{t=1}^R G_t) ≤ e^{-rR/8}`." -/
theorem exponential_potential {r : ℝ} (hr : 0 ≤ r) :
    ∀ {n : ℕ} (T : ProgressTree n), Drift r T → expPotential T ≤ Real.exp (-(r * n / 8))
  | 0, .done, _ => by simp [expPotential]
  | n + 1, .round k w G next, ⟨hw, hsum, hG, hdrift, hnext⟩ => by
      simp only [expPotential]
      have hstep := exp_drift_finite Finset.univ w (fun i _ => hw i) hsum G
        (fun i _ => hG i) hr hdrift
      calc ∑ i, w i * Real.exp (-G i) * expPotential (next i)
          ≤ ∑ i, w i * Real.exp (-G i) * Real.exp (-(r * n / 8)) :=
            Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left
              (exponential_potential hr (next i) (hnext i))
              (mul_nonneg (hw i) (Real.exp_pos _).le)
        _ = (∑ i, w i * Real.exp (-G i)) * Real.exp (-(r * n / 8)) := by
            rw [Finset.sum_mul]
        _ ≤ Real.exp (-(r / 8)) * Real.exp (-(r * n / 8)) :=
            mul_le_mul_of_nonneg_right (hstep.1.trans hstep.2) (Real.exp_pos _).le
        _ = Real.exp (-(r * ((n + 1 : ℕ) : ℝ) / 8)) := by
            rw [← Real.exp_add]; push_cast; ring_nf

/-- Markov's inequality for the potential: `Pr[Σ G ≤ c] ≤ e^c E exp(-Σ G)`. -/
theorem probTotalLE_le : ∀ {n : ℕ} (T : ProgressTree n) {r : ℝ}, Drift r T → ∀ c : ℝ,
    probTotalLE T c ≤ Real.exp c * expPotential T
  | 0, .done, _, _, c => by
      simp only [probTotalLE, expPotential, mul_one]
      split_ifs with h
      · exact Real.one_le_exp h
      · exact (Real.exp_pos c).le
  | _ + 1, .round k w G next, r, hT, c => by
      obtain ⟨hw, -, -, -, hnext⟩ := hT
      simp only [probTotalLE, expPotential]
      rw [Finset.mul_sum]
      refine Finset.sum_le_sum fun i _ => ?_
      calc w i * probTotalLE (next i) (c - G i)
          ≤ w i * (Real.exp (c - G i) * expPotential (next i)) :=
            mul_le_mul_of_nonneg_left (probTotalLE_le (next i) (hnext i) _) (hw i)
        _ = Real.exp c * (w i * Real.exp (-G i) * expPotential (next i)) := by
            rw [sub_eq_add_neg, Real.exp_add]; ring

/-- "On an execution that exhausts the budget without a normal stop, `eq:total-charge`
gives `Σ_{t=1}^R G_t ≤ B`. Markov's inequality and `eq:exponential-potential` therefore
imply `Pr[budget exhaustion] ≤ e^{B-rR/8}`": the probability of `Σ G ≤ B` (which
contains budget exhaustion) is at most `e^{B-rR/8}`. -/
theorem prob_total_le_bound {r : ℝ} (hr : 0 ≤ r) {n : ℕ} (T : ProgressTree n)
    (hT : Drift r T) (B : ℝ) : probTotalLE T B ≤ Real.exp (B - r * n / 8) := by
  calc probTotalLE T B ≤ Real.exp B * expPotential T := probTotalLE_le T hT B
    _ ≤ Real.exp B * Real.exp (-(r * n / 8)) :=
        mul_le_mul_of_nonneg_left (exponential_potential hr T hT) (Real.exp_pos B).le
    _ = Real.exp (B - r * n / 8) := by rw [← Real.exp_add]; ring_nf

end ProgressTree

/-! ### The query budget -/

/-- `e^{B - rR/8} ≤ ε/2` for `R = ⌈8r⁻¹(B + ln(2/ε))⌉`. -/
theorem budget_tail {r ε : ℝ} (hr0 : 0 < r) (hε0 : 0 < ε) (K : ℕ) :
    Real.exp (chargeBound K ε - r * roundBudget r K ε / 8) ≤ ε / 2 := by
  have hR : 8 * r⁻¹ * (chargeBound K ε + Real.log (2 / ε)) ≤ roundBudget r K ε :=
    Nat.le_ceil _
  have h1 : chargeBound K ε + Real.log (2 / ε) ≤ r * roundBudget r K ε / 8 := by
    have e : r * (8 * r⁻¹ * (chargeBound K ε + Real.log (2 / ε))) / 8 =
        chargeBound K ε + Real.log (2 / ε) := by field_simp
    have := mul_le_mul_of_nonneg_left hR hr0.le
    linarith
  have e2 : Real.log (2 / ε) = -Real.log (ε / 2) := by rw [← Real.log_inv, inv_div]
  calc Real.exp (chargeBound K ε - r * roundBudget r K ε / 8)
      ≤ Real.exp (Real.log (ε / 2)) := Real.exp_le_exp.mpr (by linarith)
    _ = ε / 2 := Real.exp_log (by positivity)

/-- "`Pr[budget exhaustion] ≤ e^{B-rR/8} ≤ ε/2`": for a process of `R` rounds with
conditional drift `r/4`, the probability that the total progress is at most `B` is at
most `ε/2`. -/
theorem prob_total_le_chargeBound {r ε : ℝ} (hr0 : 0 < r) (hε0 : 0 < ε) (K : ℕ)
    (T : ProgressTree (roundBudget r K ε)) (hT : ProgressTree.Drift r T) :
    T.probTotalLE (chargeBound K ε) ≤ ε / 2 :=
  (ProgressTree.prob_total_le_bound hr0.le T hT _).trans (budget_tail hr0 hε0 K)

/-- "There are at most three queries per round, so `3R+1` is a valid worst-case bound":
`q t ≤ 3` queries in each of the at most `R` rounds. -/
theorem query_count (R : ℕ) (q : ℕ → ℕ) (hq : ∀ t < R, q t ≤ 3) :
    ∑ t ∈ Finset.range R, q t ≤ 3 * R + 1 := by
  have : ∑ t ∈ Finset.range R, q t ≤ ∑ _t ∈ Finset.range R, 3 :=
    Finset.sum_le_sum fun t ht => hq t (Finset.mem_range.mp ht)
  simp only [Finset.sum_const, Finset.card_range, smul_eq_mul] at this
  omega

/-- "Combining this with `eq:normal-loss` and the trivial loss bound one proves expected
loss at most `ε`": on a finite law over executions, loss at most `ε/2` off an event `E`,
loss at most one on `E`, and `Pr[E] ≤ ε/2`. -/
theorem expected_loss_le {α : Type*} [DecidableEq α] (s : Finset α) (w : α → ℝ)
    (hw : ∀ i ∈ s, 0 ≤ w i)
    (hsum : ∑ i ∈ s, w i = 1) (lossOf : α → ℝ) (E : Finset α) {ε : ℝ}
    (hnormal : ∀ i ∈ s, i ∉ E → lossOf i ≤ ε / 2) (hone : ∀ i ∈ s, lossOf i ≤ 1)
    (hE : ∑ i ∈ s.filter (· ∈ E), w i ≤ ε / 2) (hε : 0 ≤ ε) :
    ∑ i ∈ s, w i * lossOf i ≤ ε := by
  have hpt : ∀ i ∈ s, w i * lossOf i ≤ w i * (ε / 2) + (if i ∈ E then w i else 0) := by
    intro i hi
    split_ifs with h
    · have := mul_le_mul_of_nonneg_left (hone i hi) (hw i hi)
      have : 0 ≤ w i * (ε / 2) := mul_nonneg (hw i hi) (by linarith)
      linarith
    · simpa using mul_le_mul_of_nonneg_left (hnormal i hi h) (hw i hi)
  calc ∑ i ∈ s, w i * lossOf i ≤ ∑ i ∈ s, (w i * (ε / 2) + if i ∈ E then w i else 0) :=
        Finset.sum_le_sum hpt
    _ = ε / 2 + ∑ i ∈ s.filter (· ∈ E), w i := by
        rw [Finset.sum_add_distrib, ← Finset.sum_mul, hsum, Finset.sum_filter]; ring
    _ ≤ ε := by linarith

/-- The parameter formulas behind `eq:rectanglebound`, for `r = 1/ρ`, `ρ ≥ 1`,
`0 < ε < 1/4`: the budget `3R+1` is at most `124ρ(ln K + ln(1/ε))` and the tolerance
satisfies `τ ≥ ε/(288ρ ln(1/ε))`, matching the orders `O(ρ(log K + log(1/ε)))` and
`Ω(ε/(ρ log(1/ε)))`. This bounds the parameters only; no learner is constructed here.
(The constants `124` and `288` are ours.) -/
theorem rectanglebound_explicit {ρ ε : ℝ} (hρ : 1 ≤ ρ) (hε0 : 0 < ε) (hε1 : ε < 1 / 4)
    (K : ℕ) :
    ((3 * roundBudget (1 / ρ) K ε + 1 : ℕ) : ℝ) ≤ 124 * ρ * (Real.log K + Real.log (1 / ε)) ∧
      ε / (288 * ρ * Real.log (1 / ε)) ≤ tol (1 / ρ) ε := by
  set L := Real.log (1 / ε)
  have hL4 : Real.log 4 < L := Real.log_lt_log (by norm_num) (by rw [lt_div_iff₀ hε0]; linarith)
  have h4 := one_lt_log_four
  have hl2 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; norm_num
  have hl8 : Real.log 8 = 3 * Real.log 2 := by
    rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]; norm_num
  have h8e : Real.log (8 / ε) = Real.log 8 + L := by
    rw [div_eq_mul_one_div 8 ε, Real.log_mul (by norm_num) (by positivity)]
  have h2e : Real.log (2 / ε) = Real.log 2 + L := by
    rw [div_eq_mul_one_div 2 ε, Real.log_mul (by norm_num) (by positivity)]
  have hK : 0 ≤ Real.log K := Real.log_natCast_nonneg K
  have hρinv : (1 / ρ)⁻¹ = ρ := by rw [one_div, inv_inv]
  have hL1 : 1 < L := by linarith
  constructor
  · have hR : (roundBudget (1 / ρ) K ε : ℝ) < 8 * ρ * (Real.log K + 5 * L) + 1 := by
      unfold roundBudget chargeBound
      rw [hρinv, h8e, h2e]
      have hpos : 0 ≤ 8 * ρ * (Real.log K + (Real.log 8 + L) + 1 + (Real.log 2 + L)) := by
        have : 0 < Real.log 2 := Real.log_pos (by norm_num)
        positivity
      have := Nat.ceil_lt_add_one hpos
      have hin : Real.log K + (Real.log 8 + L) + 1 + (Real.log 2 + L) ≤ Real.log K + 5 * L := by
        linarith
      have := mul_le_mul_of_nonneg_left hin (by linarith : (0 : ℝ) ≤ 8 * ρ)
      linarith
    push_cast
    have hρL : 1 ≤ ρ * (Real.log K + L) := by nlinarith
    nlinarith
  · have hP : (peelCap (1 / ρ) ε : ℝ) < 12 * ρ * L := by
      unfold peelCap
      push_cast
      rw [hρinv, h8e]
      have hpos : 0 ≤ 4 * ρ * (Real.log 8 + L) := by
        have : 0 < Real.log 2 := Real.log_pos (by norm_num); positivity
      have := Nat.ceil_lt_add_one hpos
      nlinarith
    have hPpos : (0 : ℝ) < peelCap (1 / ρ) ε := by exact_mod_cast one_le_peelCap _ _
    unfold tol
    rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith

section coverage

variable {X ι : Type*} [Fintype X] [DecidableEq X] [Fintype ι] [DecidableEq ι]

omit [Fintype X] [DecidableEq X] [Fintype ι] [DecidableEq ι] in
theorem monochromatic_mono {H : ι → Hyp X} {S S' : Finset X} {T T' : Finset ι} {c : Bool}
    (h : Monochromatic H S T c) (hS : S' ⊆ S) (hT : T' ⊆ T) : Monochromatic H S' T' c :=
  fun x hx i hi => h x (hS hx) i (hT hi)

/-- A linear functional on `X → ℝ` is given by its values on the coordinate vectors. -/
theorem linear_eq_sum (f : (X → ℝ) →L[ℝ] ℝ) (y : X → ℝ) :
    f y = ∑ x, y x * f (Pi.single x 1) := by
  conv_lhs => rw [← Finset.univ_sum_single y]
  rw [map_sum]
  refine Finset.sum_congr rfl fun x _ => ?_
  rw [show Pi.single x (y x) = y x • (Pi.single x (1 : ℝ) : X → ℝ) by
    rw [← Pi.single_smul', smul_eq_mul, mul_one], map_smul, smul_eq_mul]

/-- The coverage vector `z_R(x) = 1_{S_R}(x) ν(T_R)` of a rectangle `R = (S_R, T_R, c_R)`. -/
def coverVec (ν : FinDist ι) (R : Finset X × Finset ι × Bool) : X → ℝ :=
  fun x => (if x ∈ R.1 then 1 else 0) * ν.massOf R.2.1

/-- The admissible rectangles: monochromatic and contained in `U × V`. -/
def Admissible (H : ι → Hyp X) (U : Finset X) (V : Finset ι)
    (R : Finset X × Finset ι × Bool) : Prop :=
  R.1 ⊆ U ∧ R.2.1 ⊆ V ∧ Monochromatic H R.1 R.2.1 R.2.2

/-- Lemma *Pointwise coverage* (`lem:mixture`), via the finite separation argument of
Appendix `app:rectangle` (`eq:mixture-lp`): "Fix nonempty `U ⊆ X`, `V ⊆ H`, a prior `ν`
on `V`, and `0 < r ≤ rect(H)`. There is a law `λ` on monochromatic rectangles
`S × T ⊆ U × V` satisfying `E_{(S,T,c)∼λ}[1_S(z)ν(T)] ≥ r` for `z ∈ U`. This law
depends on the table, `U`, `V`, and `ν`, but not on `D`." The law is a finitely
supported probability vector on triples `(S, T, c)`; its support consists of admissible
rectangles. -/
theorem pointwise_coverage (H : ι → Hyp X) (U : Finset X) (V : Finset ι)
    (ν : FinDist ι) (hν : ∀ i ∉ V, ν.mass i = 0) {r : ℝ} (hr0 : 0 < r)
    (hr : r ≤ rect H) :
    ∃ lam : Finset X × Finset ι × Bool → ℝ,
      (∀ R, 0 ≤ lam R) ∧ ∑ R, lam R = 1 ∧
      (∀ R, lam R ≠ 0 → Admissible H U V R) ∧
      ∀ z ∈ U, r ≤ ∑ R, lam R * ((if z ∈ R.1 then 1 else 0) * ν.massOf R.2.1) := by
  classical
  set A : Finset (Finset X × Finset ι × Bool) := Finset.univ.filter (Admissible H U V)
  set pts : Set (X → ℝ) := coverVec ν '' ↑A
  set K := convexHull ℝ pts
  set C : Set (X → ℝ) := {y | ∀ x ∈ U, r ≤ y x}
  have hR0 : ((∅ : Finset X), (∅ : Finset ι), true) ∈ A := by
    simp [A, Admissible, Monochromatic]
  have h0K : (0 : X → ℝ) ∈ K := by
    refine subset_convexHull ℝ pts ⟨_, hR0, ?_⟩
    funext x; simp [coverVec]
  -- the main claim: `K` meets `C`
  have hmeet : ∃ y ∈ K, y ∈ C := by
    by_contra hno
    have hdisj : Disjoint K C := Set.disjoint_left.mpr fun y hyK hyC => hno ⟨y, hyK, hyC⟩
    have hKc : IsCompact K := (A.finite_toSet.image _).isCompact_convexHull ℝ
    have hCc : Convex ℝ C := by
      intro y1 h1 y2 h2 a b ha hb hab x hx
      simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
      have := h1 x hx; have := h2 x hx
      nlinarith
    have hCcl : IsClosed C := by
      have : C = ⋂ x ∈ (U : Set X), {y : X → ℝ | r ≤ y x} := by
        ext y; simp [C]
      rw [this]
      exact isClosed_biInter fun x _ => isClosed_le continuous_const (continuous_apply x)
    obtain ⟨f, u, v, hfK, huv, hfC⟩ :=
      geometric_hahn_banach_compact_closed (convex_convexHull ℝ pts) hKc hCc hCcl hdisj
    set c : X → ℝ := fun x => f (Pi.single x 1)
    have hf : ∀ y, f y = ∑ x, y x * c x := linear_eq_sum f
    set b0 : X → ℝ := fun _ => r
    have hb0 : b0 ∈ C := fun x _ => le_rfl
    have hshift : ∀ x t, f (b0 + t • Pi.single x 1) = f b0 + t * c x := by
      intro x t; rw [map_add, map_smul, smul_eq_mul]
    -- coefficients vanish off `U` and are nonnegative on `U`
    have hc_out : ∀ x ∉ U, c x = 0 := by
      intro x hx
      by_contra hne
      have hmem : b0 + ((v - f b0 - 1) / c x) • Pi.single x 1 ∈ C := by
        intro x' hx'
        have : x' ≠ x := fun h => hx (h ▸ hx')
        simp [b0, this]
      have := hfC _ hmem
      rw [hshift, div_mul_cancel₀ _ hne] at this
      linarith
    have hc_nonneg : ∀ x, 0 ≤ c x := by
      intro x
      by_cases hx : x ∈ U
      · by_contra hneg'
        have hneg : c x < 0 := not_le.mp hneg'
        have ht : 0 ≤ (f b0 - v + 1) / (-c x) := by
          have := hfC b0 hb0
          exact div_nonneg (by linarith) (by linarith)
        have hmem : b0 + ((f b0 - v + 1) / (-c x)) • Pi.single x 1 ∈ C := by
          intro x' hx'
          by_cases hxx : x' = x
          · subst hxx
            simp only [Pi.add_apply, Pi.smul_apply, Pi.single_eq_same, smul_eq_mul, mul_one, b0]
            linarith
          · simp [b0, hxx]
        have := hfC _ hmem
        rw [hshift] at this
        have e : (f b0 - v + 1) / (-c x) * c x = -(f b0 - v + 1) := by
          rw [div_mul_eq_mul_div, div_eq_iff (show -c x ≠ 0 by linarith)]
          ring
        rw [e] at this
        linarith
      · exact (hc_out x hx).ge
    -- normalize to a distribution `μ` on `U`
    have hf0 : f 0 = 0 := map_zero f
    have hfb0 : f b0 = r * ∑ x, c x := by rw [hf, Finset.mul_sum]
    have hsum_pos : 0 < ∑ x, c x := by
      have h1 := hfK 0 h0K
      have h2 := hfC b0 hb0
      rw [hf0] at h1
      rw [hfb0] at h2
      have : 0 < r * ∑ x, c x := by linarith
      exact pos_of_mul_pos_right this hr0.le
    set σ := ∑ x, c x
    let μ : FinDist X :=
      { mass := fun x => c x / σ
        nonneg := fun x => div_nonneg (hc_nonneg x) hsum_pos.le
        total := by rw [← Finset.sum_div]; exact div_self hsum_pos.ne' }
    obtain ⟨S, T, col, hmono, hmass⟩ := exists_rectangle_of_le_rect hr μ ν
    set S' := S.filter (· ∈ U)
    set T' := T.filter (· ∈ V)
    have hR' : (S', T', col) ∈ A := by
      simp only [A, Finset.mem_filter, Finset.mem_univ, true_and, Admissible]
      exact ⟨fun x hx => (Finset.mem_filter.mp hx).2, fun i hi => (Finset.mem_filter.mp hi).2,
        monochromatic_mono hmono (Finset.filter_subset _ _) (Finset.filter_subset _ _)⟩
    have hμS : μ.massOf S' = μ.massOf S := by
      unfold FinDist.massOf
      rw [Finset.sum_filter]
      refine Finset.sum_congr rfl fun x _ => ?_
      split_ifs with h
      · rfl
      · simp [μ, hc_out x h]
    have hνT : ν.massOf T' = ν.massOf T := by
      unfold FinDist.massOf
      rw [Finset.sum_filter]
      refine Finset.sum_congr rfl fun i _ => ?_
      split_ifs with h
      · rfl
      · exact (hν i h).symm
    have hzR := hfK _ (subset_convexHull ℝ pts ⟨_, hR', rfl⟩)
    rw [hf] at hzR
    have hval : ∑ x, coverVec ν (S', T', col) x * c x = μ.massOf S' * ν.massOf T' * σ := by
      have h1 : ∑ x, coverVec ν (S', T', col) x * c x = ν.massOf T' * ∑ x ∈ S', c x := by
        simp only [coverVec, ite_mul, one_mul, zero_mul]
        rw [Finset.sum_ite_mem, Finset.univ_inter, Finset.mul_sum]
      have h2 : μ.massOf S' = (∑ x ∈ S', c x) / σ := by
        simp only [FinDist.massOf, μ]; rw [Finset.sum_div]
      rw [h1, h2]
      field_simp
    rw [hval] at hzR
    have h2 := hfC b0 hb0
    rw [hfb0] at h2
    have : μ.massOf S' * ν.massOf T' < r := by
      have h3 : μ.massOf S' * ν.massOf T' * σ < r * σ := by linarith
      exact lt_of_mul_lt_mul_right h3 hsum_pos.le
    rw [hμS, hνT] at this
    linarith
  -- extract a law on rectangles from a point of `K ∩ C`
  obtain ⟨y, hyK, hyC⟩ := hmeet
  obtain ⟨κ, _, w, zz, hw0, hw1, hzz, hy⟩ := mem_convexHull_iff_exists_fintype.mp hyK
  have hchoose : ∀ i, ∃ R ∈ A, coverVec ν R = zz i := fun i => by
    obtain ⟨R, hR, he⟩ := hzz i
    exact ⟨R, hR, he⟩
  choose Rc hRcA hRc using hchoose
  refine ⟨fun R => ∑ i ∈ Finset.univ.filter (fun i => Rc i = R), w i, fun R =>
    Finset.sum_nonneg fun i _ => hw0 i, ?_, ?_, ?_⟩
  · rw [Finset.sum_fiberwise Finset.univ Rc w]; exact hw1
  · intro R hR
    obtain ⟨i, hi⟩ : (Finset.univ.filter fun i => Rc i = R).Nonempty := by
      by_contra hne
      rw [Finset.not_nonempty_iff_eq_empty] at hne
      simp [hne] at hR
    have := hRcA i
    rw [(Finset.mem_filter.mp hi).2] at this
    exact (Finset.mem_filter.mp this).2
  · intro z hz
    have hyz : y z = ∑ i, w i * coverVec ν (Rc i) z := by
      rw [← hy, Finset.sum_apply]
      exact Finset.sum_congr rfl fun i _ => by rw [Pi.smul_apply, smul_eq_mul, hRc i]
    have hfib := Finset.sum_fiberwise Finset.univ Rc (fun i => w i * coverVec ν (Rc i) z)
    calc r ≤ y z := hyC z hz
      _ = ∑ i, w i * coverVec ν (Rc i) z := hyz
      _ = ∑ R, ∑ i ∈ Finset.univ.filter (fun i => Rc i = R), w i * coverVec ν (Rc i) z :=
          hfib.symm
      _ = ∑ R, (∑ i ∈ Finset.univ.filter (fun i => Rc i = R), w i) *
            ((if z ∈ R.1 then 1 else 0) * ν.massOf R.2.1) := by
          refine Finset.sum_congr rfl fun R _ => ?_
          rw [Finset.sum_mul]
          refine Finset.sum_congr rfl fun i hi => ?_
          rw [(Finset.mem_filter.mp hi).2]
          rfl

omit [DecidableEq ι] in
/-- "Integrating `eq:pointwise` against `D` conditioned on `U` gives
`E[ab | current history] ≥ r`" for the law of `pointwise_coverage`, with
`a = D(S)/D(U)` and `b = ν(T)`. -/
theorem coverage_expected_ab (H : ι → Hyp X) (D : FinDist X) (U : Finset X)
    (hU : 0 < D.massOf U) (V : Finset ι) (ν : FinDist ι) {r : ℝ}
    (lam : Finset X × Finset ι × Bool → ℝ) (hadm : ∀ R, lam R ≠ 0 → Admissible H U V R)
    (hcov : ∀ z ∈ U, r ≤ ∑ R, lam R * ((if z ∈ R.1 then 1 else 0) * ν.massOf R.2.1)) :
    r ≤ ∑ R, lam R * ((D.massOf R.1 / D.massOf U) * ν.massOf R.2.1) :=
  expected_ab_ge D hU Finset.univ lam (fun R => R.1) (fun R => ν.massOf R.2.1)
    (fun R _ hR => (hadm R hR).1) hcov

omit [DecidableEq ι] in
/-- One round of `alg:rectify`: `eq:drift-app` for the law of `pointwise_coverage` (or any
law with the same properties) on the current state `(U, V)`, with `a = D(S)/D(U)`,
`b = ν(T)` (`ν` uniform on `V` in the paper), and an arbitrary outcome for each proposal
subject to `rejected_small`. -/
theorem round_drift (H : ι → Hyp X) (D : FinDist X) (U : Finset X) (hU : 0 < D.massOf U)
    (V : Finset ι) (ν : FinDist ι) {r : ℝ} (hr0 : 0 ≤ r)
    (lam : Finset X × Finset ι × Bool → ℝ) (hlam0 : ∀ R, 0 ≤ lam R) (hlam1 : ∑ R, lam R = 1)
    (hadm : ∀ R, lam R ≠ 0 → Admissible H U V R)
    (hcov : ∀ z ∈ U, r ≤ ∑ R, lam R * ((if z ∈ R.1 then 1 else 0) * ν.massOf R.2.1))
    (o : Finset X × Finset ι × Bool → Outcome)
    (hrej : ∀ R, lam R ≠ 0 → o R = .reject → D.massOf R.1 / D.massOf U < 3 * r / 4) :
    r / 4 ≤ ∑ R, lam R * progress (o R) (D.massOf R.1 / D.massOf U) (ν.massOf R.2.1) := by
  set s := Finset.univ.filter fun R => lam R ≠ 0
  have hsub : ∀ (f : Finset X × Finset ι × Bool → ℝ),
      ∑ R ∈ s, lam R * f R = ∑ R, lam R * f R := fun f =>
    Finset.sum_filter_of_ne fun R _ h => left_ne_zero_of_mul h
  have hab := coverage_expected_ab H D U hU V ν lam hadm hcov
  have hsum : ∑ R ∈ s, lam R = 1 := by
    rw [← hlam1]
    exact Finset.sum_filter_of_ne fun R _ h => h
  rw [← hsub]
  refine drift s lam (fun R _ => hlam0 R) hsum _ _ (fun R hR => ?_) hr0 ?_ o
    (fun R hR => hrej R (Finset.mem_filter.mp hR).2)
  · have hR := hadm R (Finset.mem_filter.mp hR).2
    refine ⟨div_nonneg (D.massOf_nonneg _) (D.massOf_nonneg _), ?_, ν.massOf_nonneg _,
      ν.massOf_le_one _⟩
    exact (div_le_one hU).mpr (Finset.sum_le_sum_of_subset_of_nonneg hR.1
      fun x _ _ => D.nonneg x)
  · rw [hsub (fun R => (D.massOf R.1 / D.massOf U) * ν.massOf R.2.1)]
    exact hab

end coverage

end SQDC.RectangleLearner
