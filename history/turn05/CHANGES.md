# Changes from the preceding manuscript

Author: Samuel Mausberg. Date: September 10, 2026.

## Summary

The title page and PDF metadata name Samuel Mausberg as the sole author. The title is retained and the requested subtitle is added. The main text has ten sections and is at most 30 pages. Longer proofs remain in appendices. The abstract has eight sentences and fewer than 180 words. Five vector figures, four algorithm2e procedures, a notation table and two comparison tables replace text-only diagrams and dispersed summaries. All labels are section-based.

## Statement mapping

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

The exact-probabilistic conversion formerly included in Theorem 5 is now Lemma 4.3. The existing tie argument is Lemma 2.3. Existing minimax and repetition arguments are consolidated as Lemmas 2.1 and 2.2. Corollary 4.4 states the existing separation in the three source-form relaxations. No established theorem was removed to reduce length.

## Strengthened or promoted claims

- Proposition 6.3 promotes the previous polynomial-advice construction. Its full proof collapses the exterior domain to one positive point and invokes the deterministic proper learner on the polynomial-size effective table. It is an almost-every-advice theorem, not an efficient deterministic good-advice selector.
- Corollary 8.1 is the permitted engineered differentiable-learning consequence. It uses the verified full-batch part of AKMSS Theorem 3d, retains the architecture, initialization, loss, precision and sample-size hypotheses, and gives the square-loss-to-classification calculation. It does not establish the prescribed online-SGD conjecture or a dimension-versus-network-size separation.
- The main definitions explicitly cover both ordinary tie conventions up to one dimension and all nondegenerate probabilistic conventions. The eta=C epsilon specialization is displayed in Corollary 4.4.

## Proof consolidation and clarifications

- Prove finite minimax once, including the finite-payoff-type case, and invoke it in the rectangle mixture, randomized statistical dimension, deterministic transcript bound and average-margin argument.
- Prove product-weight extension once. Start with strictly positive rational weights before passing to arbitrary weights, avoiding an unnecessary deletion-closure assumption in the general lemma.
- Retain the R1-R20 endpoint table and the independent role of learner randomness. The core rectangle constants and guarantee are unchanged.
- Make fixed dyadic rounding of approximate convex-program gradients explicit, so exact rational projection does not conceal uncontrolled bit growth.
- State both singleton-side cases of negative cap rectangles. Keep the deterministic finite-net stage bound and distinguish table-polynomial time from polynomial time in log domain size.
- Keep the first-negative-rectangle proper completion, the all-light order-median proof, and the star-regularity quantifiers. D_k first becomes positive at k=180; the k>=32 observation is identified as only an auxiliary implication.
- Keep the hidden-table lower bound averaged over random tables for one table-independent learner. The addendum's universal per-table inference is rejected because it is false for the all-positive table and does not match OQ1's class-dependent architecture quantifier.

## Moved, not dropped

The full construction proof, cap and proper-learning proofs, median proof, PRF proof, original spectral and transcript proofs, communication proof, all-product projective-plane proof, halfspace analysis, network representation, resource barriers, statistical-dimension route, finite-bit isotropy argument, concentration calculation and experiments are retained in the appendices. Their theorem statements remain in the relevant main sections, except the independent backup geometric bounds and the separate RSD theorem, which remain appendical statements.

## Source-driven edits

- Add BDES02, KMS20 and CMW25 to the definitions, and the source bibliography's SQ, rescaling, margin, differentiable-learning and staircase context to related work.
- Correct the 2021 staircase paper's authors to Abbe, Boix-Adsera, Brennan, Bresler and Nagaraj; the Abbe-Boix-Adsera-Misiakiewicz paper is the distinct 2022 result.
- Use the verified 2017 preprint/conference version of the mean-estimation/SQ optimization paper rather than asserting an unchecked 2021 journal record.
- Correct VALG's full title and retain the polynomial response-span assumption in its comparison. No unconditional resolution is attributed to that preprint.
- Distinguish BHKR's deterministic-column approximate sign-rank from the random-embedding dimensions here, and preserve stars for partial matrices.
- Quote only a short verified clause from the FKS abstract. The complete original PDF was not recovered; the formal question is restated from the supplied setting, not passed off as a full verbatim quotation.
- Do not attribute an unverified personal-communication correction to FKS. The prior random-feature upper-bound context is described neutrally at the level checked.
- Retain the exact 2^-15 rectangle constant as verified in HHPTZ Theorem 1.9, with the independent 2^-18 proof available. Original publisher retrieval limits are recorded in VERIFICATION.md, not hidden behind fabricated DOI links.

## Presentation

Replace per-result defensive commentary with explicit theorem hypotheses, a main-text Scope paragraph and one experiment-scope paragraph. Use RECTIFY, the cap sampler, Proper RECTIFY and the order-median learner as named algorithms. Use original TikZ drawings for the grid template, one RECTIFY round, cap geometry, order-median geometry and the implication map. The implication map never draws small rectangles => SQ-hard: halfspaces refute that implication.

## Executed checks and preserved data

Recompute all stated numerical constants and rerun the exact median endpoint, unseen-label, large-star and affine-certificate checks. Preserve the earlier full keyed-oracle sweeps and their raw results rather than presenting old timings as a newly rerun benchmark. No SGD experiments were added. The reproducibility package separates finite computations from universal mathematical proofs and from unproved cryptographic assumptions.

## Remaining completion items

Full-source comparison with the FKS PDF and direct resolution of a few original classical references remain outstanding. The mathematical formulations and imported versions used here are explicitly identified. The final response must not claim that these source-level checks or formal verification were completed.
