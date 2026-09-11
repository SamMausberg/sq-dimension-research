# Distribution-independent SQ learning does not imply low dimension complexity

Research working draft, Turn 2, September 10, 2026.

## Main result

For a known finite truth table with rectangle ratio at least 1/rho, the proved common randomized SQ learner has

    P = 1 + ceil(4 rho ln(8/epsilon))
    tau = epsilon / (24 P)
    B = ln(K) + ln(8/epsilon) + 1
    R = ceil(8 rho (B + ln(2/epsilon)))
    m <= 3 R + 1.

The domain-size consequence uses VC(H) <= rho/2 and a proved finite counting induction to give m = O(rho^2 ln(e|X|) + rho ln(1/epsilon)), with the same tolerance.

It attains expected loss at most epsilon for every marginal, every target, and every history-dependent valid oracle. A finite minimax LP replaces the proposed isotropic-cap procedure. Its computation is not claimed efficient.

The random monotone grid-incidence flips have rho <= 2^15 using the classical homogeneous-rectangle theorem, and rho <= 2^18 from the separate radial-isotropy proof in this manuscript. With high probability their ordinary, exact-probabilistic, and approximate-probabilistic dimensions are polynomial in M, while their SQ query count is logarithmic in M at fixed accuracy. The high-dimension class selection is non-explicit; the learner given its full table is explicit.

## Contents and mathematical dependencies

`paper/main.pdf` is the rendered manuscript. Its LaTeX source includes `retained.tex`, `figure.tex`, and `results_table.tex`. Retained statements 1--5 keep the first draft's numbering. The new main theorem is 9; the pointwise mixture lemma is 10; the construction is 11; probabilistic variants are 12; the statistical-dimension bound is 13; the independent geometric bound is 14; the projective-plane rectangle calculation is 15.

The paper explicitly imports Warren's standard strict polynomial sign-pattern theorem rather than claiming to reprove its general real-algebraic proof. All counting reductions and incidence-specific constants are derived. The sharp rectangle constant additionally uses the Alon--Pach--Pinchasi--Radoicic--Sharir theorem. The independent weaker cap constant suffices for every polynomial separation and does not use that theorem. See `sources/audit.md`.

## CPU reproduction

The executed environment was Python 3.13.5, NumPy 2.3.5, SciPy 1.17.0, Linux, CPU only. To reproduce:

```sh
python -m pip install -r requirements.txt
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python experiments/rectangle_sq.py
OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 python experiments/verify_results.py
```

The scripts overwrite their own result files. No GPU, external service, training experiment, or statistical estimate of an oracle answer is used. Times can vary. LP optima and trajectories can vary across solver versions and degenerate LP tie-breaking; the exact coverage verifier checks the resulting laws independently. Fixed library versions and seeds are supplied.

All oracle answers are `fractions.Fraction` values from integer distribution masses. The LP is a numerical proposal mechanism only: its mixture is quantized to integer sampling weights, and every coverage inequality is certified with integer arithmetic before use. Sampling uses integer cumulative weights. Exact rational certification is not an implementation of exact radial isotropy. The experiment intentionally implements the rectangle learner actually proved here, not the requested cap transform.

The catalogue includes point-singleton rectangles, row-colored rectangles, and seeded closed positive rectangles. For N <= 5 the singleton rectangles alone guarantee enough coverage. Therefore the tested subcatalogue is a valid implementation of the theorem's mixture step on these cases, although the theoretical general algorithm enumerates all rectangles.

The adversary searches distributions supported on at most 20 points with separate error and round objectives, four random restarts per objective, ten coordinate steps, and two mutations per step. Structured attacks and held-out learner seeds are included. This is empirical search, not a certified maximization over all distributions or oracle policies.

Family seeds: 20260910 + N. Catalogue seeds: 9900 + N. Search seeds: 8800 + N. Attack learner seeds: 11, 12, 13. Optimization learner seeds: 20 + restart. Held-out seeds: 101 through 105. Sign-rank sampling seeds: 7000 through 7023. Independent audit seed: 20260911.

`experiments/results/runs.jsonl` records every distribution, target, learner seed, exact loss and proposal trace. `certificates_N*.json` stores every queried-state mixture law and the complete rectangle catalogue. `family_N*.npz` stores the exact matrices and coordinates. `exact_signranks_N2.json` stores integer rank-three factorizations and exhaustive rank-two exclusion counts. `summary.csv`, `metadata.json`, and `verification.json` contain aggregate results. The logs are actual execution output.

793 runs completed. All 393 mixture certificates, 29,242 pointwise coverage constraints, 3,863 proposal rounds, and 26 small sign-rank records passed independent auditing. All 24 sampled N=2 matrices have exact sign-rank 3; the template has rank 3; the all-flipped control has rank 1. No general SDP sign-rank estimate was used.

## LaTeX reproduction

```sh
cd paper
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

References use an embedded bibliography. The figure is an exact TikZ rendering of finite matrix entries, not an illustrative generated image. The PDF was rendered and visually inspected before delivery.

## Lean: pinned, unverified

`lake --version`, `lake build`, and `lean --version` each failed with command-not-found, exit 127. See `logs/lean_build_attempt.log`. No successful compiler run or axiom audit is reported.

The exact dependency is Mathlib commit

    2631d1cc8c2ace6c6a900425d6e5d2b5963966e9

whose toolchain file specifies `leanprover/lean4:v4.34.0-rc2`. This SHA and file were retrieved from the public repository through the GitHub connector, not guessed. The pin is in `lean/lakefile.toml` and `lean/lean-toolchain`.

With a compatible Lean installation and network access:

```sh
cd lean
lake update
lake exe cache get
lake build
lake env lean Turn2.lean
```

`SQDC.lean` contains the previous finite definitions and unverified proof scripts. `Turn2.lean` targets L1 (finite peeling error and budget), L2 (elimination potential), L3 (positive rectangles survive flips), and L4 (two distinct integer grid lines share at most one point). The source intentionally contains no proof holes or custom axioms, but compilation may require repairs. The main randomized theorem is not yet formalized. The `#print axioms` commands are source requests, not completed audits.

## Limitations

The paper does not produce an explicit deterministic high-sign-rank family, polynomial-time small-circuit queries, an exact isotropic-transform implementation, or a small plain Gaussian-initialized bias-free ReLU SGD learner. The original heavy-subspace restriction is not silently treated as correct. No SGD experiments were run this turn.
