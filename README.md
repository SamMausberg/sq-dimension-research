# SQ learning and dimension complexity

**Samuel Mausberg**

*Distribution-independent SQ learning does not imply low dimension complexity.*
Manuscript, reproducible experiments, and supporting Lean proofs.

**[Read the paper](paper/paper.pdf)** · **[Cite it](CITATION.cff)** ·
**[Automated checks](https://github.com/SamMausberg/sq-dimension-research/actions)**

## Contents

| Path | Contents |
| --- | --- |
| [`paper/`](paper/) | Current LaTeX source, bibliography, TikZ figures, and PDF. Build `paper.tex`. |
| [`experiments/`](experiments/) | Python experiments and retained reference data. |
| [`formalization/`](formalization/) | Lean definitions, nine supporting lemmas, and an axiom verifier. |
| [`tools/`](tools/), [`tests/`](tests/) | Build, reproduction, packaging, integrity, and regression checks. |
| [`audits/`](audits/), [`docs/`](docs/) | Verification records, provenance, and integrity hashes; `audits/current/` is the original revision 8 snapshot. |
| [`history/`](history/) | Superseded source snapshots and archived development notes. |
| [`submission/`](submission/) | Draft publication metadata and disclosure; nothing has been submitted. |

## Verification

- [x] Manuscript builds; citation and reference checks pass.
- [x] All 36 cited papers checked against primary titles and records.
- [x] Twelve tool regression tests and six experiment suites pass.
- [x] Nine Lean lemmas compile; all 30 local compiler theorem declarations pass
  the axiom audit without proof holes or custom axioms.

Lean covers supporting lemmas, **not the complete paper**. Tests and AI reviews
are not independent mathematical peer review. HMAC experiments are not a PRF
security proof.

Detailed [citation evidence](audits/citation-titles-2026-09-11/titles.json),
[Lean results](audits/setup-2026-09-11/lean/verification.json), and
[release checks](audits/public-release-2026-09-11/verification.json) record the scope.

## Reproduce

Use Python 3.13. Create and activate a virtual environment, then run from the
repository root:

```sh
python -m pip install -r requirements-dev.txt
python -m unittest discover -s tests -v
python -X utf8 tools/run_checks.py --output work/run-1 --caps
python tools/make_manifest.py --check
```

Use a new output directory each time and keep Python assertions enabled.
Check formatting with `python -m ruff check .` and
`python -m ruff format --check .`.

For the PDF, install TeX Live (`texlive-latex-extra`, `texlive-science`,
`texlive-pictures`, `texlive-fonts-recommended`, and `lmodern` on Debian/Ubuntu):

```sh
python -X utf8 tools/build_paper.py --bibtex
python -X utf8 tools/check_sources.py
```

For Lean, install [elan](https://github.com/leanprover/elan), then:

```sh
cd formalization
lake exe cache get Mathlib.Analysis.SpecialFunctions.Sqrt Mathlib.MeasureTheory.Integral.Bochner.Basic Mathlib.Tactic.Linarith Mathlib.Tactic.Ring Mathlib.Analysis.SpecialFunctions.Log.Basic
python verify.py --output ../work/lean-verification.json
cd ..
```

Dependencies are pinned; do not run `lake update` unless changing them.
Generated dependencies and rerun outputs are ignored.
`python tools/package_submission.py --output dist` builds a local source package.

## Authorship, rights, and history

GPT-6 Astra (OpenAI) assisted with derivations,
drafting, source checks, code, figures, and simulated reviews. The paper discloses
this assistance and attributes imported results. Samuel Mausberg is responsible
for the claims, citations, and presentation.

Original contributions are **all rights reserved** under [LICENSE](LICENSE).
Public access does not grant an open-source license;
[GitHub's viewing and forking rights](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)
still apply. Dependencies and the identified PMLR source excerpt retain their
own licenses. No DOI or arXiv identifier has been assigned.

Historical snapshots contain superseded claims and failed or uncompiled attempts.
Prior notes and previews are preserved in
[supporting-documents.tar.gz](history/supporting-documents.tar.gz), with original
paths and bytes. The legacy `release-expert-review` tag does not indicate external
peer review. The release audit lists preexisting archive omissions; current build
inputs are checked separately.
