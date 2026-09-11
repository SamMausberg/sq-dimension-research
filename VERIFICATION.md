# Verification

The latest bibliography and reading-copy checks are documented in
[the exact-title and citation audit](audits/citation-titles-2026-09-11/README.md).
The unchanged Lean and experiment code is covered by
[the repository setup audit](audits/setup-2026-09-11/README.md).

| Check | Result and scope |
| --- | --- |
| Lean | Nine supporting lemmas compile; all 30 compiler theorem declarations in the two local modules pass the axiom audit. No proof holes or custom axioms. |
| Manuscript | Regenerated 64-page PDF, 13 main pages; no errors, unresolved references/citations, overfull boxes, or duplicate anchors. |
| Mathematics preserved | All mathematical statements, proof prose, and experiment algorithms preserved. The setup's three presentation changes and the later expansion of one series citation are recorded separately. |
| Citations | All 36 individual papers represented by the original 34 entries checked against primary titles and records. All 69 citation occurrences resolve; exact-title, author-order, and publication-field corrections are documented with access limits. |
| Computation | All six suites pass, including 304 seeded median runs and 56 keyed cap runs. |
| Tool regressions | 11 tests pass, including optimized-Python, stale-result, baseline, and integrity cases. |
| Code and metadata | Active Python lint/format, dependency consistency, and citation schema checks pass. |

Lean covers selected supporting lemmas, **not all 40 manuscript statements**.
Compilation, finite computation, and citation verification do not replace a
complete formalization or independent mathematical peer review.

The original revision 8 mathematical ledger remains in
[audits/current/VERIFICATION.md](audits/current/VERIFICATION.md), with
[the result ledger](audits/current/NEW_RESULT_LEDGER.md) and
[numbering map](audits/current/NUMBERING.md). Its historical tool-availability
statements are superseded by the fresh setup audit. Earlier reports remain in
`audits/prior/` and `history/`.
