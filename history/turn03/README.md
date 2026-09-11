# SQ versus dimension complexity: third research draft

The main document is `paper/main.pdf` (38 pages). Build from the complete LaTeX source with the commands below. New results are Theorems 16--20, Proposition 21, Theorem 22, and Proposition 23. Theorem 9 is restated asymptotically, with the original exact constants in Lemma 9.1 and a complete endpoint audit in Appendix A. Theorems 2--5 and 11--13 are retained.

## Mathematical outcomes

The cap sampler has pointwise coverage c_d/(8d) in the exact real model. A rational approximate transform and finite direction net give polynomial bit complexity for each fixed template dimension, measured in the size of the supplied truth table and rational template, not in log(domain size) alone. Enumerating the fixed-dimensional net also yields a deterministic learner.

The proper-learning completion succeeds. No exponential proper/improper separation is asserted. The global projective-plane rectangle ratio is Theta(1/q). Odd-dimensional cube majority halfspaces are SQ-easy with exponentially small rectangle ratio, so small rectangles do not imply SQ hardness. A description-length-only repair is false if source-program length is charged but unbounded preprocessing and generated memory are free. Ordinary Gaussian-initialized bias-free ReLU online SGD remains unresolved here.

The general minimax rectangle-mixture device is attributed to Hatami et al.; its learning application, product-progress proof, and proper completion are the contributions developed in this project. Warren's theorem, the sharper homogeneous-rectangle theorem, and real-closed-field decidability are cited classical inputs, not new formalized proofs.

## Build the paper

From this directory:

```sh
cd paper
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

The final executed LaTeX log is `logs/pdflatex_final.log`. It contains no undefined references, undefined citations, or overfull/underfull box warnings. The optional `paper/assemble.py` reconstructs the main file from its included Turn 2 baseline and the new modular sources. It is not needed to compile the supplied main file. It does not download anything.

## Reproduce the CPU experiments

The scripts require Python with NumPy, SciPy, mpmath, and threadpoolctl. Exact package versions used are in `requirements.txt`. Python was 3.13.5. The scripts limit numerical thread pools to one CPU thread. No GPU or SGD experiments are included.

```sh
python -m pip install -r requirements.txt
python experiments/cap_sq.py --N 2 3 4 5 6 7 8 --restarts 4 --steps 3
python experiments/rectangle_witnesses.py
python experiments/finite_checks.py
python experiments/audit.py
```

These commands overwrite the corresponding files in `experiments/results`. Preserve the supplied outputs first when comparing platforms. The final learner sweep took about 300 seconds in the reporting environment; runtimes and floating optimization paths can differ on another platform.

### What actually ran

The implemented proposal law is a finite cap catalog, constructed from point-centered directions and 32 seeded Gaussian directions after numerical radial-isotropy optimization. It is not exact sampling from a continuous sphere, and its numerical matrix is not claimed to be an exact irrational optimizer. L-BFGS and high-precision Newton are practical constructors. Every reported catalog was then checked against the integer truth table, and the actual finite mixture's pointwise coverage was verified by integer counting. This exact catalog check, rather than a numerical isotropy residual, validates the finite law used in each reported state. The polynomial-time algorithm proved in the paper is a separate conservative rational construction.

The adversarial oracle is an explicit greedy endpoint policy using only the public transcript and the true instance. Marginal queries do not reveal the learner's private row side or the later mismatch color. All final reporting results use the corrected public-transcript policy. It is not claimed to be a globally optimal policy over all future random choices. Random restarts and coordinate changes search distributions of support size at most 20; they do not certify the worst distribution.

The rectangle search gives an exact maximum rectangle for each reported rational product distribution. Each value is therefore an upper bound on the global infimum `rect(A)`, not a proof that the searched product distribution is globally worst.

### Final audit

`experiments/results/audit.json` records:

- 448 reporting runs and 339,922 query-answer checks, including 103,989 tolerance-endpoint answers.
- 1,735 cap catalogs, 1,106,791 checked rectangles, and 1,096,914 exact pointwise coverage constraints.
- All 224 proper outputs belong to the supplied class.
- All seven rational product-distribution rectangle witnesses pass exact enumeration.
- Every audit assertion passes.

All individual distributions, seeds, queried masks, exact expectations, returned rational answers, and predictions are in `experiments/results/runs.jsonl`. The compressed catalog files carry the exact finite proposal laws. Per-mode summary results are in `summary.csv`. `finite_checks.json` records the separate endpoint, elimination, strictification, star-union, cube, and projective-plane checks.

The files `initial_float_solver_diagnostic.log` and `pre_referee_policy_diagnostic.log` are failed/obsolete diagnostic attempts, not final experiment results. The first exposed floating conditioning issues; the second preceded removal of private row-side information from the oracle policy. Both were corrected before the final reporting sweep and audit. `cap_runs.log`, `audit.log`, and `finite_checks.log` are the final command logs.

## Lean status: unverified

`lake --version` returned command-not-found with exit code 127. No installation or further compilation was attempted in this turn. The actual log is `logs/lean_check.txt`.

The retained files define finite distributions, strict dimension, SQ queries, real-response adaptive trees, oracle validity, and distribution-independent learnability. `Turn2.lean` contains the L1--L4 proof drafts matched to the paper. It has not been compiled. There is no axiom audit, and no formalization of the new cap, proper-learning, or source-length theorems is claimed.

Mathlib is pinned to commit `2631d1cc8c2ace6c6a900425d6e5d2b5963966e9`; the specified toolchain is `leanprover/lean4:v4.34.0-rc2`. On a machine with that toolchain and network access, the intended build commands are:

```sh
cd lean
lake update
lake exe cache get
lake build
```

These are build instructions, not commands successfully executed here. Compiler compatibility and the proof scripts still need checking.

## Proof and verification limits

All newly asserted mathematical theorems have full human-readable proofs in the paper, with imported classical inputs explicitly identified. This is not a claim of machine verification or independent peer review. Numerical solver convergence on arbitrary inputs, globally worst adversaries, and globally minimizing rectangle product measures are not established by the experiments. Efficiently explicit high-sign-rank selection, a full characterization of SQ complexity, the optimal query/tolerance tradeoff, a finite-resource-aware replacement theorem, and the specified ordinary-SGD implication remain open in this work.
