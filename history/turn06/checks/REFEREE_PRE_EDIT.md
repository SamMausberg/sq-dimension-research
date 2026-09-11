# Simulated referee reports: pre-edit record

These are three sequential, AI-generated adversarial readings of the same complete source, not reports from independent people or independent models. They were recorded before manuscript edits in this revision. The frozen source hashes and timestamp are in `pre_edit_manifest.json`. The response section in the final REFEREE.md will identify each resulting edit or the exact unchanged source lines answering the objection. Bibliographic access limitations are not silently treated as mathematical verification.

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
