# SQ learning and dimension complexity

**Samuel Mausberg** · Private research repository · Manuscript revision 8

*Distribution-independent SQ learning does not imply low dimension complexity*

The manuscript studies distribution-independent statistical-query learning,
sign-rank, probabilistic dimension, and gradient-learning comparisons. This
repository collects the paper, reproducible experiments, supporting Lean lemmas,
and the preserved development record.

**[Read the paper](paper/paper.pdf)** · **[Verification](VERIFICATION.md)** ·
**[Citation and title audit](audits/citation-titles-2026-09-11/README.md)** ·
**[Reproduce the results](docs/REPRODUCIBILITY.md)** · **[Repository guide](docs/REPOSITORY_GUIDE.md)**

## Repository map

| Directory | Purpose |
| --- | --- |
| [`paper/`](paper/) | Current manuscript, proofs, TikZ figures, and bibliography. `paper.tex` is the only entry point. |
| [`experiments/`](experiments/) | Active Python experiments and retained reference results. |
| [`formalization/`](formalization/) | Selected supporting Lean lemmas, pinned dependencies, coverage notes, and axiom audit. |
| [`tools/`](tools/) | Build, source checks, reproduction, integrity manifests, and submission packaging. |
| [`tests/`](tests/) | Regression tests for the verification tools. |
| [`audits/citation-titles-2026-09-11/`](audits/citation-titles-2026-09-11/) | Latest exact-title, citation, and regenerated-PDF audit. |
| [`audits/setup-2026-09-11/`](audits/setup-2026-09-11/) | Fresh repository-setup verification evidence. |
| [`audits/current/`](audits/current/) | Manuscript revision 8 ledgers, proof dependencies, and original build/check evidence. |
| [`history/`](history/) | Seven preserved earlier snapshots; old numbering and superseded claims are retained as history. |
| [`submission/`](submission/) | Draft metadata, disclosure, summary, and pre-submission checklist. |
| [`docs/`](docs/) | Reproducibility, topic navigation, repository organization, and file checksums. |

## Verification scope

The current manuscript contains **40 numbered statements** and retains all 39
prior labels. The Lean project covers **nine supporting lemmas**, not the entire
paper. The cap construction, PRF reduction, and full query lower bound are not
fully formalized. [Coverage](formalization/COVERAGE.md) and the
[verification reports](VERIFICATION.md) explain exactly what
was checked and what remains open.

Finite experiments distinguish integer/rational checks from floating-point
parameter checks. A successful build, source audit, or numerical run does not
establish every mathematical claim or constitute independent peer review.
HMAC-SHA256 is an experimental keyed hash; its runs are not a PRF security proof.

## Quick start

Use Python 3.13 in a virtual environment. From the repository root:

```sh
python -m venv .venv
# Linux/macOS: source .venv/bin/activate
# Windows PowerShell: .\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m pip check
python -m ruff check .
python -m ruff format --check .
python -m unittest discover -s tests -v
cffconvert --validate
python tools/make_manifest.py --check
python -X utf8 tools/run_checks.py --output work/checks-1
```

Use a new output directory for each run. Add `--caps` for the slower cap sweep.
For the paper, install TeX Live and run:

```sh
python -X utf8 tools/build_paper.py --bibtex --report work/paper/build.json
python -X utf8 tools/check_sources.py --output work/paper/sources
```

With elan installed, verify the pinned Lean project:

```sh
cd formalization
lake exe cache get Mathlib.Analysis.SpecialFunctions.Sqrt Mathlib.MeasureTheory.Integral.Bochner.Basic Mathlib.Tactic.Linarith Mathlib.Tactic.Ring Mathlib.Analysis.SpecialFunctions.Log.Basic
python verify.py --output ../work/lean-verification.json
```

The [reproducibility guide](docs/REPRODUCIBILITY.md) includes platform details,
TeX dependencies, formatting, packaging, and the interpretation of each check.
GitHub Actions runs Python checks on Linux and Windows, the Lean build and axiom
audit, and manuscript compilation/source checks.

## Citation and rights

Cite the manuscript using [CITATION.cff](CITATION.cff) and identify the commit used.
The manuscript has no assigned DOI or arXiv identifier. Original contributions
are **all rights reserved** under [LICENSE](LICENSE). The repository is private;
public redistribution or licensing requires a separate author decision.

The bibliography, acknowledgments, and [third-party notices](THIRD_PARTY_NOTICES.md)
preserve attribution to prior work. See [rights and access](LICENSE_STATUS.md)
for the distinction between citation, copyright, and mathematical ideas.

## Provenance

The supplied Git bundle was imported with its three original commits and
`release-expert-review` tag intact. Later setup commits record repository cleanup
and validation. The snapshots in `history/` retain their original Git bytes;
[the ancillary manifest](docs/ANCILLARY_MANIFEST.json) records the indexed files.
Submission materials remain drafts; see the
[author checklist](submission/PRE_SUBMISSION_CHECKLIST.md).
