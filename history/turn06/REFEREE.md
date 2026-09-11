# Simulated referee reports: pre-edit record

These are three sequential, AI-generated adversarial readings of the same complete source, not reports from independent people or independent models. They were recorded before manuscript edits in this revision. The frozen source hashes and timestamp are in `pre_edit_manifest.json`. The response section below identifies each resulting edit or the exact unchanged source lines answering the objection. Bibliographic access limitations are not silently treated as mathematical verification.

## Referee 1: statistical queries and learning theory

The most vulnerable part is the distinction between a history-adapted adversary and an adversary supplied with the entire private seed. The main drift proof can handle the former; the differentiable-learning comparison invokes a source with an expectation of a supremum. Those are different claims and must remain visibly separated.

**R1.1. Public history and coin leakage.** Equation (1) permits dependence on the public history, but the proof says only “conditional on the pre-proposal history.” Specify that this includes the current stopping answer and all previous queries, including queries revealing earlier random choices. The next rectangle must be a fresh conditional draw. Otherwise the coverage calculation could be applied under the wrong law.

**R1.2. Supremum and expectation.** Give a local reason that the upper bound does not move a supremum inside expectation. For the lower bound, the adversarial reference oracle must be chosen before the private seed. For Corollary 8.1, show why the stronger imported `E sup` premise is satisfied rather than inferred from equation (1).

**R1.3. Randomized versus deterministic error.** Distinguish the randomized learner's expected error and finite query budget from the deterministic finite-net learner's pointwise error guarantee. In the proper completion, identify exactly where budget-failure probability is used, and why it vanishes in the deterministic version.

**R1.4. Every C in the averaged variant.** Corollary 4.4 must quantify over an arbitrary fixed proposed C and polynomial before choosing a positive constant epsilon with C epsilon<1/2. The constants may depend on that epsilon but must not depend on M. Also clarify whether the family is chosen for one prescribed eta or simultaneously for every eta.

**R1.5. Accuracy and domain exponent.** Audit every `O_epsilon`, `O_d`, and fixed-accuracy phrase used against (Pn). In particular, m=O(n^2) for the deterministic succinct learner must not be described as its table-based O(n) implementation. State the accuracy interval inside Theorems 7.1 and 7.9, not just globally.

**R1.6. Theorems 7.6 and 7.10.** The transcript theorem uses a depth-m decision tree and epsilon<1/4, but its statement currently leaves some hypotheses in the surrounding notation. The adaptation theorem similarly begins “Any deterministic learner.” Include m, tolerance, accuracy and the common-learning premise explicitly. Retain the small-query condition for its Omega conclusion; without it the exhaustive correlational learner is a counterexample.

**R1.7. Relation to the source note.** A landing-page abstract is not the statement of OQ2. The verbatim quotation and comparisons must be based on the complete note, or specifically marked unavailable. The literal raw-score zero-predictor defect must not be called a refutation of a nondegenerate probabilistic problem without specifying the convention.

## Referee 2: sign-rank, communication and combinatorics

The least routine component is the computational realization of radial isotropy, not the elementary incidence count. It needs a statement-to-proof audit of the small-survivor case and exact versus approximate transforms. The counting applications also require strict sign patterns throughout.

**R2.1. Warren's range and constant.** Display the identification s=K^2, v=2Kd, degree=2 and the condition d<=K/2 in each application. When floor thresholds vanish, the event is empty. The subgrid assertion D_k>=1 implies k>=32 is a sufficient implication, not the first nonzero threshold. Identify the precise original or secondary formulation being used.

**R2.2. Bias and counting.** The approximate embedding only promises Boolean signs, potentially with zeros. Check the row-wise bias explicitly, including rows with no negative scores and empty incidence rows. Explain why a d-dimensional witness produces strict rank at most d+1, and why the probability event is dc^eta<s_eta.

**R2.3. Rectangle constants.** The 2^{-15} constant uses a particular per-side homogeneous-rectangle formulation. Verify it or attribute that formulation explicitly. Independently check the 5-ball estimate and the fallback 2^{-18}; these must not depend circularly on the sharp imported bound.

**R2.4. Perturbation and k<=d.** The small-survivor construction replaces the factorization by evaluation coordinates; it is not literally an invertible transform on the full original ambient space. State its rows and point vectors explicitly and verify nonzero normalization and k^{-1}I_k covariance. For k>d, retain all targets and verify general position for every survivor subset.

**R2.5. Appendix J bit bound.** The exact transform may be irrational. Verify the convex sublevel radius, each projected-gradient error term, denominator growth across iterations, and the final covariance perturbation. A finite oracle reply cannot be obtained by an uncosted operation on an arbitrary exact real in a Turing model; specify the oracle's rounded finite-bit interface in the computational corollary.

**R2.6. Communication completion.** Zero-mass cells still require an exact protocol. Confirm that arbitrary completion there has no expected cost and that positive-mass continuations form strictly smaller cells, so every input terminates.

**R2.7. Projective-plane algebra and notation.** The user prompt refers to 7.3 as projective-plane algebra, but 7.3 is the joint barrier. Check the actual plane statements 7.5 and 7.8, including A^T A, the residual Gram scale, R>=q and the 19 bound with m>=1 and tau<=1. Separate the plain-Gram certificate from the target-dependent joint certificate.

**R2.8. Average margin is not a sign-rank upper bound.** Proposition 10.2 must only bound the numerical classical lower-bound certificates. Its rectangle feature construction initially has zeros. Check that adding an orthogonal strict realization, then normalizing via private coordinates, preserves all signs and gives the claimed limit.

## Referee 3: cryptography and computation

The weakest interface is the transfer from source-query computations to the precise full-batch model. A second concrete concern is a definition drift: the main succinct-learning section defines star-regularity at 64 ceil(n), while Lemma 6.4 mentions a threshold C0 that also depends on epsilon. The proof already appears to establish the stronger definition, but the statements must agree.

**R3.1. The subgrid distinguisher.** Its uniform-function input must expose exactly I_k independent bits, not the full grid. Check the embedding of the subgrid into the large domain, the >=1 scaling, degree and coefficient bit size, singly exponential rather than doubly exponential decision cost, and the eventual absorption of constants in 2^{sigma^delta}.

**R3.2. Negligibility and stars.** Reconcile the two star-regularity thresholds. Show that negligibility in sigma transfers to n for the fixed polynomial reparameterization, and that the intersection event in Corollary 6.5 has a negligible exceptional key fraction. No deterministic selector of good keys follows.

**R3.3. Full-batch simulation.** Check the original theorem's activation, DAG inputs, all trainable edge parameters, initialization map, half-square loss, sample reuse, rounding lattice, clipping, differentiability and the order E sup. Confirm that the deterministic source learner satisfies the stronger premise. Check whether r=0 is explicitly admissible; an ignored dummy bit is an alternative that preserves all claims.

**R3.4. Hidden-key collision bound.** The learner is independent of the key and sees only the supplied samples. The test point must be independent; repeated training points only improve the stated q/N upper bound. The bound applies averaged over keys, not to every table or to a class-dependent architecture.

**R3.5. Finite-bit median computation.** Rounding must reserve half the tolerance. Query predicates use integer arithmetic of O(n) bit length, including divisibility with negative denominators. The proper large-star sampling is biased modulo sampling, so its proof needs the 1/(2t), not 1/t, lower bound and the resulting 1/16 success probability.

**R3.6. Advice and explicitness.** The advice construction must not hide an exponential lookup table after collapsing the domain. The added point's label is fixed positive for every row, the effective rank-seven template remains strict, and the proper output extends to a member of the original class. This does not give a uniform deterministic explicit sequence or refute a bound charging arbitrary polynomial runtime.

## Initial disposition

No counterexample to the main peeling/elimination argument was found in this reading. Two concrete statement defects require edits: missing local learning-budget hypotheses and the star-regularity threshold mismatch. Several source-access checks remain open. The final disposition must report unresolved access separately, rather than calling it a proof verification.


# Responses and disposition

The labels below close the 21 simulated referee points at the level requested: a text fix, an exact existing proof pointer, or an explicitly attributed and downgraded imported formulation. A closed response is not a claim that all original bibliography records were recovered. Source limitations remain in VERIFICATION.md and the author checklist.

## R1.1: FIXED

The model now includes the entire public transcript and current query, while excluding future private coins. The drift conditions on the stopping answer before the fresh draw. `sections/02_preliminaries.tex:9-17`; `sections/03_rectangle.tex:63-124`

## R1.2: ANSWERED AND CLARIFIED

For the upper bound a single valid policy is fixed throughout, and progress is bounded for each permissible action. The lower-bound memoryless policy is chosen before the private seed. The full-batch comparison uses the deterministic source learner, whose guarantee is pointwise in all response sequences, so it satisfies the stronger expectation-of-supremum premise. `sections/03_rectangle.tex:63-124`; `appendices/certificate_proofs.tex:23-50`; `sections/08_sgd.tex:36-40`

## R1.3: ANSWERED

The randomized construction bounds the probability of budget exhaustion, not the conditional loss on every seed. The finite-net construction has progress at every stage and a fixed deterministic cap; the last paragraph of the proper proof explicitly removes the failure event for that implementation. `sections/03_rectangle.tex:63-124`; `appendices/cap_proper_proofs.tex:4-57`; `appendices/cap_proper_proofs.tex:60-103`

## R1.4: FIXED AND ANSWERED

The displayed Main Theorem now places the prescribed fixed eta before the existence of infinitely many classes. Corollary 4.4 fixes any proposed constant C and polynomial, chooses a constant epsilon with C epsilon<1/2, and then sends M to infinity. Accuracy-dependent constants do not grow with M. `sections/01_introduction.tex:17-35`; `sections/04_family.tex:89-95`; `sections/04_family.tex:96-98`

## R1.5: FIXED

The computational regimes remain separate: 5.1 and 5.2 are table-polynomial; 5.4 and 6.5 are succinct and use O(n^2) queries. Local accuracy hypotheses were added to 7.1 and 7.9. `sections/05_learners.tex:6-21`; `sections/05_learners.tex:46-59`; `sections/05_learners.tex:113-120`; `sections/06_explicit.tex:65-72`; `sections/07_characterizations.tex:7-19`; `sections/07_characterizations.tex:190-197`

## R1.6: FIXED

The transcript and adaptation statements now include finite nonempty classes, integer query budget, tolerance range, accuracy range and the common-learning premise. The Omega conclusion explicitly assumes the high-dimension event and m <= (log M)^C. The exhaustive correlational learner remains the counterexample to dropping the budget restriction. `sections/07_characterizations.tex:133-149`; `sections/07_characterizations.tex:217-228`; `sections/07_characterizations.tex:233-233`

## R1.7: FIXED; ORIGINAL PAGES RECOVERED

Repository base64 ranges recovered the checksummed original content streams for PDF pages 2-4, including OQ1, OQ2 and the two probabilistic formulas. The direct full-PDF downloads failed; no claim is made that a complete original binary was saved. The quotation matches the original words; symbols, ligatures and line wrapping are typeset normally. The explicit tie convention is retained rather than identifying the vacuous raw-score formula with the nondegenerate problem. `sections/01_introduction.tex:3-6`; `sections/02_preliminaries.tex:36-39`; see SOURCE_CHECKS.md A1.

## R2.1: FIXED; SOURCE FORMULATION IDENTIFIED

The family proof gives s=K^2, v=2Kd and degree 2, with d<=K/2 and empty zero-floor cases. The subgrid proof now states D_k<=k<=K_k/2 explicitly and explains the limited use of k>=32; the first positive floor is 180. Warren is used in AMY Theorem 21/Lemma 22 form, not represented as an original-source verification. `appendices/family_proof.tex:2-30`; `appendices/explicit_proofs.tex:4-20`; checks/constants.json.

## R2.2: ANSWERED; PROOF BINDING IMPROVED

The row bias is positive under sign(0)=+1 and negative under the opposite rule. A row with no negative scores admits any sufficiently small positive bias. Empty-incidence rows receive weight zero. The inequality is dc^eta<s_eta so that d+1<=s_eta. The tie lemma now states only its finite core; the lower-bound consequence is placed after Corollary 4.4, avoiding a forward logical dependency in its statement. `sections/02_preliminaries.tex:95-97`; `appendices/oracle_bounds.tex:36-40`; `sections/04_family.tex:51-76`

## R2.3: ANSWERED WITH EXPLICIT SOURCE STATUS

The sharp per-side constant is explicitly the HHPTZ Theorem 1.9 formulation of APP. The original APP DOI/text lookup remains unresolved and is downgraded in the source ledger. The independent cap proof uses no sharp imported constant: its Gaussian-volume estimate gives c6/48>1/207360>2^-18. `appendices/family_proof.tex:2-30`; `appendices/geometric_bounds.tex:7-21`

## R2.4: FIXED

The k<=d case is explicitly a new evaluation-coordinate factorization: rows are e_h, and point coordinates are their strict template scores. Each score is nonzero, so normalization is legal and uniform row covariance is I_k/k. The perturbation for larger survivor sets preserves all signs and makes every d-subset independent, without removing candidates. `appendices/cap_proper_proofs.tex:4-57`

## R2.5: ANSWERED; ORACLE INTERFACE CLARIFIED

Appendix J gives a polynomial radius, fixed-precision gradient grid, rational clipped projection and denominator growth bounded over a polynomial number of iterations. It then controls Cholesky pivots and normalized covariance. The computational model now explicitly uses finite binary oracle responses; arbitrary exact reals are allowed only in the uncharged query model. `appendices/isotropy_program.tex:4-81`; `appendices/isotropy_program.tex:81-81`; `sections/02_preliminaries.tex:15-17`

## R2.6: ANSWERED

Every positive-mass continuation is a proper nonempty rectangular subcell. There are finitely many pairs, so exact termination holds; zero-mass cells receive a finite exact lookup protocol at zero expected cost. Conditional measures remain product. `appendices/certificate_proofs.tex:4-10`

## R2.7: ANSWERED

The actual algebra is in Theorems 7.5 and 7.8; 7.3 is the joint barrier. The proof computes A^T A, the two-label residual Gram, R>=q and 11+8M<=19M for M=m/tau^2>=1. Ordinary and joint certificates remain distinct. Integer affine checks and exact rational plane constants were rerun. `sections/07_characterizations.tex:105-123`; `appendices/certificate_proofs.tex:105-163`; `appendices/certificate_proofs.tex:205-220`

## R2.8: ANSWERED

The proposition bounds numerical certificates, not actual sign-rank. In the proof the rectangle representation is mixed with an orthogonal strict representation, and separate private padding coordinates restore unit norms without changing cross products; delta tends to zero only after strict realization. `sections/10_discussion.tex:25-37`; `appendices/resource_proofs.tex:18-37`

## R3.1: ANSWERED; DECISION-SOURCE FORMULATION IDENTIFIED

The distinguisher reads I_k independent incidence bits and fills the rest deterministically. Finite strict scores have a positive minimum, so scaling gives >=1 constraints with degree two and bounded integer coefficients. The singly exponential bit bound is explicitly the formulation in Vorobjov attributed to Renegar. Constants in 2^{O_c(n^{4c})} are eventually absorbed by n^{4c+2}<=sigma^delta. `appendices/explicit_proofs.tex:4-20`; `appendices/explicit_proofs.tex:23-37`

## R3.2: FIXED

Lemma 6.4 now uses the same epsilon-independent threshold 64 ceil(n) as star-regularity in Section 5. C0 additionally includes 128/epsilon only for candidate testing. The existing Chernoff proof establishes the stronger threshold. Both failure terms are negligible under the fixed polynomial reparameterization, and their sum remains negligible. `sections/06_explicit.tex:57-59`; `appendices/explicit_proofs.tex:40-49`; `appendices/explicit_proofs.tex:52-54`

## R3.3: FIXED AND CHECKED AGAINST FULL VERSION

The full-batch model lists the five-piece activation, DAG with constant input, trainable edge parameters, initialization map, half-square loss, reused sample, clipped mean and rounding lattice. Its expectation-of-supremum is now displayed explicitly. The deterministic source algorithm satisfies that premise pointwise. One ignored random bit is used, so r=0 need not be interpreted. Theorem 3d and the definitions were checked in arXiv:2108.04190v2, printed pages 4,7,14. `sections/08_sgd.tex:4-29`; `sections/08_sgd.tex:36-40`

## R3.4: ANSWERED

The test point is independent of all training indices. A union bound gives collision probability at most q/N, whether or not training indices repeat, and noncollision success for a random function is exactly 1/2. The resulting subtraction is q/(2N). The proposition quantifies a key-independent learner and average key success, not per-table or class-dependent-architecture success. `sections/08_sgd.tex:83-88`; `appendices/network_proofs.tex:13-15`; `sections/10_discussion.tex:48-56`

## R3.5: ANSWERED

The proof reserves half the tolerance for rounding. Residuals and divisibility predicates have O(n)-bit integer arguments; signed denominator division is an exact integer predicate. Biased modulo sampling assigns every slope probability >=1/(2t), and at least t/8 slopes pass, giving 1/16. C0 and J agree with the script after distinguishing raw from effective tolerance. `appendices/median_proofs.tex:11-68`; `supplement/experiments/seeded_fast.py:33-33,97-99`; checks/constant_occurrences.json.

## R3.6: ANSWERED

Only the polynomial subgrid bits are stored. Every outside point is mapped to one positive dummy point and outside rows to one all-positive row. The seven-coordinate template is strict; proper predictions lift to indexed rows of the full class. This neither selects a uniform good-key sequence nor removes the runtime exponent from a resource-charged bound. `sections/06_explicit.tex:46-52`; `appendices/explicit_proofs.tex:57-65`

## Final disposition

No counterexample to the central rectangle learner was found in this pass. Local theorem hypotheses, the star threshold and proof dependencies were corrected as recorded. All 21 mathematical/model points have responses tied to physical source lines. Five requested original bibliography records remain unresolved; APP05 DOI metadata is verified, but its original full theorem text remains unavailable. These are sequential simulated reports, not independent external peer review.
