import SQDC.Basic
import Mathlib.Algebra.Order.Ring.Star
import Mathlib.Analysis.SpecialFunctions.Log.Base

/-!
# Noisy integer medians

Correspondence with Lemma *Noisy median* (`lem:noisymedian`) in Appendix `app:median`
("The succinct order-median learner"):

* `bisect`, `noisyMedian`: "Maintain an integer bracket initially equal to `[L-1,H]`.
  [...] Regard them as a lower and an upper comparison without querying them." At an
  interior threshold an answer at least `β̂/2` moves the upper endpoint, an answer below
  it moves the lower endpoint.
* `noisy_median`: the full lemma, i.e. `eq:medianlo`, `eq:medianhi`, the query bound,
  `eq:balancedprefix` in the light-atom case and `m_v > β/9` in the heavy-atom case.
* `bisect_spec`: "The reasoning uses only the inequalities at the retained endpoints,
  not consistency of all observed answers."
* `noisyMedian_queries_le_log`: the bound `O(log(H-L+2))`, explicitly
  `⌈log₂(H-L+1)⌉ + 1 ≤ 3 log₂(H-L+2)` queries including the atom query.

Modelling choices.

* `μ⁻` is a finite nonnegative measure on a finite type `α`, given by weights `w`
  (in the application `w x = D(x)·[h*(x) = -1]` on the finite domain); `f : α → ℤ`
  takes values in `[L,H]` on the support `{w > 0}`.
* Oracle answers are fully adaptive: a `ThresholdOracle` sees the whole transcript of
  previous thresholds and answers (any earlier history of the surrounding algorithm can
  be absorbed into the choice of `O`), and every answer is only assumed to be within `ζ`
  of the true cumulative mass `μ⁻{f ≤ t}`. Answers need not be monotone in `t` or
  mutually consistent. The model "answers are an arbitrary function of the queried
  threshold" is the special case of an oracle ignoring the transcript; conversely that
  model loses nothing, because the binary search queries each threshold at most once
  per run (`bisect_spec`: the queried thresholds are distinct and lie strictly inside
  the initial bracket), so on any run an adaptive oracle's answers coincide with those
  of the function sending each queried threshold to its unique answer. A randomized
  oracle is covered by fixing its randomness. The atom answer `m̂_v` is quantified over
  all values within `ζ` of `m_v`, so it may also depend on everything before it.

Not formalized: the rest of Appendix `app:median` (the slope search, completion,
star regularity, and Theorem *Order-median learner* `thm:median`).
-/

noncomputable section
open scoped BigOperators

namespace SQDC.NoisyMedian

/-- Transcript entries `(threshold, answer)`. -/
abbrev Transcript := List (ℤ × ℝ)

/-- An adaptive answer policy for threshold queries: the answer to threshold `t` may
depend on the transcript of all earlier queries and answers. -/
abbrev ThresholdOracle := Transcript → ℤ → ℝ

/-- Binary search on the integer bracket `(lo, hi]` with comparison threshold `θ`.
Returns the final upper endpoint and the list of queries made (threshold, answer). The
oracle sees `hist` followed by the queries made so far. -/
def bisect (O : ThresholdOracle) (θ : ℝ) (hist : Transcript) (lo hi : ℤ) : ℤ × Transcript :=
  if lo + 1 < hi then
    let mid := lo + (hi - lo) / 2
    let a := O hist mid
    let r := if θ ≤ a then bisect O θ (hist ++ [(mid, a)]) lo mid
      else bisect O θ (hist ++ [(mid, a)]) mid hi
    (r.1, (mid, a) :: r.2)
  else (hi, [])
termination_by (hi - lo).toNat
decreasing_by all_goals omega

/-- The noisy median procedure of `lem:noisymedian`: binary search over `[L-1, H]` with
threshold `β̂/2`. -/
def noisyMedian (O : ThresholdOracle) (βhat : ℝ) (L H : ℤ) : ℤ × Transcript :=
  bisect O (βhat / 2) [] (L - 1) H

theorem clog_step {n : ℕ} (hn : 2 ≤ n) :
    Nat.clog 2 (n / 2) + 1 ≤ Nat.clog 2 n ∧ Nat.clog 2 (n - n / 2) + 1 ≤ Nat.clog 2 n := by
  rw [Nat.clog_of_two_le (by norm_num) hn]
  have e : (n + 2 - 1) / 2 = n - n / 2 := by omega
  rw [e]
  exact ⟨Nat.add_le_add_right (Nat.clog_mono_right 2 (by omega)) 1, le_rfl⟩

/-- Correctness of the bracket search from endpoint inequalities only. If every answer
at least `θ` certifies `Hi` at its threshold and every answer below `θ` certifies `Lo`,
and the initial endpoints satisfy `Lo lo`, `Hi hi`, then the returned `v` satisfies
`Lo (v-1)` and `Hi v`, using at most `⌈log₂(hi-lo)⌉` queries, each at a distinct
threshold strictly inside `(lo, hi)`. -/
theorem bisect_spec (O : ThresholdOracle) (θ : ℝ) (Lo Hi : ℤ → Prop)
    (hHi : ∀ hist t, θ ≤ O hist t → Hi t) (hLo : ∀ hist t, O hist t < θ → Lo t)
    (hist : Transcript) (lo hi : ℤ) (hlt : lo < hi) (hlo : Lo lo) (hhi : Hi hi) :
    Lo ((bisect O θ hist lo hi).1 - 1) ∧ Hi (bisect O θ hist lo hi).1 ∧
      lo < (bisect O θ hist lo hi).1 ∧ (bisect O θ hist lo hi).1 ≤ hi ∧
      (bisect O θ hist lo hi).2.length ≤ Nat.clog 2 (hi - lo).toNat ∧
      (∀ p ∈ (bisect O θ hist lo hi).2, lo < p.1 ∧ p.1 < hi) ∧
      ((bisect O θ hist lo hi).2.map Prod.fst).Nodup := by
  induction hist, lo, hi using bisect.induct O θ with
  | case1 hist lo hi h mid a ih1 ih2 =>
    simp only [mid, a] at ih1 ih2
    rw [bisect]
    simp only [h, ↓reduceIte]
    set m := lo + (hi - lo) / 2 with hm
    have hm1 : lo < m := by omega
    have hm2 : m < hi := by omega
    have hn : 2 ≤ (hi - lo).toNat := by omega
    obtain ⟨c1, c2⟩ := clog_step hn
    have e1 : (m - lo).toNat = (hi - lo).toNat / 2 := by omega
    have e2 : (hi - m).toNat = (hi - lo).toNat - (hi - lo).toNat / 2 := by omega
    by_cases hθ : θ ≤ O hist m
    · simp only [hθ, ↓reduceIte] at ih1 ⊢
      obtain ⟨r1, r2, r3, r4, r5, r6, r7⟩ := ih1 hm1 hlo (hHi hist m hθ)
      refine ⟨r1, r2, r3, by omega, ?_, ?_, ?_⟩
      · simp only [List.length_cons]; rw [e1] at r5; omega
      · intro p hp
        rcases List.mem_cons.mp hp with rfl | hp
        · exact ⟨hm1, hm2⟩
        · have := r6 p hp; omega
      · refine List.nodup_cons.mpr ⟨fun hmem => ?_, r7⟩
        obtain ⟨p, hp, hpe⟩ := List.mem_map.mp hmem
        have := r6 p hp; omega
    · simp only [hθ, ↓reduceIte] at ih2 ⊢
      obtain ⟨r1, r2, r3, r4, r5, r6, r7⟩ := ih2 hm2 (hLo hist m (not_le.mp hθ)) hhi
      refine ⟨r1, r2, by omega, r4, ?_, ?_, ?_⟩
      · simp only [List.length_cons]; rw [e2] at r5; omega
      · intro p hp
        rcases List.mem_cons.mp hp with rfl | hp
        · exact ⟨hm1, hm2⟩
        · have := r6 p hp; omega
      · refine List.nodup_cons.mpr ⟨fun hmem => ?_, r7⟩
        obtain ⟨p, hp, hpe⟩ := List.mem_map.mp hmem
        have := r6 p hp; omega
  | case2 hist lo hi h =>
    rw [bisect]
    simp only [h, ↓reduceIte]
    have e : hi - 1 = lo := by omega
    refine ⟨by simpa [e] using hlo, hhi, hlt, le_rfl, by simp, by simp, by simp⟩

/-! ### The measure `μ⁻` and its cumulative masses -/

variable {α : Type*} [Fintype α]

/-- `μ⁻{f ≤ v}`. -/
def massLE (w : α → ℝ) (f : α → ℤ) (v : ℤ) : ℝ := ∑ x ∈ Finset.univ.filter (f · ≤ v), w x

/-- `μ⁻{f < v}`. -/
def massLT (w : α → ℝ) (f : α → ℤ) (v : ℤ) : ℝ := ∑ x ∈ Finset.univ.filter (f · < v), w x

/-- The atom mass `m_v = μ⁻{f = v}`. -/
def massEq (w : α → ℝ) (f : α → ℤ) (v : ℤ) : ℝ := ∑ x ∈ Finset.univ.filter (f · = v), w x

theorem massLE_eq_massLT_add_massEq (w : α → ℝ) (f : α → ℤ) (v : ℤ) :
    massLE w f v = massLT w f v + massEq w f v := by
  classical
  unfold massLE massLT massEq
  rw [← Finset.sum_union]
  · congr 1
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union]
    omega
  · rw [Finset.disjoint_filter]
    intro x _ h1 h2
    omega

theorem massLT_eq_massLE_sub_one (w : α → ℝ) (f : α → ℤ) (v : ℤ) :
    massLT w f v = massLE w f (v - 1) := by
  unfold massLT massLE
  congr 1
  ext x
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  omega

/-- The lower endpoint `L-1` of the initial bracket has cumulative mass zero. -/
theorem massLE_below (w : α → ℝ) (f : α → ℤ) {L : ℤ} (hw : ∀ x, 0 ≤ w x)
    (hsupp : ∀ x, 0 < w x → L ≤ f x) : massLE w f (L - 1) = 0 := by
  unfold massLE
  refine Finset.sum_eq_zero fun x hx => ?_
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
  rcases (hw x).lt_or_eq with h | h
  · have := hsupp x h; omega
  · exact h.symm

/-- The upper endpoint `H` of the initial bracket has cumulative mass `β`. -/
theorem massLE_above (w : α → ℝ) (f : α → ℤ) {H : ℤ} (hw : ∀ x, 0 ≤ w x)
    (hsupp : ∀ x, 0 < w x → f x ≤ H) : massLE w f H = ∑ x, w x := by
  unfold massLE
  rw [Finset.sum_filter]
  refine Finset.sum_congr rfl fun x _ => ?_
  split_ifs with h
  · rfl
  · rcases (hw x).lt_or_eq with h' | h'
    · exact absurd (hsupp x h') h
    · exact h'

/-- `log₂` form of the query bound: `⌈log₂ n⌉ + 1 ≤ 3 log₂(n+1)` for `n ≥ 1`. -/
theorem clog_add_one_le_log (n : ℕ) (hn : 1 ≤ n) :
    (Nat.clog 2 n : ℝ) + 1 ≤ 3 * Real.logb 2 ((n : ℝ) + 1) := by
  have h1 : 1 ≤ Real.logb 2 ((n : ℝ) + 1) := by
    rw [Real.le_logb_iff_rpow_le (by norm_num) (by positivity)]
    have : (1 : ℝ) ≤ n := by exact_mod_cast hn
    norm_num; linarith
  rcases Nat.lt_or_ge n 2 with h | h
  · have : n = 1 := by omega
    subst this
    simp only [Nat.clog_one_right, Nat.cast_zero, zero_add]
    linarith
  · have hc := Nat.pow_pred_clog_lt_self (b := 2) (by norm_num) (x := n) (by omega)
    have hcpos : 1 ≤ Nat.clog 2 n := Nat.succ_le_of_lt (Nat.clog_pos (by norm_num) (by omega))
    have hreal : ((Nat.clog 2 n).pred : ℝ) < Real.logb 2 n := by
      rw [Real.lt_logb_iff_rpow_lt (by norm_num) (by positivity), Real.rpow_natCast]
      exact_mod_cast hc
    have hpred : ((Nat.clog 2 n).pred : ℝ) = (Nat.clog 2 n : ℝ) - 1 := by
      rw [Nat.pred_eq_sub_one, Nat.cast_sub hcpos, Nat.cast_one]
    have hmono : Real.logb 2 n ≤ Real.logb 2 ((n : ℝ) + 1) :=
      Real.logb_le_logb_of_le (by norm_num) (by positivity) (by linarith)
    linarith

/-- Lemma *Noisy median* (`lem:noisymedian`): "Let `μ⁻` be a finite measure of total
mass `β > 0`, and suppose `|β̂-β| ≤ ζ` and `β ≥ 512ζ`. Let `f` be integer-valued in
`[L,H]` on its support. With `O(log(H-L+2))` queries, binary search with threshold
`β̂/2` returns an integer `v` such that `μ⁻{f ≤ v} ≥ β/2-3ζ/2` (`eq:medianlo`) and
`μ⁻{f < v} < β/2+3ζ/2` (`eq:medianhi`). Query the atom mass `m_v = μ⁻{f = v}`. If
`m̂_v ≤ β̂/8`, then `β/2-3ζ/2 ≤ μ⁻{f ≤ v} < 5β/8+21ζ/8` (`eq:balancedprefix`).
Otherwise `m_v > β/9`."

The binary search makes at most `⌈log₂(H-L+1)⌉` threshold queries (plus the one atom
query); see `noisyMedian_queries_le_log` for the logarithmic form. -/
theorem noisy_median (w : α → ℝ) (hw : ∀ x, 0 ≤ w x) (f : α → ℤ) (L H : ℤ)
    (hsupp : ∀ x, 0 < w x → L ≤ f x ∧ f x ≤ H) {β βhat ζ : ℝ} (hβ : ∑ x, w x = β)
    (hβpos : 0 < β) (hβhat : |βhat - β| ≤ ζ) (h512 : 512 * ζ ≤ β)
    (O : ThresholdOracle) (hO : ∀ hist t, |O hist t - massLE w f t| ≤ ζ) :
    β / 2 - 3 * ζ / 2 ≤ massLE w f (noisyMedian O βhat L H).1 ∧
      massLT w f (noisyMedian O βhat L H).1 < β / 2 + 3 * ζ / 2 ∧
      L ≤ (noisyMedian O βhat L H).1 ∧ (noisyMedian O βhat L H).1 ≤ H ∧
      (noisyMedian O βhat L H).2.length ≤ Nat.clog 2 (H - L + 1).toNat ∧
      ∀ mhat : ℝ, |mhat - massEq w f (noisyMedian O βhat L H).1| ≤ ζ →
        (mhat ≤ βhat / 8 →
          β / 2 - 3 * ζ / 2 ≤ massLE w f (noisyMedian O βhat L H).1 ∧
            massLE w f (noisyMedian O βhat L H).1 < 5 * β / 8 + 21 * ζ / 8) ∧
        (βhat / 8 < mhat → β / 9 < massEq w f (noisyMedian O βhat L H).1) := by
  have hζ : 0 ≤ ζ := (abs_nonneg _).trans hβhat
  obtain ⟨hb1, hb2⟩ := abs_le.mp hβhat
  -- the support is nonempty, so `L ≤ H`
  have hLH : L ≤ H := by
    by_contra hcon
    have : ∀ x, w x = 0 := fun x => by
      rcases (hw x).lt_or_eq with h | h
      · have := hsupp x h; omega
      · exact h.symm
    simp [this] at hβ
    linarith
  set Lo : ℤ → Prop := fun t => massLE w f t < β / 2 + 3 * ζ / 2
  set Hi : ℤ → Prop := fun t => β / 2 - 3 * ζ / 2 ≤ massLE w f t
  have hHi : ∀ hist t, βhat / 2 ≤ O hist t → Hi t := by
    intro hist t ha
    have := (abs_le.mp (hO hist t)).2
    simp only [Hi]; linarith
  have hLo : ∀ hist t, O hist t < βhat / 2 → Lo t := by
    intro hist t ha
    have := (abs_le.mp (hO hist t)).1
    simp only [Lo]; linarith
  have hlo : Lo (L - 1) := by
    simp only [Lo]
    rw [massLE_below w f hw (fun x hx => (hsupp x hx).1)]
    linarith
  have hhi : Hi H := by
    simp only [Hi]
    rw [massLE_above w f hw (fun x hx => (hsupp x hx).2), hβ]
    linarith
  obtain ⟨r1, r2, r3, r4, r5, -, -⟩ :=
    bisect_spec O (βhat / 2) Lo Hi hHi hLo [] (L - 1) H (by omega) hlo hhi
  set v := (noisyMedian O βhat L H).1
  have hlt : massLT w f v < β / 2 + 3 * ζ / 2 := by
    rw [massLT_eq_massLE_sub_one]; exact r1
  have hsplit := massLE_eq_massLT_add_massEq w f v
  refine ⟨r2, hlt, by simp only [v, noisyMedian]; omega, r4, ?_, fun mhat hm => ⟨?_, ?_⟩⟩
  · have e : H - (L - 1) = H - L + 1 := by ring
    simpa [noisyMedian, e] using r5
  · intro hlight
    have := (abs_le.mp hm).1
    refine ⟨r2, ?_⟩
    -- `m_v ≤ β̂/8 + ζ ≤ β/8 + 9ζ/8`
    have hm' : massEq w f v ≤ β / 8 + 9 * ζ / 8 := by linarith
    linarith
  · intro hheavy
    have := (abs_le.mp hm).2
    -- `m_v > β̂/8 - ζ ≥ β/8 - 9ζ/8 > β/9`
    have hm' : β / 8 - 9 * ζ / 8 < massEq w f v := by linarith
    nlinarith

/-- The binary search makes at most `⌈log₂(H-L+1)⌉` threshold queries, against every
oracle. -/
theorem noisyMedian_length_le (O : ThresholdOracle) (βhat : ℝ) {L H : ℤ} (hLH : L ≤ H) :
    (noisyMedian O βhat L H).2.length ≤ Nat.clog 2 (H - L + 1).toNat := by
  have := (bisect_spec O (βhat / 2) (fun _ => True) (fun _ => True) (fun _ _ _ => trivial)
    (fun _ _ _ => trivial) [] (L - 1) H (by omega) trivial trivial).2.2.2.2.1
  have e : H - (L - 1) = H - L + 1 := by ring
  simpa [noisyMedian, e] using this

/-- The query count `O(log(H-L+2))` of `lem:noisymedian`, made explicit: the binary
search and the atom query together use at most `⌈log₂(H-L+1)⌉ + 1 ≤ 3 log₂(H-L+2)`
queries whenever `L ≤ H`. -/
theorem noisyMedian_queries_le_log (O : ThresholdOracle) (βhat : ℝ) {L H : ℤ}
    (hLH : L ≤ H) :
    ((noisyMedian O βhat L H).2.length : ℝ) + 1 ≤ 3 * Real.logb 2 ((H - L + 2 : ℤ) : ℝ) := by
  have hn : 1 ≤ (H - L + 1).toNat := by omega
  have hcast : (((H - L + 1).toNat : ℕ) : ℝ) + 1 = ((H - L + 2 : ℤ) : ℝ) := by
    have : ((H - L + 1).toNat : ℤ) = H - L + 1 := Int.toNat_of_nonneg (by omega)
    have h2 : (((H - L + 1).toNat : ℕ) : ℝ) = ((H - L + 1 : ℤ) : ℝ) := by
      rw [← this]; norm_cast
    rw [h2]; push_cast; ring
  have := clog_add_one_le_log _ hn
  rw [hcast] at this
  have h' : ((noisyMedian O βhat L H).2.length : ℝ) ≤ (Nat.clog 2 (H - L + 1).toNat : ℝ) := by
    exact_mod_cast noisyMedian_length_le O βhat hLH
  linarith

end SQDC.NoisyMedian
