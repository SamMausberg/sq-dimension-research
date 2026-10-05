import SQDC.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.LinearCombination

/-!
# Incidence signs: geometry and the upper representation

Correspondence with Section *Incidence signs and representation dimension*
(`sec:incidence`), Appendix *Geometry of the separating family* (`app:geometry`), and two
pieces of Appendix *Query lower bounds and transcript embeddings* (`app:query`). Results are
cited by title and TeX label.

* `Point N`, `Line N`: the 1-based sets `X = 𝓛 = [N] × [2N²]` (a subtype of `ℕ × ℕ`);
  `ℓ = (a, b)` represents `y = ax + b`. `card_point`, `card_line`: `K = Q = 2N³`.
* `template N`: the template `F` of `eq:grid` (`false`, i.e. `-1`, exactly at `y = ax + b`).
* `IsFlip A`: `A` is an incidence flip, negative only at template incidences; `A` itself is
  the indexed row class `𝓗_A`. `flipOfSigns`/`flipOfSigns_restrict`: flips are exactly the
  sign vectors on the incidences.
* `card_incidences`, `card_incidences_eq_sum`, `pow_four_le_card_incidences`:
  `eq:incidencecount` (Proposition *Geometry and an upper representation*, `prop:geometry`).
* `topRow_not_incident`, `topRow_all_positive`: row `(1, 2N²)` has no incidences and stays
  all-positive (`app:geometry`).
* `eq_of_incident_of_incident`, `eq_of_negative_of_negative`, `no_negative_two_by_two`: two
  lines share at most one point; no all-negative `2 × 2` (`app:geometry`).
* `vcDim_le_two`: `VC(𝓗_A) ≤ 2` (`eq:geometry`).
* `template_polynomial`, `templateScore_neg_iff`, `templateScore_pos_iff`,
  `template_embedsAt_six`, `template_dc_le_six`: the template has sign-rank at most six
  (`prop:geometry`, `app:geometry`).
* `lineLabel` (`q_ℓ`), `upperScore_eq`, `upperScore_of_incident`,
  `one_le_upperScore_of_not_incident`, `flip_embedsAt`, `flip_dc_le`: `dc(𝓗_A) ≤ N + 3`
  (`eq:geometry`, `eq:representation-score`).
* `monochromatic_true_of_template`, `template_negative_rectangle_singleton_side`,
  `exists_half_rectangle`, `half_le_rect_flip`: rectangle survival (`app:geometry`,
  "For the rank-six template…"); `rect_template_ge`, `rect_flip_ge`: `rect(F) ≥ 2^{-14}` and
  `rect(𝓗_A) ≥ 2^{-15}` (`eq:geometry`) for `N ≥ 1`, given the [APP05] input `APP05Template`.
* `fullLines` (`𝓛₀ = [N] × [N²]`), `card_fullLines`, `fullLine_point_mem_grid`,
  `card_linePoints_of_full`, `card_incidences_of_rows`, `lineDist` (`D_ℓ`): full-length
  lines (Theorem *Dimension after discarding targets*, `thm:prior`; `app:prior`; `app:query`).
* `slopePredictor` (`g_a`), `slope_cond_iff`, `slopePredictor_eq_of_incident`,
  `loss_lineDist_slopePredictor`: "One improper predictor for a whole slope" (`app:query`).
* `card_correct_negPoints_le_one`, `loss_lineDist_ge`, `three_eighths_bound`,
  `eq_of_loss_lineDist_le`, `proper_fits_at_most_one`: the proper-output step of
  `app:query`.

NOT formalized here: the homogeneous-rectangle theorem of Alon–Pach–Pinchasi–Radoičić–Sharir
[APP05] and its weighted form, which enter only as the explicit hypothesis `APP05Template`;
the probabilistic dimensions (`eq:exactprob`, `eq:avgprob`) and the remark that the
deterministic `N + 3` representation bounds them; random flips and all probability
statements (in particular Hoeffding's bound for the event that every full row has at least
`3N/8` negatives, which enters `eq_of_loss_lineDist_le` as a hypothesis); the running example
and figure; the dimension lower bounds and the learners. The counting part of
`sec:incidence` is in `SQDC/Counting.lean`.
-/

noncomputable section
open scoped BigOperators

namespace SQDC.Incidence

/-! ### The grid, the template, and incidence flips (`eq:grid`) -/

/-- The 1-based box `[N] × [2N²]` of pairs of naturals. -/
def grid (N : ℕ) : Finset (ℕ × ℕ) := Finset.Icc 1 N ×ˢ Finset.Icc 1 (2 * N ^ 2)

theorem mem_grid {N : ℕ} {p : ℕ × ℕ} :
    p ∈ grid N ↔ (1 ≤ p.1 ∧ p.1 ≤ N) ∧ (1 ≤ p.2 ∧ p.2 ≤ 2 * N ^ 2) := by
  simp [grid, Finset.mem_product, Finset.mem_Icc]

/-- The points `X = [N] × [2N²]`; `p = (x, y)`. -/
abbrev Point (N : ℕ) := {p : ℕ × ℕ // p ∈ grid N}

/-- The line indices `𝓛 = [N] × [2N²]`; `ℓ = (a, b)` represents `y = a x + b`. -/
abbrev Line (N : ℕ) := {ℓ : ℕ × ℕ // ℓ ∈ grid N}

/-- `|X| = |𝓛| = N · 2N² = 2N³` (Theorem *Sharp incidence separation* (`thm:main`): "on `2N³`
points"; `sec:incidence`: "`K = Q = 2N³`"). -/
theorem card_point (N : ℕ) : Fintype.card (Point N) = 2 * N ^ 3 := by
  rw [Fintype.card_coe, grid, Finset.card_product, Nat.card_Icc, Nat.card_Icc,
    Nat.add_sub_cancel, Nat.add_sub_cancel]
  ring

theorem card_line (N : ℕ) : Fintype.card (Line N) = 2 * N ^ 3 := card_point N

variable {N : ℕ}

/-- `p = (x, y)` lies on `ℓ = (a, b)`: `y = a x + b`. -/
def Incident (ℓ : Line N) (p : Point N) : Prop := p.1.2 = ℓ.1.1 * p.1.1 + ℓ.1.2

instance (ℓ : Line N) (p : Point N) : Decidable (Incident ℓ p) :=
  inferInstanceAs (Decidable (_ = _))

variable (N) in
/-- The template `F` of `eq:grid`: `F_{ℓ,p} = -1` (`false`) iff `y = a x + b`. -/
def template : Line N → Hyp (Point N) := fun ℓ p => decide (¬ Incident ℓ p)

theorem template_eq_false_iff (ℓ : Line N) (p : Point N) :
    template N ℓ p = false ↔ Incident ℓ p := by
  simp [template]

/-- An incidence flip: a table that is negative only at template incidences. It may
turn any subset of the negative template entries positive and is positive elsewhere. -/
def IsFlip (A : Line N → Hyp (Point N)) : Prop :=
  ∀ ℓ p, A ℓ p = false → Incident ℓ p

/-- Equivalently, every positive template entry stays positive. -/
theorem isFlip_iff (A : Line N → Hyp (Point N)) :
    IsFlip A ↔ ∀ ℓ p, template N ℓ p = true → A ℓ p = true := by
  refine ⟨fun h ℓ p hF => ?_, fun h ℓ p hA => ?_⟩
  · by_contra hA
    have := h ℓ p (by simpa using hA)
    simp [template, this] at hF
  · by_contra hI
    have := h ℓ p (by simp [template, hI])
    simp [hA] at this

/-- The template is itself a flip (no sign changed). -/
theorem template_isFlip : IsFlip (template N) := fun ℓ p h =>
  (template_eq_false_iff ℓ p).1 h

/-! ### The incidence count (`eq:incidencecount`) -/

variable (N) in
/-- The template incidences, i.e. the negative entries of `F`. -/
def incidences : Finset (Line N × Point N) :=
  Finset.univ.filter fun e => Incident e.1 e.2

theorem mem_incidences {e : Line N × Point N} : e ∈ incidences N ↔ Incident e.1 e.2 := by
  simp [incidences]

variable (N) in
/-- Triples `((a, x), b)` with `a, x ∈ [N]`, `b ∈ [2N²]` and `b ≤ 2N² - a x`. -/
private def triples : Finset ((ℕ × ℕ) × ℕ) :=
  ((Finset.Icc 1 N ×ˢ Finset.Icc 1 N) ×ˢ Finset.Icc 1 (2 * N ^ 2)).filter
    fun t => t.1.1 * t.1.2 + t.2 ≤ 2 * N ^ 2

private theorem card_incidences_eq_card_triples :
    (incidences N).card = (triples N).card := by
  refine Finset.card_bij (fun e _ => ((e.1.1.1, e.2.1.1), e.1.1.2)) ?_ ?_ ?_
  · rintro ⟨⟨⟨a, b⟩, hℓ⟩, ⟨⟨x, y⟩, hp⟩⟩ he
    rw [mem_incidences] at he
    simp only [Incident] at he
    rw [mem_grid] at hℓ hp
    subst he
    simp only [triples, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
    omega
  · rintro ⟨⟨⟨a, b⟩, hℓ⟩, ⟨⟨x, y⟩, hp⟩⟩ he ⟨⟨⟨a', b'⟩, hℓ'⟩, ⟨⟨x', y'⟩, hp'⟩⟩ he' h
    rw [mem_incidences] at he he'
    simp only [Incident] at he he'
    simp only [Prod.mk.injEq] at h
    obtain ⟨⟨rfl, rfl⟩, rfl⟩ := h
    have : y = y' := by rw [he, he']
    subst this
    rfl
  · rintro ⟨⟨a, x⟩, b⟩ ht
    simp only [triples, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at ht
    have hℓ : (a, b) ∈ grid N := by rw [mem_grid]; omega
    have hp : (x, a * x + b) ∈ grid N := by rw [mem_grid]; omega
    exact ⟨(⟨(a, b), hℓ⟩, ⟨(x, a * x + b), hp⟩),
      by rw [mem_incidences]; rfl, rfl⟩

private theorem card_triples :
    (triples N).card = ∑ u ∈ Finset.Icc 1 N ×ˢ Finset.Icc 1 N, (2 * N ^ 2 - u.1 * u.2) := by
  rw [triples, Finset.card_filter, Finset.sum_product]
  refine Finset.sum_congr rfl fun u hu => ?_
  rw [← Finset.card_filter]
  have : (Finset.Icc 1 (2 * N ^ 2)).filter (fun b => u.1 * u.2 + b ≤ 2 * N ^ 2) =
      Finset.Icc 1 (2 * N ^ 2 - u.1 * u.2) := by
    ext b; simp only [Finset.mem_filter, Finset.mem_Icc]; omega
  rw [this, Nat.card_Icc]
  omega

private theorem sum_Icc_id (n : ℕ) : ∑ a ∈ Finset.Icc 1 n, (a : ℚ) = n * (n + 1) / 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.sum_Icc_succ_top (by omega), ih]
    push_cast
    ring

/-- Proposition *Geometry and an upper representation* (`prop:geometry`), equation
`eq:incidencecount`, proved in `app:geometry` ("To count incidences…"): the template has
exactly `I = 2N⁴ - (N(N+1)/2)²` incidences. -/
theorem card_incidences :
    ((incidences N).card : ℚ) = 2 * N ^ 4 - (N * (N + 1) / 2) ^ 2 := by
  rw [card_incidences_eq_card_triples, card_triples, Nat.cast_sum]
  have hterm : ∀ u ∈ Finset.Icc 1 N ×ˢ Finset.Icc 1 N,
      (((2 * N ^ 2 - u.1 * u.2 : ℕ)) : ℚ) = 2 * (N : ℚ) ^ 2 - (u.1 : ℚ) * u.2 := by
    intro u hu
    simp only [Finset.mem_product, Finset.mem_Icc] at hu
    have : u.1 * u.2 ≤ 2 * N ^ 2 := by
      have := Nat.mul_le_mul hu.1.2 hu.2.2
      nlinarith
    push_cast [this]
    ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.card_product, Nat.card_Icc, Finset.sum_product]
  simp_rw [← Finset.mul_sum, ← Finset.sum_mul, sum_Icc_id]
  push_cast
  ring

/-- `app:geometry` ("To count incidences…"): `I = ∑_{a ∈ [N]} ∑_{x ∈ [N]} (2N² - ax)`; for
`a, x ∈ [N]` the intercepts giving an incidence are exactly `1 ≤ b ≤ 2N² - ax`. -/
theorem card_incidences_eq_sum :
    (incidences N).card = ∑ a ∈ Finset.Icc 1 N, ∑ x ∈ Finset.Icc 1 N, (2 * N ^ 2 - a * x) := by
  rw [card_incidences_eq_card_triples, card_triples, Finset.sum_product]

/-- `eq:incidencecount`: `I ≥ N⁴` (from `(N+1)² ≤ 4N²`; it also holds for `N = 0`). -/
theorem pow_four_le_card_incidences : N ^ 4 ≤ (incidences N).card := by
  have h := card_incidences (N := N)
  have : ((N : ℚ)) ^ 4 ≤ (incidences N).card := by
    rw [h]
    rcases Nat.eq_zero_or_pos N with hN | hN
    · subst hN; norm_num
    · have h1 : (1 : ℚ) ≤ N := by exact_mod_cast hN
      have h2 : ((N : ℚ) * (N + 1) / 2) ^ 2 ≤ (N : ℚ) ^ 4 := by
        have h3 : (N : ℚ) * (N + 1) / 2 ≤ (N : ℚ) ^ 2 := by nlinarith
        have h4 : 0 ≤ (N : ℚ) * (N + 1) / 2 := by positivity
        calc ((N : ℚ) * (N + 1) / 2) ^ 2 ≤ ((N : ℚ) ^ 2) ^ 2 := pow_le_pow_left₀ h4 h3 2
          _ = (N : ℚ) ^ 4 := by ring
      linarith
  exact_mod_cast this

/-- The flip with prescribed signs `σ` on the incidences and `+1` elsewhere. "Each incidence
corresponds to a different matrix entry, so all `I` signs can be chosen independently"
(`app:geometry`); a random flip takes `σ` uniform. -/
def flipOfSigns (σ : incidences N → Bool) : Line N → Hyp (Point N) := fun ℓ p =>
  if h : Incident ℓ p then σ ⟨(ℓ, p), mem_incidences.2 h⟩ else true

theorem isFlip_flipOfSigns (σ : incidences N → Bool) : IsFlip (flipOfSigns σ) := by
  intro ℓ p h
  by_contra hI
  simp [flipOfSigns, hI] at h

theorem flipOfSigns_apply (σ : incidences N → Bool) (e : incidences N) :
    flipOfSigns σ e.1.1 e.1.2 = σ e := by
  have h : Incident e.1.1 e.1.2 := mem_incidences.1 e.2
  simp [flipOfSigns, h]

/-- Every flip arises from its signs on the incidences, so flips correspond exactly to sign
vectors `incidences N → Bool`. -/
theorem flipOfSigns_restrict {A : Line N → Hyp (Point N)} (hA : IsFlip A) :
    flipOfSigns (fun e => A e.1.1 e.1.2) = A := by
  funext ℓ p
  by_cases h : Incident ℓ p
  · simp [flipOfSigns, h]
  · have : A ℓ p = true := by
      by_contra h'
      exact h (hA ℓ p (by simpa using h'))
    simp [flipOfSigns, h, this]

variable (N) in
/-- The row `(1, 2N²)` (a line index once `N ≥ 1`). -/
def topRow (hN : 1 ≤ N) : Line N :=
  ⟨(1, 2 * N ^ 2), by
    rw [mem_grid]
    have : 1 ≤ N ^ 2 := Nat.one_le_pow _ _ hN
    exact ⟨⟨le_rfl, hN⟩, by omega, le_rfl⟩⟩

/-- `app:geometry`: "Row `(1,2N²)` has no incidences …" -/
theorem topRow_not_incident (hN : 1 ≤ N) (p : Point N) : ¬ Incident (topRow N hN) p := by
  obtain ⟨⟨x, y⟩, hp⟩ := p
  rw [mem_grid] at hp
  simp only [Incident, topRow]
  omega

/-- `app:geometry`: "… and remains the all-positive hypothesis" in every flip. -/
theorem topRow_all_positive {A : Line N → Hyp (Point N)} (hA : IsFlip A) (hN : 1 ≤ N)
    (p : Point N) : A (topRow N hN) p = true := by
  by_contra h
  exact topRow_not_incident hN p (hA _ _ (by simpa using h))

/-! ### One intersection (`app:geometry`) -/

/-- `app:geometry`: "Two different lines in `𝓛` share at most one point." -/
theorem eq_of_incident_of_incident {ℓ ℓ' : Line N} (hne : ℓ ≠ ℓ') {p q : Point N}
    (hp : Incident ℓ p) (hp' : Incident ℓ' p) (hq : Incident ℓ q) (hq' : Incident ℓ' q) :
    p = q := by
  obtain ⟨⟨a, b⟩, hℓ⟩ := ℓ
  obtain ⟨⟨a', b'⟩, hℓ'⟩ := ℓ'
  obtain ⟨⟨x, y⟩, hp0⟩ := p
  obtain ⟨⟨x', y'⟩, hq0⟩ := q
  simp only [Incident] at hp hp' hq hq'
  by_cases hx : x = x'
  · subst hx
    have : y = y' := by rw [hp, hq]
    subst this
    rfl
  · exfalso
    have key : ((a : ℤ) - a') * ((x : ℤ) - x') = 0 := by
      have h1 : (y : ℤ) = a * x + b := by exact_mod_cast hp
      have h2 : (y : ℤ) = a' * x + b' := by exact_mod_cast hp'
      have h3 : (y' : ℤ) = a * x' + b := by exact_mod_cast hq
      have h4 : (y' : ℤ) = a' * x' + b' := by exact_mod_cast hq'
      linear_combination -(h1 - h2) + (h3 - h4)
    rcases mul_eq_zero.1 key with h | h
    · have ha : a = a' := by omega
      subst ha
      have hb : b = b' := by omega
      subst hb
      exact hne rfl
    · exact hx (by omega)

/-- `app:geometry`: "Hence their negative supports in any monotone flip share at most one
point." -/
theorem eq_of_negative_of_negative {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    {ℓ ℓ' : Line N} (hne : ℓ ≠ ℓ') {p q : Point N}
    (hp : A ℓ p = false) (hp' : A ℓ' p = false) (hq : A ℓ q = false) (hq' : A ℓ' q = false) :
    p = q :=
  eq_of_incident_of_incident hne (hA _ _ hp) (hA _ _ hp') (hA _ _ hq) (hA _ _ hq')

/-- `app:geometry`: "In particular, the table contains no all-negative `2×2` submatrix"
(for the template and for every flip). -/
theorem no_negative_two_by_two {A : Line N → Hyp (Point N)} (hA : IsFlip A) :
    ¬ ∃ (ℓ ℓ' : Line N) (p q : Point N), ℓ ≠ ℓ' ∧ p ≠ q ∧
      A ℓ p = false ∧ A ℓ' p = false ∧ A ℓ q = false ∧ A ℓ' q = false := by
  rintro ⟨ℓ, ℓ', p, q, hne, hpq, h1, h2, h3, h4⟩
  exact hpq (eq_of_negative_of_negative hA hne h1 h2 h3 h4)

/-! ### VC dimension (`eq:geometry`) -/

/-- An indexed class shatters `S` when every labelling of `S` is realized by some row. -/
def Shatters {ι X : Type*} (H : ι → Hyp X) (S : Finset X) : Prop :=
  ∀ f : X → Bool, ∃ i, ∀ x ∈ S, H i x = f x

/-- The VC dimension: the largest size of a shattered finite set. -/
def vcDim {ι X : Type*} (H : ι → Hyp X) : ℕ :=
  sSup {n | ∃ S : Finset X, Shatters H S ∧ S.card = n}

/-- `app:geometry`: "If three points were shattered, the row negative on all three and the
row negative on exactly two of them would share two negative points." Every set shattered by
a flip has at most two points. -/
theorem card_le_two_of_shatters {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    {S : Finset (Point N)} (hS : Shatters A S) : S.card ≤ 2 := by
  by_contra hlt
  obtain ⟨p, hp, q, hq, r, hr, hpq, hpr, hqr⟩ := (Finset.two_lt_card (s := S)).1 (by omega)
  obtain ⟨i, hi⟩ := hS fun _ => false
  obtain ⟨j, hj⟩ := hS fun z => decide (z = r)
  have hij : i ≠ j := by
    rintro rfl
    have h1 := hi r hr
    have h2 := hj r hr
    rw [h1] at h2
    simp at h2
  have hjp : A j p = false := by rw [hj p hp]; simpa using hpr
  have hjq : A j q = false := by rw [hj q hq]; simpa using hqr
  exact hpq (eq_of_negative_of_negative hA hij (hi p hp) hjp (hi q hq) hjq)

/-- Proposition *Geometry and an upper representation* (`prop:geometry`),
`eq:geometry`: `VC(𝓗_A) ≤ 2` for every incidence flip. -/
theorem vcDim_le_two {A : Line N → Hyp (Point N)} (hA : IsFlip A) : vcDim A ≤ 2 := by
  refine csSup_le' ?_
  rintro n ⟨S, hS, rfl⟩
  exact card_le_two_of_shatters hA hS

/-! ### The six-dimensional template representation (`prop:geometry`) -/

/-- A nonzero integer has square at least one. -/
private theorem one_le_sq_of_ne_zero {r : ℤ} (h : r ≠ 0) : (1 : ℝ) ≤ (r : ℝ) ^ 2 := by
  have : (1 : ℤ) ≤ r ^ 2 := by
    rcases lt_or_gt_of_ne h with h | h <;> nlinarith
  exact_mod_cast this

/-- The residual `y - a x - b` is an integer, zero exactly at an incidence. -/
private theorem residual_eq_zero_iff (ℓ : Line N) (p : Point N) :
    ((p.1.2 : ℤ) - ℓ.1.1 * p.1.1 - ℓ.1.2 = 0) ↔ Incident ℓ p := by
  simp only [Incident]
  omega

/-- The six point monomials `x², xy, y², x, y, 1`. -/
def templateFeatures (p : Point N) : Fin 6 → ℝ :=
  ![(p.1.1 : ℝ) ^ 2, (p.1.1 : ℝ) * p.1.2, (p.1.2 : ℝ) ^ 2, p.1.1, p.1.2, 1]

/-- The coefficients `a², -2a, 1, 2ab, -2b, b² - 1/2` of a line. -/
def templateWeights (ℓ : Line N) : Fin 6 → ℝ :=
  ![(ℓ.1.1 : ℝ) ^ 2, -2 * ℓ.1.1, 1, 2 * ℓ.1.1 * ℓ.1.2, -2 * ℓ.1.2, (ℓ.1.2 : ℝ) ^ 2 - 1 / 2]

/-- `app:geometry`: the displayed expansion
`(ax+b-y)² - 1/2 = a²x² - 2axy + y² + 2abx - 2by + b² - 1/2`. -/
theorem template_polynomial (a b x y : ℝ) :
    (a * x + b - y) ^ 2 - 1 / 2 =
      a ^ 2 * x ^ 2 - 2 * a * x * y + y ^ 2 + 2 * a * b * x - 2 * b * y + b ^ 2 - 1 / 2 := by
  ring

/-- The template score is `⟨w_ℓ, φ(p)⟩ = (ax+b-y)² - 1/2`. -/
theorem templateScore_eq (ℓ : Line N) (p : Point N) :
    ∑ k, templateWeights ℓ k * templateFeatures p k =
      ((ℓ.1.1 : ℝ) * p.1.1 + ℓ.1.2 - p.1.2) ^ 2 - 1 / 2 := by
  simp only [Fin.sum_univ_succ, Fin.sum_univ_zero, templateWeights, templateFeatures]
  simp
  ring

/-- `app:geometry`: the score "is negative exactly at an incidence …" -/
theorem templateScore_neg_iff (ℓ : Line N) (p : Point N) :
    ((ℓ.1.1 : ℝ) * p.1.1 + ℓ.1.2 - p.1.2) ^ 2 - 1 / 2 < 0 ↔ Incident ℓ p := by
  constructor
  · intro h
    by_contra hI
    have hr := one_le_sq_of_ne_zero (mt (residual_eq_zero_iff ℓ p).1 hI)
    push_cast at hr
    nlinarith
  · intro h
    have h0 : (p.1.2 : ℝ) = ℓ.1.1 * p.1.1 + ℓ.1.2 := by exact_mod_cast h
    rw [h0]
    norm_num

/-- `app:geometry`: "… and positive otherwise." -/
theorem templateScore_pos_iff (ℓ : Line N) (p : Point N) :
    0 < ((ℓ.1.1 : ℝ) * p.1.1 + ℓ.1.2 - p.1.2) ^ 2 - 1 / 2 ↔ ¬ Incident ℓ p := by
  rw [← templateScore_neg_iff]
  constructor
  · intro h h'
    linarith
  · intro h
    rcases lt_trichotomy (((ℓ.1.1 : ℝ) * p.1.1 + ℓ.1.2 - p.1.2) ^ 2 - 1 / 2) 0 with
      h' | h' | h'
    · exact absurd h' h
    · exfalso
      have : ((ℓ.1.1 : ℝ) * p.1.1 + ℓ.1.2 - p.1.2) ^ 2 = 1 / 2 := by linarith
      by_cases hI : Incident ℓ p
      · have h0 : (p.1.2 : ℝ) = ℓ.1.1 * p.1.1 + ℓ.1.2 := by exact_mod_cast hI
        rw [h0] at this
        norm_num at this
      · have hr := one_le_sq_of_ne_zero (mt (residual_eq_zero_iff ℓ p).1 hI)
        push_cast at hr
        nlinarith
    · exact h'

/-- Proposition *Geometry and an upper representation* (`prop:geometry`): "The template has
sign-rank at most six", via the six point monomials of `app:geometry` (strict realization
`eq:dcdef`). -/
theorem template_embedsAt_six : EmbedsAt (template N) 6 := by
  refine ⟨templateFeatures, fun ℓ => ⟨templateWeights ℓ, fun p => ?_⟩⟩
  rw [templateScore_eq]
  by_cases hI : Incident ℓ p
  · have hF : template N ℓ p = false := (template_eq_false_iff ℓ p).2 hI
    rw [hF, labelValue]
    have := (templateScore_neg_iff ℓ p).2 hI
    simp only [Bool.false_eq_true, ↓reduceIte]
    linarith
  · have hF : template N ℓ p = true := by simpa [template] using hI
    rw [hF, labelValue]
    have := (templateScore_pos_iff ℓ p).2 hI
    simpa using this

/-- `prop:geometry`: the template has `dc(F) ≤ 6`. -/
theorem template_dc_le_six : dc (template N) ≤ 6 :=
  dc_le_of_embedsAt _ template_embedsAt_six

/-! ### The `N + 3` upper representation (`eq:representation-score`) -/

/-- `q_ℓ(t)`: the label of row `ℓ` at `(t, at+b)`, taken `+1` when that point is outside
the domain (`sec:incidence`, before `eq:representation-score`). -/
def lineLabel (A : Line N → Hyp (Point N)) (ℓ : Line N) (t : ℕ) : ℝ :=
  if h : (t, ℓ.1.1 * t + ℓ.1.2) ∈ grid N then labelValue (A ℓ ⟨_, h⟩) else 1

/-- The `N + 3` features `𝟙{x=t}` (`t ∈ [N]`, stored at index `t - 1`), `y`, `xy`, `y²`. -/
def upperFeatures (p : Point N) : Fin (N + 3) → ℝ :=
  Fin.addCases (motive := fun _ => ℝ) (fun t : Fin N => if p.1.1 = t.1 + 1 then 1 else 0)
    ![(p.1.2 : ℝ), (p.1.1 : ℝ) * p.1.2, (p.1.2 : ℝ) ^ 2]

/-- The weights `q_ℓ(t) + 2(at+b)²` on `𝟙{x=t}` and `-4b, -4a, 2` on `y, xy, y²`
(`app:geometry`, last paragraph). -/
def upperWeights (A : Line N → Hyp (Point N)) (ℓ : Line N) : Fin (N + 3) → ℝ :=
  Fin.addCases (motive := fun _ => ℝ)
    (fun t : Fin N => lineLabel A ℓ (t.1 + 1) + 2 * ((ℓ.1.1 : ℝ) * (t.1 + 1) + ℓ.1.2) ^ 2)
    ![-4 * (ℓ.1.2 : ℝ), -4 * (ℓ.1.1 : ℝ), 2]

/-- `app:geometry`: "The resulting score is exactly `eq:representation-score`",
`q_ℓ(x) + 2(y - ax - b)²`. -/
theorem upperScore_eq (A : Line N → Hyp (Point N)) (ℓ : Line N) (p : Point N) :
    ∑ k, upperWeights A ℓ k * upperFeatures p k =
      lineLabel A ℓ p.1.1 + 2 * ((p.1.2 : ℝ) - ℓ.1.1 * p.1.1 - ℓ.1.2) ^ 2 := by
  obtain ⟨⟨x, y⟩, hp⟩ := p
  have hx := (mem_grid.1 hp).1
  simp only [upperWeights, upperFeatures, Fin.sum_univ_add, Fin.addCases_left,
    Fin.addCases_right, Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons]
  have hsum : ∑ t : Fin N, (lineLabel A ℓ (t.1 + 1) +
      2 * ((ℓ.1.1 : ℝ) * (t.1 + 1) + ℓ.1.2) ^ 2) * (if x = t.1 + 1 then 1 else 0) =
      lineLabel A ℓ x + 2 * ((ℓ.1.1 : ℝ) * x + ℓ.1.2) ^ 2 := by
    rw [Finset.sum_eq_single (⟨x - 1, by omega⟩ : Fin N)]
    · have h1 : x - 1 + 1 = x := by omega
      have h2 : ((x - 1 : ℕ) : ℝ) + 1 = (x : ℝ) := by exact_mod_cast h1
      simp only [h1, h2, ↓reduceIte, mul_one]
    · intro t _ ht
      have : x ≠ t.1 + 1 := by
        intro h
        apply ht
        ext
        simp only
        omega
      simp [this]
    · simp
  rw [hsum]
  ring

/-- `app:geometry`: "On incidences it equals `q_ℓ(x) = A_{ℓ,(x,y)}`." -/
theorem upperScore_of_incident (A : Line N → Hyp (Point N)) {ℓ : Line N} {p : Point N}
    (h : Incident ℓ p) :
    ∑ k, upperWeights A ℓ k * upperFeatures p k = labelValue (A ℓ p) := by
  rw [upperScore_eq]
  obtain ⟨⟨x, y⟩, hp⟩ := p
  simp only [Incident] at h
  subst h
  have hmem : (x, ℓ.1.1 * x + ℓ.1.2) ∈ grid N := hp
  simp only [lineLabel, hmem, ↓reduceDIte]
  push_cast
  ring

/-- `app:geometry`: "Off incidences, the squared integer residual is at least one, and the
score is at least `-1 + 2 = 1`." -/
theorem one_le_upperScore_of_not_incident (A : Line N → Hyp (Point N)) {ℓ : Line N}
    {p : Point N} (h : ¬ Incident ℓ p) :
    1 ≤ ∑ k, upperWeights A ℓ k * upperFeatures p k := by
  rw [upperScore_eq]
  have hr := one_le_sq_of_ne_zero (mt (residual_eq_zero_iff ℓ p).1 h)
  push_cast at hr
  have hq : -1 ≤ lineLabel A ℓ p.1.1 := by
    unfold lineLabel labelValue
    split_ifs <;> norm_num
  linarith

/-- Proposition *Geometry and an upper representation* (`prop:geometry`), `eq:geometry`:
every incidence flip has a strict realization with the `N + 3` features. -/
theorem flip_embedsAt {A : Line N → Hyp (Point N)} (hA : IsFlip A) : EmbedsAt A (N + 3) := by
  refine ⟨upperFeatures, fun ℓ => ⟨upperWeights A ℓ, fun p => ?_⟩⟩
  by_cases hI : Incident ℓ p
  · rw [upperScore_of_incident A hI]
    cases A ℓ p <;> norm_num [labelValue]
  · have hpos : A ℓ p = true := by
      by_contra h
      exact hI (hA ℓ p (by simpa using h))
    rw [hpos, labelValue]
    have := one_le_upperScore_of_not_incident A hI
    simp only [↓reduceIte, one_mul]
    linarith

/-- Proposition *Geometry and an upper representation* (`prop:geometry`), `eq:geometry`:
`dc(𝓗_A) ≤ N + 3` for every incidence flip. -/
theorem flip_dc_le {A : Line N → Hyp (Point N)} (hA : IsFlip A) : dc A ≤ N + 3 :=
  dc_le_of_embedsAt _ (flip_embedsAt hA)

/-! ### Rectangle survival (`app:geometry`, "For the rank-six template…") -/

/-- `app:geometry`: "A positive rectangle remains positive after flipping." -/
theorem monochromatic_true_of_template {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    {S : Finset (Point N)} {T : Finset (Line N)} (h : Monochromatic (template N) S T true) :
    Monochromatic A S T true := fun p hp ℓ hℓ =>
  ((isFlip_iff A).1 hA) ℓ p (h p hp ℓ hℓ)

/-- A nonempty negative rectangle of any flip has a singleton side. -/
theorem card_eq_one_of_monochromatic_false {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    {S : Finset (Point N)} {T : Finset (Line N)} (h : Monochromatic A S T false)
    (hS : S.Nonempty) (hT : T.Nonempty) : S.card = 1 ∨ T.card = 1 := by
  by_contra hc
  push Not at hc
  have hS2 : 1 < S.card := lt_of_le_of_ne (Finset.one_le_card.2 hS) (Ne.symm hc.1)
  have hT2 : 1 < T.card := lt_of_le_of_ne (Finset.one_le_card.2 hT) (Ne.symm hc.2)
  obtain ⟨p, hp, q, hq, hpq⟩ := Finset.one_lt_card.1 hS2
  obtain ⟨ℓ, hℓ, ℓ', hℓ', hne⟩ := Finset.one_lt_card.1 hT2
  exact no_negative_two_by_two hA
    ⟨ℓ, ℓ', p, q, hne, hpq, h p hp ℓ hℓ, h p hp ℓ' hℓ', h q hq ℓ hℓ, h q hq ℓ' hℓ'⟩

/-- `app:geometry`: "A nonempty negative rectangle has a singleton side, because there is no
negative `2×2`" (for the template `F`). -/
theorem template_negative_rectangle_singleton_side {S : Finset (Point N)}
    {T : Finset (Line N)} (h : Monochromatic (template N) S T false)
    (hS : S.Nonempty) (hT : T.Nonempty) : S.card = 1 ∨ T.card = 1 :=
  card_eq_one_of_monochromatic_false template_isFlip h hS hT

/-- Splitting by a Boolean label: one part keeps at least half of the weight. -/
private theorem half_le_of_split {α : Type*} [Fintype α] (D : FinDist α) (T : Finset α)
    (f : α → Bool) :
    D.massOf T / 2 ≤ D.massOf (T.filter fun i => f i = true) ∨
      D.massOf T / 2 ≤ D.massOf (T.filter fun i => ¬ f i = true) := by
  have hsplit := Finset.sum_filter_add_sum_filter_not T (fun i => f i = true) D.mass
  unfold FinDist.massOf
  by_contra hc
  push Not at hc
  linarith [hc.1, hc.2]

/-- `app:geometry`: "Partition the other side according to its labels in `A`. The heavier
part retains at least half the rectangle's product mass and is monochromatic in `A`." For
any product weights and any monochromatic rectangle `S × T` of `F`, the flip `A` has a
monochromatic rectangle inside `S × T` with at least half its product mass. -/
theorem exists_half_rectangle {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    (μ : FinDist (Point N)) (ν : FinDist (Line N)) {S : Finset (Point N)}
    {T : Finset (Line N)} {c : Bool} (h : Monochromatic (template N) S T c) :
    ∃ S' ⊆ S, ∃ T' ⊆ T, ∃ c', Monochromatic A S' T' c' ∧
      μ.massOf S * ν.massOf T / 2 ≤ μ.massOf S' * ν.massOf T' := by
  have hμ := μ.massOf_nonneg S
  have hν := ν.massOf_nonneg T
  cases c with
  | true =>
    exact ⟨S, subset_rfl, T, subset_rfl, true, monochromatic_true_of_template hA h,
      by nlinarith [mul_nonneg hμ hν]⟩
  | false =>
    rcases S.eq_empty_or_nonempty with hS | hS
    · exact ⟨S, subset_rfl, T, subset_rfl, true, by simp [Monochromatic, hS],
        by simp [hS, FinDist.massOf]⟩
    rcases T.eq_empty_or_nonempty with hT | hT
    · exact ⟨S, subset_rfl, T, subset_rfl, true, by simp [Monochromatic, hT],
        by simp [hT, FinDist.massOf]⟩
    rcases template_negative_rectangle_singleton_side h hS hT with h1 | h1
    · obtain ⟨p, rfl⟩ := Finset.card_eq_one.1 h1
      rcases half_le_of_split ν T (fun ℓ => A ℓ p) with h2 | h2
      · refine ⟨{p}, subset_rfl, T.filter fun ℓ => A ℓ p = true, Finset.filter_subset _ _,
          true, ?_, ?_⟩
        · intro z hz ℓ hℓ
          rw [Finset.mem_singleton.1 hz]
          exact (Finset.mem_filter.1 hℓ).2
        · nlinarith
      · refine ⟨{p}, subset_rfl, T.filter fun ℓ => ¬ A ℓ p = true, Finset.filter_subset _ _,
          false, ?_, ?_⟩
        · intro z hz ℓ hℓ
          rw [Finset.mem_singleton.1 hz]
          simpa using (Finset.mem_filter.1 hℓ).2
        · nlinarith
    · obtain ⟨ℓ, rfl⟩ := Finset.card_eq_one.1 h1
      rcases half_le_of_split μ S (fun p => A ℓ p) with h2 | h2
      · refine ⟨S.filter fun p => A ℓ p = true, Finset.filter_subset _ _, {ℓ}, subset_rfl,
          true, ?_, ?_⟩
        · intro z hz ℓ' hℓ'
          rw [Finset.mem_singleton.1 hℓ']
          exact (Finset.mem_filter.1 hz).2
        · nlinarith
      · refine ⟨S.filter fun p => ¬ A ℓ p = true, Finset.filter_subset _ _, {ℓ}, subset_rfl,
          false, ?_, ?_⟩
        · intro z hz ℓ' hℓ'
          rw [Finset.mem_singleton.1 hℓ']
          simpa using (Finset.mem_filter.1 hz).2
        · nlinarith

private theorem rect_nonneg {X ι : Type*} [Fintype X] [Fintype ι] (H : ι → Hyp X) :
    0 ≤ rect H :=
  Real.iInf_nonneg fun μ => Real.iInf_nonneg fun ν => rectValue_nonneg H μ ν

/-- `app:geometry`: a rectangle bound `r` for the template gives `r/2` for every flip
(`rect` is `eq:rectdef`, with weights on the indexed rows). -/
theorem half_le_rect_flip {A : Line N → Hyp (Point N)} (hA : IsFlip A) {r : ℝ}
    (hr : r ≤ rect (template N)) : r / 2 ≤ rect A := by
  by_cases hne : Nonempty (Point N)
  · refine le_rect_of_forall fun μ ν => ?_
    obtain ⟨S, T, c, hm, hmass⟩ := exists_rectangle_of_le_rect hr μ ν
    obtain ⟨S', -, T', -, c', hm', hmass'⟩ := exists_half_rectangle hA μ ν hm
    exact ⟨S', T', c', hm', by linarith⟩
  · have hempty : IsEmpty (FinDist (Point N)) := ⟨fun μ => by
      have h := μ.total
      have : IsEmpty (Point N) := not_nonempty_iff.1 hne
      simp at h⟩
    have h0 : rect (template N) = 0 := Real.iInf_of_isEmpty _
    have := rect_nonneg A
    linarith

/-- The weighted homogeneous-rectangle theorem of Alon–Pach–Pinchasi–Radoičić–Sharir
(`app:geometry`, [APP05] in the form of [HHPTZ22, Theorem 1.9]) for the template: sign-rank
at most `d` gives, under every product distribution, a monochromatic rectangle of product mass
at least `2^{-2d-2}`. This is an external input, NOT proved here; it is used only as an
explicit hypothesis. It is stated per product distribution, so it holds vacuously when the
grid is empty (`N = 0`) and is never stronger than the cited theorem. -/
def APP05Template (N : ℕ) : Prop :=
  ∀ d : ℕ, EmbedsAt (template N) d →
    ∀ (μ : FinDist (Point N)) (ν : FinDist (Line N)),
      ∃ (S : Finset (Point N)) (T : Finset (Line N)) (c : Bool),
        Monochromatic (template N) S T c ∧ (1 / 2 ^ (2 * d + 2) : ℝ) ≤ μ.massOf S * ν.massOf T

/-- For `N ≥ 1` the point `(1,1)` lies in the grid. -/
theorem one_one_mem_grid (hN : 1 ≤ N) : ((1, 1) : ℕ × ℕ) ∈ grid N := by
  rw [mem_grid]
  have : 1 ≤ N ^ 2 := Nat.one_le_pow _ _ hN
  omega

/-- `app:geometry`: "For the rank-six template, every product distribution therefore has a
monochromatic rectangle of mass at least `2^{-14}`" (`2·6 + 2 = 14`), given [APP05]. -/
theorem rect_template_ge (hN : 1 ≤ N) (hAPP : APP05Template N) :
    (1 / 2 ^ 14 : ℝ) ≤ rect (template N) := by
  have : Nonempty (Point N) := ⟨⟨_, one_one_mem_grid hN⟩⟩
  have : Nonempty (Line N) := ⟨⟨_, one_one_mem_grid hN⟩⟩
  refine le_rect_of_forall fun μ ν => ?_
  obtain ⟨S, T, c, hm, hmass⟩ := hAPP 6 template_embedsAt_six μ ν
  exact ⟨S, T, c, hm, by norm_num at hmass ⊢; exact hmass⟩

/-- Proposition *Geometry and an upper representation* (`prop:geometry`), `eq:geometry`:
`rect(𝓗_A) ≥ 2^{-15}` for every incidence flip, conditional on the [APP05] input. -/
theorem rect_flip_ge (hN : 1 ≤ N) (hAPP : APP05Template N) {A : Line N → Hyp (Point N)}
    (hA : IsFlip A) : (1 / 2 ^ 15 : ℝ) ≤ rect A := by
  have := half_le_rect_flip hA (rect_template_ge hN hAPP)
  norm_num at this ⊢
  exact this

/-! ### Full-length lines (`thm:prior`, `app:prior`, `app:query`) -/

variable (N) in
/-- The full-length lines `𝓛₀ = [N] × [N²]`. -/
def fullLines : Finset (Line N) := Finset.univ.filter fun ℓ => ℓ.1.2 ≤ N ^ 2

theorem mem_fullLines {ℓ : Line N} :
    ℓ ∈ fullLines N ↔ (1 ≤ ℓ.1.1 ∧ ℓ.1.1 ≤ N) ∧ (1 ≤ ℓ.1.2 ∧ ℓ.1.2 ≤ N ^ 2) := by
  have := mem_grid.1 ℓ.2
  simp only [fullLines, Finset.mem_filter, Finset.mem_univ, true_and]
  omega

/-- Theorem *Dimension after discarding targets* (`thm:prior`): `L = |𝓛₀| = N³`. -/
theorem card_fullLines : (fullLines N).card = N ^ 3 := by
  have h : (fullLines N).map (Function.Embedding.subtype _) =
      Finset.Icc 1 N ×ˢ Finset.Icc 1 (N ^ 2) := by
    ext ⟨a, b⟩
    simp only [Finset.mem_map, Function.Embedding.coe_subtype, Finset.mem_product,
      Finset.mem_Icc]
    constructor
    · rintro ⟨ℓ, hℓ, hℓeq⟩
      have := mem_fullLines.1 hℓ
      rw [hℓeq] at this
      exact this
    · intro hab
      have hmem : (a, b) ∈ grid N := by rw [mem_grid]; omega
      exact ⟨⟨(a, b), hmem⟩, mem_fullLines.2 hab, rfl⟩
  rw [← Finset.card_map, h, Finset.card_product, Nat.card_Icc, Nat.card_Icc,
    Nat.add_sub_cancel, Nat.add_sub_cancel]
  ring

/-- The template points of a row (its negative support in `F`). -/
def linePoints (ℓ : Line N) : Finset (Point N) := Finset.univ.filter fun p => Incident ℓ p

theorem mem_linePoints {ℓ : Line N} {p : Point N} : p ∈ linePoints ℓ ↔ Incident ℓ p := by
  simp [linePoints]

/-- `thm:prior`/`app:query`: every template point `(t, at+b)`, `t ∈ [N]`, of a full-length
line lies in the grid. -/
theorem fullLine_point_mem_grid {ℓ : Line N} (hℓ : ℓ ∈ fullLines N) {t : ℕ}
    (ht : 1 ≤ t ∧ t ≤ N) : (t, ℓ.1.1 * t + ℓ.1.2) ∈ grid N := by
  have h := mem_fullLines.1 hℓ
  rw [mem_grid]
  have : ℓ.1.1 * t ≤ N * N := Nat.mul_le_mul h.1.2 ht.2
  refine ⟨ht, by omega, ?_⟩
  nlinarith

/-- `app:prior`, `app:query`: each full-length line has exactly `N` template points. -/
theorem card_linePoints_of_full {ℓ : Line N} (hℓ : ℓ ∈ fullLines N) :
    (linePoints ℓ).card = N := by
  have : (linePoints ℓ).card = (Finset.Icc 1 N).card := by
    refine Finset.card_bij (fun p _ => p.1.1) ?_ ?_ ?_
    · intro p _
      exact Finset.mem_Icc.2 (mem_grid.1 p.2).1
    · rintro ⟨⟨x, y⟩, hp⟩ h ⟨⟨x', y'⟩, hq⟩ h' (hx : x = x')
      rw [mem_linePoints] at h h'
      simp only [Incident] at h h'
      subst hx
      have : y = y' := by rw [h, h']
      subst this
      rfl
    · intro t ht
      have hmem := fullLine_point_mem_grid hℓ (Finset.mem_Icc.1 ht)
      exact ⟨⟨_, hmem⟩, mem_linePoints.2 rfl, rfl⟩
  rw [this, Nat.card_Icc]
  omega

/-- `app:prior`: "Each full-length row contains `N` such entries, so `|J_R| = gN`." -/
theorem card_incidences_of_rows {R : Finset (Line N)} (hR : R ⊆ fullLines N) :
    ((incidences N).filter fun e => e.1 ∈ R).card = R.card * N := by
  rw [Finset.card_filter]
  simp only [incidences, Finset.sum_filter, Fintype.sum_prod_type]
  have : ∀ ℓ : Line N, (∑ p : Point N, if Incident ℓ p then (if ℓ ∈ R then 1 else 0) else 0) =
      if ℓ ∈ R then N else 0 := by
    intro ℓ
    split_ifs with hℓ
    · have := card_linePoints_of_full (hR hℓ)
      rw [linePoints, Finset.card_filter] at this
      simpa using this
    · simp
  rw [Finset.sum_congr rfl fun ℓ _ => this ℓ, Finset.sum_ite_mem, Finset.univ_inter,
    Finset.sum_const, smul_eq_mul]

/-- `D_ℓ`: the uniform distribution on the `N` template points of a full-length line. -/
def lineDist {ℓ : Line N} (hℓ : ℓ ∈ fullLines N) : FinDist (Point N) where
  mass p := if Incident ℓ p then 1 / (N : ℝ) else 0
  nonneg p := by split_ifs <;> positivity
  total := by
    have hN : (N : ℝ) ≠ 0 := by
      have := (mem_fullLines.1 hℓ).1
      exact_mod_cast (show N ≠ 0 by omega)
    rw [Finset.sum_ite, Finset.sum_const_zero, add_zero, Finset.sum_const, nsmul_eq_mul]
    have : (Finset.univ.filter fun p => Incident ℓ p).card = N := card_linePoints_of_full hℓ
    rw [this]
    field_simp

/-! ### One improper predictor for a whole slope (`app:query`) -/

/-- `g_a(x,y)`: the label of row `(a, y - ax)` at `(x, y)` when `1 ≤ y - ax ≤ 2N²` (and
`a ∈ [N]`), and `+1` otherwise. (`y - a x` is truncated subtraction; see
`slope_cond_iff`.) -/
def slopePredictor (A : Line N → Hyp (Point N)) (a : ℕ) : Hyp (Point N) := fun p =>
  if h : (a, p.1.2 - a * p.1.1) ∈ grid N then A ⟨_, h⟩ p else true

/-- The condition in `slopePredictor` is exactly `1 ≤ y - ax ≤ 2N²` over the integers, for
`a ∈ [N]`. -/
theorem slope_cond_iff {a : ℕ} (ha : 1 ≤ a ∧ a ≤ N) (p : Point N) :
    (a, p.1.2 - a * p.1.1) ∈ grid N ↔
      1 ≤ (p.1.2 : ℤ) - a * p.1.1 ∧ (p.1.2 : ℤ) - a * p.1.1 ≤ 2 * N ^ 2 := by
  rw [mem_grid]
  have hm : (a : ℤ) * p.1.1 = ((a * p.1.1 : ℕ) : ℤ) := by push_cast; ring
  have hN2 : 2 * (N : ℤ) ^ 2 = ((2 * N ^ 2 : ℕ) : ℤ) := by push_cast; ring
  rw [hm, hN2]
  generalize a * p.1.1 = m
  generalize 2 * N ^ 2 = M
  omega

/-- `app:query`: "At a point of a line `(a,b) ∈ 𝓛₀`, the recovered intercept is exactly `b`",
so `g_a` agrees with `h_{(a,b)}` at every template point, for every table `A` (in particular
every flip). The hypothesis `(a,b) ∈ 𝓛₀` is not needed: this holds for every line in `𝓛`. -/
theorem slopePredictor_eq_of_incident (A : Line N → Hyp (Point N)) {ℓ : Line N}
    {p : Point N} (h : Incident ℓ p) : slopePredictor A ℓ.1.1 p = A ℓ p := by
  have hb : p.1.2 - ℓ.1.1 * p.1.1 = ℓ.1.2 := by
    simp only [Incident] at h
    omega
  have hmem : (ℓ.1.1, p.1.2 - ℓ.1.1 * p.1.1) ∈ grid N := by rw [hb]; exact ℓ.2
  have hrow : (⟨_, hmem⟩ : Line N) = ℓ := Subtype.ext (Prod.ext rfl hb)
  unfold slopePredictor
  simp only [hmem, ↓reduceDIte, hrow]

/-- `app:query`: `g_a` has zero error under every distribution supported on the template
points of a line of slope `a`. -/
theorem loss_slopePredictor_eq_zero (A : Line N → Hyp (Point N)) {ℓ : Line N}
    (D : FinDist (Point N)) (hD : ∀ p, D.mass p ≠ 0 → Incident ℓ p) :
    loss D (A ℓ) (slopePredictor A ℓ.1.1) = 0 := by
  unfold loss
  refine Finset.sum_eq_zero fun p _ => ?_
  by_cases hp : D.mass p = 0
  · simp [hp]
  · simp [slopePredictor_eq_of_incident A (hD p hp)]

/-- `app:query`, "One improper predictor for a whole slope": "`g_a` has zero error under
`D_{(a,b)}` for all `N²` full-length lines of slope `a`, for every choice of incidence
signs." -/
theorem loss_lineDist_slopePredictor (A : Line N → Hyp (Point N)) {ℓ : Line N}
    (hℓ : ℓ ∈ fullLines N) : loss (lineDist hℓ) (A ℓ) (slopePredictor A ℓ.1.1) = 0 :=
  loss_slopePredictor_eq_zero A _ fun p hp => by
    by_contra h
    exact hp (by simp [lineDist, h])

/-! ### Proper outputs fit at most one full line (`app:query`) -/

/-- The negative points of row `ℓ`. -/
def negPoints (A : Line N → Hyp (Point N)) (ℓ : Line N) : Finset (Point N) :=
  Finset.univ.filter fun p => A ℓ p = false

/-- `app:query`: "any row other than `ℓ` can correctly label at most one of `h_ℓ`'s negative
points." -/
theorem card_correct_negPoints_le_one {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    {ℓ ℓ' : Line N} (hne : ℓ' ≠ ℓ) :
    ((negPoints A ℓ).filter fun p => A ℓ' p = A ℓ p).card ≤ 1 := by
  refine Finset.card_le_one.2 fun p hp q hq => ?_
  simp only [negPoints, Finset.mem_filter, Finset.mem_univ, true_and] at hp hq
  exact eq_of_negative_of_negative hA (Ne.symm hne) hp.1 (hp.2.trans hp.1) hq.1
    (hq.2.trans hq.1)

/-- `app:query`: if `h_ℓ` has at least `3N/8` negative entries, every other row has error at
least `(3N/8 - 1)/N` under `D_ℓ`. -/
theorem loss_lineDist_ge {A : Line N → Hyp (Point N)} (hA : IsFlip A) {ℓ ℓ' : Line N}
    (hℓ : ℓ ∈ fullLines N) (hne : ℓ' ≠ ℓ)
    (hneg : (3 * N / 8 : ℝ) ≤ (negPoints A ℓ).card) :
    (3 * N / 8 - 1) / N ≤ loss (lineDist hℓ) (A ℓ) (A ℓ') := by
  have hN : (0 : ℝ) < N := by
    have := (mem_fullLines.1 hℓ).1
    exact_mod_cast (show 0 < N by omega)
  -- the loss counts the template points of `ℓ` where `ℓ'` disagrees, weighted `1/N`
  have hloss : loss (lineDist hℓ) (A ℓ) (A ℓ') =
      ((linePoints ℓ).filter fun p => ¬ A ℓ' p = A ℓ p).card * (1 / (N : ℝ)) := by
    unfold loss lineDist linePoints
    rw [Finset.filter_filter, ← nsmul_eq_mul, ← Finset.sum_const, Finset.sum_filter]
    refine Finset.sum_congr rfl fun p _ => ?_
    by_cases h1 : Incident ℓ p <;> by_cases h2 : A ℓ' p = A ℓ p <;> simp [h1, h2]
  have hsub : (negPoints A ℓ).filter (fun p => ¬ A ℓ' p = A ℓ p) ⊆
      (linePoints ℓ).filter fun p => ¬ A ℓ' p = A ℓ p := by
    intro p hp
    simp only [negPoints, linePoints, Finset.mem_filter, Finset.mem_univ, true_and] at hp ⊢
    exact ⟨hA ℓ p hp.1, hp.2⟩
  have hsplit := Finset.card_filter_add_card_filter_not (s := negPoints A ℓ)
    (fun p => A ℓ' p = A ℓ p)
  have hone := card_correct_negPoints_le_one hA hne
  have hwrong : ((negPoints A ℓ).card : ℝ) - 1 ≤
      ((linePoints ℓ).filter fun p => ¬ A ℓ' p = A ℓ p).card := by
    have h1 := Finset.card_le_card hsub
    have : (negPoints A ℓ).card ≤
        ((linePoints ℓ).filter fun p => ¬ A ℓ' p = A ℓ p).card + 1 := by omega
    have : ((negPoints A ℓ).card : ℝ) ≤
        ((linePoints ℓ).filter fun p => ¬ A ℓ' p = A ℓ p).card + 1 := by exact_mod_cast this
    linarith
  rw [hloss, div_eq_mul_one_div]
  exact mul_le_mul_of_nonneg_right (by linarith) (by positivity)

/-- `app:query`: "`(3N/8 - 1)/N = 3/8 - 1/N > 1/3`, where the final inequality uses
`N ≥ 25`." -/
theorem three_eighths_bound (hN : 25 ≤ N) :
    (3 * N / 8 - 1) / (N : ℝ) = 3 / 8 - 1 / N ∧ (1 / 3 : ℝ) < 3 / 8 - 1 / N := by
  have hN' : (25 : ℝ) ≤ N := by exact_mod_cast hN
  have hpos : (0 : ℝ) < N := by linarith
  constructor
  · field_simp
  · have h1 : (0 : ℝ) < (N - 24) / (24 * N) := div_pos (by linarith) (by positivity)
    have h2 : (3 / 8 : ℝ) - 1 / N = 1 / 3 + (N - 24) / (24 * N) := by
      field_simp
      ring
    linarith

/-- `app:query`: "Thus every proper predictor has error at most `1/3` on at most one
full-line instance", on the event that every full row has at least `3N/8` negative entries
(`N ≥ 25`). A row `h_{ℓ'}` with error at most `1/3` under `D_ℓ` is the row `ℓ` itself. -/
theorem eq_of_loss_lineDist_le {A : Line N → Hyp (Point N)} (hA : IsFlip A) (hN : 25 ≤ N)
    (hneg : ∀ ℓ ∈ fullLines N, (3 * N / 8 : ℝ) ≤ (negPoints A ℓ).card)
    {ℓ : Line N} (hℓ : ℓ ∈ fullLines N) (ℓ' : Line N)
    (hle : loss (lineDist hℓ) (A ℓ) (A ℓ') ≤ 1 / 3) : ℓ' = ℓ := by
  by_contra hne
  have h1 := loss_lineDist_ge hA hℓ hne (hneg ℓ hℓ)
  have h2 := three_eighths_bound hN
  rw [h2.1] at h1
  linarith [h2.2]

/-- `app:query`: hence a fixed proper predictor has error at most `1/3` on at most one
full-line instance. -/
theorem proper_fits_at_most_one {A : Line N → Hyp (Point N)} (hA : IsFlip A) (hN : 25 ≤ N)
    (hneg : ∀ ℓ ∈ fullLines N, (3 * N / 8 : ℝ) ≤ (negPoints A ℓ).card) (ℓ' : Line N)
    {ℓ₁ ℓ₂ : Line N} (h₁ : ℓ₁ ∈ fullLines N) (h₂ : ℓ₂ ∈ fullLines N)
    (hle₁ : loss (lineDist h₁) (A ℓ₁) (A ℓ') ≤ 1 / 3)
    (hle₂ : loss (lineDist h₂) (A ℓ₂) (A ℓ') ≤ 1 / 3) : ℓ₁ = ℓ₂ :=
  (eq_of_loss_lineDist_le hA hN hneg h₁ ℓ' hle₁).symm.trans
    (eq_of_loss_lineDist_le hA hN hneg h₂ ℓ' hle₂)

end SQDC.Incidence
