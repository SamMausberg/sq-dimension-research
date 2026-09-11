# Reproducibility

Run commands from the repository root unless noted. Use Python 3.13, the pinned
Python requirements, and the Lean/Mathlib versions in `formalization/`.

## Python setup

```sh
python -m venv .venv
```

On Linux/macOS use `source .venv/bin/activate`. In Windows PowerShell use
`.\.venv\Scripts\Activate.ps1`; alternatively invoke `.venv\Scripts\python.exe`
directly if local execution policy prevents activation.

```sh
python -m pip install -r requirements-dev.txt
python -m pip check
```

`requirements.txt` contains the experiment dependencies. `requirements-dev.txt`
also installs formatting, citation-validation, and PDF-comparison tools. Never
run verification with `python -O`, `python -OO`, or `PYTHONOPTIMIZE` enabled:
mathematical checks use assertions, and the runner rejects those modes.

## Formatting and regression tests

```sh
python -m ruff check --fix .
python -m ruff format .
python -m ruff check .
python -m ruff format --check .
python -m unittest discover -s tests -v
cffconvert --validate
```

Formatting covers active experiments, build tools, the Lean verification helper,
and regression tests. Historical snapshots are excluded. Lean formatting follows
its existing two-space proof indentation; the compiler and axiom audit verify it.

## Reproduce experiments

```sh
python -X utf8 tools/run_checks.py --output work/run-1
python -X utf8 tools/run_checks.py --output work/run-2-with-caps --caps
```

Each output directory must be new or empty. The runner records RUNNING, FAILED,
or PASS, command exit codes, Python/package versions, and the selected suite.
The child processes run with assertions enabled, UTF-8, and one numerical-library
thread. Exact integer/Fraction checks and floating-point checks remain identified
separately. Seeds and parameters are recorded in the scripts and output JSON.

The default suite runs current finite checks, retained parameter constants,
algebra and unseen-label/star stress tests, affine certificates, and the seeded
median sweep. `--caps` adds the slower keyed cap sweep and its certificate audit.
Preserved raw data under `experiments/results/` are reference artifacts, never
silently overwritten by these commands. Timings can vary by host.

With Make installed, `make check` and `make check-caps` use separate output
directories. For repeat runs, choose new directories with
`make check CHECK_OUTPUT=work/run-3` or
`make check-caps CAPS_OUTPUT=work/run-4-with-caps`.

## Build the manuscript

Install TeX Live with the packages in `paper/preamble.tex`. A suitable Debian or
Ubuntu installation is:

```sh
sudo apt-get install texlive-latex-extra texlive-science texlive-pictures texlive-fonts-recommended lmodern
```

Then run:

```sh
python -X utf8 tools/build_paper.py --bibtex --report work/paper/build.json
python -X utf8 tools/check_sources.py --output work/paper/sources
```

The build runs three `pdflatex` passes with shell escape disabled. `--bibtex`
regenerates the bibliography; omitting it uses the supplied `paper.bbl`.
Diagnostics enforce no TeX errors, undefined citations/references, duplicate
anchors, or overfull boxes, and a maximum of 16 main-text pages.

To keep the retained PDF/BBL untouched, copy `paper/` into a scratch directory,
pass `--directory work/paper-copy` to `build_paper.py`, then pass
`--paper-directory work/paper-copy` to `check_sources.py`. Source checks require
the `.aux` produced by a successful build. They verify 40 consecutively numbered
statements, proof linkage, preserved earlier labels, and a reviewed dependency
graph; they do not prove the mathematical arguments.

## Build Lean and audit axioms

Install elan using the official Lean instructions, then:

```sh
cd formalization
lake exe cache get Mathlib.Analysis.SpecialFunctions.Sqrt Mathlib.MeasureTheory.Integral.Bochner.Basic Mathlib.Tactic.Linarith Mathlib.Tactic.Ring Mathlib.Analysis.SpecialFunctions.Log.Basic
python verify.py --output ../work/lean-verification.json
```

The committed `lean-toolchain`, `lakefile.toml`, and `lake-manifest.json` pin the
compiler, Mathlib, and transitive packages. The verifier builds `SQDC` and `Turn2`
and audits every current theorem, accepting only `propext`, `Classical.choice`,
and `Quot.sound`. Unexpected axioms, missing audit entries, and compiler errors
fail verification. Read `STATUS.md` and `COVERAGE.md` for the limited theorem scope.

Do not run `lake update` as a routine reproduction step: changing dependencies is
a separate change requiring review and new validation. `.lake/` is a generated
cache and must never be committed.

## Check integrity and package locally

```sh
python -X utf8 tools/make_manifest.py --check
# After intentional source or evidence changes:
python -X utf8 tools/make_manifest.py
python -X utf8 tools/make_manifest.py --check
python -X utf8 tools/package_submission.py --output dist
```

The manifest records POSIX-style paths, sizes, and SHA-256 hashes for indexed
ancillary material. Git tracks the paper and root configuration separately. Cache
and ignored files are excluded. Packaging creates and recompiles an arXiv-shaped
source archive locally; it neither publishes nor selects a submission license.
The default PDF comparison checks every page against the retained reading copy.
Its `clean_package.json` report is saved inside the selected output directory.
