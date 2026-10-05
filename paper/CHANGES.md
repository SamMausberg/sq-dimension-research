# Final revision changes

## v4 - 5 October 2026

- Fixed both proof-sketch headings to print "Proof sketch" without a duplicated "Proof" or literal square brackets. The dedicated environment uses the jmlr class's proof styling and end marker.
- Mathematical statements and proof text are unchanged from v3.

## v3 - 4 October 2026

- Restricted the classical-SQ rectangle to the chosen hypotheses and stated the positive lower bound on the rectangle ratio.
- Restricted the proper-learner leaf argument to leaves reached by valid runs.
- Stated the effective threshold N >= 1373 in Theorem 12.
- Corrected the active-mass cross-reference and tightened the rectangle learner's query budget to 3R, including its Lean counterpart.
- Added the nonempty-rectangle qualification, defined the flips explicitly, and used "sign-rank at most six."
- Updated the reproducibility paragraph and included the expanded Lean development, its coverage table, and the release verification report.

## v2 - 4 October 2026

- Dated the authored preprint and marked it v2.
- Ended the Feldman-Kamath-Srebro quotation at "proof" and identified its Karchmer-Malach attribution as a personal communication.
- Verified Patel's 17 September 2026 arXiv submission date. Replaced the Karchmer-Malach bibliography URL with the ICML/PMLR record while retaining the v1 theorem-numbering note.
- Simplified Theorem 1's proper query bound to O(log N + 1/epsilon), and stated the deterministic improper bound O(log N + log(1/epsilon)) separately. The inverse-error term arises in proper completion.
- Made the randomization of the succinct proper learner explicit in Section 7 and Appendix H; clarified how a full-class representation restricts to the subclass on the subgrid.
- Retained the stronger exp(-t/8) Hoeffding bound in G.5, yielding a star-regularity failure bound exp(-7n), and carried that bound into H.4. Removed ceilings around the integer n. Simplified the analogous redundant term in the succinct proper query bound.
- Checked all 22 entries in the bibliography database against original publisher/repository records or publisher-deposited DOI metadata. All 21 cited entries are included in the PDF and the Zenodo reference metadata. The unused Aslam-Decatur database entry is retained. See REFERENCE_AUDIT.json for sources and scope.

## Original revision

- Replaced the opening and abstract with the question, answer, and quantitative comparison. The abstract is below 150 words, and the main text occupies 11 pages.
- Added the exact independence sentence reporting that a draft containing the main separation was shared with V. Feldman on September 11, 2026. The anonymous version omits only its identifying chronology.
- Recast the Karchmer–Malach comparison around their Theorem 4.1 and cited Feldman–Kamath–Srebro's reported proof flaw. Removed the obsolete claim that a formal definition of benign networks was missing. The comparison does not claim that the mini-batch SGD conclusion is false.
- Preserved every established theorem and bound, including Theorem 9, Propositions 10 and 11, the query lower bounds, and all transcript bounds. Clarified “rank at most d+1,” made the integer rank parameter explicit, and corrected a cross-reference to the fixed-tolerance query conclusion. Rechecked the arguments and reran the finite exact and numerical tests.
- Tightened proof introductions and transitions. Cut the duplicated source comparison from the proof appendix, the separate diagnosis of the boosting proof, detailed mini-batch parameters irrelevant to the SQ result, repeated endpoint assurances, and redundant scope sentences. No result was removed.
- Rebuilt the three TikZ figures: the two removed regions and their progress factors, a consistent incidence-flip example, and a comparison that distinguishes proved lower bounds from the transcript upper bound. Prepared authored and anonymous PDFs and independently compiled consolidated sources.
