# Author pre-submission checklist

Turn 6 checklist, status-marked for release. DONE records completed preparation or checks. OPEN records remaining author review, source work, or acknowledgment of conditional assumptions. The Turn 6 status of each item is retained.

## Items to finish before submission

- **OPEN**: Resolve five original bibliography records: Feldman08 ACM DOI/text; DV04 ACM DOI/text; CMW25 STOC pages/DOI; Warren68 DOI/text; Renegar92 individual part DOIs/text. APP05's DOI is verified; its original full theorem text remains to be obtained. The current manuscript identifies the checked formulations and does not fabricate identifiers.
- **OPEN**: Review the exact FKS quotation and the explicit distinction between its literal raw-score formulas and nondegenerate Boolean tie conventions. The relevant original pages were recovered, not a complete original PDF binary.
- **OPEN**: Review the full manuscript and the 21 simulated referee responses personally. The simulations and finite checks are not independent external peer review or a machine-checked proof.
- **OPEN**: Confirm authorship, date, final AI-use acknowledgment and any actual affiliation/contact details. No affiliation has been invented; the disclosure is final text without a placeholder and now names GPT-6 Astra (OpenAI).
- **OPEN**: Decide the submission license, confirm rights to all included text and figures, and confirm cross-list suitability. The suggested categories are cs.LG primary, cs.CC/math.CO/stat.ML secondary. No upload or email has been sent.
- **OPEN**: Replace the arXiv-link placeholder in COVER_EMAIL.txt only after an identifier exists.

## Conditional statements

- **OPEN**: Theorem 6.2, the PRF part of Lemma 6.4, Corollary 6.5, the high-dimension part of Corollary 8.1, and Proposition 8.3 depend on the explicitly stated subexponential PRF hypothesis.
- **OPEN**: HMAC-SHA256 is only an experimental instantiation. No experiment verifies that security premise, all keys, or an efficient deterministic good-key selector.
- **OPEN**: The polynomial degree in key length, evaluation time and engineered model size can depend on the prescribed c. The paper does not claim one polynomial-key family beating all polynomials or a superpolynomial gap relative to that model's actual size.

## Checks provided

- **DONE**: 39 canonical statements matched to 39 proof bindings; no independent appendix restatements.
- **DONE**: Reviewed dependency graph has a topological order; shared proof units and auxiliary/import nodes are explicit.
- **DONE**: Fixed-budget, median endpoint, covariance, incidence, unseen-label, large-star and affine checks rerun from a clean directory.
- **DONE**: Exact scope of previous full experimental sweeps is distinguished from the fresh runs.
- **DONE**: Finished AI-use disclosure, under-limit arXiv abstract and unsent cover email supplied. The release changes only "ChatGPT (OpenAI)" to "GPT-6 Astra (OpenAI)" in the acknowledgment; its remaining wording is unchanged.
- **DONE**: Release archive regenerated, extracted into an empty directory, and compiled in three pdflatex passes with shell escape disabled: 59 pages; zero errors; zero undefined references or citations; zero overfull boxes; zero duplicate anchors. All 59 clean-build page texts and rendered pages match the released PDF. Only the acknowledgment page differs from Turn 6; the change was visually checked. Every source file is unchanged except the requested system-name replacement in acknowledgments.tex.

The O(n)-query succinct improvement, ordinary class-dependent online SGD, efficient explicit selection, the resource-aware characterization and optimal (m,tau) tradeoff remain open. The source package is technically build-ready; unresolved original bibliography records remain substantive author checklist items.

## Release build record

Command, run three times after extracting the regenerated archive into an empty directory:

```sh
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error main.tex
```

Only `acknowledgments.tex` changed among the 37 packaged source files. No mathematical or structural edits were made.

PDF SHA-256: `9791b2460d998104f8beed0d16edec0aedfd29de8ea1b3caa934d48d1eef86e6`

Package SHA-256: `36228cfff61513b2337b8d94ff365b405a83d78170d04f4fd8afc062f39c563d`
