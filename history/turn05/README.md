# Distribution-independent SQ learning does not imply low dimension complexity

**Samuel Mausberg**  
A negative answer to Open Question 2 of Feldman, Kamath and Srebro  
September 10, 2026

## Contents

`paper.pdf` is the compiled manuscript. The main text occupies pages 1–30; references and complete proof appendices follow. `paper.tex`, `preamble.tex`, `abstract.tex`, `sections/`, `appendices/`, `references.bib`, and `figures/` are its editable sources. All five substantive figures are native TikZ and are also provided as PNGs under `renders/`.

`VERIFICATION.md` records the proof dependencies, checked constants, source-status limitations, and the old-to-new numbering map. `CHANGES.md` records changes from the preceding manuscript. `checks/statement_inventory.json` and `checks/number_mapping.json` provide machine-readable versions of the statement inventory and mapping.

`checks/build_report.json` records compilation, bibliography, metadata, and layout checks. `logs/` contains the actual build, lint, and numerical-check output. The source-status limitations in the verification ledger remain part of the release; compilation is not external proof review.

## Build

Use a recent TeX Live installation with pdfLaTeX, BibTeX or BibTeX8, Latin Modern, TikZ/PGFPlots, algorithm2e, thmtools, cleveref, natbib, and the packages named in `preamble.tex`. Python 3 and PyMuPDF are used only for validation and rendering.

```sh
bash build.sh
python checks/render_figures.py
```

The figure renderer creates temporary `preview_*` drivers in the working directory. These are generated files, not manuscript sources. The shipped source was compiled with pdfLaTeX; no claim about an untested alternative engine is made.

## Finite checks and experiments

The constant checks require NumPy and SciPy:

```sh
python checks/recompute_constants.py
cd supplement/experiments
python algebra_and_stress.py
python affine_checks.py
```

The retained experiment implementation is in `supplement/experiments/seeded_fast.py`; the keyed cap implementation is in `run_keyed_caps.py` and its companion modules. Exact seeds, key derivation, oracle policy, distributions, raw transcripts, and recorded timings are retained under `supplement/experiments/results/`. Their definitions and scope appear in Appendix M. The keyed hash is an experimental instantiation, not a cryptographic-security claim.

This revision reran the constant, median-endpoint, unseen-label, large-star and affine-certificate checks. The larger recorded sweeps are preserved data from the preceding revision, not newly rerun timing benchmarks. To regenerate a complete sweep, inspect each script's `if __name__ == '__main__'` entry point and its output location before execution.

Checked runtime: Python 3.13.5, NumPy 2.3.5, SciPy 1.17.0, and PyMuPDF 1.26.7. All experiments are CPU-only. Floating-point optimizers propose finite catalogs; the recorded catalogs and oracle transcripts are checked separately using exact arithmetic.

## Mathematical scope

The ordinary and nondegenerate probabilistic dimension separations, rectangle learner, deterministic table-based implementation, proper completion, and succinct median learner are retained with full proofs. The almost-every-key results and engineered differentiable-learning consequence assume the stated PRF security. The specified class-dependent Gaussian-initialized online-SGD question remains open. Source verification is incomplete for the full original problem PDF and some original classical publication records; the precise checked substitutes are identified in `VERIFICATION.md`.
