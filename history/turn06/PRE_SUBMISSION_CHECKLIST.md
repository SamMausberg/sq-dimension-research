# Author pre-submission checklist

## Items to finish before submission

- [ ] Resolve five original bibliography records: Feldman08 ACM DOI/text; DV04 ACM DOI/text; CMW25 STOC pages/DOI; Warren68 DOI/text; Renegar92 individual part DOIs/text. APP05's DOI is verified; its original full theorem text remains to be obtained. The current manuscript identifies the checked formulations and does not fabricate identifiers.
- [ ] Review the exact FKS quotation and the explicit distinction between its literal raw-score formulas and nondegenerate Boolean tie conventions. The relevant original pages were recovered, not a complete original PDF binary.
- [ ] Review the full manuscript and the 21 simulated referee responses personally. The simulations and finite checks are not independent external peer review or a machine-checked proof.
- [ ] Confirm authorship, date, final AI-use acknowledgment and any actual affiliation/contact details. No affiliation has been invented; the disclosure is final text without a placeholder.
- [ ] Decide the submission license, confirm rights to all included text and figures, and confirm cross-list suitability. The suggested categories are cs.LG primary, cs.CC/math.CO/stat.ML secondary. No upload or email has been sent.
- [ ] Replace the arXiv-link placeholder in COVER_EMAIL.txt only after an identifier exists.

## Conditional statements

- [ ] Theorem 6.2, the PRF part of Lemma 6.4, Corollary 6.5, the high-dimension part of Corollary 8.1, and Proposition 8.3 depend on the explicitly stated subexponential PRF hypothesis.
- [ ] HMAC-SHA256 is only an experimental instantiation. No experiment verifies that security premise, all keys, or an efficient deterministic good-key selector.
- [ ] The polynomial degree in key length, evaluation time and engineered model size can depend on the prescribed c. The paper does not claim one polynomial-key family beating all polynomials or a superpolynomial gap relative to that model's actual size.

## Checks provided

- [x] 39 canonical statements matched to 39 proof bindings; no independent appendix restatements.
- [x] Reviewed dependency graph has a topological order; shared proof units and auxiliary/import nodes are explicit.
- [x] Fixed-budget, median endpoint, covariance, incidence, unseen-label, large-star and affine checks rerun from a clean directory.
- [x] Exact scope of previous full experimental sweeps is distinguished from the fresh runs.
- [x] Finished AI-use disclosure, under-limit arXiv abstract and unsent cover email supplied.
- [x] Actual archive extracted and compiled in a fresh directory: 59 pages, zero errors/undefined references/overfull boxes/duplicate anchors, with all page renderings matching the inspected PDF. See checks/archive_test.json.

The O(n)-query succinct improvement, ordinary class-dependent online SGD, efficient explicit selection, the resource-aware characterization and optimal (m,tau) tradeoff remain open. The source package is technically build-ready; unresolved original bibliography records remain substantive author checklist items.
