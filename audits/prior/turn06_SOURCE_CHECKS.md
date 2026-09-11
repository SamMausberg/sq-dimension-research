# Source checks and bibliography status

## A1. Original FKS note

Direct retrieval from the supplied raw URL returned an unsupported octet-stream response; the PMLR mirror was unavailable. The GitHub repository file action did return encoded original bytes. Relevant base64 line ranges were recovered from blob `59fb15e60215a07d5bb1ca60ce061ee659d24b13` (203,909-byte, six-page PDF), and the compressed content streams for original PDF pages 2, 3 and 4 were decompressed with valid zlib checksums. The notes retain the extracted primary operators/text. The complete original binary and its font programs were not reconstructed or shipped. This is a primary-page recovery, not a secondary quotation or OCR.

Original file: https://raw.githubusercontent.com/mlresearch/v336/main/assets/feldman26a/feldman26a.pdf
Mirror attempted: https://proceedings.mlr.press/v336/feldman26a/feldman26a.pdf
Primary landing record: https://proceedings.mlr.press/v336/feldman26a.html
PMLR publication license: https://proceedings.mlr.press/pmlr-license-agreement.pdf (CC BY 4.0, with original citation and link).

| Item | Original text/formula | Manuscript comparison | Status |
|---|---|---|---|
| OQ2 quotation | Page 3, `Is there a constant C ... algorithm s.t. ... then dc(H) <= C · m/tau^2.` | Intro block retains words, s.t., quantifiers and terminal period; PDF ligatures/line wraps and mathematical symbols are typeset normally. | VERIFIED from original content stream |
| SQ oracle | Page 3, bounded q on X × {±1}, additive error at most tau, arbitrary v. | Section 2 uses the same bounds and explicitly handles every nonanticipating full-history policy. | VERIFIED; stronger explicit oracle-policy formulation |
| Randomization and error | m adaptive queries; output Boolean predictor; expected error over algorithm randomness for every marginal and target. | Equation (2.1), fixed policy then expectation. Deterministic implementation has pointwise error. | VERIFIED |
| (L) | Universal constant times m/tau². | Equation (1.1), apart from harmless notation/strict dimension convention. | VERIFIED |
| (P), (Pn) | Section 4 allows a polynomial in (m,1/tau), then additionally log|X|. | Equations (1.2)-(1.3); base two chosen explicitly. | VERIFIED |
| Exact probabilistic formula | Page 4: one law over embeddings before D,h; probability inf_w L=0 at least 1-delta. | dc_delta uses an attained minimum over Boolean sign predictions. Delta=1/2 exactly matches the confidence parameter. | VERIFIED quantifiers; tie interpretation stated explicitly |
| Averaged formula | Page 4: E_phi inf_w L <= eta; asks for dc_{C epsilon}. | dc^eta changes only notation and adopts Boolean predictions. Corollary 4.4 chooses fixed epsilon<min(1/4,1/(2C)). | VERIFIED quantifiers; tie interpretation stated explicitly |
| Raw-score caveat | Page 3 defines loss by strictly negative product; page 4 writes h_{w,phi}=<w,phi>. | w=0 has zero loss literally. Main text identifies this and states the nondegenerate conventions covered, rather than silently claiming identical formulas. | VERIFIED literal difference |
| Ordinary dimension | Source uses sign representations; manuscript uses strict sign-rank. | Lemma 2.3 proves the one-coordinate conversion for fixed ties. | VERIFIED convention difference, asymptotics unaffected |
| OQ1 network | Pages 2-3: X={±1}^n, fully connected ReLU, no biases in formula, n0=n,nL=1. | Section 8.2 same architecture and S=sum n_i n_{i-1}. | VERIFIED |
| OQ1 initialization | Independent Gaussian layer-i variance 1/n_{i-1}. | Section 8.2 uses N(0,1/n_{i-1}), the stated standard centered initialization. | VERIFIED |
| OQ1 update/output | Single eta; t=0,...,T-1 fresh samples; logistic loss; sign of sum t=ceil(T/2),...,T. | Both endpoints and loss are identical. | VERIFIED |
| OQ1 expectation | Random initialization and sampling; architecture, eta,T chosen for the class before D,h. | Section 8.2 preserves these quantifiers and does not infer class-agnosticity. | VERIFIED |
| Prior 2025 upper bounds | Page 4 records their failure and cites the authors' 2026 communication. | Section 9 now reports this neutrally with attribution. | VERIFIED as source attribution, not a new proof audit of that paper |

## A2. Requested original records

Crossref query endpoints could not be opened by the web environment, and the container could not resolve external hosts. A final exact-title search recovered the APP05 DOI in Princeton's primary institutional publication record. Other candidate identifiers found only in secondary indexes were not inserted as primary-verified records. Five requested bibliography records remain unresolved; APP05 original full text remains an additional theorem-source gap. These are access/verification limits, not claims that no DOI exists.

| Key | Requested record and attempted route | Result | Status |
|---|---|---|---|
| APP05 | JCTA 111(2):310-326 (2005), DOI 10.1016/j.jcta.2004.12.008 | DOI and full record checked in Princeton's institutional publication record. The DOI endpoint itself was blocked. HHPTZ Theorem 1.9 remains the identified formulation for the theorem. | VERIFIED METADATA; ORIGINAL FULL TEXT UNRESOLVED |
| Feldman08 | STOC 2008:619-628; ACM/Crossref | Original ACM DOI unresolved. Removed generic vtaly.net list URL. Original-source theorem not newly verified; Section 9 identifies the source-note attribution. | DOWNGRADED: original DOI/theorem lookup unresolved |
| DV04 | STOC 2004:315-320; ACM/Crossref | Original ACM DOI unresolved. The converse is reported via FKS and the checked BF extended appendix. | DOWNGRADED: original DOI/text unresolved |
| FGV21 | Mathematics of Operations Research 46(3):912-945 (2021) | Primary journal record confirms DOI **10.1287/moor.2020.1111**. Entry corrected from preprint-style metadata. arXiv:1512.09170 remains secondary. | VERIFIED primary publication record |
| BF13 | NeurIPS 26 (2013) | Primary proceedings title is **Statistical Active Learning Algorithms**; original PDF and record checked. Appendix A is in arXiv:1307.3102v4, stated explicitly. No DOI invented. | VERIFIED primary version and extended-version distinction |
| ABM22 | COLT 2022, PMLR 178 | Primary record confirms pages **4782-4887** and exact title/authors. arXiv:2202.08658 secondary. | VERIFIED primary publication record |
| CMW25 | STOC 2025 proceedings | arXiv:2411.10784 supplies verified title/authors/preprint. Original proceedings pages and DOI still unresolved. Kept preprint as primary accessible version, without invented pages. | DOWNGRADED: original proceedings record unresolved |
| Warren68 | Trans. AMS 133:167-178 (1968), original AMS endpoint | Original DOI/full text unavailable. Used formulation explicitly identified as AMY Theorem 21/Lemma 22. | DOWNGRADED: original DOI/text unresolved |
| Renegar92 | J. Symbolic Computation 13(3), Parts I-III, 255-352 (1992) | Original part DOIs/full texts unavailable. Exact singly exponential formulation attributed to Vorobjov's notes. | DOWNGRADED: original part DOIs/text unresolved |

Primary APP metadata: https://collaborate.princeton.edu/en/publications/crossing-patterns-of-semi-algebraic-sets/
APP DOI: https://doi.org/10.1016/j.jcta.2004.12.008

Primary FGV record: https://pubsonline.informs.org/doi/abs/10.1287/moor.2020.1111?journalCode=moor
Primary BF record: https://proceedings.neurips.cc/paper_files/paper/2013/hash/84117275be999ff55a987b9381e01f96-Abstract.html
Primary ABM record: https://proceedings.mlr.press/v178/abbe22a.html

## A3. Imported mathematical formulations

| Input | Form used and original attempt | Status and manuscript treatment |
|---|---|---|
| Warren counting | s polynomials, degree k, v variables, s>=v: at most (4eks/v)^v strict patterns. Original AMS attempt failed. | VERIFIED THROUGH IDENTIFIED FORMULATION: AMY arXiv:1503.07648, Theorem 21/Lemma 22. Appendix B says so; not called an original-source verification. |
| Homogeneous rectangles | Per-side fraction 2^{-(d+1)}. Original APP text failed. | VERIFIED THROUGH IDENTIFIED FORMULATION: HHPTZ TR22-079, Theorem 1.9. Independent Appendix L proof supplies 2^-18 without this input. |
| ETR decision cost | (s d)^{O(v)} L^{O(1)} bit cost for existential real feasibility. Original Renegar text failed. | VERIFIED THROUGH IDENTIFIED FORMULATION: Vorobjov arXiv:2112.00456. Appendix E explicitly names that formulation and its attribution. |
| Feldman characterization | Definition 4.6 and Theorems 4.8/4.11 checked on original PDF pages 19,20,22. Finite class in Theorem 4.8; distinct verifiable-search dimension in 4.11. | VERIFIED ORIGINAL. The all-marginal extension is separately derived in Appendix I; no log of a discretized instance set is claimed. |
| Feldman finite-field lines | Original Theorems 7.7 and 7.8 checked on PDF pages 33-34. | VERIFIED ORIGINAL. The affine comparison is computed separately, not inferred from the original bound. |
| Full-batch differentiable simulation | AKMSS arXiv:2108.04190v2, Theorem 3d plus definitions and Figure 1. Five-piece activation, constant input, trainable DAG edges, prescribed initialization, reused sample, square loss, clipped rounded gradients, E sup. | VERIFIED ORIGINAL FULL VERSION. An ignored bit uses r=1. Corollary 8.1 uses a deterministic source learner and square-to-classification conversion. |
| Approximate rank rectangles | BHKR arXiv:2605.01038v2 Theorem 1.3, fixed deterministic embedding, fractions d^{-C_eta d},d^{-C_eta d²}. | VERIFIED ORIGINAL FORMULATION. Only total matrices are fed to RECTIFY; partial stars are not silently completed. |
| RCF decidability | Constructive real-closed-field decision treatment in Mahboubi-Cohen arXiv:1201.3731. | VERIFIED ACCESSIBLE FORMULATION. Only decidability, not a practical runtime, is used in Theorem 10.1. |
| HILL/GGM quantitative security composition | Full original reduction statements were not recovered in this revision. | DOWNGRADED TO BACKGROUND. The quantitative one-way-function implication was removed from the proof narrative; the PRF time/security condition is an explicit assumption, not deduced here. |
| Classical converse / margin background | FKS original pages 3-4 checked; BF extended Appendix A and GSS Lemma 10 were the accessible formulations. Feldman08/DV originals unresolved. | VERIFIED AS ATTRIBUTED SOURCE CONTEXT, not independent original-source verification. No new theorem relies on this converse. |
| Forster bounds | Original access restricted; attribution retained. | PROVED IN FULL in Appendix F, so the used mathematical statements are not imported black boxes. |
| HHPTZ construction, minimax and communication | TR22-079 Sections 1-3, including 3.2/3.14. | VERIFIED ORIGINAL AND APPLICATION PROOFS SUPPLIED. |
| Topological, list-replicability and VALG comparisons | Original 2025-2026 preprints and the specific formulations identified in Section 9. | CHECKED COMPARISONS; no priority-exhaustiveness claim and no use as an input to the main counterexample. |

Primary accessible formulations:
- https://arxiv.org/pdf/1503.07648
- https://eccc.weizmann.ac.il/report/2022/079/download/
- https://arxiv.org/pdf/2112.00456
- https://proceedings.mlr.press/v65/feldman17c/feldman17c.pdf
- https://arxiv.org/pdf/2108.04190
- https://arxiv.org/html/2605.01038v2

The remaining original-source and bibliography gaps are included in the author checklist. They are not changed to VERIFIED because the document compiles.
