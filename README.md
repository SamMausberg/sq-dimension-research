# SQ learning and dimension complexity

Samuel Mausberg

The current manuscript studies distribution-independent statistical-query learning, sign-rank, probabilistic dimension, and the stated gradient-learning comparisons. `paper/paper.pdf` is the current reading copy. `paper/paper.tex` is the sole TeX entry point.

## Start here

| Path | Contents |
|---|---|
| `paper/` | Current paper, all deferred proofs, native TikZ figures, bibliography source and generated BBL. |
| `audits/current/` | The nine adversarial ledgers, new output-count proof checks, statement/proof extracts, dependency graph, numbering map, source notes, build logs and fresh outputs. |
| `experiments/` | CPU learners and oracle simulators; preserved raw records and the current finite-check script. |
| `formalization/` | The recovered Lean drafts and pinned project configuration. **Uncompiled; not formal verification of this paper.** |
| `history/turn01` through `history/turn07` | Earlier supplied project snapshots, including proofs, failed approaches, SGD experiments, scripts, logs and data. These use old numbering and may contain superseded claims. |
| `submission/` | arXiv metadata, abstract, cover email, disclosure, plain-language summary and author checklist. |
| `tools/` | Build, reproduction, source-consistency and packaging commands. |
| `docs/` | Archive provenance and topic index. |

This repository covers this SQ/dimension project and its retained OQ1 comparisons. It does not contain unrelated projects from other conversations. Historical data are separated from the current manuscript; their presence is not an endorsement of superseded claims.

## Import the Git bundle

```sh
git clone sq-dimension-research.bundle sq-dimension-research
cd sq-dimension-research
```

The bundle is a self-contained local Git repository. No GitHub repository has been created or pushed. The assembled Git history records this release; the source snapshots under `history/` preserve the earlier work without fabricating original commit dates.

## Build the paper

Use stock TeX Live with the packages listed in `paper/preamble.tex` and Python 3.13 for the scripts.

```sh
python tools/build_paper.py
```

This runs three `pdflatex` passes with shell escape disabled and uses the supplied `paper.bbl`. To regenerate the bibliography as well:

```sh
python tools/build_paper.py --bibtex
python tools/check_sources.py
```

Manual equivalent:

```sh
cd paper
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex
bibtex paper
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex
```

## Reproduce the checks

```sh
python -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
python tools/run_checks.py --output /tmp/sq-dc-checks
```

The command uses fresh temporary directories and preserves the historical raw data. It runs the 77-row ledger's finite regressions, the earlier parameter checks, unseen-label and star tests, affine certificates, and the 304-run keyed median sweep. To repeat the slower cap sweep as well:

```sh
python tools/run_checks.py --output /tmp/sq-dc-checks-with-caps --caps
```

Recorded arithmetic identities and oracle answers are checked with integers or `fractions.Fraction`. Floating-point logarithmic/convex-program checks are marked separately. CPU wall times depend on the machine. No new SGD experiment is part of the current release; previous SGD work is preserved under `history/`.

## Read the verification status

The current paper retains all 39 earlier numbered statements and adds one query-order theorem. The requested leading `n - O(1)` lower-bound numerator is proved for proper outputs. For unrestricted outputs the proof gives `n/3 - O(1)` and the same optimal asymptotic order; a single predictor can fit an entire parallel class, so the distinct-output argument does not apply.

`audits/current/VERIFICATION.md` distinguishes proofs, conditional results, source-formulation checks, fresh computation, and open checks. A successful source check or PDF build is not a proof-assistant certificate or independent peer review. The PRF assumption is mathematical; HMAC-SHA256 is only the experimental keyed hash. Its historical input format is documented in the experiment and differs from the newly explicit bit encoding used to state the abstract PRF reduction. Both retain their ambient coordinates on restriction.

The Lean files are included because they are part of the project record. Read `formalization/STATUS.md` before using them. They cover finite definitions and selected old lemmas, not all theorems, and have no successful compiler or axiom audit in this environment.

## Ancillary index

`docs/ANCILLARY_MANIFEST.md` gives the reproduction commands and file-group counts. The adjacent JSON records each indexed ancillary file's SHA-256. `docs/TOPIC_INDEX.md` maps the SQ, sign-rank, PRF and OQ1 material across the current text and retained history.

## Rights and release

No publication or software license has been selected on the author's behalf. See `LICENSE_STATUS.md` and the pre-submission checklist. Third-party font files and complete downloaded third-party papers are excluded; ordinary embedded fonts in PDFs remain. No email or arXiv upload has been sent.
