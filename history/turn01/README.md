# SQ versus dimension complexity: first attempt

This packet does **not** resolve unrestricted OQ2 or OQ1. It contains a complete
mathematical analysis of a failed explicit separation, a stronger joint-
distribution SQ barrier, an exact audit of a prior-conditioning error, executed
CPU checks, and an **uncompiled** Lean source draft.

## Files

- `paper/main.pdf`: 13-page working paper, with full proofs and references.
- `paper/main.tex`: self-contained LaTeX source, including the formatted references.
- `paper/references.bib`: the same citation records in BibTeX format.
- `lean/SQDC.lean`: finite-domain definitions and four proof-script drafts.
- `lean/README.md`: the formalization boundary and build instructions.
- `experiments/check_bounds.py`: incidence, spectral, oracle, exact-small-sign-rank,
  and tree checks.
- `experiments/check_auxiliary.py`: radial-isotropy searches, minimax LP checks,
  gradient error checks, the conditioning example, ReLU identities, and fixed-D covers.
- `experiments/sgd_cpu.py`: Gaussian-initialized bias-free online logistic SGD.
- `experiments/families.py`: deterministic prime-field projective-plane generator.
- `experiments/results/`: complete saved outputs, including all 135 SGD reporting
  runs and the selected distributions and pilot scores.
- `logs/`: actual execution logs. The Lean log records a failure, not a successful build.
- `verification.json`: execution status and environment versions.

## Statement-to-artifact map

| Paper statement | Mathematical result | Lean status | Executed CPU coverage |
|---|---|---|---|
| Lemma 1 | Gram energy bound and threshold counting | Counting consequence only, uncompiled | 500 energy/count cases |
| Theorem 2 | Randomized adaptive joint-distribution SQ barrier | Final scalar inequality only, uncompiled | 200 oracle couplings; 1000 scalar cases; 100 dimension checks |
| Theorem 3 | Generalized and weighted Forster bounds | Not formalized | 12 radial-isotropy instances; integral Walsh rank-3 witness and exhaustive rank-2 exclusion |
| Theorem 4 | Projective-plane dc bounds, bounded ordinary Gram, fixed-D learners, common-learner obstruction | Not formalized | Five prime fields; 600 ordinary-Gram cases; 100 exhaustive-learner cases; 10 fixed-D covers |
| Theorem 5 | Deterministic marginal branching; exponential approximate probabilistic dc | Query decomposition only, uncompiled | 24 grid/tree cases; 100 minimax LP pairs |
| Theorem 6 | Robust population-gradient to SQ simulation with explicit parameters | Not formalized | 1000 coordinate-error cases |
| Proposition 7 | Prior-conditioning obstruction | Not formalized | Exact rational two-target example |
| Proposition 8 | Odd-part restriction for one-hidden-layer bias-free ReLU | Scalar identity only, uncompiled | 100 identity cases; infeasible parity LP; 135 SGD reporting runs |

The paper proves its numbered mathematical statements in ordinary mathematics.
Numerical checks do not certify the universal proofs. No completed Lean proof of
the spectral/coupling theorem is present. Absence of intentional proof holes in a
source file is not a substitute for a successful compiler and axiom audit.

## Reproduce CPU runs

Tested with Python 3.13.5. Package versions are pinned in `requirements.txt`.
From this directory, run:

```sh
python -m pip install -r requirements.txt
bash run_cpu.sh
```

The scripts regenerate results and execution logs. Seeds, architecture, step
indexing, Gaussian variances, tolerance conventions, and the empirical adversary
are recorded in the JSON outputs and paper. The numerical adversary chooses a
fixed distribution on two pilot seeds and is evaluated on five different seeds.
It is not a worst-case certificate. Floating-point differences across platforms
are judged at the scripts' stated tolerances; tiny signed roundoff in computed
zero distances is retained in the raw output. No GPU, SDP solver, downloaded data,
or pretrained model is used.

## Build the paper

```sh
cd paper
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

The references are included directly, so BibTeX is not required. The final run
had no undefined citations or overfull-box warnings. Every page was rendered for
layout inspection.

## Lean: failed verification, explicit boundary

Actual local commands returned:

```text
lean --version: command not found, exit 127
lake build: command not found, exit 127
toolchain fetch: DNS resolution failure
```

Target: Lean `v4.34.0-rc2`, as found in the official Mathlib master toolchain file
on 2026-09-10. Mathlib's dependency is not yet commit-locked. The source is a draft
and has not passed the user's compile requirement. The instructions under `lean/`
are for a future successful build, not a report of one.

## Literature / supplied-fact boundary

The quantitative halfspace-to-SQ converse and general boosting statement were not
used as proof premises and were not re-proved in this packet. The deterministic
correlational statement is proved in Theorem 5. Theorem 4 independently verifies
a fixed-distribution versus distribution-independent separation. The valid
conditional spectral barrier is proved in Theorems 1--3; the ordinary-Gram
universality assertion is disproved by Theorem 4. The 2025 audit identifies a flaw
in Appendix A.2--A.3 of arXiv:2505.10423v1, not an independently verified retraction.
The gradient transfer is limited to the exact assumptions of Theorem 6. No claim
of novelty for these ingredients or of a general resolution is made.
