# Distribution-independent SQ learning does not imply low dimension complexity

Samuel Mausberg  
A negative answer to Open Question 2 of Feldman, Kamath and Srebro

## Submission files

`paper.pdf` is the final manuscript: 30 pages of main text, 59 pages total. `paper.tex`, `preamble.tex`, `abstract.tex`, `acknowledgments.tex`, `sections/`, `appendices/`, `figures/`, `references.bib` and `paper.bbl` are its sources. Figures are native TikZ; rendered PNGs are under `renders/`.

`arxiv_submission.tar.gz` contains the source-only upload tree with entrypoint `main.tex` and generated `main.bbl`. It was actually extracted and compiled from a clean directory with stock pdfLaTeX and shell escape disabled. No submission or email was sent.

The submission text files are `ARXIV_ABSTRACT.txt`, `ARXIV_METADATA.txt`, `AI_USE_STATEMENT.txt`, `COVER_EMAIL.txt`, and `PRE_SUBMISSION_CHECKLIST.md`. The acknowledgment is finished text, not a placeholder. Only the cover email's future arXiv link is a placeholder.

`REFEREE.md` contains three sequential simulated referee reports recorded before edits and 21 point-by-point responses. `VERIFICATION.md`, `SOURCE_CHECKS.md` and `CHANGES.md` distinguish mathematical checks, primary-source checks, unresolved original records, deliberate statement corrections and historical numbering. The referee reports are AI-assisted simulations, not independent external reviews.

## Build

With stock TeX Live and its standard packages, run:

```sh
bash build.sh
```

The generated bibliography is supplied. To regenerate it after editing references:

```sh
REBUILD_BIB=1 bash build.sh
```

The source-only arXiv archive uses `main.tex` instead of `paper.tex`; run pdfLaTeX three times as specified in its README. No Python, network calls or shell escape is needed to compile either manuscript tree.

Optional Python checks and figure rendering require PyMuPDF and Pillow:

```sh
python checks/source_consistency.py
python checks/render_figures.py
python checks/validate_build.py
```

A rerender does not itself perform a new visual review; the recorded review is tied to the distributed PDF hash. The source checker uses the supplied canonical baseline fixture to reproduce the documented six statement edits.

## Reproduce the finite numerical checks

The checks use CPU-only Python, NumPy and SciPy:

```sh
python checks/recompute_constants.py
cd supplement/experiments
python algebra_and_stress.py
python affine_checks.py
```

Fresh outputs from the clean-directory runs are preserved in `checks/clean_run/`; actual logs are under `logs/current/`. Earlier full experimental sweeps remain in `supplement/experiments/results/` and are not presented as newly rerun timing benchmarks. Exact seeds, the keyed-hash encoding, rational oracle transcripts, distributions and coverage certificates are retained. The keyed hash is an experimental instantiation, not a security theorem. See Appendix M for each experiment's scope.

Checked numerical environment: Python 3.13.5, NumPy 2.3.5, SciPy 1.17.0, PyMuPDF 1.26.7. Hunspell was accessed through its installed C library with a detex filter; the invocation and reviewed flags are supplied. Compiled with pdfTeX/TeX Live 2025dev (Debian); all source packages are standard TeX Live packages.

## Remaining author checks

Five requested original bibliography records remain unresolved. APP05 DOI metadata is now verified, but its original theorem text is checked through the identified secondary formulation. Other general imported statements and the direct PRF assumption are identified in SOURCE_CHECKS.md. The relevant original FKS pages were recovered from the repository PDF streams; the complete PDF binary was not reconstructed. The common SQ separation is distinct from the still-open class-dependent Gaussian-initialized online-SGD question. Final author review remains necessary before submission.
