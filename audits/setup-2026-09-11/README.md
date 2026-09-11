# Repository setup audit — 11 September 2026

The supplied Git bundle was imported from commit
`c7fbd8c96c72a6b20ec75518f1a99531a155237c`. This audit records fresh checks of the
organized repository and regenerated manuscript. Original revision 8 ledgers
remain in `audits/current/`; original snapshots remain in `history/`.

## Results

| Area | Fresh result | Evidence |
| --- | --- | --- |
| Lean | Both libraries compile under pinned Lean 4.34.0-rc2/Mathlib. Nine named lemmas and all 30 compiler theorem declarations pass; no `sorryAx` or custom axioms. | [Report](lean/verification.json), [statement comparison](lean/statement_comparison.json) |
| PDF | 64 pages, 13 main; zero errors, undefined citations/references, overfull boxes, or duplicate anchors. | [Final validation](paper/FINAL_VALIDATION.md), [build](paper/final_build.json) |
| Source package | Clean extraction of all 47 source files compiles; every page matches the final PDF's text and pixels at 72 DPI. | [Package verification](paper/clean_package.json) |
| Mathematical preservation | All 44 TeX inputs preserve mathematics/prose; three exact presentation changes only. All 677 historical files retain original bytes. All nine research-script ASTs retain their logic. | [Preservation](preservation.json), [PDF/source comparison](paper/final_content_comparison.json) |
| Citations | All 34 works verified against live primary records; no fabricated work or gross attribution mismatch found. | [Citation audit](citations/README.md) |
| Source linkage | 40 statements, 40 proof bindings, 39 retained earlier labels; 51-node dependency graph acyclic. | [Final source audit](paper/final_sources/source_consistency.json) |
| Experiments | All six commands pass, including the optional cap sweep. | [Run manifest](experiments/run_manifest.json) |
| Median sweep | 304 proper-output runs, 4,798 checked oracle answers; maximum error 26/1069. | [Audit](experiments/fast/audit.json), [summary](experiments/summary.json) |
| Cap sweep | 56 runs, 28,262 checked answers, 499 catalogs, 231,151 rectangles, 228,684 pointwise checks; maximum error 4278523253/500000000000. | [Audit](experiments/keyed_caps/audit.json) |
| Tooling | 11 verification-tool regression tests; Ruff lint/format; dependency check; CFF schema validation. | `tests/test_verification_tools.py`, pinned environment and CI |

All observed experiment errors are below the target 1/10. No median run ended in
`star_sampling_failure`, and no cap run exhausted its budget. Exact and floating
checks are identified separately in the result JSON; the finite runs do not
establish universal theorems or cryptographic security.

## Changes permitted by the preservation check

- Move the existing construction-proof hyperlink label before its figure input.
- Keep Appendix E's sole figure below its heading with `[H]` placement.
- Keep the short `signrank(F) <= 6` expression together with an `mbox` wrapper.

Bibliography fields and formatting were updated separately; all 34 citation keys
and cited works remain. Active Python code was formatted without changing the
research algorithms. Verification tools received explicit correctness fixes and
regression tests. Lean imports were narrowed and two stylistic linter warnings
were locally suppressed to retain the original theorem parameters; proof bodies
and mathematical statements were preserved.

## Limits and environment

The nine Lean lemmas are only a partial formalization. Read
`formalization/COVERAGE.md` before citing their scope. The standard trusted axioms
are `propext`, `Classical.choice`, and `Quot.sound`; one named lemma uses none.
Mathematical peer review and author submission decisions remain separate.

Some original publisher full texts were inaccessible. Their bibliography records
were verified from primary records, including publisher-deposited DOI metadata,
and the stated accessible theorem restatements were checked. Detailed limits and
two primary-metadata discrepancies remain visible in the citation reports.

Python checks ran on Windows with Python 3.13.3 and pinned NumPy/SciPy/mpmath/
threadpoolctl. Lean ran in native WSL Ubuntu with exact source hashes compared to
the delivered tree. TeX Live 2023 plus workspace-local missing packages built the
paper. Final PDF pages were rendered and checked; 19 underfull spacing notices
remain without observed clipping or overlap. Preliminary paper checks are grouped
under `paper/baseline/`; `paper/final_*` and `FINAL_VALIDATION.md` are authoritative
for the delivered PDF.

Rights and citation files document original contributions and attribution. They
do not confer ownership of mathematical ideas or guarantee against plagiarism.
The repository remains private; no arXiv submission or public release was made.
