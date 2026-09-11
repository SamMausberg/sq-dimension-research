# Verification record

## Current scope

The current revision preserves the 39 earlier numbered statements and adds Theorem 8, the proper/improper target-line query-order lower bound. The main text is 13 pages, including the title/abstract and one-page results summary. The full paper is 64 pages. Statements are numbered consecutively in order of declaration, including the appendices. See `NUMBERING.md` for the release-7 mapping and `source_consistency.json` for exact source/proof line ranges.

The nine requested later results were rederived and checked against the draft. `NEW_RESULT_LEDGER.md` and its JSON source contain 77 inequality rows, including adverse endpoints and randomness. `independent_derivations.md` records the median and PRF arithmetic before the corresponding source comparison. The complete universal arguments are in the paper; the exact finite checks provide regression evidence, not a formal proof certificate.

## Corrected new lower-bound claim

For typical independent incidence flips, both proper and unrestricted query complexity have order Theta_epsilon(n) at a fixed accuracy-dependent tolerance. The leading n - O_epsilon(1) numerator is proved for proper outputs. The unrestricted lower bound has numerator n/3 - O_epsilon(1). A predictor defined from all rows of a fixed slope fits N^2 target-line instances perfectly, for every table. Therefore the proposed distinct-good-output assertion is false. The paper instead bounds how many target-line instances any Boolean output can fit, uniformly over all outputs, before counting leaves.

The theorem excludes the all-positive deterministic flip, which has a zero-query learner. Its probability statement is over random tables, before the learner is selected, and the ensuing lower bound covers randomized learners and arbitrary valid nonanticipating policies. The lower-bound policy is a deterministic midpoint quantizer with B = ceil(1/tau) answers. No seed-dependent choice of oracle is used.

## Primary-source checks performed in this revision

- Abbe, Kamath, Malach, Sandon and Srebro, *On the Power of Differentiable Learning versus PAC and SQ Learning*, arXiv:2108.04190, Theorem 3d and Definitions on printed pp. 3--5, 14. The full-batch theorem, its computational statement, activation figure, clipping and rounding definition, reused sample and E[sup] error criterion were read in the original PDF. PDF pp. 4 and 14 were visually inspected. Source: https://arxiv.org/pdf/2108.04190 . Corollary 18 retains that E[sup] criterion; its deterministic source learner has a pathwise guarantee, so no exchange of expectation and supremum is required. One ignored bit gives r=1. Model size uses the polynomial TIME of Theorem 12 including query evaluation.
- VALG, arXiv:2608.13060v2, dated 10 September 2026. Section 4.3.2, Assumptions 4.39--4.42 and Theorem 4.9 were read. The mean-response span is formed over deterministic complete response rules. The rank certificate r_A <= B(1+m/tau^2)^k is an added primitive assumption. The theorem obtains a common strict embedding from that assumption. The paper's comparison is version-specific and does not call it an unconditional resolution. Source: https://arxiv.org/html/2608.13060v2 .

No new claim that every original publication record is resolved is made. The release-6 bibliography/source audit is preserved under `audits/prior/` and `history/turn06/`. Its five unresolved original records remain in the current author checklist. Every current bibliography entry names a venue, report series or arXiv identifier; this structural check is distinct from resolving the original full text.

## Fresh computation

`late_results.json` records the current seeded checks, separating exact Fraction/integer assertions from floating logarithmic parameter checks. `rerun_results/fast/audit.json` records a fresh 304-run keyed median sweep, 4,798 exact response checks, and 304 proper outputs. The core constants, unseen-label enumeration, large-star test and affine certificate were rerun in newly created directories. The keyed-cap and earlier SGD sweeps are preserved historical outputs. The current update ran no SGD experiment.

The ambient-encoding test reads exactly I_k distinct incidence inputs from a subgrid while keeping the full grid's encoding width. Historical HMAC experiments retain their documented message format; they do not stand in for the abstract PRF security assumption or its existential-real distinguisher.

## Formalization

The recovered Lean drafts are included under `formalization/`, not claimed as compiled proofs. The current bounded check found no lake executable, and elan bootstrap retrieval failed at DNS resolution for raw.githubusercontent.com. The pinned commit and toolchain are present; no successful compiler run or axiom audit exists. The draft coverage is limited to the finite definitions and selected earlier lemmas listed in `formalization/COVERAGE.md`.

## Statement ledger

Statuses below concern what was done in this revision. All retained statements have their original proof preserved, unless a specifically recorded explanatory correction was added. A source-consistency pass alone is not a reproof.

| Current | Previous | Statement | This revision | Source / proof |
|---|---|---|---|---|
| Theorem 1 | 3.1 | Distribution-independent rectangle learner | Retained proof; canonical statement and proof binding checked | `paper/sections/03_rectangle.tex:2`; `paper/appendices/rectangle_proof.tex:2` |
| Lemma 2 | 3.2 | Exact parameters | Retained proof; canonical statement and proof binding checked | `paper/sections/03_rectangle.tex:10`; `paper/appendices/rectangle_proof.tex:2` |
| Lemma 3 | 3.3 | A marginal-free rectangle mixture | Retained proof; canonical statement and proof binding checked | `paper/sections/03_rectangle.tex:17`; `paper/sections/03_rectangle.tex:26` |
| Theorem 4 | 4.1 | Construction and ordinary dimension | Retained proof; canonical statement and proof binding checked | `paper/sections/04_family.tex:3`; `paper/appendices/family_proof.tex:4` |
| Theorem 5 | 4.2 | Approximate counting and exact probabilistic dimension | Retained proof; canonical statement and proof binding checked | `paper/sections/04_family.tex:15`; `paper/appendices/family_proof.tex:34` |
| Lemma 6 | 4.3 | From exact probabilistic to strict dimension | Retained proof; canonical statement and proof binding checked | `paper/sections/04_family.tex:30`; `paper/appendices/family_proof.tex:61` |
| Corollary 7 | 4.4 | Negative answers to the dimension implications | Retained proof; canonical statement and proof binding checked | `paper/sections/04_family.tex:37`; `paper/appendices/family_proof.tex:66` |
| Theorem 8 | new | Optimal query order for random incidence flips | New complete proof and finite regression checks | `paper/sections/04_family.tex:47`; `paper/appendices/query_lower_bound.tex:2` |
| Theorem 9 | 5.1 | Pointwise cap mixture and table-polynomial implementation | Retained proof; canonical statement and proof binding checked | `paper/sections/05_learners.tex:4`; `paper/appendices/cap_proper_proofs.tex:4` |
| Theorem 10 | 5.2 | Proper RECTIFY | Retained proof; canonical statement and proof binding checked | `paper/sections/05_learners.tex:24`; `paper/appendices/cap_proper_proofs.tex:60` |
| Lemma 11 | 5.3 | Noisy integer medians | Adversarially rederived; inequality ledger checked | `paper/sections/05_learners.tex:52`; `paper/appendices/median_proofs.tex:22` |
| Theorem 12 | 5.4 | Succinct median learner | Adversarially rederived; inequality ledger checked | `paper/sections/05_learners.tex:69`; `paper/appendices/median_proofs.tex:29` |
| Lemma 13 | 6.1 | Small subgrid counting and decision cost | Adversarially rederived; inequality ledger checked | `paper/sections/06_explicit.tex:14`; `paper/appendices/explicit_proofs.tex:4` |
| Theorem 14 | 6.2 | Conditional almost-every-key explicit lower bounds | Adversarially rederived; inequality ledger checked; PRF-dependent dimension/hardness conclusion | `paper/sections/06_explicit.tex:27`; `paper/appendices/explicit_proofs.tex:23` |
| Proposition 15 | 6.3 | Unconditional polynomial advice | Retained proof; canonical statement and proof binding checked | `paper/sections/06_explicit.tex:39`; `paper/appendices/explicit_proofs.tex:57` |
| Lemma 16 | 6.4 | Regular stars for almost every key | Retained proof; canonical statement and proof binding checked; random-flip part unconditional, key transfer conditional | `paper/sections/06_explicit.tex:47`; `paper/appendices/explicit_proofs.tex:40` |
| Corollary 17 | 6.5 | Conditional polynomial-time, seed-known separation | Adversarially rederived; inequality ledger checked; PRF-dependent dimension/hardness conclusion | `paper/sections/06_explicit.tex:51`; `paper/appendices/explicit_proofs.tex:52` |
| Corollary 18 | 8.1 | Engineered differentiable learning with high dimension | Adversarially rederived; inequality ledger checked; PRF-dependent dimension/hardness conclusion | `paper/sections/07_gradient.tex:3`; `paper/appendices/engineered_simulation.tex:28` |
| Proposition 19 | 10.3 | Unseen independent labels | Adversarially rederived; inequality ledger checked | `paper/sections/07_gradient.tex:18`; `paper/appendices/resource_proofs.tex:39` |
| Proposition 20 | 8.3 | Hidden-key computational hardness | Retained proof; canonical statement and proof binding checked; PRF-dependent dimension/hardness conclusion | `paper/sections/07_gradient.tex:28`; `paper/appendices/network_proofs.tex:13` |
| Lemma 21 | 2.1 | Finite minimax and pointwise coverage | Retained proof; canonical statement and proof binding checked | `paper/appendices/foundations.tex:2`; `paper/appendices/foundations.tex:11` |
| Lemma 22 | 2.2 | From uniform rectangles to product weights | Retained proof; canonical statement and proof binding checked | `paper/appendices/foundations.tex:26`; `paper/appendices/foundations.tex:29` |
| Lemma 23 | 2.3 | Tie conventions and strict realization | Retained proof; canonical statement and proof binding checked | `paper/appendices/foundations.tex:33`; `paper/appendices/oracle_bounds.tex:36` |
| Theorem 24 | 7.1 | Communication as a sufficient condition | Adversarially rederived; inequality ledger checked | `paper/appendices/comparisons.tex:7`; `paper/appendices/certificate_proofs.tex:4` |
| Lemma 25 | 7.2 | Finite energy and threshold counting | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:28`; `paper/appendices/certificate_proofs.tex:13` |
| Theorem 26 | 7.3 | Joint-distribution SQ barrier | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:49`; `paper/appendices/certificate_proofs.tex:23` |
| Theorem 27 | 7.4 | Spectral sign-rank bounds | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:87`; `paper/appendices/certificate_proofs.tex:53` |
| Theorem 28 | 7.5 | Projective-plane incidence classes | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:105`; `paper/appendices/certificate_proofs.tex:105` |
| Theorem 29 | 7.6 | Marginal-branching and approximate probabilistic bounds | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:133`; `paper/appendices/certificate_proofs.tex:166` |
| Proposition 30 | 7.7 | Affine-line quantitative comparison | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:158`; `paper/appendices/certificate_proofs.tex:185` |
| Theorem 31 | 7.8 | Global projective-plane rectangle ratio | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:175`; `paper/appendices/certificate_proofs.tex:205` |
| Theorem 32 | 7.9 | Small rectangle ratio does not prevent SQ learning | Adversarially rederived; inequality ledger checked | `paper/appendices/comparisons.tex:190`; `paper/appendices/certificate_proofs.tex:223` |
| Theorem 33 | 7.10 | Marginal adaptation, under a small-query budget | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:217`; `paper/appendices/certificate_proofs.tex:266` |
| Corollary 34 | 7.11 | Published approximate rank as an SQ sufficient condition | Retained proof; canonical statement and proof binding checked | `paper/appendices/comparisons.tex:236`; `paper/appendices/certificate_proofs.tex:271` |
| Proposition 35 | 8.2 | A bias-free ReLU representation | Retained proof; canonical statement and proof binding checked | `paper/appendices/sgd_models.tex:25`; `paper/appendices/network_proofs.tex:4` |
| Theorem 36 | 10.1 | Source-description length alone does not repair the implication | Retained proof; canonical statement and proof binding checked | `paper/appendices/resources.tex:2`; `paper/appendices/resource_proofs.tex:3` |
| Proposition 37 | 10.2 | The classical certificate barrier | Retained proof; canonical statement and proof binding checked | `paper/appendices/resources.tex:12`; `paper/appendices/resource_proofs.tex:18` |
| Theorem 38 | I.1 | Rectangle bound for randomized statistical dimension | Retained proof; canonical statement and proof binding checked | `paper/appendices/statistical_dimension.tex:10`; `paper/appendices/statistical_dimension.tex:18` |
| Proposition 39 | L.1 | Independent constant rectangle bound | Retained proof; canonical statement and proof binding checked | `paper/appendices/geometric_bounds.tex:3`; `paper/appendices/geometric_bounds.tex:7` |
| Proposition 40 | L.2 | Uniform-product rectangles in a projective plane | Retained proof; canonical statement and proof binding checked | `paper/appendices/geometric_bounds.tex:23`; `paper/appendices/geometric_bounds.tex:31` |

## Claims not established

The paper has no compiled full formalization or external referee endorsement. The cryptographic conclusion is conditional. The requested leading n numerator for unrestricted outputs is not proved; the matching asymptotic order is. The improved O(n) succinct algorithm, efficient deterministic good-key selection, the original class-dependent benign-SGD question, the optimal query/tolerance tradeoff and the resource-aware characterization remain the stated open problems. The Git bundle and clean compilation checks concern packaging and source consistency.
