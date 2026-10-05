import SQDC.ClassicalSQ
import SQDC.Incidence
import SQDC.QueryBounds

/-!
# Consequences for incidence flips

Compositions of the incidence geometry (`SQDC/Incidence.lean`) with the general bounds of
`SQDC/ClassicalSQ.lean` and `SQDC/QueryBounds.lean`. Results are cited by title and TeX
label.

* `sqDim_flip_le`: Proposition *Rectangles bound classical SQ dimension*
  (`prop:classical-sq`), "every incidence flip has `sq(H_A) ≤ 2^16`", for `N ≥ 1` and given
  the [APP05] input `Incidence.APP05Template`.
* `proper_event_of_flip`: the proper table event of `app:query`, "every proper predictor
  has error at most `1/3` on at most one full-line instance", in the form used by
  `QueryBounds.querylower_proper`, given the Hoeffding event that every full row has at
  least `3N/8` negative entries.
* `querylower_proper_flip`: `eq:lowerproper` of Theorem *Query lower bounds*
  (`thm:querylower`) for every randomized proper learner of an incidence flip, with
  targets the full-length lines and the uniform marginal on each target line, on that
  event.

Not formalized: the probability of the Hoeffding event and of the improper table event
over random flips.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace SQDC.IncidenceConsequences

open SQDC.Incidence

/-- Proposition *Rectangles bound classical SQ dimension* (`prop:classical-sq`): "In
particular, every incidence flip has `sq(H_A) ≤ 2^16`", given the [APP05] input. -/
theorem sqDim_flip_le {N : ℕ} (hN : 1 ≤ N) (hAPP : APP05Template N)
    {A : Line N → Hyp (Point N)} (hA : IsFlip A) : ClassicalSQ.sqDim A ≤ 2 ^ 16 := by
  have : Nonempty (Point N) := ⟨⟨_, one_one_mem_grid hN⟩⟩
  refine ClassicalSQ.sqDim_le_of_rect_ge A ?_
  have := rect_flip_ge hN hAPP hA
  norm_num at this ⊢
  exact this

/-- `app:query`: "every proper predictor has error at most `1/3` on at most one full-line
instance", on the event that every full row has at least `3N/8` negative entries
(`N ≥ 25`), in the form of the hypothesis of `QueryBounds.querylower_proper`. -/
theorem proper_event_of_flip {N : ℕ} {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    (hN : 25 ≤ N) (hneg : ∀ ℓ ∈ fullLines N, (3 * N / 8 : ℝ) ≤ (negPoints A ℓ).card)
    (j : Line N) :
    (Finset.univ.filter fun ℓ : {ℓ // ℓ ∈ fullLines N} =>
        loss (lineDist ℓ.2) (A ℓ.1) (A j) ≤ 1 / 3).card ≤ 1 := by
  refine Finset.card_le_one.2 fun a ha b hb => ?_
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha hb
  exact Subtype.ext (proper_fits_at_most_one hA hN hneg j a.2 b.2 ha hb)

/-- Theorem *Query lower bounds* (`thm:querylower`), `eq:lowerproper`: on the event that
every full row has at least `3N/8` negative entries (`N ≥ 25`), every randomized learner
satisfying `eq:learnmodel` for `𝓗_A` whose output belongs to `𝓗_A` uses
`m ≥ (3 log₂ N + log₂(1 - 3ε)) / log₂⌈1/τ⌉` queries. "The bounds already hold on targets
from `𝓛₀`, with the uniform marginal on each target line." -/
theorem querylower_proper_flip {N : ℕ} {A : Line N → Hyp (Point N)} (hA : IsFlip A)
    (hN : 25 ≤ N) (hneg : ∀ ℓ ∈ fullLines N, (3 * N / 8 : ℝ) ≤ (negPoints A ℓ).card)
    {m : ℕ} {Ω : Type*} [MeasurableSpace Ω] {P : Measure Ω} [IsProbabilityMeasure P]
    {L : Ω → SQTree (Point N) m} {τ ε : ℝ} (hτ0 : 0 < τ) (hτ1 : τ < 1) (hε1 : ε < 1 / 4)
    (hL : RandomizedLearns A P L τ ε)
    (hproper : ∀ ω (D : FinDist (Point N)) (i : Line N) (O : Oracle (Point N)),
      ValidOracle D (A i) τ O → ∃ j, runTree (L ω) O [] = A j) :
    (3 * Real.logb 2 N + Real.logb 2 (1 - 3 * ε)) / Real.logb 2 (⌈1 / τ⌉₊ : ℕ) ≤ m :=
  QueryBounds.querylower_proper (H := A) Subtype.val (fun ℓ => lineDist ℓ.2) (by omega)
    (by rw [Fintype.card_coe, card_fullLines]) (proper_event_of_flip hA hN hneg) hτ0 hτ1
    hε1 hL hproper

end SQDC.IncidenceConsequences
