# Source audit

Only primary research papers and the official Mathlib repository were used. URLs below are source identifiers for reproducibility. Papers are not bundled.

## ECCC TR22-079

H. Hatami, P. Hatami, W. Pires, R. Tao, R. Zhao, *Lower bound methods for sign-rank and their limitations* (2022).
https://eccc.weizmann.ac.il/report/2022/079/download/

Sections 1--3 were read. Theorem 1.9 and Remark 1.10 give the rank-to-product-rectangle implication with the 2^(-2d-2) constant and its duplication argument. Theorem 3.2 gives the incidence-flip construction. Lemma 1.1 states the counting bound. Proposition 3.14 concerns average deterministic communication under fixed product distributions. Problem 4.1 is the explicitness direction. Pages containing the construction and the original geometric statements were inspected as rendered PDF images.

The present manuscript derives the exact incidence count, all quantifiers for the common learner, the monotone-flip reduction, and the probabilistic-dimension arguments. It does not infer SQ learnability from fixed-distribution communication alone.

## Classical counting and homogeneous rectangles

Alon, Moran, Yehudayoff, *Sign rank versus VC dimension* (2016), full version:
https://arxiv.org/pdf/1503.07648

The strict-sign-pattern theorem and its rank-factorization application were checked in the displayed full version (Theorem 21 and Lemma 22). Different editions have different lemma numbers. The exact bound used is (4 e k s / v)^v for s >= v degree-k polynomials in v variables, excluding zero signs. The manuscript uses it with k=2, s=K^2, v=2Kd. It does not claim an independent proof of the general Warren theorem.

Alon, Pach, Pinchasi, Radoicic, Sharir, *Crossing patterns of semi-algebraic sets* (2005), Theorem 1.3. Its precise homogeneous-rectangle consequence was checked through its explicit statement in TR22-079. A fresh original-source download was not obtained in this environment. For that reason the manuscript also supplies an independent radial-isotropy proof with constant 2^(-18), which already yields the counterexample without this sharp classical input. The bound 2^(-15) uses the cited classical theorem.

## Randomized SQ characterization

Feldman, *A general characterization of the statistical query complexity* (COLT 2017):
https://proceedings.mlr.press/v65/feldman17c/feldman17c.pdf

Definition 4.6 and Theorem 4.8 were inspected, including the PDF image of printed page 20. The latter has tolerance kappa/3, success alpha-delta, and query bound O(d R_KL/kappa^2 log(R_KL/(kappa delta))). It is stated for a finite class of distributions on a finite domain. The manuscript separately explains why its own finite payoff-type minimax and KL-update proof apply to all realizable marginals. The deterministic set-cover logarithm is not imported into this randomized bound. Theorem 4.11's verifiability dimension is not identified with the fairness-1/4 dimension without proof.

## Differentiable-learning simulation

Abbe, Kamath, Malach, Sandon, Srebro, *On the power of differentiable learning versus PAC and SQ learning* (2021):
https://arxiv.org/pdf/2108.04190

Theorem 1d and the simulation discussion were checked. Computational model size depends on simulated computation time, not only SQ count. Engineered activation, initialization, and the fixed-weight requirements for the stated ReLU alternative differ from the fully trained bias-free Gaussian network in OQ1. The manuscript's elementary coordinatewise SQ simulation is proved directly.

## Explicitness check, 2023--2026

Hatami, Hosseini, Meng, *A Borsuk--Ulam lower bound for sign-rank and its applications*, STOC 2023:
https://eccc.weizmann.ac.il/report/2022/130/

The third author's name is Xiang Meng. The reviewed applications concern partial gap-inner-product and Gap Hamming matrices, not the required exponentially growing total sign matrix with bounded inverse rectangle ratio.

Goos, Harms, Imbach, Sokolov, *Sign-Rank of k-Hamming Distance is Constant*, arXiv:2506.12022v2:
https://arxiv.org/html/2506.12022v2

The bound is 2^{O(k)}, independent of the number of bits. This rules out unbounded sign-rank for the fixed-k hypercube candidate in this direction.

Frick, Hosseini, Vasileuski, *A Z2-Topological Framework for Sign-rank Lower Bounds*, arXiv:2604.01510v2:
https://arxiv.org/html/2604.01510v2

The near-extremal Gap Hamming result is approximately 2k for a partial matrix, with k less than half the bit dimension. It does not by itself give the required explicit total matrix. The manuscript reports the scope of the papers checked, not an exhaustive absence theorem about all current literature.

## Open-problem source and Lean pin

Feldman, Kamath, Srebro, COLT 2026 invited open problem:
https://proceedings.mlr.press/v336/feldman26a.html

Official Mathlib pin fetched through GitHub connector:
https://api.github.com/repos/leanprover-community/mathlib4/commits/2631d1cc8c2ace6c6a900425d6e5d2b5963966e9
https://raw.githubusercontent.com/leanprover-community/mathlib4/2631d1cc8c2ace6c6a900425d6e5d2b5963966e9/lean-toolchain

The toolchain file is leanprover/lean4:v4.34.0-rc2. Neither lean nor lake exists in the current runtime. This pin is not a successful build.
