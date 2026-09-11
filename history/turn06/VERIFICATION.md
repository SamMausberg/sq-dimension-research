# Verification ledger: Turn 6

## Meaning of status

VERIFIED below means the stated mathematical argument, its hypotheses, source bindings and applicable finite checks were reviewed during this preparation. It does not mean external peer review or a machine-checked proof. CONDITIONAL identifies the PRF hypothesis. VERIFIED VIA IDENTIFIED FORMULATION distinguishes checked secondary formulations of imported theorems from their unresolved original-source records. The original-publication gaps are explicitly DOWNGRADED in SOURCE_CHECKS.md and reproduced in the submission checklist.

The two direct FKS PDF endpoints failed, but original repository content streams for pages 2-4 were recovered with zlib checksum validation. OQ2 is now a verbatim typeset quotation; the finite nondegenerate interpretation is distinguished from the raw-score zero-predictor formula. See SOURCE_CHECKS.md for the term-by-term comparison.

## Every numbered statement

| Statement | Canonical source | Proof source | Dependencies | Status |
|---|---|---|---|---|
| Lemma 2.1 | `sections/02_preliminaries.tex:64-72` | `sections/02_preliminaries.tex:73-86` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Lemma 2.2 | `sections/02_preliminaries.tex:88-90` | `sections/02_preliminaries.tex:91-93` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Lemma 2.3 | `sections/02_preliminaries.tex:95-97` | `appendices/oracle_bounds.tex:36-40` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Theorem 3.1 | `sections/03_rectangle.tex:3-10` | `sections/03_rectangle.tex:63-124` | 3.3 | VERIFIED proof and hypotheses |
| Lemma 3.2 | `sections/03_rectangle.tex:13-19` | `sections/03_rectangle.tex:63-124` | 3.3 | VERIFIED proof and hypotheses |
| Lemma 3.3 | `sections/03_rectangle.tex:23-30` | `sections/03_rectangle.tex:32-36` | 2.1 | VERIFIED proof and hypotheses |
| Theorem 4.1 | `sections/04_family.tex:7-17` | `appendices/family_proof.tex:2-30` | 2.2, 3.1, import:Warren-AMY, import:APP-HHPTZ, L.1 | VERIFIED via identified counting/decision formulation; original-source gaps listed separately |
| Theorem 4.2 | `sections/04_family.tex:36-49` | `sections/04_family.tex:51-76` | 4.1, 2.3, import:Warren-AMY | VERIFIED via identified counting/decision formulation; original-source gaps listed separately |
| Lemma 4.3 | `sections/04_family.tex:77-82` | `sections/04_family.tex:83-85` | 2.3 | VERIFIED proof and hypotheses |
| Corollary 4.4 | `sections/04_family.tex:89-95` | `sections/04_family.tex:96-98` | 4.1, 4.2, 4.3, 5.1, 5.2 | VERIFIED via identified counting/decision formulation; original-source gaps listed separately |
| Theorem 5.1 | `sections/05_learners.tex:6-21` | `appendices/cap_proper_proofs.tex:4-57` | 7.4, aux:convex-bit, 3.1 | VERIFIED proof and hypotheses |
| Theorem 5.2 | `sections/05_learners.tex:46-59` | `appendices/cap_proper_proofs.tex:60-103` | 5.1, 3.1 | VERIFIED proof and hypotheses |
| Lemma 5.3 | `sections/05_learners.tex:87-100` | `appendices/median_proofs.tex:4-8` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Theorem 5.4 | `sections/05_learners.tex:113-120` | `appendices/median_proofs.tex:11-68` | 5.3 | VERIFIED proof and hypotheses |
| Lemma 6.1 | `sections/06_explicit.tex:11-22` | `appendices/explicit_proofs.tex:4-20` | import:Warren-AMY, import:ETR-Vorobjov | VERIFIED via identified counting/decision formulation; original-source gaps listed separately |
| Theorem 6.2 | `sections/06_explicit.tex:28-38` | `appendices/explicit_proofs.tex:23-37` | 6.1, 4.1, 5.2, assumption:PRF | VERIFIED CONDITIONAL on stated PRF security |
| Proposition 6.3 | `sections/06_explicit.tex:46-52` | `appendices/explicit_proofs.tex:57-65` | 6.1, 5.1, 5.2 | VERIFIED via identified counting/decision formulation; original-source gaps listed separately |
| Lemma 6.4 | `sections/06_explicit.tex:57-59` | `appendices/explicit_proofs.tex:40-49` | assumption:PRF | VERIFIED CONDITIONAL on stated PRF security |
| Corollary 6.5 | `sections/06_explicit.tex:65-72` | `appendices/explicit_proofs.tex:52-54` | 6.2, 6.4, 5.4 | VERIFIED CONDITIONAL on stated PRF security |
| Theorem 7.1 | `sections/07_characterizations.tex:7-19` | `appendices/certificate_proofs.tex:4-10` | 3.1 | VERIFIED proof and hypotheses |
| Lemma 7.2 | `sections/07_characterizations.tex:28-43` | `appendices/certificate_proofs.tex:13-20` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Theorem 7.3 | `sections/07_characterizations.tex:49-67` | `appendices/certificate_proofs.tex:23-50` | 7.2 | VERIFIED proof and hypotheses |
| Theorem 7.4 | `sections/07_characterizations.tex:87-96` | `appendices/certificate_proofs.tex:53-102` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Theorem 7.5 | `sections/07_characterizations.tex:105-123` | `appendices/certificate_proofs.tex:105-163` | 7.4, 7.3 | VERIFIED proof and hypotheses |
| Theorem 7.6 | `sections/07_characterizations.tex:133-149` | `appendices/certificate_proofs.tex:166-182` | 2.1 | VERIFIED proof and hypotheses |
| Proposition 7.7 | `sections/07_characterizations.tex:158-168` | `appendices/certificate_proofs.tex:185-202` | 7.2, 7.3 | VERIFIED proof and hypotheses |
| Theorem 7.8 | `sections/07_characterizations.tex:175-181` | `appendices/certificate_proofs.tex:205-220` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Theorem 7.9 | `sections/07_characterizations.tex:190-197` | `appendices/certificate_proofs.tex:223-263` | aux:cube-concentration | VERIFIED proof and hypotheses |
| Theorem 7.10 | `sections/07_characterizations.tex:217-228` | `appendices/certificate_proofs.tex:266-268` | 7.6, 5.1 | VERIFIED proof and hypotheses |
| Corollary 7.11 | `sections/07_characterizations.tex:236-248` | `appendices/certificate_proofs.tex:271-273` | 2.2, 3.1, import:BHKR26 | VERIFIED proof and hypotheses |
| Corollary 8.1 | `sections/08_sgd.tex:29-35` | `sections/08_sgd.tex:36-40` | 5.4, 6.2, import:AKMSS21 | VERIFIED CONDITIONAL on stated PRF security |
| Proposition 8.2 | `sections/08_sgd.tex:68-74` | `appendices/network_proofs.tex:4-10` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Proposition 8.3 | `sections/08_sgd.tex:83-88` | `appendices/network_proofs.tex:13-15` | assumption:PRF | VERIFIED CONDITIONAL on stated PRF security |
| Theorem 10.1 | `sections/10_discussion.tex:9-16` | `appendices/resource_proofs.tex:3-16` | 4.1, 3.1, import:RCF-MC12 | VERIFIED via identified counting/decision formulation; original-source gaps listed separately |
| Proposition 10.2 | `sections/10_discussion.tex:25-37` | `appendices/resource_proofs.tex:18-37` | 2.1 | VERIFIED proof and hypotheses |
| Proposition 10.3 | `sections/10_discussion.tex:48-56` | `appendices/resource_proofs.tex:39-41` | Elementary finite/analytic argument supplied | VERIFIED proof and hypotheses |
| Theorem I.1 | `appendices/statistical_dimension.tex:10-16` | `appendices/statistical_dimension.tex:18-46` | 2.1, import:Feldman17-definition | VERIFIED proof and hypotheses |
| Proposition L.1 | `appendices/geometric_bounds.tex:3-5` | `appendices/geometric_bounds.tex:7-21` | 7.4, 2.2 | VERIFIED proof and hypotheses |
| Proposition L.2 | `appendices/geometric_bounds.tex:23-29` | `appendices/geometric_bounds.tex:31-39` | 7.5 | VERIFIED proof and hypotheses |

## Statement drift and proof dependencies

The extraction script finds 39 numbered canonical statements and 39 proof bindings. Each statement appears once; deferred proofs use canonical-reference headers rather than independent restatements. The explicit 3.1/3.2 proof is a shared proof unit, not mutual assumption. The finite tie lemma now contains its finite core only; its probabilistic consequence appears after Corollary 4.4. Appendix L's elementary half-mass argument is explicit rather than a backwards dependence on the sharper constant.

`checks/statement_proof_extracts/` contains the exact extracted source for every statement and proof. `checks/statement_changes.diff` is the mechanical baseline-to-final statement diff. `checks/proof_dependencies.json` and `.dot` contain the reviewed dependency graph and a successful topological order. All 25 explicit deferred `proof:` pointers resolve to bound proofs. The graph checks source dependencies, not semantic proof validity by automation.

## Numerical constants and scope

The clean-directory run used seed 20260910. Its fresh output is in `checks/clean_run/` and `logs/current/`. It checked 20 rectangle-parameter cases, 280 median endpoint inequalities, 19 covariance cases, 15 brute-force subgrid counts, 7 plane parameter cases and 15 hinge constants. The separate exact scripts checked another 280 endpoint inequalities, 12 unseen-label expectations, 5 subgrid counts, 20 large-star runs, 5 affine-field Gram identities and 4 success-probability substitutions. Every executed assertion passed.

| Constant | Meaning and consistency check |
|---|---|
| 2^-15 | Imported sharp rectangle constant from the identified HHPTZ formulation; unchanged. |
| 2^-18 | Independent Appendix L bound: c6/48 > 1/207360 > 2^-18; recomputed. |
| 24 | RECTIFY tau=epsilon/(24P), and a separate subgrid denominator 24 log2 k. Both contexts retained. |
| 30 | k=ceil(c n^c) and log2 k <= (5/4)c log2 n give 24*(5/4)=30. |
| 512 and 1023 | The proof starts with beta>1023*zeta and uses the weaker beta>512*zeta for endpoint comparisons. They are intentionally different bounds, not conflicting tolerances. |
| 4096 and 8192 | Effective zeta=epsilon/4096 versus raw tolerance epsilon/8192 with half reserved for rounding. The exact rational simulator uses the effective budget; this difference is explicit. |
| 16/17 and 16/15 | Lower/upper normalized covariance factors, before a 1/(8d) approximation perturbation. Recomputed for d=1,...,19. |
| 19 | 11+8M<=19M requires M=m/tau²>=1; now stated locally. |
| C0 | max(64 ceil(n),ceil(128/epsilon)); star regularity itself uses only 64 ceil(n). Manuscript and script now agree in these distinct roles. |
| J | Proper RECTIFY uses ceil(8/epsilon)+1 deterministic tests; the succinct large-star sampler uses ceil(16 ln(4/epsilon)) random tests. J is local in each algorithm; neither replaces the other. |

`checks/constant_occurrences.json` lists physical source and script occurrences. Formula checks are distinguished from literal token matches. The actual c6 is approximately 0.0003509774353562009; 48/c6 is approximately 136760.9287; the first k with D_k>=1 is 180.

## Referee process

REFEREE.md preserves the three reports recorded before edits, then 21 responses with physical source-line pointers. They are sequential simulated readings generated in this interaction, not reports by independent people or independent models. The frozen pre-edit manifest is included. A response marked closed may identify an explicitly downgraded original-source gap under A3; it is not a claim that the bibliography is completely resolved.

## Build, spelling and disclosure

The professional AI-use statement is final text, without an author-edit placeholder. The date/title/author/subject/keywords are checked against the title page and metadata. The actual spelling engine is Hunspell 1.7 via its installed C library, after `detex -n -l -s`; this is recorded rather than claiming an absent executable ran. Technical words, names and TeX label fragments were reviewed separately. The singular-author `Feldman ... proves` error was fixed. ChkTeX's remaining style notices concern the verbatim s.t. quotation, TikZ range syntax, math primes and abbreviated table headings; they are not silently counted as zero raw lint warnings.

The final build report and clean-package test log are generated after packaging. The broader recorded experiment sweeps are preserved previous runs, not presented as newly rerun timing data.

## Original publication records still downgraded

APP05 original full text (DOI metadata now verified); Feldman08 original ACM DOI/text; DV04 original ACM DOI/text; CMW25 original STOC pages/DOI; Warren68 original DOI/text; Renegar92 individual part DOIs/text. See SOURCE_CHECKS.md for the attempted routes and formulations used. Other carried bibliography records are not silently upgraded to a fresh original-theorem verification merely because their links were previously checked.

## Turn-4 to final numbering

| Turn-4 number | Turn-6 number | Label |
|---|---|---|
| 1 | 3.1 | `thm:main` |
| 2 | 3.2 | `lem:params` |
| 3 | 3.3 | `lem:mixture` |
| 4 | 4.1 | `thm:construction` |
| 5 | 4.2 | `thm:prob` |
| 6 | I.1 | `thm:rsd` |
| 7 | 5.1 | `thm:caps` |
| 8 | 5.2 | `thm:proper` |
| 9 | 6.1 | `lem:subgrid` |
| 10 | 6.2 | `thm:prf` |
| 11 | 5.3 | `lem:median` |
| 12 | 5.4 | `thm:fast` |
| 13 | 6.4 | `lem:regularstars` |
| 14 | 6.5 | `cor:fastprf` |
| 15 | 7.1 | `thm:communication` |
| 16 | 7.2 | `thm:energy` |
| 17 | 7.3 | `thm:barrier` |
| 18 | 7.4 | `thm:forster` |
| 19 | 7.5 | `thm:plane` |
| 20 | 7.6 | `thm:tree` |
| 21 | 7.7 | `prop:affine` |
| 22 | 7.8 | `thm:pgglobal` |
| 23 | 7.9 | `thm:halfspaces` |
| 24 | 7.10 | `thm:adapt` |
| 25 | 7.11 | `cor:approxrect` |
| 26 | 8.2 | `thm:network` |
| 27 | 10.1 | `thm:description` |
| 28 | 10.2 | `thm:classicalbarrier` |
| 29 | 10.3 | `prop:unseen` |
| 30 | 8.3 | `prop:hiddenkey` |
| 31 | L.1 | `prop:cap-bound` |
| 32 | L.2 | `prop:pg-rect` |

The Turn-5 section numbering is unchanged in Turn 6. Added in Turn 5 and retained here: 2.1, 2.2, 2.3, 4.3, 4.4, 6.3 and 8.1.

## Final package, build and review results

The actual `arxiv_submission.tar.gz` was extracted into an empty directory and compiled with three invocations of `pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error main.tex`. The provided `main.bbl` was used. The resulting PDF has 59 pages, with 30 pages of main text. It has zero LaTeX errors, zero undefined references/citations, zero overfull boxes and zero duplicate PDF anchors. All 59 extracted page texts and rendered thumbnails are identical to those in the inspected final manuscript. The five figure previews and all page contact sheets were visually reviewed. The archive contains 37 source/documentation files, no absolute input paths, no shell-escape dependencies and no font files.

The 39 canonical statements each have a unique bound proof. All 25 deferred proof pointers resolve. The reviewed dependency graph has 50 nodes and is acyclic. All 21 referee points have file-and-line responses; the range checks were rerun on the final source. These are source-consistency checks and simulated readings, not external peer review or proof-assistant verification.

Hunspell 1.7 was run through its C API with `detex` as the TeX filter. Technical terms, names and TeX remnants were reviewed; no remaining spelling mistake was identified. Raw chktex diagnostics are retained with their adjudication, without a false zero-warning lint claim.

The bounded formalization setup attempt failed: `lake` was absent (exit 127), and fetching elan failed because the container could not resolve `raw.githubusercontent.com` (curl exit 6). No uncompiled formalization or corresponding appendix is shipped. The manuscript contains no reference to that attempt.

The optional O(n)-query extension was not pursued: original-source completion remains on the checklist. Its existing open-problem statement is unchanged. No new result was added in this revision.

Evidence: `checks/archive_test.json`, `checks/arxiv_clean_build.json`, `checks/build_report.json`, `checks/visual_review.json`, `checks/referee_pointer_audit.json`, `checks/lint_review.json`, and `logs/current/`.

Final manuscript SHA-256: `1faf3c373b76e7626b51fda3af88e58ac3a238a5e927cc1a64140f253e6096a3`.
Archive SHA-256: `d50b98bd47d7b36aafc0b382e81babaa4c117f4025e3fa539f7cbf3ac9a6107d`.
