# Verification ledger

Author: Samuel Mausberg. Revision date: September 10, 2026.

## Meaning of status

“Checked” records a review of the mathematical proof and its stated quantifiers in this revision. It does not mean external peer review or machine-checked formalization. Executed finite checks and their exact outputs are in `checks/constants.json`, `logs/constants.log`, and the two rechecked experiment logs. Conditional results retain their cryptographic hypotheses. Imported results are identified rather than silently treated as newly proved.

## Outstanding source-level items

1. The PMLR landing page for Feldman, Kamath and Srebro was retrieved and confirms the title, authors, venue, pages and the abstract's question. The linked full PDF could not be retrieved through the supplied raw-GitHub address, the matching GitHub connector, or alternative publisher routes. The manuscript therefore quotes only a short verified abstract clause and restates the quantitative problem from the supplied problem statement. It does not present an unverified long quotation as verbatim source text.
2. The main text proves the zero-score degeneracy mathematically and states the nondegenerate conventions it uses. The precise printing of the original source's probabilistic formulas and its reported 2026 personal communication were not independently checked in the inaccessible PDF. Neither is asserted as a verified quotation or attributed correction in the paper.
3. Warren's numerical sign-pattern theorem was checked in the primary AMY full paper, the homogeneous-rectangle constant in HHPTZ's exact statement, and the existential-real decision bound in Vorobjov's primary lecture notes. Direct original-publisher records for Warren68, Renegar92 and DV04 remain unresolved here. Their bibliographic metadata is retained without invented URLs. Several valid DOI endpoints also rejected automated access. Thus the requested claim that every reference was directly resolved is not made.
4. The general OWF-to-PRF security transformations are cited background. The paper assumes the needed PRF security directly; no theorem depends on a newly established quantitative cryptographic reduction.

## Source-problem checks A1-A7

| Item | Confirmation and limitation |
|---|---|
| A1 | The supplied oracle model is stated with all valid history-dependent policies. The finite-net deterministic learner has a worst-case guarantee and avoids dependence on an expected-error interpretation. Full-source wording is pending. |
| A2 | Every learning bound states 0<epsilon<1/4 or a named fixed epsilon regime. Dependence on accuracy is explicit, and the exact rectangle constants appear once in Lemma 3.2. |
| A3 | Strict dimension is defined by positive signed scores and equals sign-rank by rank factorization. BDES02 is cited. A fixed tie rule changes ordinary dimension by at most one. |
| A4 | Both probabilistic definitions precede their proofs, with sign(0)=+1. Lemma 2.3 covers the opposite rule and zeros-as-errors. Empty incidence rows receive zero averaging weight; finite infima are attained. Corollary 4.4 covers eta=C epsilon<1/2. Literal source formulas were not reopened. |
| A5 | (L), (P), (Pn) are defined in Section 1 before the result summary. |
| A6 | The stipulated Gaussian-initialized, fully connected, bias-free, logistic-loss, online-update process and its tail-sum output are restated in Section 8; its dimension implication remains open. |
| A7 | Missing background references were added and checked to the levels recorded below. The full general converse and the source's personal-communication sentence are not claimed independently verified; the paper states the checked rescaling/margin route. |

## Number mapping

| Earlier number | New number | Label |
|---:|---:|---|
| 1 | 3.1 | `thm:main` |
| 2 | 3.2 | `lem:params` |
| 3 | 3.3 | `lem:mixture` |
| 4 | 4.1 | `thm:construction` |
| 5 | 4.2 | `thm:prob` |
| 6 | I.1 | `thm:rsd` |
| 7 | 5.1 | `thm:caps` |
| 8 | 5.2 | `thm:proper` |
| 9 | 6.1 | `lem:subgrid` |
| 10 | 6.2 | `thm:prf` |
| 11 | 5.3 | `lem:median` |
| 12 | 5.4 | `thm:fast` |
| 13 | 6.4 | `lem:regularstars` |
| 14 | 6.5 | `cor:fastprf` |
| 15 | 7.1 | `thm:communication` |
| 16 | 7.2 | `thm:energy` |
| 17 | 7.3 | `thm:barrier` |
| 18 | 7.4 | `thm:forster` |
| 19 | 7.5 | `thm:plane` |
| 20 | 7.6 | `thm:tree` |
| 21 | 7.7 | `prop:affine` |
| 22 | 7.8 | `thm:pgglobal` |
| 23 | 7.9 | `thm:halfspaces` |
| 24 | 7.10 | `thm:adapt` |
| 25 | 7.11 | `cor:approxrect` |
| 26 | 8.2 | `thm:network` |
| 27 | 10.1 | `thm:description` |
| 28 | 10.2 | `thm:classicalbarrier` |
| 29 | 10.3 | `prop:unseen` |
| 30 | 8.3 | `prop:hiddenkey` |
| 31 | L.1 | `prop:cap-bound` |
| 32 | L.2 | `prop:pg-rect` |

## One entry per numbered statement

| Statement | Hypotheses | Dependencies | Imported result | Status and constants |
|---|---|---|---|---|
| Lemma 2.1: Finite minimax and pointwise coverage | Finite actions and finitely many payoff types; arbitrary real threshold. | Compact convex hull and nonnegative-orthant separation. | None. | Checked: nearest-point argument and finite-type reduction. |
| Lemma 2.2: From uniform rectangles to product weights | Property invariant under repetition; uniform side fractions a,b. | Positive rational repetition and continuity. | None. | Checked: use positive rational weights first; deletion closure is unnecessary. |
| Lemma 2.3: Tie conventions and strict realization | Finite prediction matrix; either fixed tie rule, or zeros counted as errors. | One constant coordinate; row-specific small bias. | None. | Checked: d to d+1, finite loss minimum, empty-incidence rows. |
| Theorem 3.1: Distribution-independent rectangle learner | Finite nonempty class; rect >= 1/rho; 0 < epsilon < 1/4; every valid history-dependent oracle. | Mixture lemma, multiplicative potentials, conditional exponential bound. | None. | Checked: all endpoint directions, target retention, drift r/4, fixed round budget. |
| Lemma 3.2: Exact parameters | Same hypotheses as rectangle theorem. | P, tau, B, R given in equations (3.2)-(3.3). | None. | Checked: 20 parameter cases and symbolic inequalities; see constants.json. |
| Lemma 3.3: A marginal-free rectangle mixture | Nonempty surviving U,V; arbitrary known prior nu; valid rectangle lower bound r. | Finite minimax. | HHPTZ22 Theorem 3.1 supplies prior attribution, not a needed proof step. | Checked: distribution law is independent of unknown D; rational feasible solution exists. |
| Theorem 4.1: Construction and ordinary dimension | Real-grid template; independent flips for the probability statement; fixed epsilon for learning. | Six-coordinate factorization, no negative 2x2, repetition, Warren count, rectangle learner. | APP05 through HHPTZ22 Theorem 1.9; Warren through AMY16 Theorem 21/Lemma 22 in the checked arXiv version. | Checked: I and empty-row counts; strict moment-curve upper bound; independent 2^-18 backup retained. |
| Theorem 4.2: Approximate counting and exact probabilistic dimension | Each fixed eta in [0,1/2); one embedding law precedes D,h. | Incidence-weighted marginals, bias coordinate, entropy ball and rank-pattern count. | Warren as above. | Checked: event is dc^eta < s_eta; zero-incidence rows carry weight zero. |
| Lemma 4.3: From exact probabilistic to strict dimension | Finite nonempty H; exact success >=1/2 for every D,h. | Full-support marginal, t=ceil(log2 K)+1 draws, union bound, bias. | None. | Checked: dc <= t dc_1/2 + 1, including d=0. |
| Corollary 4.4: Negative answers to the dimension implications | Universal proposed polynomial or fixed C; choose fixed epsilon with C epsilon < 1/2. | Construction and both dimension reductions. | None beyond their dependencies. | Checked: all three asymptotic forms, not the degenerate raw-zero-score formula. |
| Theorem 5.1: Pointwise cap mixture and table-polynomial implementation | Fixed d; rational strict template; no negative 2x2; fixed epsilon for SQ bounds. | General-position perturbation, isotropy program, two singleton-side cases, rational direction net. | None needed; DKT22 is comparison. | Checked: c_d/(8d), r_d, covariance bounds, and deterministic stage potential. |
| Theorem 5.2: Proper RECTIFY | Same geometric assumptions for the grid family; 0 < epsilon < 1/4. | First negative rectangle; heavy point; disjoint negative supports in a star. | None. | Checked: first peel mass >18 tau; negative mass >15 tau; candidate and star thresholds. |
| Lemma 5.3: Noisy integer medians | Nonnegative finite measure beta >512 zeta; integer-valued statistic; every answer error <=zeta. | Binary-search endpoint invariants. | None. | Checked: thresholds beta_hat/2, beta_hat/8 and mass intervals; 280 endpoint inequalities. |
| Theorem 5.4: Succinct median learner | Evaluable grid flips; 0 < epsilon <1/4; regular stars only for proper branch. | Noisy median lemma; affine order; heavy-point/star completion. | None. | Checked: prefix/suffix gap, unique line tests, finite-bit response rounding, bounded trial count. |
| Lemma 6.1: Small subgrid counting and decision cost | Scale k>=2; independent flip bits. | Warren count; existential-real feasibility in 2KD variables. | Warren; singly exponential existential-real decision bound as presented by Vorobjov21 (Renegar92 attribution). | Checked: first nonzero D_k is k=180; D_k>=1 implies k>=32 is only an auxiliary implication. |
| Theorem 6.2: Conditional almost-every-key explicit lower bounds | Stated subexponential PRF assumption; fixed c, epsilon, delta; n=3b+1. | Subgrid distinguisher with k=ceil(c n^c). | PRF security is an assumption; ETR from subgrid lemma. | Conditional: runtime fits 2^(sigma^delta); coefficient 30 checked; no deterministic good-key selection. |
| Proposition 6.3: Unconditional polynomial advice | Fixed c,epsilon; advice stores I_k subgrid bits. | Subgrid counting; collapse exterior points; dimension-seven template; deterministic proper caps. | None beyond those dependencies. | Checked: all-positive subgrid row supplies collapsed rows; polynomial-size effective table. |
| Lemma 6.4: Regular stars for almost every key | Fixed epsilon; C0=max(64 ceil n,ceil(128/epsilon)); independent flips, then stated PRF. | Chernoff bound and union over 2^n points; exhaustive star distinguisher. | PRF assumption only. | Checked: e^(-t/16), e^(-3n), and 2^O(n) distinguishing time. |
| Corollary 6.5: Conditional polynomial-time, seed-known separation | Fixed c,epsilon; key known; stated PRF assumption. | PRF rank theorem, regular stars, median learner. | None beyond these results. | Conditional: O_epsilon(n^2) queries; proper for almost every key, improper for every key. |
| Theorem 7.1: Communication as a sufficient condition | Exact deterministic leaf-labelled protocols; product marginals. | Shallow leaves and Markov; recursive two-bit rectangle membership. | HHPTZ22 Proposition 3.14 attribution; proof supplied. | Checked: rect >=2^(-2c-1), average cost <=2rho; zero-mass cells handled. |
| Lemma 7.2: Finite energy and threshold counting | Finite L2 vectors and their positive semidefinite Gram matrix. | Operator norm and threshold counting. | None. | Checked: finite linear-algebra proof. |
| Theorem 7.3: Joint-distribution SQ barrier | Full-support fair-label reference; realizable target-dependent marginals; every valid oracle. | Energy lemma; seed-independent reference-following oracle. | None. | Checked: m/tau^2 >=(1-2epsilon)R-sqrt R and R<=4+4m/tau^2. |
| Theorem 7.4: Spectral sign-rank bounds | Strict sign matrices or real entries of magnitude >=1; arbitrary row weights. | General-position perturbation, coercive radial-isotropy minimization, Cauchy-Schwarz. | Forster02 attribution; needed proof is supplied. | Checked: both weighted and entry-weighted bounds; no completeness claim. |
| Theorem 7.5: Projective-plane incidence classes | Prime q; projective-plane incidence class; m>=1, 0<tau<=1, epsilon<1/4. | Incidence identities, spectral bounds, balanced target marginals, fixed-D cover. | None. | Checked: A^T A; residual Gamma; R>=q; dc<=19m/tau^2; ordinary-Gram ratio<=16. |
| Theorem 7.6: Marginal-branching and approximate probabilistic bounds | Deterministic learner for strict bound; arbitrary randomized learner for approximate bound. | Marginal-response tree, finite minimax, finite grid for randomized leaves. | None. | Checked: (m+1)B^u and B^m; deterministic seed assumption retained. |
| Proposition 7.7: Affine-line quantitative comparison | Affine lines over prime field; expected-error or stated success/correlation guarantee. | Balanced marginals and joint residual Gram. | Feldman17 Theorems 7.7-7.8 only for parameter comparison. | Checked: five prime-field matrix identities and success-probability substitution rerun. |
| Theorem 7.8: Global projective-plane rectangle ratio | Every product distribution on a projective-plane incidence matrix. | Maximum-degree random rectangle and centered incidence norm. | None. | Checked: 1/(8(q+1)) <= rect <=q/(q+1)^2; joint (m,tau) tightness not asserted. |
| Theorem 7.9: Small rectangle ratio does not prevent SQ learning | Odd cube dimension; Boolean normal vectors; fixed epsilon. | Bounded differences, separated subsets, bounded-margin hinge optimization. | None; concentration proof supplied. | Checked: rect<=e^(-n/4); T=ceil(100/(epsilon^2 gamma^2)); m/tau^2=O(n^5/epsilon^4). |
| Theorem 7.10: Marginal adaptation, under a small-query budget | Deterministic learner with an explicit upper bound on m. | Logarithm of transcript dimension bound. | None. | Checked: subtract log(m+1); no unconditional lower bound on u when m is large. |
| Corollary 7.11: Published approximate rank as an SQ sufficient condition | Total matrix with the published deterministic-column approximate sign-rank d; fixed eta and epsilon. | Published side fractions, repetition lemma, rectangle theorem. | BHKR26 Theorem 1.3, v2: side fractions d^(-C_eta d), d^(-C_eta d^2). | Checked corollary conditional on that imported theorem; partial stars not treated as arbitrary completions. |
| Corollary 8.1: Engineered differentiable learning with high dimension | Key-known family; fixed c,epsilon; engineered DAG, square loss, specified initialization and rounded gradients. | Deterministic improper median learner; label recoding; square-loss threshold conversion. | AKMSS21 v2, Theorem 3d: lambda=tau0/16, Tprime=2k, polynomial model size and stated sample inequality. | Conditional on PRF only for high dimension; simulation parameters/source model checked; OQ1 remains separate. |
| Proposition 8.2: A bias-free ReLU representation | Cube-padded finite grid row with at most N negative points. | Positive/negative coordinate features, constant from antipodal coordinates, point detectors. | None. | Checked representation only: S=2n^2+2n(N+1)+(N+1); no SGD convergence claim. |
| Proposition 8.3: Hidden-key computational hardness | One key-independent polynomial-time sample learner; polynomial-time predictor evaluation. | Fresh-point PRF distinguishing test and collision probability. | PRF assumption only. | Conditional: advantage >=gamma-q/(2N), averaged over random keys. |
| Theorem 10.1: Source-description length alone does not repair the implication | Uncharged preprocessing and ordinary source-program length. | Canonical exhaustive high-rank selector and finite real decision procedure. | Real-closed-field decidability, MC12/Vorobjov21. | Checked: description O(log N); no efficient selector claim. |
| Proposition 10.2: The classical certificate barrier | Finite matrix, strict normalized representations; average-margin parameter as defined. | Finite minimax, rectangle-coordinate embedding, strict perturbation, shattered cube trace bound. | HHPTZ22 supplies attribution; comparison proof supplied. | Checked: sqrt(VC)<=1/m_avg<=1/rect bounds certificates, not actual sign-rank. |
| Proposition 10.3: Unseen independent labels | One learner independent of random table; uniform N-point target line; T iid samples. | Unobserved fair bits and Bernoulli inequality. | None. | Checked: averaged/minimax quantifier; false per-individual-table/OQ1 extrapolation excluded. |
| Theorem I.1: Rectangle bound for randomized statistical dimension | Realizable search at error eta; arbitrary reference and target-dependent marginals. | Peeling prior-averaged marginal; finite payoff types; common minimax lemma. | Feldman17 Definition 4.6/Theorems 4.8,4.11 checked for the separate conversion. | Checked: fairness 1/4, RSD<=4L; KL and tolerance costs retained. |
| Proposition L.1: Independent constant rectangle bound | Any strict rank-d matrix; no negative 2x2 for monotone flips. | Isotropy proof, cap geometry, product-weight lemma, singleton split. | None. | Checked: five-ball estimate gives >2^-18; numerical c6 and inverse coverage recomputed. |
| Proposition L.2: Uniform-product rectangles in a projective plane | Uniform product weights on PG(2,q). | Incidence operator norm and disjointness counting. | None. | Checked; retained as a consequence alongside the stronger all-product theorem. |

## Recomputed constants

The symbolic endpoint analysis is retained as R1-R20 in Appendix A, including which extremes are adverse and where fresh learner randomness enters. The oracle is never averaged into a favorable response.

- `c6` = `0.0003509774353562009`.
- `inverse_coverage_exact` = `136760.92866564382`.
- `r6` = `1/4961523892727904`.
- `inverse_r6` = `4961523892727904`.
- `five_ball_lower` = `0.0003403264786554272`.
- `five_ball_flip_lower` = `7.0901349719880665e-06`.
- `first_positive_D_k` = `180`.
- `covariance_lower_factor` = `0.8161764705882353`.
- `proper_mass_ratio_min` = `18.195113489698564`.

Executed case counts: {"covariance_cases": 19, "exact_median_endpoint_inequalities": 280, "hinge_constant_cases": 15, "plane_cases": 7, "rectangle_parameter_cases": 20, "subgrid_enumerations": 15}. All assertions passed.

For the rank distinguisher, k=ceil(c n^c) is essential to the coefficient 30. D_k first becomes positive at k=180. The weaker implication D_k>=1 => k>=32 is used solely to bound log2(8 e k^3) by 4 log2(k). For the proper learner, (15/4)ln(128)=18.195113489698564 is the limiting lower bound behind the >18 tau step. The conservative median proof uses beta>512 zeta, although the stopping rule actually gives beta>1023 zeta.

## Imported statements and source checks

All URLs below were attempted in this revision. “Full text” means the relevant statement was inspected; “metadata” is explicitly weaker.

| Reference | Source | Check |
|---|---|---|
| FKS26 | https://proceedings.mlr.press/v336/feldman26a.html | Landing/abstract/metadata. Full linked PDF retrieval failed. |
| HHPTZ22 | https://eccc.weizmann.ac.il/report/2022/079/download/ | Full text: Theorem 1.9, Theorem 3.1, construction/Theorem 3.2, Proposition 3.14, Problem 4.1. The exact per-side 2^{-(d+1)} constant was confirmed here. |
| APP05 | https://web.math.princeton.edu/~nalon/PDFS/publications.html | Author's publication list confirms title, authors, journal, year and pages. The imported statement is checked through HHPTZ Theorem 1.9 rather than an unverified original numbering. |
| AMY16 / Warren68 | https://arxiv.org/pdf/1503.07648 | Full text: Theorem 21 and Lemma 22 in this version. Other published versions use different numbering. Warren original URL was not resolved. |
| Feldman17 | https://proceedings.mlr.press/v65/feldman17c/feldman17c.pdf | Full text: Definition 4.6; Theorems 4.8, 4.11, 7.7, 7.8. The randomized conversion retains R_KL/tau^2 and logarithmic factors. |
| AKMSS21 | https://arxiv.org/pdf/2108.04190 | Full text, v2: learning models in Section 2 and Theorem 3d. DAG inputs include the constant one; engineered initialization; square loss; clipped and rounded full-batch gradients. See exact formulas in Section 8. |
| BHKR26 | https://arxiv.org/html/2605.01038v2 | Full text: Theorem 1.3 and its approximate-rank definition. Side fractions d^{-C_eta d} and d^{-C_eta d^2}. Partial entries retain stars. |
| BHHLT26 | https://arxiv.org/html/2606.18236v1 | Full text: index <=2 LR-1; projective-plane example. No unsupported SQ equivalence is inferred. |
| VALG26 | https://arxiv.org/pdf/2608.13060 | Full title/authors/version verified. Theorem 4.9 is conditional on Assumptions 4.39-4.42, including the polynomial response-span hypothesis. No universal span bound is derived there. |
| FHV26 | https://arxiv.org/abs/2604.01510 | Abstract/full-text statement of the partial Gap-Hamming result checked; it is not an exponential-in-bit-dimension total-matrix lower bound. |
| GHIS25 | https://arxiv.org/abs/2506.12022 | Version/title/authors and constant-in-n, 2^{O(k)} Hamming-distance upper bound checked. |
| DKT22 | https://arxiv.org/abs/2212.03008 | Metadata and stated algorithmic result checked; no dependency on its stronger algorithm, since the needed weakly polynomial argument is supplied. |
| BDES02 | https://www.jmlr.org/papers/v3/bendavid02a.html | Primary JMLR record checked. Strict dimension convention is explicitly defined in this paper. |
| KMS20 | https://proceedings.mlr.press/v125/kamath20b.html | Primary record and probabilistic-dimension source checked. |
| CMW25 | https://arxiv.org/abs/2411.10784 | Primary preprint metadata and probabilistic representation context checked; STOC 2025 attribution is distinguished from preprint year. |
| Kearns98 | https://doi.org/10.1145/293347.293351 | Established bibliographic entry retained; direct publisher endpoint rejected automated access. |
| Feldman08 | https://vtaly.net/papers.html | Author publication list verifies STOC 2008 and pages 619-628; the characterization is also discussed in the checked Feldman11 text. |
| Feldman11 | https://proceedings.mlr.press/v19/feldman11b.html | Full primary text checked. The conjunction limitation is on efficient strong CSQ learning, not a denial of weak learning. |
| DV04 / BF13 / GSS13 | https://arxiv.org/abs/1307.3102 ; https://jmlr.org/papers/volume14/gonen13a/gonen13a.pdf | BF Appendix A rescaling statement and GSS Lemma 10 grid-margin bound checked. Direct DV04 publisher record remains unresolved. No general bit-complexity converse is newly proved. |
| FGV | https://arxiv.org/abs/1512.09170 | Primary version and SODA 2017 history checked. The bibliography uses this verified version rather than an unchecked 2021 journal designation. |
| KM25 | https://proceedings.mlr.press/v267/karchmer25a.html | Primary record checked. The unverified FKS personal-communication sentence is omitted. |
| MKAS21 | https://proceedings.mlr.press/v139/malach21a.html | Primary title/authors/pages checked. |
| ABBBN21 | https://arxiv.org/abs/2108.10573 | Correct 2021 authors include Brennan, Bresler and Nagaraj. |
| ABM22 | https://arxiv.org/abs/2202.08658 | Correct 2022 authors are Abbe, Boix-Adsera and Misiakiewicz. |
| GGM86 / HILL99 | https://doi.org/10.1145/6490.6503 ; https://doi.org/10.1137/S0097539793244708 | HILL publisher record resolved; GGM publisher access was restricted. General reductions are imported background, not re-proved quantitative security transformations. |
| Renegar92 / Vorobjov21 | https://arxiv.org/abs/2112.00456 | The singly exponential existential-real statement was checked in Vorobjov's notes. Original trilogy record remains unresolved. |
| MC12 | https://arxiv.org/abs/1201.3731 | Title/authors and real-closed-field decision context checked. The paper's canonical selector only needs decidability. |
| Forster02 | https://doi.org/10.1016/S0022-0000(02)00019-3 | Bibliographic attribution retained; direct automated access restricted. A complete proof of the used bounds is provided. |
| HHM23 | https://eccc.weizmann.ac.il/report/2022/130/ | Primary preprint and topological-method context checked. |

## Addendum-specific checks

The engineered simulation corollary uses the deterministic improper succinct learner, which works for every key and all valid SQ answers. At accuracy epsilon/8 its Boolean output has square loss at most epsilon/16 after {0,1} recoding. Theorem 3d adds delta=epsilon/16, yielding square loss at most epsilon/8. A threshold mistake costs at least 1/8, so expected classification loss is at most epsilon. Initialization is key-dependent but is fixed before the target and marginal. The network-size polynomial charges simulated time; this is not a theorem for OQ1's Gaussian initialization, logistic loss, or prescribed architecture.

The strengthened per-individual-table sample assertion in the addendum is false. The all-positive table is a counterexample. Proposition 10.3 retains the valid single-table-independent-learner quantifier, averaged over fair tables or required uniformly over them. This correction is preserved in Section 10 rather than silently promoting a minimax result to a pointwise lower bound.

## Build and layout

The final build is checked separately in `checks/build_report.json`. Five figure inputs are compiled from TikZ and rendered to PNG. All pages are rendered in contact sheets; the first page, algorithms, figures, comparisons, references and appendices were inspected. The author field is Samuel Mausberg. The main text ends on page 30; references and appendices follow.

ChkTeX was run. Its raw output is retained. The installation has no global resource file, and its default diagnostics flag valid TeX math spacing, compound-word hyphens, TikZ iteration syntax and quote punctuation. The reviewed invocation disables only the recorded style categories; the compiler and independent reference/overflow checks remain enabled. No claim of a zero-warning unconfigured ChkTeX run is made.
