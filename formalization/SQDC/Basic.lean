import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Order.ConditionallyCompleteLattice.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Learning and representation models

Shared definitions for the paper *Distribution-independent SQ learning does not
imply low dimension complexity*. Results are cited by title and TeX label, not by
number, so the references survive renumbering between manuscript versions.

Correspondence with Section "Learning and representation models" (`sec:definitions`)
and the rectangle ratio of Section "A learner from monochromatic rectangles"
(`sec:rectangle`, equation `eq:rectdef`):

* Labels `{-1,+1}` are encoded by `Bool`, with `true ↦ +1` (`labelValue`).
* An indexed class `H : ι → X → Bool` allows repeated rows, as in the paper.
* `loss D h g` is `L_{D,h}(g) = Pr_{z∼D}[g(z) ≠ h(z)]`.
* Statistical queries take values in `[-1,1]`; a valid oracle policy may depend on
  the previous queries and answers and on the current query (`ValidOracle`).
* A depth-`m` learner is a query tree of depth exactly `m`; an algorithm using at
  most `m` queries is padded. `RandomizedLearns` is the guarantee `eq:learnmodel`
  for an arbitrary seed law. Two modelling choices: oracle policies are deterministic
  functions of the transcript and cannot see the seed (the paper handles randomized
  policies by conditioning on their randomness), and the loss of the output must be
  integrable in the seed for every valid policy.
* `EmbedsAt`/`dc` are ordinary dimension complexity, `eq:dcdef`.
* `Monochromatic`, `rectValue` and `rect` formalize `eq:rectdef`.

The probabilistic dimensions and the prior-average dimension are not formalized.
-/

noncomputable section
open scoped BigOperators
open MeasureTheory

namespace SQDC

abbrev Hyp (X : Type*) := X → Bool

/-- The `±1` value of a Boolean label: `true ↦ +1`, `false ↦ -1`. -/
def labelValue (b : Bool) : ℝ := if b then 1 else -1

/-- A probability distribution on a finite set. -/
structure FinDist (X : Type*) [Fintype X] where
  mass : X → ℝ
  nonneg : ∀ x, 0 ≤ mass x
  total : ∑ x, mass x = 1

variable {X : Type*} [Fintype X]

/-- The mass `D(S)` of a finite set. -/
def FinDist.massOf (D : FinDist X) (S : Finset X) : ℝ := ∑ x ∈ S, D.mass x

theorem FinDist.massOf_nonneg (D : FinDist X) (S : Finset X) : 0 ≤ D.massOf S :=
  Finset.sum_nonneg fun x _ => D.nonneg x

theorem FinDist.massOf_le_one (D : FinDist X) (S : Finset X) : D.massOf S ≤ 1 := by
  classical
  calc D.massOf S ≤ ∑ x, D.mass x :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
          (fun x _ _ => D.nonneg x)
    _ = 1 := D.total

/-- The point mass at `x₀`. -/
def FinDist.dirac [DecidableEq X] (x₀ : X) : FinDist X where
  mass x := if x = x₀ then 1 else 0
  nonneg x := by split_ifs <;> norm_num
  total := by simp

instance [DecidableEq X] [Nonempty X] : Nonempty (FinDist X) :=
  ⟨FinDist.dirac (Classical.arbitrary X)⟩

def expectation (D : FinDist X) (f : X → ℝ) : ℝ :=
  ∑ x, D.mass x * f x

/-- `L_{D,h}(g) = Pr_{z∼D}[g(z) ≠ h(z)]`. -/
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

/-- A valid answer policy: every answer is within `τ` of the true query mean.
It may depend on the previous queries and answers and on the current query. -/
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

/-- A deterministic depth-`m` learner for the indexed class `H`. -/
def DeterministicLearns {ι : Type*} (H : ι → Hyp X) {m : ℕ}
    (A : SQTree X m) (τ ε : ℝ) : Prop :=
  ∀ (D : FinDist X) (i : ι),
    ∀ O : Oracle X, ValidOracle D (H i) τ O →
      loss D (H i) (runTree A O []) ≤ ε

/-- The guarantee `eq:learnmodel` for an arbitrary private seed law, not a
finite-seed restriction. Integrability of each output-loss random variable is
required explicitly. -/
def RandomizedLearns {ι : Type*} (H : ι → Hyp X) {m : ℕ}
    {Ω : Type*} [MeasurableSpace Ω]
    (P : Measure Ω) [IsProbabilityMeasure P]
    (A : Ω → SQTree X m) (τ ε : ℝ) : Prop :=
  ∀ (D : FinDist X) (i : ι),
    ∀ O : Oracle X, ValidOracle D (H i) τ O →
      Integrable (fun ω => loss D (H i) (runTree (A ω) O [])) P ∧
      (∫ ω, loss D (H i) (runTree (A ω) O []) ∂P) ≤ ε

/-- Strict homogeneous realization `eq:dcdef`: `h(z)⟨w_h, φ(z)⟩ > 0`. -/
def EmbedsAt {ι : Type*} (H : ι → Hyp X) (d : ℕ) : Prop :=
  ∃ φ : X → Fin d → ℝ,
    ∀ i, ∃ w : Fin d → ℝ,
      ∀ x, 0 < labelValue (H i x) * (∑ k, w k * φ x k)

/-- Ordinary dimension complexity: the least `d` with a strict realization. -/
def dc {ι : Type*} (H : ι → Hyp X) : ℕ := sInf {d | EmbedsAt H d}

omit [Fintype X] in
theorem dc_le_of_embedsAt {ι : Type*} (H : ι → Hyp X) {d : ℕ} (h : EmbedsAt H d) :
    dc H ≤ d :=
  Nat.sInf_le h

/-! ### Monochromatic rectangles and the rectangle ratio `eq:rectdef` -/

variable {ι : Type*} [Fintype ι]

/-- `S × T` is monochromatic with color `c`: `h(z) = c` for `z ∈ S`, `h ∈ T`. -/
def Monochromatic (H : ι → Hyp X) (S : Finset X) (T : Finset ι) (c : Bool) : Prop :=
  ∀ x ∈ S, ∀ i ∈ T, H i x = c

/-- The product masses `μ(S)ν(T)` of the monochromatic rectangles. -/
def rectMasses (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) : Set ℝ :=
  {v | ∃ (S : Finset X) (T : Finset ι) (c : Bool),
    Monochromatic H S T c ∧ v = μ.massOf S * ν.massOf T}

/-- `max_{S×T monochromatic} μ(S)ν(T)`. -/
def rectValue (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) : ℝ :=
  sSup (rectMasses H μ ν)

/-- `rect(H) = inf_{μ,ν} max_{S×T monochromatic} μ(S)ν(T)`, equation `eq:rectdef`. -/
def rect (H : ι → Hyp X) : ℝ :=
  ⨅ (μ : FinDist X) (ν : FinDist ι), rectValue H μ ν

theorem rectMasses_finite (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) :
    (rectMasses H μ ν).Finite := by
  classical
  have : rectMasses H μ ν ⊆
      Set.range (fun p : Finset X × Finset ι => μ.massOf p.1 * ν.massOf p.2) := by
    rintro v ⟨S, T, c, -, rfl⟩
    exact ⟨(S, T), rfl⟩
  exact (Set.finite_range _).subset this

theorem rectMasses_nonempty (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) :
    (rectMasses H μ ν).Nonempty :=
  ⟨_, ∅, ∅, true, by simp [Monochromatic], rfl⟩

theorem le_rectValue {H : ι → Hyp X} (μ : FinDist X) (ν : FinDist ι)
    {S : Finset X} {T : Finset ι} {c : Bool} (h : Monochromatic H S T c) :
    μ.massOf S * ν.massOf T ≤ rectValue H μ ν :=
  le_csSup (rectMasses_finite H μ ν).bddAbove ⟨S, T, c, h, rfl⟩

/-- The maximum in `eq:rectdef` is attained. -/
theorem exists_rectValue_eq (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) :
    ∃ (S : Finset X) (T : Finset ι) (c : Bool),
      Monochromatic H S T c ∧ rectValue H μ ν = μ.massOf S * ν.massOf T := by
  obtain ⟨S, T, c, h, hv⟩ :=
    (rectMasses_nonempty H μ ν).csSup_mem (rectMasses_finite H μ ν)
  exact ⟨S, T, c, h, hv⟩

theorem rectValue_nonneg (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) :
    0 ≤ rectValue H μ ν := by
  have h0 : Monochromatic H (∅ : Finset X) (∅ : Finset ι) true := by
    simp [Monochromatic]
  simpa [FinDist.massOf] using le_rectValue (H := H) μ ν h0

theorem rect_le_rectValue (H : ι → Hyp X) (μ : FinDist X) (ν : FinDist ι) :
    rect H ≤ rectValue H μ ν := by
  have hbdd : BddBelow (Set.range fun μ' : FinDist X => ⨅ ν' : FinDist ι, rectValue H μ' ν') :=
    ⟨0, by
      rintro _ ⟨μ', rfl⟩
      exact Real.iInf_nonneg fun ν' => rectValue_nonneg H μ' ν'⟩
  have hbdd' : BddBelow (Set.range fun ν' : FinDist ι => rectValue H μ ν') :=
    ⟨0, by
      rintro _ ⟨ν', rfl⟩
      exact rectValue_nonneg H μ ν'⟩
  exact (ciInf_le hbdd μ).trans (ciInf_le hbdd' ν)

/-- `r ≤ rect(H)` gives, for every product distribution, a monochromatic rectangle
of product mass at least `r`. -/
theorem exists_rectangle_of_le_rect {H : ι → Hyp X} {r : ℝ} (hr : r ≤ rect H)
    (μ : FinDist X) (ν : FinDist ι) :
    ∃ (S : Finset X) (T : Finset ι) (c : Bool),
      Monochromatic H S T c ∧ r ≤ μ.massOf S * ν.massOf T := by
  obtain ⟨S, T, c, h, hv⟩ := exists_rectValue_eq H μ ν
  exact ⟨S, T, c, h, hv ▸ hr.trans (rect_le_rectValue H μ ν)⟩

/-- Conversely, a rectangle of mass at least `r` under every product distribution
gives `r ≤ rect(H)` (for a nonempty domain and a nonempty index set). -/
theorem le_rect_of_forall [DecidableEq X] [DecidableEq ι] [Nonempty X] [Nonempty ι]
    {H : ι → Hyp X} {r : ℝ}
    (h : ∀ (μ : FinDist X) (ν : FinDist ι), ∃ (S : Finset X) (T : Finset ι) (c : Bool),
      Monochromatic H S T c ∧ r ≤ μ.massOf S * ν.massOf T) :
    r ≤ rect H := by
  refine le_ciInf fun μ => le_ciInf fun ν => ?_
  obtain ⟨S, T, c, hm, hr⟩ := h μ ν
  exact hr.trans (le_rectValue μ ν hm)

end SQDC
