# Source checks for the current revision

## Original sources reread

- VALG, arXiv:2608.13060v2, 10 September 2026, Section 4.3.2, Assumptions 4.39--4.42 and Theorem 4.9. Original HTML: https://arxiv.org/html/2608.13060v2 . The response space spans seed-averaged terminal predictors over all deterministic complete response rules, including invalid ones. The bound on its dimension is a separate assumption. The comparison in the introduction states this additional hypothesis without attributing an unconditional answer to VALG.
- Abbe, Kamath, Malach, Sandon and Srebro, arXiv:2108.04190, original PDF: https://arxiv.org/pdf/2108.04190 . Theorem 3d on printed page 14 and the model/learning definitions were checked. The simulation's size is polynomial in source TIME, not just the SQ query count. It uses the two-stage-ramp network, an engineered initialization map, square loss, clipped rounded full-batch gradients, reuse of one sample batch, and the expectation-of-supremum error criterion. The deterministic source learner supplies its guarantee for every response path. One ignored bit suffices for the randomness parameter. The appendix gives the actual model and parameter substitutions.

The PDF theorem and model pages were visually inspected; the two source comparisons are also decomposed in the nine-result inequality ledger. Complete third-party papers are not redistributed in the Git repository.

## Inherited original-source gaps

The prior release still has unresolved original publisher-record/full-text checks for Feldman 2008, Dunagan--Vempala 2004, Chornomaz--Moran--Waknine 2025, Warren 1968, and the individual Renegar 1992 parts. The Alon--Pach--Pinchasi--Radoicic--Sharir DOI was resolved previously; its theorem is used through the explicitly named Hatami et al. formulation. The current revision does not relabel these gaps as closed. Prior attempts and checked formulations are preserved under `audits/prior/` and `history/turn06/`.

Warren's count and the singly exponential existential-real decision theorem remain imported results used in their identified formulations. Finite recomputation checks their parameter applications, not the general imported theorem.

## Limits of the audit

The claim is a recheck of the specified primary sources and retained formulations. It is not an exhaustive priority search, independent external referee report, or proof-assistant certification. Source-specific comparisons remain distinct from the new proofs in this manuscript.
