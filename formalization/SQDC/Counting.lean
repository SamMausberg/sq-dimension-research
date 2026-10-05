import SQDC.Basic
import Mathlib.Analysis.SpecialFunctions.BinaryEntropy
import Mathlib.Analysis.SpecialFunctions.Log.Base
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.InformationTheory.Hamming
import Mathlib.LinearAlgebra.Matrix.Rank

/-!
# Counting on the incidence support

Correspondence with Subsection *Counting on the incidence support* of Section *Incidence
signs and representation dimension* (`sec:incidence`), Lemma *Approximation on a random mask*
(`lem:mask-approx`) and Appendix *Dimension lower bounds on the incidence support*
(`app:counting`), the asymptotic part of Appendix *Prior-average representations*
(`app:prior`), and equation `eq:fixed-output` of Appendix *Query lower bounds and transcript
embeddings* (`app:query`). Results are cited by title and TeX label.

* `h2`, `cEta`, `h2_eq_binEntropy`, `cEta_mem_Ioc`: `h₂` in bits and `c_η = 1 - h₂(η) ∈ (0,1]`
  for `0 ≤ η < 1/2` (`eq:seta`).
* `hammingBall`, `card_hammingBall_le`, `card_hammingBall_fin_le`: a Hamming ball of radius
  `ηI` has at most `2^{h₂(η) I}` vectors (`app:counting`).
* `fExp`, `hasDerivAt_fExp`, `fExp_deriv_pos`, `fExp_strictMonoOn`, `fExp_one`,
  `logb_256e_lt`, `exponent_le_half`, `gExp`, `gExp_strictMonoOn`, `warren_bound_le`: the
  exponent estimates of `app:counting`.
* `nearSet`, `card_nearSet_le`, `prob_nearSet_le`: the union bound over patterns and their
  Hamming balls.
* `rankPatterns`, `RestrictedPatternCount`, `sEta`, `maskEvent`, `mask_approx`: Lemma
  *Approximation on a random mask* (`lem:mask-approx`), with the count of Lemma *Restricted
  sign patterns* (`lem:mask`, `eq:maskcount`) as an explicit hypothesis.
* `sEta_ge`, `s0_ge`: `s_η ≥ c_η² N/128 - 1`, `s₀ ≥ N/128 - 1` (`app:counting`);
  `gRows`, `tEta`, `tEta_eq_sEta`, `tEta_ge`, `prior_prob_le`: `eq:prior-threshold` and the
  asymptotic estimates of `app:prior`.
* `chi`, `fixed_output_count`, `fixed_output_prob`: `eq:fixed-output`.

NOT formalized here: Warren's theorem and hence Lemma *Restricted sign patterns* (`lem:mask`),
which enters `mask_approx` only as the explicit hypothesis `RestrictedPatternCount`; Lemma
*Probabilistic reductions* (`lem:prob-reduction`) and Theorem *Dimension probabilities*
(`thm:dimensions`), since the probabilistic dimensions are not defined; the reduction from the
prior-average dimension to `eq:fixed-rowset` and the union bound `eq:prior-prob` of
Theorem *Dimension after discarding targets* (`thm:prior`); the `exp(-Ω(N⁴))` asymptotics;
Hoeffding's inequality and the remaining query lower-bound arguments of `app:query`.
Probabilities under independent fair signs are expressed as counts divided by `2^I`.
-/

noncomputable section
open scoped BigOperators
open Real

namespace SQDC.Counting

/-! ### Binary entropy in bits and `c_η` (`eq:seta`) -/

/-- `h₂(η) = -η log₂ η - (1-η) log₂(1-η)`. Mathlib's `Real.log 0 = 0` gives the
convention `0 log₂ 0 = 0`. -/
def h2 (η : ℝ) : ℝ := -η * Real.logb 2 η - (1 - η) * Real.logb 2 (1 - η)

/-- `h₂` is Mathlib's binary entropy (in nats) divided by `ln 2`. -/
theorem h2_eq_binEntropy (η : ℝ) : h2 η = Real.binEntropy η / Real.log 2 := by
  simp only [h2, Real.binEntropy, Real.logb, Real.log_inv]
  ring

theorem h2_zero : h2 0 = 0 := by simp [h2_eq_binEntropy]

/-- `c_η = 1 - h₂(η)` (`eq:seta`). -/
def cEta (η : ℝ) : ℝ := 1 - h2 η

theorem cEta_zero : cEta 0 = 1 := by simp [cEta, h2_zero]

theorem h2_nonneg {η : ℝ} (h0 : 0 ≤ η) (h1 : η ≤ 1) : 0 ≤ h2 η := by
  rw [h2_eq_binEntropy]
  exact div_nonneg (Real.binEntropy_nonneg h0 h1) (Real.log_nonneg (by norm_num))

theorem h2_lt_one {η : ℝ} (h : η ≠ 1 / 2) : h2 η < 1 := by
  rw [h2_eq_binEntropy, div_lt_one (Real.log_pos (by norm_num))]
  exact Real.binEntropy_lt_log_two.2 (by norm_num [h])

/-- `app:counting`: "Let `c = c_η ∈ (0,1]`" for `0 ≤ η < 1/2`. -/
theorem cEta_mem_Ioc {η : ℝ} (h0 : 0 ≤ η) (h1 : η < 1 / 2) : cEta η ∈ Set.Ioc 0 1 := by
  have hlt := h2_lt_one (η := η) (by linarith)
  have hnn := h2_nonneg h0 (by linarith)
  constructor <;> simp only [cEta] <;> linarith

/-! ### The Hamming-ball bound (`app:counting`) -/

section Hamming

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The sign vectors within Hamming distance `r` of `v`. -/
def hammingBall (v : ι → Bool) (r : ℝ) : Finset (ι → Bool) :=
  Finset.univ.filter fun u => (hammingDist u v : ℝ) ≤ r

/-- The product weight `∏ᵢ (η or 1-η)`, i.e. one term of the expansion of
`1 = (η + (1-η))^I`. -/
private def weight (η : ℝ) (v u : ι → Bool) : ℝ := ∏ i, if u i = v i then 1 - η else η

private theorem sum_weight (η : ℝ) (v : ι → Bool) : ∑ u, weight η v u = 1 := by
  unfold weight
  rw [← Fintype.prod_sum (fun i (b : Bool) => if b = v i then 1 - η else η)]
  refine Finset.prod_eq_one fun i _ => ?_
  cases h : v i <;> simp

omit [DecidableEq ι] in
private theorem weight_eq (η : ℝ) (v u : ι → Bool) :
    weight η v u = (1 - η) ^ (Fintype.card ι - hammingDist u v) * η ^ hammingDist u v := by
  unfold weight
  rw [Finset.prod_ite, Finset.prod_const, Finset.prod_const]
  have hsplit := Finset.card_filter_add_card_filter_not (s := (Finset.univ : Finset ι))
    (fun i => u i = v i)
  have hd : (Finset.univ.filter fun i => ¬ u i = v i).card = hammingDist u v := rfl
  rw [Finset.card_univ] at hsplit
  rw [hd]
  congr 2
  omega

/-- `app:counting`: "The number of sign vectors within Hamming distance `ηI` of a fixed
vector is at most `2^{h₂(η) I}`", for `0 ≤ η < 1/2` (here `I = |ι|`). The proof follows the
expansion of `1 = (η + (1-η))^I`; `η = 0` is the single-vector case. -/
theorem card_hammingBall_le {η : ℝ} (h0 : 0 ≤ η) (h1 : η < 1 / 2) (v : ι → Bool) :
    ((hammingBall v (η * Fintype.card ι)).card : ℝ) ≤ 2 ^ (h2 η * Fintype.card ι) := by
  rcases h0.eq_or_lt with rfl | hη
  · -- the ball of radius `0` is `{v}`
    rw [h2_zero, zero_mul, Real.rpow_zero]
    have hsub : hammingBall v 0 ⊆ {v} := by
      intro u hu
      simp only [hammingBall, Finset.mem_filter, Finset.mem_univ, true_and] at hu
      have : hammingDist u v = 0 := by exact_mod_cast le_antisymm hu (Nat.cast_nonneg _)
      exact Finset.mem_singleton.2 (hammingDist_eq_zero.1 this)
    have := Finset.card_le_card hsub
    rw [Finset.card_singleton] at this
    exact_mod_cast this
  · have hη1 : 0 < 1 - η := by linarith
    have hlog : Real.log η < Real.log (1 - η) := Real.log_lt_log hη (by linarith)
    have hpow : (0 : ℝ) < 2 ^ (-(h2 η * Fintype.card ι)) :=
      Real.rpow_pos_of_pos (by norm_num) _
    -- each term of weight `j ≤ ηI` is at least `η^{ηI} (1-η)^{(1-η)I} = 2^{-h₂(η) I}`
    have hterm : ∀ u ∈ hammingBall v (η * Fintype.card ι),
        2 ^ (-(h2 η * Fintype.card ι)) ≤ weight η v u := by
      intro u hu
      simp only [hammingBall, Finset.mem_filter, Finset.mem_univ, true_and] at hu
      have hdI : hammingDist u v ≤ Fintype.card ι := hammingDist_le_card_fintype
      have hw : 0 < weight η v u := by
        rw [weight_eq]; positivity
      rw [← Real.log_le_log_iff hpow hw, weight_eq, Real.log_mul (by positivity)
        (by positivity), Real.log_pow, Real.log_pow, Real.log_rpow (by norm_num),
        h2_eq_binEntropy, Real.binEntropy, Real.log_inv, Real.log_inv, Nat.cast_sub hdI]
      have hlog2 : Real.log 2 ≠ 0 := by positivity
      field_simp
      nlinarith [mul_nonneg (sub_nonneg.2 hu) (sub_nonneg.2 hlog.le)]
    have hcard := Finset.card_nsmul_le_sum _ _ _ hterm
    have hle : ∑ u ∈ hammingBall v (η * Fintype.card ι), weight η v u ≤ ∑ u, weight η v u :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) fun u _ _ => by
        rw [weight_eq]; positivity
    rw [sum_weight] at hle
    rw [nsmul_eq_mul] at hcard
    have hmul : (2 : ℝ) ^ (h2 η * Fintype.card ι) * 2 ^ (-(h2 η * Fintype.card ι)) = 1 := by
      rw [← Real.rpow_add (by norm_num), add_neg_cancel, Real.rpow_zero]
    nlinarith [Real.rpow_pos_of_pos (show (0 : ℝ) < 2 by norm_num) (h2 η * Fintype.card ι)]

/-- `app:counting`, Hamming-ball bound for `Fin I → Bool`. -/
theorem card_hammingBall_fin_le {η : ℝ} (h0 : 0 ≤ η) (h1 : η < 1 / 2) {I : ℕ}
    (v : Fin I → Bool) :
    ((hammingBall v (η * I)).card : ℝ) ≤ 2 ^ (h2 η * I) := by
  simpa using card_hammingBall_le h0 h1 v

end Hamming

/-! ### Exponent estimates (`app:counting`) -/

/-- For `x > 0`: `d/dx [x log₂(K/xⁿ)] = log₂(K/xⁿ) - n/ln 2`. -/
private theorem hasDerivAt_mul_logb {K : ℝ} (hK : 0 < K) (n : ℕ) {x : ℝ} (hx : 0 < x) :
    HasDerivAt (fun y => y * Real.logb 2 (K / y ^ n))
      (Real.logb 2 (K / x ^ n) - n / Real.log 2) x := by
  have heq : (fun y => y * Real.logb 2 (K / y ^ n)) =ᶠ[nhds x]
      (fun y => y * ((Real.log K - n * Real.log y) / Real.log 2)) := by
    filter_upwards [Ioi_mem_nhds hx] with y hy
    rw [Real.logb, Real.log_div hK.ne' (pow_ne_zero _ (ne_of_gt hy)), Real.log_pow]
  have hd := (hasDerivAt_id' x).mul (((hasDerivAt_const x (Real.log K)).sub
    ((Real.hasDerivAt_log hx.ne').const_mul (n : ℝ))).div_const (Real.log 2))
  refine (hd.congr_of_eventuallyEq heq).congr_deriv ?_
  have hlog2 : Real.log 2 ≠ 0 := by positivity
  simp only [Pi.sub_apply]
  rw [Real.logb, Real.log_div hK.ne' (pow_ne_zero _ hx.ne'), Real.log_pow]
  field_simp
  ring

/-- `f(c) = c log₂(256e/c²)` (`app:counting`). -/
def fExp (c : ℝ) : ℝ := c * Real.logb 2 (256 * exp 1 / c ^ 2)

/-- `app:counting`: "Its derivative is `f'(c) = log₂(256e/c²) - 2/ln 2`." -/
theorem hasDerivAt_fExp {c : ℝ} (hc : 0 < c) :
    HasDerivAt fExp (Real.logb 2 (256 * exp 1 / c ^ 2) - 2 / Real.log 2) c := by
  have := hasDerivAt_mul_logb (K := 256 * exp 1) (by positivity) 2 hc
  simp only [Nat.cast_ofNat] at this
  exact this

/-- `app:counting`: "`f'(c) = log₂(256e/c²) - 2/ln 2 > 0` (`0 < c ≤ 1`)." -/
theorem fExp_deriv_pos {c : ℝ} (hc0 : 0 < c) (hc1 : c ≤ 1) :
    0 < Real.logb 2 (256 * exp 1 / c ^ 2) - 2 / Real.log 2 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have he : exp 1 < 256 := by have := Real.exp_one_lt_d9; linarith
  have hc2 : 0 < c ^ 2 := by positivity
  have hc21 : c ^ 2 ≤ 1 := by nlinarith
  have hlt : 2 < Real.log (256 * exp 1 / c ^ 2) := by
    rw [Real.lt_log_iff_exp_lt (by positivity)]
    calc exp 2 = exp 1 * exp 1 := by rw [← Real.exp_add]; norm_num
      _ < 256 * exp 1 := by nlinarith [Real.exp_pos 1]
      _ ≤ 256 * exp 1 / c ^ 2 := le_div_self (by positivity) hc2 hc21
  rw [Real.logb, ← sub_div]
  exact div_pos (by linarith) hlog2

/-- `app:counting`: `f` is increasing on `(0, 1]`. -/
theorem fExp_strictMonoOn : StrictMonoOn fExp (Set.Ioc 0 1) := by
  refine strictMonoOn_of_deriv_pos (convex_Ioc 0 1)
    (fun c hc => (hasDerivAt_fExp hc.1).continuousAt.continuousWithinAt) fun c hc => ?_
  rw [interior_Ioc] at hc
  rw [(hasDerivAt_fExp hc.1).deriv]
  exact fExp_deriv_pos hc.1 hc.2.le

/-- `app:counting`: "`f(1) = log₂(256e) < 16`." -/
theorem fExp_one : fExp 1 = Real.logb 2 (256 * exp 1) := by simp [fExp]

/-- `app:counting`: "`log₂(256e) < 16`." -/
theorem logb_256e_lt : Real.logb 2 (256 * exp 1) < 16 := by
  have hlog2 : 0.6931471803 < Real.log 2 := Real.log_two_gt_d9
  have h256 : Real.log 256 = 8 * Real.log 2 := by
    rw [show (256 : ℝ) = 2 ^ 8 by norm_num, Real.log_pow]; norm_num
  rw [Real.logb, Real.log_mul (by norm_num) (Real.exp_pos 1).ne', Real.log_exp, h256,
    div_lt_iff₀ (by linarith)]
  linarith

/-- `app:counting`: "`(c²/32) log₂(256e/c²) ≤ c/2`" for `0 < c ≤ 1`. -/
theorem exponent_le_half {c : ℝ} (hc0 : 0 < c) (hc1 : c ≤ 1) :
    c ^ 2 / 32 * Real.logb 2 (256 * exp 1 / c ^ 2) ≤ c / 2 := by
  have hmono : fExp c ≤ fExp 1 :=
    fExp_strictMonoOn.monotoneOn ⟨hc0, hc1⟩ ⟨one_pos, le_rfl⟩ hc1
  rw [fExp_one] at hmono
  have h16 := logb_256e_lt
  have : c ^ 2 / 32 * Real.logb 2 (256 * exp 1 / c ^ 2) = c / 32 * fExp c := by
    simp only [fExp]; ring
  rw [this]
  have : c / 32 * fExp c ≤ c / 32 * 16 :=
    mul_le_mul_of_nonneg_left (by linarith) (by positivity)
  linarith

/-- `x log₂(8e/x)` (`app:counting`). -/
def gExp (x : ℝ) : ℝ := x * Real.logb 2 (8 * exp 1 / x)

/-- `app:counting`: "The function `x log₂(8e/x)` is increasing for `0 < x ≤ 1`." -/
theorem gExp_strictMonoOn : StrictMonoOn gExp (Set.Ioc 0 1) := by
  have hd : ∀ x : ℝ, 0 < x → HasDerivAt gExp (Real.logb 2 (8 * exp 1 / x) - 1 / Real.log 2) x :=
    fun x hx => by
      have := hasDerivAt_mul_logb (K := 8 * exp 1) (by positivity) 1 hx
      simp only [pow_one, Nat.cast_one] at this
      exact this
  refine strictMonoOn_of_deriv_pos (convex_Ioc 0 1)
    (fun x hx => (hd x hx.1).continuousAt.continuousWithinAt) fun x hx => ?_
  rw [interior_Ioc] at hx
  rw [(hd x hx.1).deriv]
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlt : 1 < Real.log (8 * exp 1 / x) := by
    rw [Real.lt_log_iff_exp_lt (by have := hx.1; positivity)]
    calc exp 1 < 8 * exp 1 := by linarith [Real.exp_pos 1]
      _ ≤ 8 * exp 1 / x := le_div_self (by positivity) hx.1 hx.2.le
  rw [Real.logb, ← sub_div]
  exact div_pos (by linarith) hlog2

/-- `app:counting`: with `c ∈ (0,1]`, `1 ≤ v ≤ (c²/32) I` gives `v ≤ I` ("as required by
Warren's theorem") and `(8eI/v)^v ≤ 2^{cI/2}`, i.e. `(1/I) log₂ (8eI/v)^v ≤ c/2`. -/
theorem warren_bound_le {c : ℝ} (hc0 : 0 < c) (hc1 : c ≤ 1) {v I : ℕ} (hv : 1 ≤ v)
    (hvI : (v : ℝ) ≤ c ^ 2 / 32 * I) :
    v ≤ I ∧ (8 * exp 1 * I / v) ^ v ≤ (2 : ℝ) ^ (c * I / 2) := by
  have hv' : (1 : ℝ) ≤ v := by exact_mod_cast hv
  have hc2 : c ^ 2 ≤ 1 := by nlinarith
  have hI : (0 : ℝ) < I := by
    by_contra h
    push Not at h
    have : c ^ 2 / 32 * (I : ℝ) ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos (by positivity) h
    linarith
  have hvI' : (v : ℝ) ≤ I := by nlinarith
  refine ⟨by exact_mod_cast hvI', ?_⟩
  set x : ℝ := v / I with hx
  have hx0 : 0 < x := by positivity
  have hxc : x ≤ c ^ 2 / 32 := by rw [hx, div_le_iff₀ hI]; exact hvI
  have hc32 : c ^ 2 / 32 ≤ 1 := by linarith
  have hg : gExp x ≤ gExp (c ^ 2 / 32) :=
    gExp_strictMonoOn.monotoneOn ⟨hx0, hxc.trans hc32⟩ ⟨by positivity, hc32⟩ hxc
  have hg' : gExp (c ^ 2 / 32) ≤ c / 2 := by
    have := exponent_le_half hc0 hc1
    have e : 8 * exp 1 / (c ^ 2 / 32) = 256 * exp 1 / c ^ 2 := by
      field_simp; ring
    simpa only [gExp, e] using this
  have hpos : 0 < 8 * exp 1 * I / v := by positivity
  have hrw : (8 * exp 1 * I / v) ^ v = (2 : ℝ) ^ (I * gExp x) := by
    have e1 : (I : ℝ) * gExp x = Real.logb 2 (8 * exp 1 * I / v) * v := by
      simp only [gExp, hx]
      have e2 : 8 * exp 1 / (v / I) = 8 * exp 1 * I / v := by
        field_simp
      rw [e2]
      field_simp
    rw [e1, Real.rpow_mul_natCast (by norm_num), Real.rpow_logb (by norm_num) (by norm_num) hpos]
  rw [hrw]
  apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
  have := mul_le_mul_of_nonneg_left (hg.trans hg') hI.le
  linarith

/-! ### The union bound of `lem:mask-approx` -/

section Union

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The sign vectors within Hamming distance `r` of some member of `P`. -/
def nearSet (P : Finset (ι → Bool)) (r : ℝ) : Finset (ι → Bool) :=
  Finset.univ.filter fun u => ∃ p ∈ P, (hammingDist u p : ℝ) ≤ r

/-- `app:counting`, proof of `lem:mask-approx`: "A union bound over the rank-`d` patterns
and their Hamming balls". If at most `2^{c_η I/2}` patterns are possible, at most
`2^I · 2^{-c_η I/2}` sign vectors lie within distance `ηI` of one of them (`I = |ι|`). -/
theorem card_nearSet_le {η : ℝ} (h0 : 0 ≤ η) (h1 : η < 1 / 2) (P : Finset (ι → Bool))
    (hP : (P.card : ℝ) ≤ 2 ^ (cEta η * Fintype.card ι / 2)) :
    ((nearSet P (η * Fintype.card ι)).card : ℝ) ≤
      2 ^ (Fintype.card ι : ℝ) * 2 ^ (-(cEta η * Fintype.card ι / 2)) := by
  have hsub : nearSet P (η * Fintype.card ι) ⊆
      P.biUnion fun p => hammingBall p (η * Fintype.card ι) := by
    intro u hu
    simp only [nearSet, Finset.mem_filter, Finset.mem_univ, true_and] at hu
    obtain ⟨p, hp, hd⟩ := hu
    exact Finset.mem_biUnion.2 ⟨p, hp, by simpa [hammingBall] using hd⟩
  have h1' : ((nearSet P (η * Fintype.card ι)).card : ℝ) ≤
      ∑ p ∈ P, ((hammingBall p (η * Fintype.card ι)).card : ℝ) := by
    exact_mod_cast (Finset.card_le_card hsub).trans Finset.card_biUnion_le
  have h2' : ∑ p ∈ P, ((hammingBall p (η * Fintype.card ι)).card : ℝ) ≤
      P.card * 2 ^ (h2 η * Fintype.card ι) := by
    rw [← nsmul_eq_mul, ← Finset.sum_const]
    exact Finset.sum_le_sum fun p _ => card_hammingBall_le h0 h1 p
  have hexp : (2 : ℝ) ^ (cEta η * Fintype.card ι / 2) * 2 ^ (h2 η * Fintype.card ι) =
      2 ^ (Fintype.card ι : ℝ) * 2 ^ (-(cEta η * Fintype.card ι / 2)) := by
    rw [← Real.rpow_add (by norm_num), ← Real.rpow_add (by norm_num), cEta]
    ring_nf
  have h3' : (P.card : ℝ) * 2 ^ (h2 η * Fintype.card ι) ≤
      2 ^ (cEta η * Fintype.card ι / 2) * 2 ^ (h2 η * Fintype.card ι) :=
    mul_le_mul_of_nonneg_right hP (by positivity)
  linarith

/-- The same bound as a probability under uniformly random signs:
`Pr ≤ 2^{-c_η I/2}`. -/
theorem prob_nearSet_le {η : ℝ} (h0 : 0 ≤ η) (h1 : η < 1 / 2) (P : Finset (ι → Bool))
    (hP : (P.card : ℝ) ≤ 2 ^ (cEta η * Fintype.card ι / 2)) :
    ((nearSet P (η * Fintype.card ι)).card : ℝ) / Fintype.card (ι → Bool) ≤
      2 ^ (-(cEta η * Fintype.card ι / 2)) := by
  have hcard : (Fintype.card (ι → Bool) : ℝ) = 2 ^ (Fintype.card ι : ℝ) := by
    rw [Fintype.card_fun, Fintype.card_bool, Real.rpow_natCast]
    norm_num
  rw [hcard, div_le_iff₀ (by positivity)]
  exact (card_nearSet_le h0 h1 P hP).trans_eq (mul_comm _ _)

end Union

/-! ### Lemma *Approximation on a random mask* (`lem:mask-approx`), given Warren's count -/

section Mask

variable {m n : Type*} [Fintype m] [Fintype n] [DecidableEq m] [DecidableEq n]

/-- `M` is strict on `J`: no entry indexed by `J` vanishes. -/
def StrictOn (J : Finset (m × n)) (M : Matrix m n ℝ) : Prop := ∀ e ∈ J, M e.1 e.2 ≠ 0

/-- The sign pattern of `M` on `J` (`true` for a positive entry). -/
def signsOn (J : Finset (m × n)) (M : Matrix m n ℝ) : J → Bool :=
  fun e => decide (0 < M e.1.1 e.1.2)

open Classical in
/-- The strict sign patterns on `J` produced by real matrices of rank at most `d`. -/
def rankPatterns (J : Finset (m × n)) (d : ℕ) : Finset (J → Bool) :=
  Finset.univ.filter fun σ => ∃ M : Matrix m n ℝ, M.rank ≤ d ∧ StrictOn J M ∧ signsOn J M = σ

/-- Lemma *Restricted sign patterns* (`lem:mask`, `eq:maskcount`) for a `K × Q` matrix and
the mask `J` of `s = |J|` entries: for `v = (K+Q)d` with `1 ≤ v ≤ s`, at most `(8es/v)^v`
strict patterns. This is Warren's theorem applied to a factorization; it is an external
input, NOT proved here, and is used only as an explicit hypothesis. -/
def RestrictedPatternCount (J : Finset (m × n)) (d : ℕ) : Prop :=
  1 ≤ (Fintype.card m + Fintype.card n) * d →
    (Fintype.card m + Fintype.card n) * d ≤ J.card →
      ((rankPatterns J d).card : ℝ) ≤
        (8 * exp 1 * J.card / ((Fintype.card m + Fintype.card n) * d : ℕ)) ^
          ((Fintype.card m + Fintype.card n) * d)

/-- `s_η = ⌊c_η² I / (32(K+Q))⌋` (`eq:seta`, `lem:mask-approx`). -/
def sEta (η : ℝ) (I K Q : ℕ) : ℕ := ⌊cEta η ^ 2 * I / (32 * (K + Q))⌋₊

open Classical in
/-- The event of `lem:mask-approx` for signs `σ` on `J`: some real matrix of rank at most
`d`, strict on `J`, disagrees with at most `ηI` of the signs. -/
def maskEvent (J : Finset (m × n)) (η : ℝ) (d : ℕ) : Finset (J → Bool) :=
  Finset.univ.filter fun σ => ∃ M : Matrix m n ℝ, M.rank ≤ d ∧ StrictOn J M ∧
    (hammingDist (signsOn J M) σ : ℝ) ≤ η * J.card

omit [Fintype m] [DecidableEq m] in
/-- A matrix of rank zero vanishes. -/
private theorem entry_eq_zero_of_rank_le_zero {M : Matrix m n ℝ} (h : M.rank ≤ 0) (i : m)
    (j : n) : M i j = 0 := by
  have h0 : Module.finrank ℝ (LinearMap.range M.mulVecLin) = 0 := Nat.le_zero.1 h
  have hbot : LinearMap.range M.mulVecLin = ⊥ := Submodule.finrank_eq_zero.1 h0
  have hmem : M.mulVecLin (Pi.single j 1) ∈ LinearMap.range M.mulVecLin :=
    LinearMap.mem_range_self _ _
  rw [hbot, Submodule.mem_bot, Matrix.mulVecLin_apply, Matrix.mulVec_single_one] at hmem
  simpa using congrFun hmem i

/-- Lemma *Approximation on a random mask* (`lem:mask-approx`), conditional on the count of
Lemma *Restricted sign patterns* (`lem:mask`) at `d = s_η`: for `0 ≤ η < 1/2` and `I = |J| > 0`,
the probability over independent fair signs on `J` that some real matrix of rank at most `s_η`,
strict on `J`, disagrees with at most `ηI` signs is at most `2^{-c_η I/2}`. -/
theorem mask_approx {η : ℝ} (h0 : 0 ≤ η) (h1 : η < 1 / 2) (J : Finset (m × n))
    (hI : 0 < J.card)
    (hW : RestrictedPatternCount J (sEta η J.card (Fintype.card m) (Fintype.card n))) :
    ((maskEvent J η (sEta η J.card (Fintype.card m) (Fintype.card n))).card : ℝ) /
      2 ^ J.card ≤ 2 ^ (-(cEta η * J.card / 2)) := by
  set d := sEta η J.card (Fintype.card m) (Fintype.card n) with hd
  set c := cEta η
  have hc := cEta_mem_Ioc h0 h1
  have hJne : J.Nonempty := Finset.card_pos.1 hI
  have hpow : (2 : ℝ) ^ J.card = Fintype.card (J → Bool) := by
    rw [Fintype.card_fun, Fintype.card_bool, Fintype.card_coe]; norm_num
  rcases Nat.eq_zero_or_pos d with hd0 | hdpos
  · -- "If `s_η = 0`, no rank-zero matrix is strict on a nonempty set of entries."
    have hempty : maskEvent J η d = ∅ := by
      rw [hd0]
      ext σ
      simp only [maskEvent, Finset.mem_filter, Finset.mem_univ, true_and,
        Finset.notMem_empty, iff_false]
      rintro ⟨M, hM, hstrict, -⟩
      obtain ⟨e, he⟩ := hJne
      exact hstrict e he (entry_eq_zero_of_rank_le_zero hM e.1 e.2)
    rw [hempty, Finset.card_empty, Nat.cast_zero, zero_div]
    positivity
  · -- `d = s_η ≥ 1`
    obtain ⟨⟨i₀, j₀⟩, -⟩ := hJne
    have hKQ : 0 < Fintype.card m + Fintype.card n :=
      Nat.add_pos_left (Fintype.card_pos_iff.2 ⟨i₀⟩) _
    set v := (Fintype.card m + Fintype.card n) * d with hv
    have hv1 : 1 ≤ v := Nat.one_le_iff_ne_zero.2 (Nat.mul_ne_zero hKQ.ne' hdpos.ne')
    have hvI : (v : ℝ) ≤ c ^ 2 / 32 * J.card := by
      have hfl : (d : ℝ) ≤ c ^ 2 * J.card / (32 * (Fintype.card m + Fintype.card n)) :=
        Nat.floor_le (by positivity)
      have hKQ' : (0 : ℝ) < Fintype.card m + Fintype.card n := by exact_mod_cast hKQ
      rw [le_div_iff₀ (by positivity)] at hfl
      rw [hv]
      push_cast
      nlinarith
    obtain ⟨hvle, hbound⟩ := warren_bound_le hc.1 hc.2 hv1 hvI
    have hP : ((rankPatterns J d).card : ℝ) ≤ 2 ^ (c * Fintype.card J / 2) := by
      rw [Fintype.card_coe]
      exact (hW hv1 hvle).trans hbound
    have hsub : maskEvent J η d ⊆ nearSet (rankPatterns J d) (η * Fintype.card J) := by
      intro σ hσ
      simp only [maskEvent, Finset.mem_filter, Finset.mem_univ, true_and] at hσ
      obtain ⟨M, hM, hstrict, hdist⟩ := hσ
      simp only [nearSet, Finset.mem_filter, Finset.mem_univ, true_and]
      refine ⟨signsOn J M, ?_, ?_⟩
      · simp only [rankPatterns, Finset.mem_filter, Finset.mem_univ, true_and]
        exact ⟨M, hM, hstrict, rfl⟩
      · rw [hammingDist_comm, Fintype.card_coe]
        exact hdist
    have hprob := prob_nearSet_le h0 h1 (rankPatterns J d) hP
    rw [Fintype.card_coe] at hprob
    rw [hpow]
    calc ((maskEvent J η d).card : ℝ) / Fintype.card (J → Bool)
        ≤ ((nearSet (rankPatterns J d) (η * J.card)).card : ℝ) / Fintype.card (J → Bool) := by
          have := Finset.card_le_card hsub
          rw [Fintype.card_coe] at this
          exact div_le_div_of_nonneg_right (by exact_mod_cast this) (by positivity)
      _ ≤ 2 ^ (-(c * J.card / 2)) := hprob

end Mask

/-! ### Thresholds (`app:counting`, `app:prior`) -/

/-- `app:counting`: "Since `I ≥ N⁴` and `K+Q = 4N³`, the thresholds satisfy
`s_η ≥ c_η² N/128 - 1`." -/
theorem sEta_ge (η : ℝ) {N I K Q : ℕ} (hI : N ^ 4 ≤ I) (hKQ : K + Q = 4 * N ^ 3) :
    cEta η ^ 2 * N / 128 - 1 ≤ (sEta η I K Q : ℝ) := by
  unfold sEta
  have hfl := Nat.lt_floor_add_one (cEta η ^ 2 * I / (32 * ((K : ℝ) + Q)))
  have hKQ' : (K : ℝ) + Q = 4 * (N : ℝ) ^ 3 := by exact_mod_cast hKQ
  have hI' : (N : ℝ) ^ 4 ≤ I := by exact_mod_cast hI
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · simp only [CharP.cast_eq_zero, mul_zero, zero_div, zero_sub]
    linarith [Nat.cast_nonneg (α := ℝ) (Nat.floor (cEta η ^ 2 * I / (32 * ((K : ℝ) + Q))))]
  · have hN' : (0 : ℝ) < N := by exact_mod_cast hN
    have hX : cEta η ^ 2 * N / 128 ≤ cEta η ^ 2 * I / (32 * ((K : ℝ) + Q)) := by
      rw [hKQ', div_le_div_iff₀ (by norm_num) (by positivity)]
      have : cEta η ^ 2 * (N : ℝ) ^ 4 ≤ cEta η ^ 2 * I :=
        mul_le_mul_of_nonneg_left hI' (sq_nonneg _)
      nlinarith [sq_nonneg (cEta η)]
    linarith

/-- `app:counting`: "`s₀ ≥ N/128 - 1`." -/
theorem s0_ge {N I K Q : ℕ} (hI : N ^ 4 ≤ I) (hKQ : K + Q = 4 * N ^ 3) :
    (N : ℝ) / 128 - 1 ≤ (sEta 0 I K Q : ℝ) := by
  simpa [cEta_zero] using sEta_ge 0 hI hKQ

/-- `g = ⌈(1-δ)L⌉` with `L = |𝓛₀| = N³` (`eq:prior-threshold`). -/
def gRows (δ : ℝ) (N : ℕ) : ℕ := ⌈(1 - δ) * ((N ^ 3 : ℕ) : ℝ)⌉₊

/-- `t_{η,δ} = ⌊c_η² g N / (32(g+Q))⌋` with `Q = 2N³` (`eq:prior-threshold`). -/
def tEta (η δ : ℝ) (N : ℕ) : ℕ :=
  ⌊cEta η ^ 2 * gRows δ N * N / (32 * (gRows δ N + 2 * (N : ℝ) ^ 3))⌋₊

/-- `app:prior`: `t_{η,δ}` is `s_η` of `lem:mask-approx` with `g` rows, `Q = 2N³` columns
and `gN` tested entries. -/
theorem tEta_eq_sEta (η δ : ℝ) (N : ℕ) :
    tEta η δ N = sEta η (gRows δ N * N) (gRows δ N) (2 * N ^ 3) := by
  simp only [tEta, sEta]
  push_cast
  ring_nf

theorem gRows_le {δ : ℝ} (hδ0 : 0 ≤ δ) (N : ℕ) : gRows δ N ≤ N ^ 3 := by
  unfold gRows
  rw [Nat.ceil_le]
  have : (0 : ℝ) ≤ ((N ^ 3 : ℕ) : ℝ) := Nat.cast_nonneg _
  nlinarith

theorem le_gRows (δ : ℝ) (N : ℕ) : (1 - δ) * (N : ℝ) ^ 3 ≤ gRows δ N := by
  have := Nat.le_ceil ((1 - δ) * ((N ^ 3 : ℕ) : ℝ))
  unfold gRows
  push_cast at this ⊢
  exact this

/-- `app:prior`: "`Q = 2N³`, `g ≥ (1-δ)N³`, and `g + Q ≤ 3N³`. Hence
`t_{η,δ} ≥ c_η²(1-δ)N/96 - 1`." -/
theorem tEta_ge (η : ℝ) {δ : ℝ} (hδ0 : 0 ≤ δ) (hδ1 : δ < 1) (N : ℕ) :
    cEta η ^ 2 * (1 - δ) * N / 96 - 1 ≤ (tEta η δ N : ℝ) := by
  unfold tEta
  set g := gRows δ N
  have hfl := Nat.lt_floor_add_one
    (cEta η ^ 2 * g * N / (32 * (g + 2 * (N : ℝ) ^ 3)))
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · simp only [CharP.cast_eq_zero, mul_zero, zero_div, zero_sub]
    linarith [Nat.cast_nonneg (α := ℝ)
      (Nat.floor (cEta η ^ 2 * g * ((0 : ℕ) : ℝ) / (32 * (g + 2 * ((0 : ℕ) : ℝ) ^ 3))))]
  · have hN' : (0 : ℝ) < N := by exact_mod_cast hN
    have hg1 : (1 - δ) * (N : ℝ) ^ 3 ≤ g := le_gRows δ N
    have hg2 : (g : ℝ) ≤ (N : ℝ) ^ 3 := by exact_mod_cast gRows_le hδ0 N
    have hg0 : (0 : ℝ) ≤ g := Nat.cast_nonneg _
    have hc2 : 0 ≤ cEta η ^ 2 := sq_nonneg _
    have hX : cEta η ^ 2 * (1 - δ) * N / 96 ≤
        cEta η ^ 2 * g * N / (32 * (g + 2 * (N : ℝ) ^ 3)) := by
      rw [div_le_div_iff₀ (by norm_num) (by positivity)]
      have h1 : cEta η ^ 2 * (1 - δ) * N * (32 * (g + 2 * (N : ℝ) ^ 3)) ≤
          cEta η ^ 2 * (1 - δ) * N * (96 * (N : ℝ) ^ 3) :=
        mul_le_mul_of_nonneg_left (by linarith)
          (mul_nonneg (mul_nonneg hc2 (by linarith)) hN'.le)
      have h2 : cEta η ^ 2 * (1 - δ) * N * (96 * (N : ℝ) ^ 3) ≤ cEta η ^ 2 * g * N * 96 := by
        have := mul_le_mul_of_nonneg_left hg1 (mul_nonneg hc2 hN'.le)
        nlinarith
      linarith
    linarith

/-- `app:prior`: "`C(L,g) ≤ 2^L`, so the right side of `eq:prior-prob` is at most
`2^{N³ - c_η(1-δ)N⁴/2}`" (any `c ≥ 0`, in particular `c = c_η`). -/
theorem prior_prob_le {c δ : ℝ} (hc : 0 ≤ c) (N : ℕ) :
    ((N ^ 3).choose (gRows δ N) : ℝ) * 2 ^ (-(c * gRows δ N * N / 2)) ≤
      2 ^ ((N : ℝ) ^ 3 - c * (1 - δ) * (N : ℝ) ^ 4 / 2) := by
  have hch : ((N ^ 3).choose (gRows δ N) : ℝ) ≤ 2 ^ ((N : ℝ) ^ 3) := by
    have := Nat.choose_le_two_pow (N ^ 3) (gRows δ N)
    have h : ((N ^ 3).choose (gRows δ N) : ℝ) ≤ ((2 ^ (N ^ 3) : ℕ) : ℝ) := by exact_mod_cast this
    rw [show ((N : ℝ) ^ 3) = ((N ^ 3 : ℕ) : ℝ) by push_cast; ring, Real.rpow_natCast]
    exact_mod_cast h
  have hexp : (2 : ℝ) ^ (-(c * gRows δ N * N / 2)) ≤ 2 ^ (-(c * (1 - δ) * (N : ℝ) ^ 4 / 2)) := by
    apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
    have hg := le_gRows δ N
    have : c * ((1 - δ) * (N : ℝ) ^ 3) * N ≤ c * gRows δ N * N :=
      mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hg hc) (Nat.cast_nonneg _)
    nlinarith
  calc ((N ^ 3).choose (gRows δ N) : ℝ) * 2 ^ (-(c * gRows δ N * N / 2))
      ≤ 2 ^ ((N : ℝ) ^ 3) * 2 ^ (-(c * (1 - δ) * (N : ℝ) ^ 4 / 2)) :=
        mul_le_mul hch hexp (by positivity) (by positivity)
    _ = 2 ^ ((N : ℝ) ^ 3 - c * (1 - δ) * (N : ℝ) ^ 4 / 2) := by
        rw [← Real.rpow_add (by norm_num)]
        ring_nf

/-! ### A fixed output on one line (`app:query`, `eq:fixed-output`) -/

/-- `χ = 1 - h₂(3/8)`. -/
def chi : ℝ := cEta (3 / 8)

theorem chi_pos : 0 < chi := (cEta_mem_Ioc (by norm_num) (by norm_num)).1

/-- `app:query`, `eq:fixed-output`, counting form: at most `2^{h₂(3/8) N}` sign vectors on
the `N` incidences of a line make a fixed predictor wrong on at most `3N/8` of them (error at
most `3/8` under the uniform distribution on the line). -/
theorem fixed_output_count (N : ℕ) (v : Fin N → Bool) :
    ((hammingBall v (3 / 8 * N)).card : ℝ) ≤ 2 ^ (h2 (3 / 8) * N) :=
  card_hammingBall_fin_le (by norm_num) (by norm_num) v

/-- `app:query`, `eq:fixed-output`: `Pr_A[err ≤ 3/8] ≤ 2^{-χN}` under independent fair signs. -/
theorem fixed_output_prob (N : ℕ) (v : Fin N → Bool) :
    ((hammingBall v (3 / 8 * N)).card : ℝ) / Fintype.card (Fin N → Bool) ≤ 2 ^ (-(chi * N)) := by
  have hcard : (Fintype.card (Fin N → Bool) : ℝ) = 2 ^ (N : ℝ) := by
    rw [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin, Real.rpow_natCast]
    norm_num
  rw [hcard, div_le_iff₀ (by positivity), ← Real.rpow_add (by norm_num), chi, cEta]
  have := fixed_output_count N v
  convert this using 2
  ring

end SQDC.Counting
