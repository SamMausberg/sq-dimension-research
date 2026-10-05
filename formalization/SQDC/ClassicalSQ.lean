import SQDC.Basic
import Mathlib.Algebra.Order.Star.Real

/-!
# Rectangles bound classical SQ dimension

Correspondence with Proposition *Rectangles bound classical SQ dimension*
(`prop:classical-sq`, equation `eq:classical-sq`), the definition in Subsection "The
comparison with gradient-descent claims" (`sec:km`), and the proof in Subsection
"Bounding classical SQ dimension" of Appendix `app:prior`:

* `IsSQFamily`, `sqDimAt`, `sqDim`: "`sq(H,D)` [is] the largest number `d` of distinct
  rows satisfying `E_D[h_i h_j] ≤ 1/d` for `i ≠ j`, and `sq(H) = max_D sq(H,D)`". Rows
  are compared as functions, so repeated rows of the indexed class count once. The
  lemmas `le_sqDimAt`, `exists_isSQFamily_card_eq`, `sqDimAt_le_sqDim` and
  `exists_sqDimAt_eq_sqDim` check that the `sSup`/`iSup` are attained maxima.
* `rect_pos`: for a finite nonempty class on a finite nonempty domain,
  `rect(H) ≥ 1/(2K) > 0` (one heaviest row and the heavier of its two label sets).
  The paper now states `rect(H) > 0` explicitly; it is
  needed because `2/0 = 0` in Lean.
* `sq_square_bound`: the core inequality `D(S)t² ≤ E_D(Σ_{h∈T} h)² ≤ t + t(t-1)/d`.
* `mass_mul_frac_le`: "Divide by `dt`. Since `t ≤ d`, this gives
  `D(S)t/d ≤ (1+(t-1)/d)/d ≤ 2/d`."
* `card_le_two_div_of_le_rect`, `sqDim_le_two_div_rect`: `sq(H) ≤ 2/rect(H)`
  (`eq:classical-sq`) for every finite nonempty class on a finite nonempty domain.
* `sqDim_le_of_rect_ge`: the arithmetic of "every incidence flip has
  `sq(H_A) ≤ 2^16`" from `rect(H_A) ≥ 2^{-15}`.

The bound `rect(H_A) ≥ 2^{-15}` enters `sqDim_le_of_rect_ge` as a hypothesis; for
incidence flips it is `Incidence.rect_flip_ge` (Proposition *Geometry and an upper
representation*, `prop:geometry`, given the [APP05] input), and the composition is
`IncidenceConsequences.sqDim_flip_le`.

Not formalized: the comparison with the prior-average dimension and with the assertion of
[KM25, Theorem 4.1], and the remark that the proof also works with absolute pairwise
correlations.
-/

noncomputable section
open scoped BigOperators

namespace SQDC.ClassicalSQ

variable {X : Type*} [Fintype X] {ι : Type*} [Fintype ι]

/-- `F` is a set of `|F|` distinct rows of `H` whose pairwise correlations under `D`
are at most `1/|F|`. -/
def IsSQFamily (H : ι → Hyp X) (D : FinDist X) (F : Finset (Hyp X)) : Prop :=
  (∀ f ∈ F, f ∈ Set.range H) ∧
    ∀ f ∈ F, ∀ g ∈ F, f ≠ g → correlation D f g ≤ 1 / (F.card : ℝ)

/-- `sq(H,D)`: the largest size of such a family. -/
def sqDimAt (H : ι → Hyp X) (D : FinDist X) : ℕ :=
  sSup {d | ∃ F, IsSQFamily H D F ∧ F.card = d}

/-- `sq(H) = max_D sq(H,D)`. -/
def sqDim (H : ι → Hyp X) : ℕ := ⨆ D : FinDist X, sqDimAt H D

theorem card_le_of_isSQFamily {H : ι → Hyp X} {D : FinDist X} {F : Finset (Hyp X)}
    (hF : IsSQFamily H D F) : F.card ≤ Fintype.card ι := by
  classical
  have : F ⊆ Finset.univ.image H := by
    intro f hf
    obtain ⟨i, rfl⟩ := hF.1 f hf
    exact Finset.mem_image_of_mem H (Finset.mem_univ i)
  exact (Finset.card_le_card this).trans (Finset.card_image_le.trans (by simp))

theorem bddAbove_families (H : ι → Hyp X) (D : FinDist X) :
    BddAbove {d | ∃ F, IsSQFamily H D F ∧ F.card = d} :=
  ⟨Fintype.card ι, by rintro d ⟨F, hF, rfl⟩; exact card_le_of_isSQFamily hF⟩

omit [Fintype ι] in
theorem isSQFamily_empty (H : ι → Hyp X) (D : FinDist X) : IsSQFamily H D ∅ := by
  simp [IsSQFamily]

theorem le_sqDimAt {H : ι → Hyp X} {D : FinDist X} {F : Finset (Hyp X)}
    (hF : IsSQFamily H D F) : F.card ≤ sqDimAt H D :=
  le_csSup (bddAbove_families H D) ⟨F, hF, rfl⟩

/-- The supremum defining `sq(H,D)` is attained. -/
theorem exists_isSQFamily_card_eq (H : ι → Hyp X) (D : FinDist X) :
    ∃ F, IsSQFamily H D F ∧ F.card = sqDimAt H D :=
  Nat.sSup_mem (⟨0, ∅, isSQFamily_empty H D, rfl⟩ :
    Set.Nonempty {d | ∃ F, IsSQFamily H D F ∧ F.card = d}) (bddAbove_families H D)

theorem sqDimAt_le_card (H : ι → Hyp X) (D : FinDist X) : sqDimAt H D ≤ Fintype.card ι := by
  obtain ⟨F, hF, he⟩ := exists_isSQFamily_card_eq H D
  exact he ▸ card_le_of_isSQFamily hF

theorem bddAbove_sqDimAt (H : ι → Hyp X) : BddAbove (Set.range (sqDimAt H)) :=
  ⟨Fintype.card ι, by rintro _ ⟨D, rfl⟩; exact sqDimAt_le_card H D⟩

theorem sqDimAt_le_sqDim (H : ι → Hyp X) (D : FinDist X) : sqDimAt H D ≤ sqDim H :=
  le_ciSup (bddAbove_sqDimAt H) D

/-- The maximum over `D` defining `sq(H)` is attained. -/
theorem exists_sqDimAt_eq_sqDim [Nonempty (FinDist X)] (H : ι → Hyp X) :
    ∃ D, sqDimAt H D = sqDim H :=
  Nat.sSup_mem (Set.range_nonempty _) (bddAbove_sqDimAt H)

/-! ### Positivity of the rectangle ratio -/

/-- `rect(H) ≥ 1/(2K)` for a finite nonempty class on a finite nonempty domain. -/
theorem inv_two_card_le_rect [DecidableEq X] [DecidableEq ι] [Nonempty X] [Nonempty ι]
    (H : ι → Hyp X) : 1 / (2 * (Fintype.card ι : ℝ)) ≤ rect H := by
  refine le_rect_of_forall fun μ ν => ?_
  obtain ⟨i, -, hi⟩ := Finset.exists_max_image Finset.univ ν.mass Finset.univ_nonempty
  have hK : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
  have hνi : 1 / (Fintype.card ι : ℝ) ≤ ν.mass i := by
    have h1 : (1 : ℝ) ≤ Fintype.card ι * ν.mass i := by
      calc (1 : ℝ) = ∑ j, ν.mass j := ν.total.symm
        _ ≤ ∑ _j : ι, ν.mass i := Finset.sum_le_sum fun j _ => hi j (Finset.mem_univ j)
        _ = Fintype.card ι * ν.mass i := by simp
    rw [div_le_iff₀ hK]; linarith
  set Sc : Bool → Finset X := fun c => Finset.univ.filter fun x => H i x = c
  have hsum : μ.massOf (Sc true) + μ.massOf (Sc false) = 1 := by
    unfold FinDist.massOf
    rw [← Finset.sum_union]
    · rw [← μ.total]
      congr 1
      ext x
      simp only [Sc, Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and,
        iff_true]
      cases H i x <;> simp
    · rw [Finset.disjoint_filter]
      intro x _ h1 h2
      rw [h1] at h2
      exact Bool.noConfusion h2
  have hmono : ∀ c, Monochromatic H (Sc c) {i} c := by
    intro c x hx j hj
    rw [Finset.mem_singleton.mp hj]
    simpa [Sc] using hx
  have hT : ν.massOf {i} = ν.mass i := by simp [FinDist.massOf]
  have hmain : ∀ c, 1 / 2 ≤ μ.massOf (Sc c) → ∃ (S : Finset X) (T : Finset ι) (c : Bool),
      Monochromatic H S T c ∧ 1 / (2 * (Fintype.card ι : ℝ)) ≤ μ.massOf S * ν.massOf T := by
    intro c hc
    refine ⟨Sc c, {i}, c, hmono c, ?_⟩
    rw [hT]
    calc 1 / (2 * (Fintype.card ι : ℝ)) = (1 / 2) * (1 / (Fintype.card ι : ℝ)) := by
          field_simp
      _ ≤ μ.massOf (Sc c) * ν.mass i :=
          mul_le_mul hc hνi (by positivity) (μ.massOf_nonneg _)
  by_cases h : 1 / 2 ≤ μ.massOf (Sc true)
  · exact hmain true h
  · exact hmain false (by linarith)

/-- `rect(H) > 0` for a finite nonempty class on a finite nonempty domain. -/
theorem rect_pos [DecidableEq X] [DecidableEq ι] [Nonempty X] [Nonempty ι]
    (H : ι → Hyp X) : 0 < rect H :=
  lt_of_lt_of_le (by have : (0 : ℝ) < Fintype.card ι := by exact_mod_cast Fintype.card_pos
                     positivity) (inv_two_card_le_rect H)

/-! ### The squared-sum bound -/

theorem correlation_self (D : FinDist X) (h : Hyp X) : correlation D h h = 1 := by
  unfold correlation expectation
  have : ∀ x, labelValue (h x) * labelValue (h x) = 1 := fun x => by
    unfold labelValue; split_ifs <;> norm_num
  simp only [this, mul_one]
  exact D.total

/-- The core inequality of the proof of `prop:classical-sq`:
`D(S)t² ≤ E_D(Σ_{h∈T} h)² ≤ t + t(t-1)/d`, for a set `T` of `t` rows from a family `F` of
`d` rows with pairwise correlations at most `1/d`, all of color `c` on `S`. -/
theorem sq_square_bound (D : FinDist X) {F T : Finset (Hyp X)} (hTF : T ⊆ F)
    (hcorr : ∀ f ∈ F, ∀ g ∈ F, f ≠ g → correlation D f g ≤ 1 / (F.card : ℝ))
    {S : Finset X} {c : Bool} (hmono : ∀ x ∈ S, ∀ h ∈ T, h x = c) :
    D.massOf S * (T.card : ℝ) ^ 2 ≤
        expectation D (fun x => (∑ h ∈ T, labelValue (h x)) ^ 2) ∧
      expectation D (fun x => (∑ h ∈ T, labelValue (h x)) ^ 2) ≤
        T.card + T.card * (T.card - 1) / (F.card : ℝ) := by
  classical
  constructor
  · -- on `S` the sum has magnitude `t`
    have hS : ∀ x ∈ S, (∑ h ∈ T, labelValue (h x)) ^ 2 = (T.card : ℝ) ^ 2 := by
      intro x hx
      have : ∑ h ∈ T, labelValue (h x) = T.card * labelValue c := by
        rw [Finset.sum_congr rfl fun h hh => by rw [hmono x hx h hh]]
        simp
      rw [this, mul_pow]
      unfold labelValue; split_ifs <;> norm_num
    unfold expectation FinDist.massOf
    rw [Finset.sum_mul]
    calc ∑ x ∈ S, D.mass x * (T.card : ℝ) ^ 2
        = ∑ x ∈ S, D.mass x * (∑ h ∈ T, labelValue (h x)) ^ 2 :=
          Finset.sum_congr rfl fun x hx => by rw [hS x hx]
      _ ≤ ∑ x, D.mass x * (∑ h ∈ T, labelValue (h x)) ^ 2 :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
            fun x _ _ => mul_nonneg (D.nonneg x) (sq_nonneg _)
  · -- expand the square into correlations
    have hexp : expectation D (fun x => (∑ h ∈ T, labelValue (h x)) ^ 2) =
        ∑ h ∈ T, ∑ g ∈ T, correlation D h g := by
      unfold correlation expectation
      simp_rw [sq, Finset.sum_mul_sum, Finset.mul_sum]
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun h _ => ?_
      rw [Finset.sum_comm]
    rw [hexp]
    have hrow : ∀ h ∈ T, ∑ g ∈ T, correlation D h g ≤ 1 + (T.card - 1) / (F.card : ℝ) := by
      intro h hh
      rw [← Finset.add_sum_erase T _ hh, correlation_self]
      have hle : ∑ g ∈ T.erase h, correlation D h g ≤ ∑ _g ∈ T.erase h, 1 / (F.card : ℝ) :=
        Finset.sum_le_sum fun g hg =>
          hcorr h (hTF hh) g (hTF (Finset.mem_of_mem_erase hg)) (Finset.ne_of_mem_erase hg).symm
      rw [Finset.sum_const, Finset.card_erase_of_mem hh, nsmul_eq_mul] at hle
      have hc : ((T.card - 1 : ℕ) : ℝ) = (T.card : ℝ) - 1 := by
        rw [Nat.cast_sub (Finset.card_pos.mpr ⟨h, hh⟩)]; simp
      rw [hc] at hle
      have : ((T.card : ℝ) - 1) * (1 / (F.card : ℝ)) = (T.card - 1) / (F.card : ℝ) := by ring
      linarith
    calc ∑ h ∈ T, ∑ g ∈ T, correlation D h g
        ≤ ∑ _h ∈ T, (1 + (T.card - 1) / (F.card : ℝ)) := Finset.sum_le_sum hrow
      _ = T.card + T.card * (T.card - 1) / (F.card : ℝ) := by
          rw [Finset.sum_const, nsmul_eq_mul]; ring

/-- "Divide by `dt`. Since `t ≤ d`, this gives `D(S)t/d ≤ (1+(t-1)/d)/d ≤ 2/d`." -/
theorem mass_mul_frac_le (D : FinDist X) {F T : Finset (Hyp X)} (hTF : T ⊆ F)
    (hcorr : ∀ f ∈ F, ∀ g ∈ F, f ≠ g → correlation D f g ≤ 1 / (F.card : ℝ))
    {S : Finset X} {c : Bool} (hmono : ∀ x ∈ S, ∀ h ∈ T, h x = c) :
    D.massOf S * ((T.card : ℝ) / F.card) ≤ 2 / F.card := by
  obtain ⟨h1, h2⟩ := sq_square_bound D hTF hcorr hmono
  have hcard : (T.card : ℝ) ≤ F.card := by exact_mod_cast Finset.card_le_card hTF
  rcases Nat.eq_zero_or_pos T.card with ht | ht
  · rw [ht]; simp only [Nat.cast_zero, zero_div, mul_zero]
    positivity
  have htr : (0 : ℝ) < T.card := by exact_mod_cast ht
  have hdr : (0 : ℝ) < F.card := lt_of_lt_of_le htr hcard
  -- `D(S) t ≤ 1 + (t-1)/d`
  have h3 : D.massOf S * T.card ≤ 1 + (T.card - 1) / (F.card : ℝ) := by
    have : D.massOf S * T.card * T.card ≤ (1 + (T.card - 1) / (F.card : ℝ)) * T.card := by
      have e : (1 + (T.card - 1) / (F.card : ℝ)) * T.card =
          T.card + T.card * (T.card - 1) / (F.card : ℝ) := by ring
      rw [e]; nlinarith
    exact le_of_mul_le_mul_right this htr
  have h4 : ((T.card : ℝ) - 1) / F.card ≤ 1 := by
    rw [div_le_one hdr]; linarith
  have e : D.massOf S * ((T.card : ℝ) / F.card) = D.massOf S * T.card / F.card := by ring
  rw [e]
  exact div_le_div_of_nonneg_right (by linarith) hdr.le

/-! ### The proposition -/

/-- Every family witnessing `sq(H,D) ≥ d` has `d ≤ 2/r` whenever `0 < r ≤ rect(H)`. -/
theorem card_le_two_div_of_le_rect {H : ι → Hyp X} {r : ℝ} (hr : 0 < r)
    (hrect : r ≤ rect H) {D : FinDist X} {F : Finset (Hyp X)} (hF : IsSQFamily H D F) :
    (F.card : ℝ) ≤ 2 / r := by
  classical
  rcases Nat.eq_zero_or_pos F.card with hd | hd
  · rw [hd]; simp only [Nat.cast_zero]; positivity
  have hdr : (0 : ℝ) < F.card := by exact_mod_cast hd
  -- choose an index for each row of the family
  have hidx : ∀ f ∈ F, ∃ i, H i = f := fun f hf => hF.1 f hf
  obtain ⟨f0, hf0⟩ := Finset.card_pos.mp hd
  obtain ⟨i0, -⟩ := hidx f0 hf0
  let idx : Hyp X → ι := fun f => if h : ∃ i, H i = f then Classical.choose h else i0
  have hidx_spec : ∀ f ∈ F, H (idx f) = f := by
    intro f hf
    simp only [idx, hidx f hf, dite_true]
    exact Classical.choose_spec (hidx f hf)
  set I : Finset ι := F.image idx
  have hIcard : I.card = F.card := by
    refine Finset.card_image_of_injOn fun f hf g hg he => ?_
    rw [← hidx_spec f hf, ← hidx_spec g hg]
    exact congrArg H he
  -- the uniform prior `ν` on the chosen rows
  let ν : FinDist ι :=
    { mass := fun i => if i ∈ I then 1 / (F.card : ℝ) else 0
      nonneg := fun i => by split_ifs <;> positivity
      total := by
        rw [← Finset.sum_filter, Finset.filter_mem_eq_inter, Finset.univ_inter,
          Finset.sum_const, hIcard, nsmul_eq_mul]
        field_simp }
  obtain ⟨S, T, c, hmono, hmass⟩ := exists_rectangle_of_le_rect hrect D ν
  set T' : Finset (Hyp X) := (T.filter (· ∈ I)).image H
  have hH_inj : Set.InjOn H ↑(T.filter (· ∈ I)) := by
    intro i hi j hj he
    simp only [Finset.mem_coe, Finset.mem_filter] at hi hj
    obtain ⟨f, hf, rfl⟩ := Finset.mem_image.mp hi.2
    obtain ⟨g, hg, rfl⟩ := Finset.mem_image.mp hj.2
    rw [hidx_spec f hf, hidx_spec g hg] at he
    rw [he]
  have hT'card : T'.card = (T.filter (· ∈ I)).card := Finset.card_image_of_injOn hH_inj
  have hT'F : T' ⊆ F := by
    intro h hh
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hh
    obtain ⟨f, hf, rfl⟩ := Finset.mem_image.mp (Finset.mem_filter.mp hi).2
    rw [hidx_spec f hf]; exact hf
  have hmono' : ∀ x ∈ S, ∀ h ∈ T', h x = c := by
    intro x hx h hh
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hh
    exact hmono x hx i (Finset.mem_filter.mp hi).1
  have hνT : ν.massOf T = (T'.card : ℝ) / F.card := by
    unfold FinDist.massOf
    simp only [ν]
    rw [← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul, hT'card]
    ring
  have key := mass_mul_frac_le D hT'F hF.2 hmono'
  rw [← hνT] at key
  have hr2 : r ≤ 2 / F.card := hmass.trans key
  rw [le_div_iff₀ hdr] at hr2
  rw [le_div_iff₀ hr]
  linarith

/-- Proposition *Rectangles bound classical SQ dimension* (`prop:classical-sq`),
equation `eq:classical-sq`: "For every finite nonempty class, `sq(H) ≤ 2/rect(H)`."
(The domain is finite and nonempty as in Section `sec:definitions`; `rect(H) > 0` by
`rect_pos`, so the right side is the genuine quotient.) -/
theorem sqDim_le_two_div_rect [DecidableEq X] [DecidableEq ι] [Nonempty X] [Nonempty ι]
    (H : ι → Hyp X) : (sqDim H : ℝ) ≤ 2 / rect H := by
  obtain ⟨D, hD⟩ := exists_sqDimAt_eq_sqDim H
  obtain ⟨F, hF, hFc⟩ := exists_isSQFamily_card_eq H D
  rw [← hD, ← hFc]
  exact card_le_two_div_of_le_rect (rect_pos H) le_rfl hF

/-- A lower bound `r ≤ rect(H)` with `r > 0` gives `sq(H) ≤ 2/r`. -/
theorem sqDim_le_two_div_of_le_rect [Nonempty (FinDist X)] (H : ι → Hyp X)
    {r : ℝ} (hr : 0 < r) (hrect : r ≤ rect H) : (sqDim H : ℝ) ≤ 2 / r := by
  obtain ⟨D, hD⟩ := exists_sqDimAt_eq_sqDim H
  obtain ⟨F, hF, hFc⟩ := exists_isSQFamily_card_eq H D
  rw [← hD, ← hFc]
  exact card_le_two_div_of_le_rect hr hrect hF

/-- "In particular, every incidence flip has `sq(H_A) ≤ 2^16`": the arithmetic step from
`rect(H_A) ≥ 2^{-15}` (`prop:geometry`, taken here as a hypothesis). -/
theorem sqDim_le_of_rect_ge [Nonempty (FinDist X)] (H : ι → Hyp X)
    (hrect : (2 : ℝ)⁻¹ ^ 15 ≤ rect H) : sqDim H ≤ 2 ^ 16 := by
  have := sqDim_le_two_div_of_le_rect H (by positivity) hrect
  have e : (2 : ℝ) / (2 : ℝ)⁻¹ ^ 15 = 2 ^ 16 := by norm_num
  rw [e] at this
  exact_mod_cast this

end SQDC.ClassicalSQ
