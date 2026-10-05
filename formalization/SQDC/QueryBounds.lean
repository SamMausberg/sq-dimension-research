import SQDC.Basic
import Mathlib.Algebra.Order.Ring.Star
import Mathlib.Algebra.Order.Star.Real
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.SpecialFunctions.Log.Base
import Mathlib.MeasureTheory.Integral.Bochner.Set

/-!
# Query lower bounds: rounding, leaf counting and the final arithmetic

Correspondence with Theorem *Query lower bounds* (`thm:querylower`), its proof in
Appendix `app:query` ("Query lower bounds and transcript embeddings"), and the answer
alphabet `B_τ = ⌈1/τ⌉` shared with Proposition *Transcript representations*
(`prop:transcript`):

* `alphabetSize`, `two_le_alphabetSize`, `inv_alphabetSize_le`: `B_τ = ⌈1/τ⌉`, with
  `B_τ ≥ 2` and `1/B_τ ≤ τ` for `0 < τ < 1`.
* `cellIndex`, `roundToMidpoint`, `abs_roundToMidpoint_sub_le`, `roundedOracle_valid`:
  "Partition `[-1,1]` into `B_τ` intervals of equal length, assigning boundary points
  consistently. Answer a query by the midpoint of the interval containing its exact
  expectation. The error is at most `1/B_τ ≤ τ`, so this defines a valid deterministic
  oracle on every instance."
* `leafPredictors`, `card_leafPredictors_le`, `runTree_mem_leafPredictors`,
  `rounded_run_mem_leafPredictors`: "Its response tree has depth at most `m` and
  branching factor at most `B_τ`, hence at most `B_τ^m` leaves."
* `log_rows_le`, `union_bound_exponent`, `choose_le_two_rpow`, `union_bound_chain`:
  the exponent arithmetic `2^Q C(L,s) 2^{-χNs} ≤ 2^{Q+s log₂L-χNs} ≤ 2^{Q-χNs/2}
  ≤ 2^{-2N³}` with `Q = 2N³`, `L = N³`, `s = ⌈8N²/χ⌉`.
* `prob_le_ge_one_sub_div`, `markov_three_eighths`, `markov_one_third`: the Markov
  steps "probability at least `1-8ε/3` of error at most `3/8`" and its proper
  analogue `1-3ε` at threshold `1/3`, for an arbitrary seed law (Mathlib's Markov
  inequality, using the integrability built into `RandomizedLearns`).
* `lowerimproper_of_count`, `lowerproper_of_count`: "Taking logarithms proves"
  `eq:lowerimproper` and `eq:lowerproper` from `N³(1-8ε/3) ≤ B_τ^m·8N²/χ` and
  `N³(1-3ε) ≤ B_τ^m`.
* `outputs_count_improper`, `outputs_count_proper`: the averaging step "Average the
  preceding coverage bound over seeds and sum these success probabilities over the
  `N³` targets", from a coverage hypothesis on the table to the two counting
  inequalities, for an arbitrary randomized learner in the sense of
  `RandomizedLearns`.
* `querylower_improper`, `querylower_proper`: `eq:lowerimproper` and `eq:lowerproper`
  for every randomized learner, on any table satisfying the two coverage events.

The constant `χ = 1 - h₂(3/8)` of the paper is replaced by an arbitrary `χ > 0`; the
arithmetic uses nothing else about it.

The two table events ("every predictor is good on fewer than `8N²/χ` rows", weakened
here to "at most `8N²/χ`"; "every proper predictor has error at most `1/3` on at most
one full-line instance") enter `outputs_count_improper`, `outputs_count_proper`,
`querylower_improper` and `querylower_proper` as explicit hypotheses. For incidence flips
the proper event is derived in `SQDC/IncidenceConsequences.lean` from
`Incidence.proper_fits_at_most_one`, given the Hoeffding event; the counting form of the
Hamming-ball bound `eq:fixed-output` is `Counting.fixed_output_count`.

Not formalized: the probability over the random table `A`, namely the union bound over
predictors and row sets itself (only its exponent arithmetic is formalized here) and the
Hoeffding bound for at least `3N/8` negative entries per full row. The transcript
representations of `prop:transcript` are not formalized beyond the shared alphabet and
leaf count.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace SQDC.QueryBounds

variable {X : Type*} [Fintype X]

/-! ### The midpoint alphabet -/

/-- The alphabet size `B_τ = ⌈1/τ⌉`. -/
def alphabetSize (τ : ℝ) : ℕ := ⌈1 / τ⌉₊

/-- For `0 < τ < 1`, `B_τ ≥ 2`. -/
theorem two_le_alphabetSize {τ : ℝ} (h0 : 0 < τ) (h1 : τ < 1) : 2 ≤ alphabetSize τ := by
  have : (1 : ℝ) < 1 / τ := by rw [lt_div_iff₀ h0]; linarith
  exact Nat.lt_ceil.mpr (by exact_mod_cast this)

theorem one_div_le_alphabetSize (τ : ℝ) : 1 / τ ≤ alphabetSize τ := Nat.le_ceil _

theorem alphabetSize_pos {τ : ℝ} (h0 : 0 < τ) : 0 < alphabetSize τ :=
  Nat.cast_pos.mp (lt_of_lt_of_le (by positivity) (one_div_le_alphabetSize τ))

/-- `1/B_τ ≤ τ`. -/
theorem inv_alphabetSize_le {τ : ℝ} (h0 : 0 < τ) : 1 / (alphabetSize τ : ℝ) ≤ τ := by
  have hB := one_div_le_alphabetSize τ
  have hBpos : (0 : ℝ) < alphabetSize τ := by exact_mod_cast alphabetSize_pos h0
  rw [div_le_iff₀ hBpos]
  rw [div_le_iff₀ h0] at hB
  linarith

/-- The index of the interval of `[-1,1]` containing `y`, for the partition into
`B` intervals of length `2/B`. Interval `k < B - 1` is `[-1 + 2k/B, -1 + 2(k+1)/B)`;
the last interval also contains its right endpoint `1`. -/
def cellIndex (B : ℕ) (y : ℝ) : ℕ := min ⌊(y + 1) * B / 2⌋₊ (B - 1)

/-- The midpoint `-1 + (2k+1)/B` of interval `k`. -/
def cellMidpoint (B k : ℕ) : ℝ := -1 + (2 * k + 1) / B

/-- Midpoint rounding. -/
def roundToMidpoint (B : ℕ) (y : ℝ) : ℝ := cellMidpoint B (cellIndex B y)

/-- The `B` midpoints. -/
def midpointAlphabet (B : ℕ) : Finset ℝ := (Finset.range B).image (cellMidpoint B)

theorem card_midpointAlphabet_le (B : ℕ) : (midpointAlphabet B).card ≤ B :=
  Finset.card_image_le.trans (Finset.card_range B).le

theorem cellIndex_lt {B : ℕ} (hB : 1 ≤ B) (y : ℝ) : cellIndex B y < B :=
  lt_of_le_of_lt (min_le_right _ _) (by omega)

theorem roundToMidpoint_mem {B : ℕ} (hB : 1 ≤ B) (y : ℝ) :
    roundToMidpoint B y ∈ midpointAlphabet B :=
  Finset.mem_image.mpr ⟨cellIndex B y, Finset.mem_range.mpr (cellIndex_lt hB y), rfl⟩

/-- The boundaries are assigned consistently: `y ∈ [-1,1]` lies in the closed interval
of its cell, and strictly below the right endpoint unless the cell is the last one. -/
theorem cellIndex_spec {B : ℕ} (hB : 1 ≤ B) {y : ℝ} (hy : |y| ≤ 1) :
    -1 + 2 * (cellIndex B y : ℝ) / B ≤ y ∧ y ≤ -1 + 2 * ((cellIndex B y : ℝ) + 1) / B ∧
      (cellIndex B y < B - 1 → y < -1 + 2 * ((cellIndex B y : ℝ) + 1) / B) := by
  obtain ⟨hy1, hy2⟩ := abs_le.mp hy
  have hBr : (1 : ℝ) ≤ B := by exact_mod_cast hB
  have hBpos : (0 : ℝ) < B := by linarith
  set t : ℝ := (y + 1) * B / 2 with ht
  have ht0 : 0 ≤ t := by rw [ht]; have : 0 ≤ y + 1 := by linarith
                         positivity
  have htB : t ≤ B := by rw [ht]; nlinarith
  have hfl := Nat.floor_le ht0
  have hfl' := Nat.lt_floor_add_one t
  -- `y = -1 + 2t/B`
  have hyt : y = -1 + 2 * t / B := by rw [ht]; field_simp; ring
  have key : (cellIndex B y : ℝ) ≤ t ∧ t ≤ (cellIndex B y : ℝ) + 1 ∧
      (cellIndex B y < B - 1 → t < (cellIndex B y : ℝ) + 1) := by
    unfold cellIndex
    rcases le_total ⌊(y + 1) * B / 2⌋₊ (B - 1) with h | h
    · rw [min_eq_left h]
      exact ⟨hfl, hfl'.le, fun _ => hfl'⟩
    · rw [min_eq_right h]
      have hcast : ((B - 1 : ℕ) : ℝ) = (B : ℝ) - 1 := by
        rw [Nat.cast_sub hB]; simp
      rw [hcast]
      have h' : ((B - 1 : ℕ) : ℝ) ≤ ⌊t⌋₊ := by exact_mod_cast h
      rw [hcast] at h'
      refine ⟨by linarith, by linarith, fun hlt => absurd hlt (lt_irrefl _)⟩
  obtain ⟨k1, k2, k3⟩ := key
  refine ⟨?_, ?_, fun hlt => ?_⟩
  · have := div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left k1
      (by norm_num : (0:ℝ) ≤ 2)) hBpos.le; linarith
  · have := div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left k2
      (by norm_num : (0:ℝ) ≤ 2)) hBpos.le; linarith
  · have := div_lt_div_of_pos_right (mul_lt_mul_of_pos_left (k3 hlt)
      (by norm_num : (0:ℝ) < 2)) hBpos; linarith

/-- Midpoint rounding has error at most `1/B` on `[-1,1]`. -/
theorem abs_roundToMidpoint_sub_le {B : ℕ} (hB : 1 ≤ B) {y : ℝ} (hy : |y| ≤ 1) :
    |roundToMidpoint B y - y| ≤ 1 / B := by
  obtain ⟨h1, h2, -⟩ := cellIndex_spec hB hy
  have hBpos : (0 : ℝ) < B := by exact_mod_cast hB
  unfold roundToMidpoint cellMidpoint
  set k : ℝ := (cellIndex B y : ℝ)
  have e1 : -1 + 2 * k / B = -1 + (2 * k + 1) / B - 1 / B := by field_simp; ring
  have e2 : -1 + 2 * (k + 1) / B = -1 + (2 * k + 1) / B + 1 / B := by field_simp; ring
  rw [abs_le]
  constructor <;> linarith

/-- Every statistical-query mean lies in `[-1,1]`. -/
theorem abs_queryMean_le_one (D : FinDist X) (h : Hyp X) (q : SQQuery X) :
    |queryMean D h q| ≤ 1 := by
  unfold queryMean expectation
  calc |∑ x, D.mass x * q.value x (h x)|
      ≤ ∑ x, |D.mass x * q.value x (h x)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ x, D.mass x := by
        refine Finset.sum_le_sum fun x _ => ?_
        rw [abs_mul, abs_of_nonneg (D.nonneg x)]
        exact mul_le_of_le_one_right (D.nonneg x) (q.bounded x (h x))
    _ = 1 := D.total

/-- The deterministic oracle answering every query by midpoint rounding of its exact
mean. -/
def roundedOracle (D : FinDist X) (h : Hyp X) (B : ℕ) : Oracle X :=
  fun _ q => roundToMidpoint B (queryMean D h q)

/-- "The error is at most `1/B_τ ≤ τ`, so this defines a valid deterministic oracle on
every instance." -/
theorem roundedOracle_valid {τ : ℝ} (h0 : 0 < τ) (D : FinDist X) (h : Hyp X) :
    ValidOracle D h τ (roundedOracle D h (alphabetSize τ)) := by
  intro hist q
  exact (abs_roundToMidpoint_sub_le (alphabetSize_pos h0) (abs_queryMean_le_one D h q)).trans
    (inv_alphabetSize_le h0)

theorem roundedOracle_mem {B : ℕ} (hB : 1 ≤ B) (D : FinDist X) (h : Hyp X)
    (hist : History X) (q : SQQuery X) :
    roundedOracle D h B hist q ∈ midpointAlphabet B :=
  roundToMidpoint_mem hB _

/-! ### Leaves of a response tree over a finite alphabet -/

/-- The leaf predictors of a depth-`m` tree whose answers range over `A`. -/
def leafPredictors (A : Finset ℝ) : {m : ℕ} → SQTree X m → Finset (Hyp X)
  | 0, .leaf g => {g}
  | _ + 1, .node _ next => A.biUnion fun a => leafPredictors A (next a)

/-- A depth-`m` tree answered from an alphabet of size `|A|` has at most `|A|^m` leaf
predictors. -/
theorem card_leafPredictors_le (A : Finset ℝ) :
    ∀ {m : ℕ} (t : SQTree X m), (leafPredictors A t).card ≤ A.card ^ m
  | 0, .leaf g => by simp [leafPredictors]
  | m + 1, .node q next => by
      simp only [leafPredictors]
      calc (A.biUnion fun a => leafPredictors A (next a)).card
          ≤ ∑ a ∈ A, (leafPredictors A (next a)).card := Finset.card_biUnion_le
        _ ≤ ∑ _a ∈ A, A.card ^ m :=
            Finset.sum_le_sum fun a _ => card_leafPredictors_le A (next a)
        _ = A.card ^ (m + 1) := by rw [Finset.sum_const, smul_eq_mul, pow_succ, mul_comm]

/-- A run against an oracle whose answers lie in `A` ends at one of the leaf
predictors. -/
theorem runTree_mem_leafPredictors (A : Finset ℝ) (O : Oracle X)
    (hO : ∀ hist q, O hist q ∈ A) :
    ∀ {m : ℕ} (t : SQTree X m) (hist : History X), runTree t O hist ∈ leafPredictors A t
  | 0, .leaf g, hist => by simp [runTree, leafPredictors]
  | m + 1, .node q next, hist => by
      simp only [runTree, leafPredictors]
      exact Finset.mem_biUnion.mpr
        ⟨O hist q, hO hist q, runTree_mem_leafPredictors A O hO (next _) _⟩

/-- "Its response tree has depth at most `m` and branching factor at most `B_τ`, hence
at most `B_τ^m` leaves": for a fixed tree (a fixed seed), one set of at most `B_τ^m`
predictors, independent of the instance, contains the output of the run against the
rounded oracle of every instance `(D,h)`. -/
theorem rounded_run_mem_leafPredictors {τ : ℝ} (h0 : 0 < τ) {m : ℕ} (t : SQTree X m) :
    (leafPredictors (midpointAlphabet (alphabetSize τ)) t).card ≤ alphabetSize τ ^ m ∧
      ∀ (D : FinDist X) (h : Hyp X),
        runTree t (roundedOracle D h (alphabetSize τ)) [] ∈
          leafPredictors (midpointAlphabet (alphabetSize τ)) t := by
  refine ⟨(card_leafPredictors_le _ t).trans
    (Nat.pow_le_pow_left (card_midpointAlphabet_le _) m), fun D h => ?_⟩
  exact runTree_mem_leafPredictors _ _
    (fun hist q => roundedOracle_mem (alphabetSize_pos h0) D h hist q) t []

/-! ### The union-bound exponent -/

/-- `log₂ L = 3 log₂ N ≤ χN/2` under the hypothesis `χN ≥ 6 log₂ N` of
`thm:querylower`. -/
theorem log_rows_le {N : ℕ} {χ : ℝ} (hlog : 6 * Real.logb 2 N ≤ χ * N) :
    Real.logb 2 ((N : ℝ) ^ 3) = 3 * Real.logb 2 N ∧
      Real.logb 2 ((N : ℝ) ^ 3) ≤ χ * N / 2 := by
  have e : Real.logb 2 ((N : ℝ) ^ 3) = 3 * Real.logb 2 N := by
    rw [Real.logb_pow]; push_cast; ring
  exact ⟨e, by rw [e]; linarith⟩

/-- The exponent in the union bound of `app:query`, with `Q = 2N³`, `L = N³` and
`s = ⌈8N²/χ⌉`: `Q + s log₂L - χNs ≤ Q - χNs/2 ≤ -2N³`. -/
theorem union_bound_exponent {N : ℕ} {χ : ℝ} (hχ : 0 < χ)
    (hlog : 6 * Real.logb 2 N ≤ χ * N) :
    let Q : ℝ := 2 * (N : ℝ) ^ 3
    let s : ℕ := ⌈8 * (N : ℝ) ^ 2 / χ⌉₊
    Q + s * Real.logb 2 ((N : ℝ) ^ 3) - χ * N * s ≤ Q - χ * N * s / 2 ∧
      Q - χ * N * s / 2 ≤ -2 * (N : ℝ) ^ 3 := by
  intro Q s
  have hL := (log_rows_le hlog).2
  have hs0 : (0 : ℝ) ≤ s := Nat.cast_nonneg _
  have hs : 8 * (N : ℝ) ^ 2 / χ ≤ s := Nat.le_ceil _
  constructor
  · nlinarith
  · have hN0 : (0 : ℝ) ≤ N := Nat.cast_nonneg _
    have h1 : 8 * (N : ℝ) ^ 2 ≤ χ * s := by
      rw [div_le_iff₀ hχ] at hs; linarith
    have h2 : 8 * (N : ℝ) ^ 3 ≤ χ * N * s := by nlinarith
    simp only [Q]
    linarith

/-- `C(L,s) ≤ 2^{s log₂ L}` for `L ≥ 1`. -/
theorem choose_le_two_rpow {L : ℕ} (hL : 1 ≤ L) (s : ℕ) :
    (L.choose s : ℝ) ≤ (2 : ℝ) ^ ((s : ℝ) * Real.logb 2 L) := by
  have hLpos : (0 : ℝ) < L := by exact_mod_cast hL
  rw [mul_comm, Real.rpow_mul (by norm_num : (0 : ℝ) ≤ 2),
    Real.rpow_logb (by norm_num) (by norm_num) hLpos, Real.rpow_natCast]
  exact_mod_cast Nat.choose_le_pow L s

/-- The chain `2^Q C(L,s) 2^{-χNs} ≤ 2^{Q+s log₂L-χNs} ≤ 2^{Q-χNs/2} ≤ 2^{-2N³}`. -/
theorem union_bound_chain {N : ℕ} (hN : 1 ≤ N) {χ : ℝ} (hχ : 0 < χ)
    (hlog : 6 * Real.logb 2 N ≤ χ * N) :
    let Q : ℝ := 2 * (N : ℝ) ^ 3
    let s : ℕ := ⌈8 * (N : ℝ) ^ 2 / χ⌉₊
    (2 : ℝ) ^ Q * ((N ^ 3).choose s : ℝ) * (2 : ℝ) ^ (-(χ * N * s)) ≤
        (2 : ℝ) ^ (Q + s * Real.logb 2 ((N : ℝ) ^ 3) - χ * N * s) ∧
      (2 : ℝ) ^ (Q + s * Real.logb 2 ((N : ℝ) ^ 3) - χ * N * s) ≤
        (2 : ℝ) ^ (Q - χ * N * s / 2) ∧
      (2 : ℝ) ^ (Q - χ * N * s / 2) ≤ (2 : ℝ) ^ (-2 * (N : ℝ) ^ 3) := by
  intro Q s
  obtain ⟨e1, e2⟩ := union_bound_exponent (N := N) hχ hlog
  have hL : 1 ≤ N ^ 3 := Nat.one_le_pow _ _ hN
  have hc := choose_le_two_rpow hL s
  push_cast at hc
  refine ⟨?_, Real.rpow_le_rpow_of_exponent_le (by norm_num) e1,
    Real.rpow_le_rpow_of_exponent_le (by norm_num) e2⟩
  rw [sub_eq_add_neg, Real.rpow_add (by norm_num), Real.rpow_add (by norm_num)]
  gcongr

/-! ### Markov steps -/

/-- Markov's inequality in the form used in `app:query`: a nonnegative integrable
random variable with mean at most `ε` is at most `θ` with probability at least
`1 - ε/θ`. No measurability of the event is needed beyond integrability. -/
theorem prob_le_ge_one_sub_div {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω)
    [IsProbabilityMeasure P] {f : Ω → ℝ} (hf0 : ∀ ω, 0 ≤ f ω) (hint : Integrable f P)
    {ε θ : ℝ} (hθ : 0 < θ) (hmean : ∫ ω, f ω ∂P ≤ ε) :
    1 - ε / θ ≤ P.real {ω | f ω ≤ θ} := by
  have hmk := mul_meas_ge_le_integral_of_nonneg (Filter.Eventually.of_forall hf0) hint θ
  have hcover : (Set.univ : Set Ω) ⊆ {ω | f ω ≤ θ} ∪ {ω | θ ≤ f ω} := by
    intro ω _
    rcases le_total (f ω) θ with h | h
    · exact Or.inl h
    · exact Or.inr h
  have h1 : 1 ≤ P.real {ω | f ω ≤ θ} + P.real {ω | θ ≤ f ω} := by
    rw [← probReal_univ (μ := P)]
    exact (measureReal_mono hcover).trans (measureReal_union_le _ _)
  have h2 : P.real {ω | θ ≤ f ω} ≤ ε / θ := by
    rw [le_div_iff₀ hθ, mul_comm]; linarith
  linarith

theorem loss_nonneg (D : FinDist X) (h g : Hyp X) : 0 ≤ loss D h g :=
  Finset.sum_nonneg fun x _ => mul_nonneg (D.nonneg x) (by split_ifs <;> norm_num)

/-- "For each target, the expected-error guarantee against the rounded oracle and
Markov's inequality give probability at least `1-8ε/3` of error at most `3/8`."
(Stated for every valid oracle.) -/
theorem markov_three_eighths {ι : Type*} {H : ι → Hyp X} {m : ℕ} {Ω : Type*}
    [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P] {A : Ω → SQTree X m}
    {τ ε : ℝ} (hA : RandomizedLearns H P A τ ε) (D : FinDist X) (i : ι) (O : Oracle X)
    (hO : ValidOracle D (H i) τ O) :
    1 - 8 * ε / 3 ≤ P.real {ω | loss D (H i) (runTree (A ω) O []) ≤ 3 / 8} := by
  obtain ⟨hint, hmean⟩ := hA D i O hO
  have := prob_le_ge_one_sub_div P (fun ω => loss_nonneg D (H i) _) hint
    (by norm_num : (0 : ℝ) < 3 / 8) hmean
  have e : ε / (3 / 8) = 8 * ε / 3 := by ring
  rw [e] at this
  exact this

/-- The proper variant: probability at least `1-3ε` of error at most `1/3`. -/
theorem markov_one_third {ι : Type*} {H : ι → Hyp X} {m : ℕ} {Ω : Type*}
    [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P] {A : Ω → SQTree X m}
    {τ ε : ℝ} (hA : RandomizedLearns H P A τ ε) (D : FinDist X) (i : ι) (O : Oracle X)
    (hO : ValidOracle D (H i) τ O) :
    1 - 3 * ε ≤ P.real {ω | loss D (H i) (runTree (A ω) O []) ≤ 1 / 3} := by
  obtain ⟨hint, hmean⟩ := hA D i O hO
  have := prob_le_ge_one_sub_div P (fun ω => loss_nonneg D (H i) _) hint
    (by norm_num : (0 : ℝ) < 1 / 3) hmean
  have e : ε / (1 / 3) = 3 * ε := by ring
  rw [e] at this
  exact this

/-! ### Taking logarithms -/

/-- `eq:lowerimproper` from the counting inequality `N³(1-8ε/3) ≤ B^m·8N²/χ`. -/
theorem lowerimproper_of_count {N B m : ℕ} (hN : 1 ≤ N) (hB : 2 ≤ B) {ε χ : ℝ}
    (hε0 : 0 < ε) (hε : ε < 1 / 4) (hχ : 0 < χ)
    (hcount : (N : ℝ) ^ 3 * (1 - 8 * ε / 3) ≤ (B : ℝ) ^ m * (8 * (N : ℝ) ^ 2 / χ)) :
    (Real.logb 2 N + Real.logb 2 (χ * (1 - 8 * ε / 3) / 8)) / Real.logb 2 B ≤ m := by
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hBr : (2 : ℝ) ≤ B := by exact_mod_cast hB
  have hBpos : (0 : ℝ) < B := by linarith
  have hc : 0 < 1 - 8 * ε / 3 := by linarith
  have hlogB : 0 < Real.logb 2 B := Real.logb_pos (by norm_num) (by linarith)
  have key : (N : ℝ) * (χ * (1 - 8 * ε / 3) / 8) ≤ (B : ℝ) ^ m := by
    have e : (B : ℝ) ^ m * (8 * (N : ℝ) ^ 2 / χ) = (B : ℝ) ^ m * (8 / χ) * N ^ 2 := by ring
    rw [e] at hcount
    have h2 : (N : ℝ) * (1 - 8 * ε / 3) ≤ (B : ℝ) ^ m * (8 / χ) := by
      have hN2 : (0 : ℝ) < (N : ℝ) ^ 2 := by positivity
      have : (N : ℝ) * (1 - 8 * ε / 3) * N ^ 2 ≤ (B : ℝ) ^ m * (8 / χ) * N ^ 2 := by
        nlinarith
      exact le_of_mul_le_mul_right this hN2
    have e2 : (N : ℝ) * (χ * (1 - 8 * ε / 3) / 8) = (N : ℝ) * (1 - 8 * ε / 3) * (χ / 8) := by
      ring
    rw [e2]
    calc (N : ℝ) * (1 - 8 * ε / 3) * (χ / 8) ≤ (B : ℝ) ^ m * (8 / χ) * (χ / 8) := by
          gcongr
      _ = (B : ℝ) ^ m := by field_simp
  have hpos : 0 < χ * (1 - 8 * ε / 3) / 8 := by positivity
  have hlog := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) key
  rw [Real.logb_mul hNpos.ne' hpos.ne', Real.logb_pow] at hlog
  rw [div_le_iff₀ hlogB]
  linarith

/-- `eq:lowerproper` from the counting inequality `N³(1-3ε) ≤ B^m`. -/
theorem lowerproper_of_count {N B m : ℕ} (hN : 1 ≤ N) (hB : 2 ≤ B) {ε : ℝ}
    (hε : ε < 1 / 4) (hcount : (N : ℝ) ^ 3 * (1 - 3 * ε) ≤ (B : ℝ) ^ m) :
    (3 * Real.logb 2 N + Real.logb 2 (1 - 3 * ε)) / Real.logb 2 B ≤ m := by
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hBr : (2 : ℝ) ≤ B := by exact_mod_cast hB
  have hc : 0 < 1 - 3 * ε := by linarith
  have hlogB : 0 < Real.logb 2 B := Real.logb_pos (by norm_num) (by linarith)
  have hlog := Real.logb_le_logb_of_le (b := 2) (by norm_num) (by positivity) hcount
  rw [Real.logb_mul (by positivity) hc.ne', Real.logb_pow, Real.logb_pow] at hlog
  rw [div_le_iff₀ hlogB]
  push_cast at hlog
  linarith

/-! ### Averaging the coverage bound over seeds -/

/-- If every seed lies in at most `M` of the events `E ℓ`, then the probabilities of the
events sum to at most `M`. (The events need only be null-measurable.) -/
theorem sum_measureReal_le_of_pointwise {Λ : Type*} [Fintype Λ] {Ω : Type*}
    [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P] (E : Λ → Set Ω)
    (hE : ∀ ℓ, NullMeasurableSet (E ℓ) P) {M : ℝ}
    (hM : ∀ ω, ∑ ℓ, (E ℓ).indicator (fun _ => (1 : ℝ)) ω ≤ M) :
    ∑ ℓ, P.real (E ℓ) ≤ M := by
  have hind : ∀ ℓ, ∫ ω, (E ℓ).indicator (fun _ => (1 : ℝ)) ω ∂P = P.real (E ℓ) := by
    intro ℓ
    rw [integral_indicator₀ (hE ℓ), setIntegral_const, smul_eq_mul, mul_one]
  have hint : ∀ ℓ, Integrable ((E ℓ).indicator (fun _ => (1 : ℝ))) P :=
    fun ℓ => (integrable_const (1 : ℝ)).indicator₀ (hE ℓ)
  calc ∑ ℓ, P.real (E ℓ)
      = ∫ ω, ∑ ℓ, (E ℓ).indicator (fun _ => (1 : ℝ)) ω ∂P := by
        rw [integral_finsetSum _ (fun ℓ _ => hint ℓ)]
        exact Finset.sum_congr rfl fun ℓ _ => (hind ℓ).symm
    _ ≤ ∫ _ω, M ∂P :=
        integral_mono (integrable_finsetSum _ fun ℓ _ => hint ℓ) (integrable_const M) hM
    _ = M := by simp

theorem sum_indicator_eq_card {Λ : Type*} [Fintype Λ] {Ω : Type*} (E : Λ → Set Ω) (ω : Ω)
    [DecidablePred fun ℓ => ω ∈ E ℓ] :
    ∑ ℓ, (E ℓ).indicator (fun _ => (1 : ℝ)) ω =
      ((Finset.univ.filter fun ℓ => ω ∈ E ℓ).card : ℝ) := by
  rw [Finset.card_filter, Nat.cast_sum]
  refine Finset.sum_congr rfl fun ℓ _ => ?_
  by_cases h : ω ∈ E ℓ <;> simp [h]

/-- "Average the preceding coverage bound over seeds and sum these success probabilities
over the `N³` targets. We obtain `N³(1-8ε/3) ≤ B_τ^m·8N²/χ`." The instances are indexed
by a finite type `Λ` (the full-length lines `Lc₀` in the paper), instance `ℓ` having
target row `tgt ℓ` and marginal `marg ℓ` (the uniform law on its template points). The
coverage property of the table is the hypothesis `hcover` (with `C = 8N²/χ` in the
paper). The learner is an arbitrary randomized depth-`m` learner in the sense of
`RandomizedLearns`. -/
theorem outputs_count_improper {ι Λ : Type*} [Fintype Λ] {H : ι → Hyp X} (tgt : Λ → ι)
    (marg : Λ → FinDist X) {C : ℝ}
    (hcover : ∀ g : Hyp X,
      ((Finset.univ.filter fun ℓ => loss (marg ℓ) (H (tgt ℓ)) g ≤ 3 / 8).card : ℝ) ≤ C)
    {m : ℕ} {Ω : Type*} [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P]
    {A : Ω → SQTree X m} {τ ε : ℝ} (hτ : 0 < τ) (hA : RandomizedLearns H P A τ ε) :
    (Fintype.card Λ : ℝ) * (1 - 8 * ε / 3) ≤ (alphabetSize τ : ℝ) ^ m * C := by
  classical
  set B := alphabetSize τ
  set O : Λ → Oracle X := fun ℓ => roundedOracle (marg ℓ) (H (tgt ℓ)) B
  set E : Λ → Set Ω := fun ℓ =>
    {ω | loss (marg ℓ) (H (tgt ℓ)) (runTree (A ω) (O ℓ) []) ≤ 3 / 8}
  have hval : ∀ ℓ, ValidOracle (marg ℓ) (H (tgt ℓ)) τ (O ℓ) :=
    fun ℓ => roundedOracle_valid hτ _ _
  have hC : 0 ≤ C := (Nat.cast_nonneg _).trans (hcover fun _ => true)
  have hE : ∀ ℓ, NullMeasurableSet (E ℓ) P := fun ℓ =>
    nullMeasurableSet_le (hA (marg ℓ) (tgt ℓ) (O ℓ) (hval ℓ)).1.aemeasurable
      aemeasurable_const
  have hlow : ∀ ℓ, 1 - 8 * ε / 3 ≤ P.real (E ℓ) := fun ℓ =>
    markov_three_eighths hA (marg ℓ) (tgt ℓ) (O ℓ) (hval ℓ)
  have hpt : ∀ ω, ∑ ℓ, (E ℓ).indicator (fun _ => (1 : ℝ)) ω ≤ (B : ℝ) ^ m * C := by
    intro ω
    rw [sum_indicator_eq_card]
    set leaves := leafPredictors (midpointAlphabet B) (A ω)
    have hsub : (Finset.univ.filter fun ℓ => ω ∈ E ℓ) ⊆ leaves.biUnion fun g =>
        Finset.univ.filter fun ℓ => loss (marg ℓ) (H (tgt ℓ)) g ≤ 3 / 8 := by
      intro ℓ hℓ
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hℓ
      refine Finset.mem_biUnion.mpr ⟨runTree (A ω) (O ℓ) [], ?_, ?_⟩
      · exact runTree_mem_leafPredictors _ _
          (fun hist q => roundedOracle_mem (alphabetSize_pos hτ) _ _ hist q) _ []
      · simpa [E] using hℓ
    have hcard : ((leaves.biUnion fun g =>
        Finset.univ.filter fun ℓ => loss (marg ℓ) (H (tgt ℓ)) g ≤ 3 / 8).card : ℝ) ≤
          (leaves.card : ℝ) * C := by
      calc _ ≤ ((∑ g ∈ leaves, (Finset.univ.filter fun ℓ =>
              loss (marg ℓ) (H (tgt ℓ)) g ≤ 3 / 8).card : ℕ) : ℝ) := by
            exact_mod_cast Finset.card_biUnion_le
        _ ≤ ∑ _g ∈ leaves, C := by push_cast; exact Finset.sum_le_sum fun g _ => hcover g
        _ = (leaves.card : ℝ) * C := by rw [Finset.sum_const, nsmul_eq_mul]
    have hleaves : (leaves.card : ℝ) ≤ (B : ℝ) ^ m := by
      exact_mod_cast (rounded_run_mem_leafPredictors hτ (A ω)).1
    calc ((Finset.univ.filter fun ℓ => ω ∈ E ℓ).card : ℝ)
        ≤ ((leaves.biUnion fun g => Finset.univ.filter fun ℓ =>
            loss (marg ℓ) (H (tgt ℓ)) g ≤ 3 / 8).card : ℝ) := by
          exact_mod_cast Finset.card_le_card hsub
      _ ≤ (leaves.card : ℝ) * C := hcard
      _ ≤ (B : ℝ) ^ m * C := mul_le_mul_of_nonneg_right hleaves hC
  calc (Fintype.card Λ : ℝ) * (1 - 8 * ε / 3) = ∑ _ℓ : Λ, (1 - 8 * ε / 3) := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
    _ ≤ ∑ ℓ, P.real (E ℓ) := Finset.sum_le_sum fun ℓ _ => hlow ℓ
    _ ≤ (B : ℝ) ^ m * C := sum_measureReal_le_of_pointwise P E hE hpt

/-- The proper analogue: "For a proper learner, each leaf predictor is good at threshold
`1/3` on at most one target. Markov's inequality now gives `N³(1-3ε) ≤ B_τ^m`." The
one-target property of the table is the hypothesis `hone`; properness is the hypothesis
that every valid run outputs a row of `H`. -/
theorem outputs_count_proper {ι Λ : Type*} [Fintype Λ] {H : ι → Hyp X} (tgt : Λ → ι)
    (marg : Λ → FinDist X)
    (hone : ∀ j : ι,
      (Finset.univ.filter fun ℓ => loss (marg ℓ) (H (tgt ℓ)) (H j) ≤ 1 / 3).card ≤ 1)
    {m : ℕ} {Ω : Type*} [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P]
    {A : Ω → SQTree X m} {τ ε : ℝ} (hτ : 0 < τ) (hA : RandomizedLearns H P A τ ε)
    (hproper : ∀ ω (D : FinDist X) (i : ι) (O : Oracle X), ValidOracle D (H i) τ O →
      ∃ j, runTree (A ω) O [] = H j) :
    (Fintype.card Λ : ℝ) * (1 - 3 * ε) ≤ (alphabetSize τ : ℝ) ^ m := by
  classical
  set B := alphabetSize τ
  set O : Λ → Oracle X := fun ℓ => roundedOracle (marg ℓ) (H (tgt ℓ)) B
  set E : Λ → Set Ω := fun ℓ =>
    {ω | loss (marg ℓ) (H (tgt ℓ)) (runTree (A ω) (O ℓ) []) ≤ 1 / 3}
  have hval : ∀ ℓ, ValidOracle (marg ℓ) (H (tgt ℓ)) τ (O ℓ) :=
    fun ℓ => roundedOracle_valid hτ _ _
  have hE : ∀ ℓ, NullMeasurableSet (E ℓ) P := fun ℓ =>
    nullMeasurableSet_le (hA (marg ℓ) (tgt ℓ) (O ℓ) (hval ℓ)).1.aemeasurable
      aemeasurable_const
  have hlow : ∀ ℓ, 1 - 3 * ε ≤ P.real (E ℓ) := fun ℓ =>
    markov_one_third hA (marg ℓ) (tgt ℓ) (O ℓ) (hval ℓ)
  have hpt : ∀ ω, ∑ ℓ, (E ℓ).indicator (fun _ => (1 : ℝ)) ω ≤ (B : ℝ) ^ m := by
    intro ω
    rw [sum_indicator_eq_card]
    set leaves := leafPredictors (midpointAlphabet B) (A ω)
    have hmaps : ∀ ℓ ∈ (Finset.univ.filter fun ℓ => ω ∈ E ℓ),
        runTree (A ω) (O ℓ) [] ∈ leaves := fun ℓ _ =>
      runTree_mem_leafPredictors _ _
        (fun hist q => roundedOracle_mem (alphabetSize_pos hτ) _ _ hist q) _ []
    have hinj : Set.InjOn (fun ℓ => runTree (A ω) (O ℓ) [])
        ↑(Finset.univ.filter fun ℓ => ω ∈ E ℓ) := by
      intro ℓ hℓ ℓ' hℓ' heq
      simp only [Finset.coe_filter, Finset.mem_univ, true_and] at hℓ hℓ'
      obtain ⟨j, hj⟩ := hproper ω (marg ℓ) (tgt ℓ) (O ℓ) (hval ℓ)
      have hj' : runTree (A ω) (O ℓ') [] = H j := by rw [← hj]; exact heq.symm
      have hmem : ∀ k ∈ [ℓ, ℓ'], k ∈ Finset.univ.filter fun ℓ =>
          loss (marg ℓ) (H (tgt ℓ)) (H j) ≤ 1 / 3 := by
        intro k hk
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hk
        rcases hk with rfl | rfl
        · simpa [E, hj] using hℓ
        · simpa [E, hj'] using hℓ'
      exact Finset.card_le_one.mp (hone j) _ (hmem ℓ (by simp)) _ (hmem ℓ' (by simp))
    have hleaves : (leaves.card : ℝ) ≤ (B : ℝ) ^ m := by
      exact_mod_cast (rounded_run_mem_leafPredictors hτ (A ω)).1
    calc ((Finset.univ.filter fun ℓ => ω ∈ E ℓ).card : ℝ) ≤ (leaves.card : ℝ) := by
          exact_mod_cast Finset.card_le_card_of_injOn _ hmaps hinj
      _ ≤ (B : ℝ) ^ m := hleaves
  calc (Fintype.card Λ : ℝ) * (1 - 3 * ε) = ∑ _ℓ : Λ, (1 - 3 * ε) := by
        rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
    _ ≤ ∑ ℓ, P.real (E ℓ) := Finset.sum_le_sum fun ℓ _ => hlow ℓ
    _ ≤ (B : ℝ) ^ m := sum_measureReal_le_of_pointwise P E hE hpt

/-! ### The two lower bounds, conditional on the table events -/

/-- Theorem *Query lower bounds* (`thm:querylower`), `eq:lowerimproper`, on a table for
which the coverage event of `app:query` holds: if the `N³` full-line instances are such
that every predictor has error at most `3/8` on at most `8N²/χ` of them (`hcover`), then
every randomized depth-`m` learner with expected error `ε` at tolerance `τ` obeys
`m ≥ (log₂N + log₂(χ(1-8ε/3)/8)) / log₂⌈1/τ⌉`. -/
theorem querylower_improper {ι Λ : Type*} [Fintype Λ] {H : ι → Hyp X} (tgt : Λ → ι)
    (marg : Λ → FinDist X) {N : ℕ} (hN : 1 ≤ N) (hΛ : Fintype.card Λ = N ^ 3) {χ : ℝ}
    (hχ : 0 < χ)
    (hcover : ∀ g : Hyp X,
      ((Finset.univ.filter fun ℓ => loss (marg ℓ) (H (tgt ℓ)) g ≤ 3 / 8).card : ℝ) ≤
        8 * (N : ℝ) ^ 2 / χ)
    {m : ℕ} {Ω : Type*} [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P]
    {A : Ω → SQTree X m} {τ ε : ℝ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (hε0 : 0 < ε)
    (hε1 : ε < 1 / 4) (hA : RandomizedLearns H P A τ ε) :
    (Real.logb 2 N + Real.logb 2 (χ * (1 - 8 * ε / 3) / 8)) /
      Real.logb 2 (⌈1 / τ⌉₊ : ℕ) ≤ m := by
  have h := outputs_count_improper tgt marg hcover hτ0 hA
  rw [hΛ] at h
  push_cast at h
  exact lowerimproper_of_count hN (two_le_alphabetSize hτ0 hτ1) hε0 hε1 hχ h

/-- Theorem *Query lower bounds* (`thm:querylower`), `eq:lowerproper`, on a table for
which every row has error at most `1/3` on at most one of the `N³` full-line instances
(`hone`): every randomized depth-`m` learner whose valid runs output rows of `H` obeys
`m ≥ (3log₂N + log₂(1-3ε)) / log₂⌈1/τ⌉`. -/
theorem querylower_proper {ι Λ : Type*} [Fintype Λ] {H : ι → Hyp X} (tgt : Λ → ι)
    (marg : Λ → FinDist X) {N : ℕ} (hN : 1 ≤ N) (hΛ : Fintype.card Λ = N ^ 3)
    (hone : ∀ j : ι,
      (Finset.univ.filter fun ℓ => loss (marg ℓ) (H (tgt ℓ)) (H j) ≤ 1 / 3).card ≤ 1)
    {m : ℕ} {Ω : Type*} [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P]
    {A : Ω → SQTree X m} {τ ε : ℝ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (hε1 : ε < 1 / 4)
    (hA : RandomizedLearns H P A τ ε)
    (hproper : ∀ ω (D : FinDist X) (i : ι) (O : Oracle X), ValidOracle D (H i) τ O →
      ∃ j, runTree (A ω) O [] = H j) :
    (3 * Real.logb 2 N + Real.logb 2 (1 - 3 * ε)) / Real.logb 2 (⌈1 / τ⌉₊ : ℕ) ≤ m := by
  have h := outputs_count_proper tgt marg hone hτ0 hA hproper
  rw [hΛ] at h
  push_cast at h
  exact lowerproper_of_count hN (two_le_alphabetSize hτ0 hτ1) hε1 h

end SQDC.QueryBounds
