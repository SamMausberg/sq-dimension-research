# Changes: Turn 5 to Turn 6

No new result or O(n)-query improvement was added. The optional improvement remains an open problem. Nothing established was deleted; one repeated spectral-rectangle calculation was consolidated and the finite tie lemma's later-use consequence was moved after Corollary 4.4.

## Mathematical and model fixes

- The Main Theorem places the prescribed fixed eta before the existence of infinitely many classes. This removes ambiguous simultaneous-eta scope.
- Theorems 7.1, 7.6, 7.9 and 7.10 now state local accuracy, query-budget and common-learning hypotheses. The adaptation Omega consequence explicitly includes the high-dimension event and small-query premise.
- Lemma 6.4 now uses the same epsilon-independent 64 ceil(n) star-regularity threshold as Section 5. The previous proof already established it; C0 retains its additional accuracy-dependent algorithmic role.
- The k<=d cap case explicitly replaces the factorization by evaluation coordinates and rows e_h; it is not an invertible ambient transformation. Nonzero scores and exact I_k/k covariance are stated.
- Public history includes previous queries and the current stopping answer. Coverage is applied before a fresh rectangle draw; no oracle policy is given future private coins.
- The full-batch comparison explicitly displays E sup and uses one ignored random bit, avoiding an assumption about r=0. Its deterministic source learner already satisfies the stronger premise.
- The subgrid proof explicitly checks the Warren range and retains the >=1 scaling, coefficient and bit-cost details.
- The finite tie lemma now states a self-contained finite strictification/error comparison. Its unchanged probabilistic consequence follows Corollary 4.4, avoiding a forward-dependency ambiguity.
- Shared proof 3.1/3.2 and all deferred proofs bind the canonical statements rather than restating them independently.

## Source and bibliography changes

- Replaced the awkward abstract quotation by the original OQ2 statement, recovered from the repository PDF content stream. Direct PDF downloads failed; relevant original pages were recovered rather than falsely claiming a complete six-page binary download.
- Added the original Section 3-4 comparisons, including the raw-score zero convention and every OQ1 update/output/expectation parameter.
- Corrected FGV21 to MOR 46(3):912-945 (2021), DOI 10.1287/moor.2020.1111.
- Corrected BF13 to the NeurIPS 2013 title and record, identifying Appendix A as the extended version's appendix.
- Corrected ABM22 to COLT 2022/PMLR178, pages 4782-4887.
- Replaced APP05's generic publication-list route with DOI 10.1016/j.jcta.2004.12.008, verified in Princeton's institutional record. Its full original text remains unavailable. Removed Feldman08's generic publications-list URL. Five requested original bibliography records remain unresolved; candidate identifiers seen only in secondary indexes are logged, not claimed primary-verified.
- Warren, APP and Renegar uses identify the checked AMY, HHPTZ and Vorobjov formulations in the paper itself.
- Downgraded the unchecked quantitative OWF-to-PRF motivation to background; the exact PRF security premise remains the assumed hypothesis, with no theorem weakened.
- Added FKS's attributed statement about the failed 2025 upper bounds, without a new proof audit or editorial characterization.

## Presentation and submission

- Samuel Mausberg remains the sole credited author; no affiliation added.
- Replaced the AI-use placeholder with a professional final acknowledgment and a matching standalone statement.
- Corrected singular-author grammar and capitalized Section/Appendix references using label-aware aliases.
- Main Theorem no longer repeats `(Main result)`. Added the requested at-least mass qualifier to the abstract.
- Figure arrows now use current statement numbers. Captions and all-page renders were reviewed.
- Kept 11-point text and horizontal margins; vertical margins are 0.82 inches to retain 30 pages of main text after adding the source quotation and clarification. No proof was shortened for pagination.
- Added source, referee, dependency, constant, spellcheck and clean-build records. The raw lint notices are retained and explained rather than claiming a zero-warning lint run.
- Added a stock-pdfLaTeX arXiv source package, plain abstract, unsent cover email and author checklist.

## Number mapping

Turn-5 numbers are unchanged. The historical Turn-4 mapping is retained below.

| Turn 4 | Turn 5 / Turn 6 | Label |
|---|---|---|
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

The exact six canonical-statement edits and unchanged statements are listed in `checks/statement_changes.diff` and `checks/statement_proof_audit.json`. The unnumbered Main Theorem has its separately documented eta-quantifier edit.

## Final packaging result

The actual 37-file arXiv archive compiles after fresh extraction with shell escape disabled. Final output: 59 pages, 30 main-text pages, zero errors, undefined references/citations, overfull boxes or duplicate anchors. All 59 page renderings match the visually inspected manuscript. The final acknowledgment has no AI-disclosure placeholder. The optional O(n) improvement remains open and was not attempted.
