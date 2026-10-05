# Changes from the preceding 32-page manuscript

## Mathematical changes

The separation now survives a target-prior relaxation: for the uniform prior on full-length lines, a feature law may be chosen for that prior and may fail on any fixed fraction of targets below one, yet its dimension remains Theta(N). The proof counts low-rank approximations simultaneously over every sufficiently large retained row set. A new minimax proposition converts bounds valid for every target prior into a worst-target expected-error bound, after adding one constant feature and adjusting the error. A rectangle calculation also bounds classical SQ dimension by twice the inverse rectangle ratio. Together these results give a counterexample to Karchmer and Malach's intermediate Theorem 4.1 as stated in arXiv:2505.10423v1; they do not by themselves disprove that paper's mini-batch SGD conclusion. Finally, the transcript argument now gives ordinary and exact probabilistic upper bounds with logarithmic overhead, as well as the previous expected-error bound. The incidence-only Warren count, N+3 representation, constant-feature exact-to-average reduction, fixed-tolerance query lower bound, and previous computational results are retained after rechecking.

## Material cut or replaced

1. Removed the paragraph attributing a private remark to Feldman and the related private-remark acknowledgment. A single neutral sentence credits the qualitative implication from Diakonikolas, Kane, and Ren and Razborov and Sherstov, as made explicit by Patel.
2. Replaced the earlier opening and repeated comparisons with an introduction centered on the learning question, the exponential separation, Patel's priority and natural construction, and the proof mechanism.
3. Replaced the previous expected-error-only transcript statement and proof with bounds for all three dimension notions, including a separate deterministic bound.
4. Replaced the single median-order figure with three new TikZ figures. The median argument itself remains fully proved.
5. Removed repeated descriptions of the computational model from the main text. The full table, median, star-regularity, and pseudorandom-function statements and proofs remain in the appendices; this is relocation, not removal of results.
6. Consolidated limitations into one final paragraph. No engineered-gradient simulation, status table, verification ledger, or experimental timing table was reintroduced.

## Limits of this revision

The revision does not settle benign-gradient learnability, construct a natural unconditional polynomial-time family with the same exponential gap, or determine the full joint tradeoff for varying query count and tolerance. The missing exact primary-source quotation of the benign definition is documented in SOURCE_NOTES.md rather than reconstructed and presented as verbatim text.
