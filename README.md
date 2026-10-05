# SQ learning and dimension complexity

**Samuel Mausberg**

*Distribution-independent SQ learning does not imply low dimension complexity.*
Manuscript, finite checks, and supporting Lean proofs.

**[Read the paper](paper/paper.pdf)** · **[Cite it](CITATION.cff)** ·
**[Automated checks](https://github.com/SamMausberg/sq-dimension-research/actions)**

## Contents

| Path | Contents |
| --- | --- |
| [`paper/`](paper/) | Current LaTeX source (`paper.tex` with `main.tex` and `appendices.tex`; self-contained `paper_single.tex`), bibliography, and PDF. [`CHANGES.md`](paper/CHANGES.md) and [`SOURCE_NOTES.md`](paper/SOURCE_NOTES.md) record changes from the preceding manuscript and source scope. |
| [`experiments/`](experiments/) | [`finite_checks/`](experiments/finite_checks/) for the current paper, plus earlier Python experiments and retained reference data. |
| [`formalization/`](formalization/) | Lean definitions, 213 supporting theorems for steps of the current paper, and an axiom verifier. |
| [`tools/`](tools/), [`tests/`](tests/) | Build, reproduction, packaging, integrity, and regression checks. |
| [`audits/`](audits/), [`docs/`](docs/) | Verification records, provenance, and integrity hashes for earlier revisions; `audits/current/` is the original revision 8 snapshot. |
| [`history/`](history/) | Superseded source snapshots (revision 8 source in `turn08/`) and archived development notes. |
| [`submission/`](submission/) | Draft arXiv metadata and disclosure. The preprint is published on Zenodo. |

## Verification

- [x] Manuscript builds (36 pages; main text ends on page 11) with no undefined
  references or overfull boxes; `paper_single.tex` matches the modular source.
- [x] All 22 bibliography records were checked against primary records or
  publisher-deposited DOI metadata; all 21 cited entries resolve. See
  [`REFERENCE_AUDIT.json`](paper/REFERENCE_AUDIT.json).
- [x] The paper's finite checks reproduce their recorded outputs; thirteen tool
  regression tests and the earlier experiment suites pass.
- [x] 213 Lean theorems compile with warnings as errors; all 534 compiler theorem
  declarations pass the axiom audit without proof holes or custom axioms. Every
  paper label cited in the Lean sources exists in the manuscript.

Lean covers parts of the argument, **not the complete paper**. Results are cited by
title and TeX label, so the mapping survives renumbering. External theorems enter
only as explicit, documented hypotheses.

| Paper statement | Lean coverage |
| --- | --- |
| Theorem *Sharp incidence separation* (`thm:main`) | Ingredients only: `2N³` points, VC dimension at most two, `dc ≤ N+3`, and threshold arithmetic. Not composed. |
| Remark *Threshold ties* (`rem:ties`) | Not formalized. |
| Theorem *Rectangle learner* (`thm:rectangle`) | Every inequality of the proof, the drift and exponential-potential argument, and the budget. The learner is not assembled into one query tree. |
| Lemma *Pointwise coverage* (`lem:mixture`) | Formalized, including the finite separation argument. |
| Proposition *Geometry and an upper representation* (`prop:geometry`) | VC dimension, `dc ≤ N+3`, template sign-rank at most six, and the incidence count are formalized. `rect ≥ 2^{-15}` assumes the homogeneous-rectangle theorem of Alon et al. |
| Lemma *Restricted sign patterns* (`lem:mask`) | Not formalized (Warren's theorem); used as a hypothesis. |
| Lemma *Probabilistic reductions* (`lem:prob-reduction`) | Not formalized. |
| Theorem *Dimension probabilities* (`thm:dimensions`) | Not composed; its counting core is `lem:mask-approx`, and the threshold bounds are formalized. |
| Theorem *Dimension after discarding targets* (`thm:prior`) | Counting steps only: full-length lines, tested entries, the threshold bound, and the probability exponent. |
| Proposition *From all priors to all targets* (`prop:prior-minimax`) | Not formalized. |
| Proposition *Rectangles bound classical SQ dimension* (`prop:classical-sq`) | Formalized. The corollary `sq(H_A) ≤ 2^16` assumes the homogeneous-rectangle theorem. |
| Theorem *Query lower bounds* (`thm:querylower`) | Both bounds for every randomized learner, given the random-table events. The proper event follows from the Hoeffding event. Probabilities over the table are not formalized; the counting form of the Hamming-ball bound and the union-bound exponent are. |
| Proposition *Transcript representations* (`prop:transcript`) | Rounding alphabet and leaf count only. |
| Theorem *Table and succinct implementations* (`thm:table`) | Not formalized. |
| Lemma *Approximation on a random mask* (`lem:mask-approx`) | Formalized, with Warren's count as a hypothesis. |
| Theorem *Finite-table implementation* (`thm:table-general`) | Not formalized. |
| Theorem *Order-median learner* (`thm:median`) | Not formalized beyond the noisy-median lemma. |
| Lemma *Noisy median* (`lem:noisymedian`) | Formalized, against fully adaptive answers. |
| Theorem *Key-known polynomial-time separation* (`thm:prf`) | Not formalized. |

The probabilistic dimension notions and the prior-average dimension are not
formalized. Finite checks are not formal verification, and tests are not independent
mathematical peer review.

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
`texlive-pictures`, `texlive-publishers`, `texlive-plain-generic`,
`texlive-fonts-recommended`, `texlive-fonts-extra`, `tex-gyre`, and `lmodern` on
Debian/Ubuntu):

```sh
python -X utf8 tools/build_paper.py --bibtex
python -X utf8 tools/check_sources.py
```

The build writes `paper/paper.pdf` in place; the committed PDF is the release copy.

For Lean, install [elan](https://github.com/leanprover/elan), then:

```sh
cd formalization
lake exe cache get
python verify.py --output ../work/lean-verification.json
cd ..
```

Dependencies are pinned; do not run `lake update` unless changing them.
Generated dependencies and rerun outputs are ignored.
`python tools/package_submission.py --output dist` builds a local source package.

## Authorship, rights, and history

GPT-6 Astra (OpenAI) assisted with mathematical development, source comparison,
code, and writing. The Lean formalization of the current version was developed with
assistance from Claude (Anthropic). The paper discloses its AI assistance and
attributes imported results. Samuel Mausberg is responsible for the claims,
citations, and presentation.

Original manuscripts and research material use [CC BY 4.0](LICENSES/CC-BY-4.0.txt).
Original code uses [MIT](LICENSES/MIT.txt); see [LICENSE](LICENSE) for the scope.
Dependencies and the identified PMLR source excerpt retain their own licenses.
The [version 3 preprint](https://zenodo.org/records/23150135) has DOI
[10.5281/zenodo.23150135](https://doi.org/10.5281/zenodo.23150135).
No arXiv identifier has been assigned.

Historical snapshots contain superseded claims and failed or uncompiled attempts.
Prior notes and previews are preserved in
[supporting-documents.tar.gz](history/supporting-documents.tar.gz), with original
paths and bytes. The legacy `release-expert-review` tag does not indicate external
peer review. The release audit lists preexisting archive omissions; current build
inputs are checked separately.
