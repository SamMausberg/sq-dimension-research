# Changelog: release 7 to the current revision

## Mathematical checks and fixes

1. **Lemma 11 (previous 5.3):** made the nonnegative tolerance domain explicit. Recomputed the 3/2, 9/8, 21/8, beta/9, 512 zeta and 1023 zeta constants. The canonical conclusion and all thresholds are unchanged.
2. **Theorem 12 (previous 5.4):** rechecked nonmonotone median bracketing, both order cases, the heavy-atom split, tail queries, C_0, the fixed-bit sampler, J and its worst-case query budget. No quantitative change was needed.
3. **Lemma 13 and Theorem 14 (previous 6.1--6.2):** explicitly fixed the ambient PRF encoding for both the full matrix and every subgrid. Read I_k distinct inputs without re-encoding at scale k. The proof now states the acceptance-probability inequality and negligibility conversion in both key length and domain encoding length. The n^c/(30 log_2 n) conclusion is unchanged.
4. **Corollary 17 (previous 6.5):** checked a union bound, not an independence assumption, for rank and star-regularity exceptions.
5. **Corollary 18 (previous 8.1):** replaced the relative phrase 'of the form above' with a precise appendix pointer after moving the imported model. Checked the original full-batch theorem again. Polynomial size uses the actual running time of the deterministic improper succinct learner. The E[sup] guarantee and r=1 ignored bit are retained.
6. **Theorem 24 and Theorem 32 (previous 7.1 and 7.9):** rechecked zero-mass-cell completion, shallow-leaf counting, both halfspace colors, and the e^{-t^2/n} concentration exponent. No parameter changed.
7. **Proposition 19 (previous 10.3):** retained the table-independent uniform/average quantifier; it is not a per-table sample lower bound. Rechecked the T*S >= dc/3 consequence with S>=2.
8. **Theorem 8, new:** proved matching logarithmic query order for typical random flips. The proper lower bound has the requested leading n numerator; the unrestricted one has leading n/3. The optimal-order conclusion fixes an accuracy-dependent constant tolerance. The proposed claim that every target needs a distinct good improper output is false, as shown by the exact same-slope counterexample. The new proof counts the maximum targets fitted per output and handles randomized learners with a fixed grid oracle.
9. **Theorem 5's proof:** spelled out the already stated asymptotic exact-probabilistic consequence using Lemma 6, rather than leaving that cross-application implicit.

## Structure and presentation

- 13-page main text, including a one-page summary before the introduction; full proofs and every earlier numbered result retained in appendices.
- Global consecutive theorem numbering, with all 39 old labels preserved and the new theorem added. The explicit old-to-new map is `NUMBERING.md`.
- Abstract under 1,900 characters; one notation table; revised expert introduction and imported-ingredients table; exact version-specific VALG v2 comparison.
- The acknowledgment names Hamed Hatami, Pooya Hatami, William Pires, Ran Tao and Rosie Zhao. The Disclosure names GPT-6 Astra (OpenAI), states the role of AI in proof and manuscript development, and distinguishes readable arguments from finite script audits.
- Current paper sources, compiled PDF, every historical project archive's usable materials, CPU scripts, raw records, source ledgers, and uncompiled formalization drafts organized into one repository. Historical statuses and numbering remain historical.

## Packaging and verification

The release tests compilation, all source/proof bindings, the acyclic reviewed dependency graph, the fresh exact/numerical regression runs, the one-page summary, figure rendering, and Git-bundle import. The tar.gz is compilation-only; the Git bundle contains the full research record. The author still chooses a public license and performs the final personal review. No upload or email is sent.
