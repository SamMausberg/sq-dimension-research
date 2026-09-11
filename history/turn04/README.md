# Distribution-independent SQ learning does not imply low dimension complexity

Research manuscript and reproducible Turn 4 packet, September 10, 2026.

## Manuscript

`paper/main.tex` is the modular source. `paper/manuscript.tex` is a self-contained
source, including both vector figures and the bibliography. `paper/main.pdf` is
the rendered manuscript. The document has 51 pages and 32 consecutively numbered
mathematical statements, plus the explicitly named Lean targets L1–L4.
`statement_index.csv` maps numbers, labels, titles and pages.

Build with a current TeX Live installation including amsmath, amsthm, lmodern,
natbib, tikz, longtable, enumitem and needspace:

```sh
cd paper
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

Alternatively compile `manuscript.tex` twice. The final actual build log is
`logs/latex_camera2.log`. There were no undefined-reference or overfull-box
warnings in that build. The PDF was rendered and visually inspected.

## Main new statements

9–10: the subgrid decision/counting reduction and conditional PRF lower bound.
11–14: noisy integer medians, the succinct learner, star regularity and the
conditional polynomial-time proper-learning separation.
15: the product-average deterministic communication sufficient condition.
21: the sharpened affine-line joint certificate, including the comparison at
Feldman's weak-learning tolerance.
25: a corollary of the May 2026 approximate-sign-rank rectangle theorem.
29–30: the correctly quantified unseen-label and hidden-key bounds.

The former Theorems 1–5 are retained as 16–20, in the main section on spectral
certificates. Former main theorem 9 is now Theorem 1; its exact constants are
Lemma 2, and its mixture is Lemma 3. Former 11–13 are now 4–6. Former 16–23 are
now 7, 8, 22, 23, 24, 26, 27, 28 respectively.

The PRF theorem is conditional and concerns almost every key, not efficient
selection of a deterministic good-key sequence. Its quantum of explicitness is
carefully distinguished from polynomial advice; the latter alone does not
require cryptography. The succinct algorithm uses O(n^2), not O(n), queries.
The original benign-SGD architecture may depend on the fixed class; the
hidden-key lower bounds concern one learner chosen independently of the key.

## CPU experiments

The new median learner uses only the Python standard library. The cap driver
also uses NumPy, SciPy and mpmath. The recorded versions are in
`logs/environment.json`, and `requirements.txt` pins those versions.

```sh
python -m pip install -r requirements.txt
python experiments/seeded_fast.py
python experiments/run_keyed_caps.py
python experiments/algebra_and_stress.py
python experiments/affine_checks.py
python experiments/make_figure.py
```

These commands overwrite their own result files. They do not run SGD. The
recorded random seed is 202609104. The keyed hash is HMAC-SHA256 with key

```
8959fe4a6b404807275400d0a95800e62d0b119c2f8e0061d0ff5d241b229c78
```

The key is SHA256 of ASCII `sq-dc-turn4-main-key-20260910`. The message is bytes
`SQDC4\0` followed by five big-endian unsigned 64-bit integers `(N,a,b,x,y)`.
The first digest byte's low bit chooses the flip. No cryptographic security
claim is made for this experimental instantiation.

### Recorded outputs

- `experiments/results/fast`: 304 runs, 4,798 exact response checks, 304 proper
  outputs. N ranges from 2 to 8, then 16 and 32. The simulator records raw rational
  expectations, endpoint answers, distributions, predictions, query counts and
  timings. It gives the learner no target or distribution data outside SQ calls.
- `experiments/results/keyed_caps`: 56 Proper RECTIFY runs, 28,262 response
  checks, 499 catalogs, 231,150 rectangle checks and 228,684 pointwise checks.
  Every used catalog has an exact integer-verified coverage guarantee, although
  the numerical optimizer used to propose it is not formally verified.
- `experiments/results/checks`: 280 median/endpoint inequalities, all 12 exact
  small unseen-label averages, subgrid counting data for k=2,...,6, twenty tests
  of the large-star branch at N=4096, and exact affine incidence/Gram identities
  over five prime fields. The small-subgrid rank threshold is zero and is
  reported as vacuous rather than presented as empirical rank evidence.

The distribution and endpoint searches are concrete reproducible adversaries,
not global optimality certificates. Cap catalog construction and the exact
oracle simulator are charged separately from the theoretical SQ access model.
The generic numerical cap solver is not described as an exact irrational
optimizer. Mathematical proofs, not the experiments, establish the universal
claims. Wall-clock maxima are single-run measurements, not calibrated scaling
laws. Earlier-turn raw outputs are not relabeled as new executions in this packet.

## Lean status

The source remains unverified: the actual `lake --version` check returned
command-not-found, exit 127 (`logs/lean_status.txt`). No installation or additional
Lean build was attempted. The files are pinned to Mathlib commit
`2631d1cc8c2ace6c6a900425d6e5d2b5963966e9` and toolchain
`leanprover/lean4:v4.34.0-rc2`.

On a machine with that toolchain and network access:

```sh
cd lean
lake update
lake exe cache get
lake build
```

`SQDC.lean` contains the finite definitions and prior proof drafts. `Turn2.lean`
contains the four L1–L4 proof drafts stated exactly in the appendix. This packet
is not a formalization of the full main theorem and contains no successful Lean
compiler output or axiom audit.

## Limits and open statements

Classical imports are identified in the manuscript, including Warren's theorem,
the homogeneous-rectangle theorem for the sharp constant, existential-real
decision complexity and the cryptographic construction reductions. The May
2026 approximate-rank theorem is imported only for its explicitly labeled
corollary. The new PRF statements depend on the stated security assumption.
Remaining open questions include deterministic efficient good-key selection,
one polynomial-key family beating every polynomial, the O(n)-query succinct
implementation, the original benign-SGD implication, the SQ characterization
question and the optimal joint query/tolerance tradeoff.
