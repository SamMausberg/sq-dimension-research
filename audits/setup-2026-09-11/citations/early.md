# Early citation audit: primary learning references

Checked 2026-09-11 against `paper/references.bib` and all matching `paper/**/*.tex` usages in `outputs/sq-dimension-research`. This is a read-only citation/attribution audit; it is not a proof of the manuscript's results. No fabricated work or materially mismatched attribution was found among these five entries. `early-spectral.md` supplies the remaining four assigned keys.

## FKS26 — verified

Supplied title, all three authors (Vitaly Feldman, Pritish Kamath, Nathan Srebro), year 2026, PMLR series, volume 336, pages 7117–7122 and URL match the official [PMLR record](https://proceedings.mlr.press/v336/feldman26a.html). Its official conference wording is “Proceedings of Thirty Ninth Conference on Learning Theory”; the entry's equivalent “Proceedings of the Thirty-Ninth Conference on Learning Theory” is harmless normalization.

The [official linked PDF](https://raw.githubusercontent.com/mlresearch/v336/main/assets/feldman26a/feldman26a.pdf) was downloaded live and extracted locally. Its Open Question 2 (printed page 3) matches the introduction's quotation, quantifiers, error threshold, expectation and dimension inequality after normalizing TeX notation and whitespace. Section 3 supports the weak correlational/margin discussion. Its statement about an error in the Karchmer–Malach bound and its bibliography's 2026 personal-communication attribution match the manuscript's carefully attributed description. That communication itself was not independently accessed.

Required corrections: none. Optional normalization: use the official conference wording. No DOI is supplied or needed for this PMLR entry.

## HHPTZ22 — verified

Supplied title, five authors (Hamed Hatami, Pooya Hatami, William Pires, Ran Tao, Rosie Zhao), 2022 year, report identifier TR22-079 and URL match [ECCC](https://eccc.weizmann.ac.il/report/2022/079/). The report was posted 25 May 2022; no revision suffix appears on the inspected record.

The [primary report PDF](https://eccc.weizmann.ac.il/report/2022/079/download) was downloaded live and read. Theorem 1.9/Remark 1.10 support the rectangle fraction formulation; Section 3.2 contains the real incidence-grid construction, monotone flips and constant `2^-15`; Theorem 3.1 uses the cited rectangle-mixture minimax game. Proposition 3.14 is the two-membership-bit recursive communication protocol with bound `2/rect(A)`. Problem 4.1 asks for explicit constant-rectangle/unbounded-sign-rank matrices. These match the manuscript's specific uses and imported-versus-new attribution. The manuscript supplies its own application analyses; those were not established merely by checking citations.

Required corrections: none. The current ECCC URL is an appropriate source anchor. A later venue is not required for this explicitly labeled report.

## AMY16 — verified; version precision recommended

Title, authors Noga Alon/Shay Moran/Amir Yehudayoff, 2016 year, PMLR 49 and pages 47–80 match the [official PMLR record](https://proceedings.mlr.press/v49/alon16.html). Its conference title is “29th Annual Conference on Learning Theory.” The supplied [arXiv identifier](https://arxiv.org/abs/1503.07648) is correct; version 2 was submitted 8 July 2016.

In the [arXiv v2 PDF](https://arxiv.org/pdf/1503.07648v2), Theorem 21 and Lemma 22 (printed page 16) are exactly the strict-sign Warren bound and rank-counting application cited at `family_proof.tex:26`. The polynomial-count hypothesis and constant agree. The [conference PDF](https://proceedings.mlr.press/v49/alon16.pdf) instead numbers these Theorem 23/Lemma 24. The existing note names the full version, so this is not a false theorem citation, but the manuscript should say the numbering refers to the full version.

Recommended metadata-only change: URL `https://arxiv.org/abs/1503.07648v2`; note `Full version: arXiv:1503.07648v2; theorem and lemma numbers refer to this version`. No mathematical changes are needed.

## Feldman17 — verified

Author Vitaly Feldman, supplied title, 2017 year, PMLR volume 65, pages 785–830 and URL match the [official record](https://proceedings.mlr.press/v65/feldman17c.html). Official conference wording is “Proceedings of the 2017 Conference on Learning Theory”; generic COLT wording is equivalent.

The [official PDF](https://proceedings.mlr.press/v65/feldman17c/feldman17c.pdf) was read. Theorem 4.8 (printed page 20) matches the randomized upper-bound formula, including the KL-radius/tolerance-squared factor. Theorem 4.11 uses the different verifiable-search dimension, as the manuscript warns. The original Theorem 4.8 assumes finite distribution class and domain; the manuscript explicitly supplies its own extension argument, which this citation check does not independently certify. Theorem 7.7 gives the quoted finite-field-line lower bound `t/2-1` with `t=(p/32)^(1/4)`, tolerance `1/t`, error below `1/2-1/t`, success at least `2/3`. Theorem 7.8 supplies the stated fixed-distribution upper bound and tolerance. Those references are accurate.

Required corrections: none. Optional conference-title normalization only. No DOI is supplied or required.

## AKMSS21 — verified; version pin recommended

The [official NeurIPS record](https://proceedings.neurips.cc/paper/2021/hash/cc225865b743ecc91c4743259813f604-Abstract.html) and its [official BibTeX](https://proceedings.neurips.cc/paper_files/paper/13486-/bibtex), downloaded live, confirm all five authors, title, NeurIPS 2021, volume 34 and pages 24340–24351. [arXiv](https://arxiv.org/abs/2108.04190) confirms version 2 dated 6 February 2022; the conference year and full-version note are consistent.

The [v2 PDF](https://arxiv.org/pdf/2108.04190v2) was downloaded/read. Theorem 3d, printed page 14, matches the imported full-batch simulation parameters: precision `tau/16`, `2k` steps, sample condition and polynomial network-size bound. Section 2 and Figure 1 support the exact activation, directed acyclic network, prescribed initialization, half-square loss, reused sample, coordinate clipping/rounding, `3rho/4` tolerance and expectation outside the supremum over admissible gradients. The source also states differentiability and gradients bounded by one along its constructions. No gross model or theorem mismatch found.

Required corrections: none. Recommended metadata-only change: pin URL to `https://arxiv.org/abs/2108.04190v2`, retaining the existing v2 note. This audit checks imported statements; it does not prove their application to the manuscript's new learner.

## Scope

The primary texts were inspected for the specific attributions above. This does not imply complete independent mathematical review, full Lean coverage, or that every negative literature-comparison claim has been exhaustively established. No repository files or mathematical text were changed by this audit.


# APP05, Warren68, Forster02, HHM23 citation audit

Checked 2026-09-11 against `outputs/sq-dimension-research/paper/references.bib` and all current `paper/**/*.tex` usages. This report makes no repository edits. It distinguishes existence/metadata checks, relevant statement attribution, and full mathematical validation. No fabricated work was found among these four keys.

## APP05 — verified

All supplied fields match: authors Noga Alon, János Pach, Rom Pinchasi, Radoš Radoičić, Micha Sharir; title *Crossing patterns of semi-algebraic sets*; JCTA Series A; 111(2), 310–326; 2005; DOI `10.1016/j.jcta.2004.12.008`.

Primary evidence:

- Publisher bibliographic record (indexed live by web search; direct HTML fetch failed): https://www.sciencedirect.com/science/article/pii/S0097316505000063
- Original author-hosted PDF, successfully read: https://web.math.princeton.edu/~nalon/PDFS/apprs8.pdf
- Author's institutional publication record independently agrees with all metadata: https://collaborate.princeton.edu/en/publications/crossing-patterns-of-semi-algebraic-sets/

Usage: `paper/appendices/family_proof.tex:15` and introduction/related-work citations attribute the homogeneous rectangle ingredient and its constants. Original Theorem 1.3 (PDF page 4, printed page 4) states the finite-multiset scalar-product result with at least `2^{-(d+1)}` of each side and a uniform nonnegative/negative sign. Strict sign representations remove the zero distinction, so this supports the manuscript's side fractions and product bound `2^{-(2d+2)}`. The subsequent factor of one half for monotone flips is the manuscript's own argument. No gross misattribution found.

Required corrections: none. Optional citation improvement: directly name original Theorem 1.3 in addition to the HHPTZ22 restatement. Keep the journal DOI as the publication anchor.

## Warren68 — verified metadata with original-source access limitation

Existing fields agree with the AMS publisher's own indexed bibliography and its publisher-deposited Crossref record: author Hugh E. Warren; title *Lower bounds for approximation by nonlinear manifolds*; Transactions of the AMS; volume 133; pages 167–178; 1968. The existing entry does not supply issue, DOI or URL, so there is no incorrect supplied identifier. The root auditor retrieved the live [Crossref record](https://api.crossref.org/works/10.1090%2FS0002-9947-1968-0226281-1); I inspected its saved JSON (`Warren68-crossref.json`). It confirms AMS, issue 1, and DOI `10.1090/S0002-9947-1968-0226281-1`.

Official AMS corroboration: reference [740] in https://www.ams.org/books/surv/152/surv152-endmatter.pdf is indexed by live web search with those exact bibliographic fields. This is publisher-hosted bibliographic corroboration, not direct inspection of the 1968 article. The full AMS PDF could not be fetched (HTTP 403). The original article landing page and PDF also returned HTTP 403 with normal escalated public downloads:

- https://www.ams.org/journals/tran/1968-133-01/S0002-9947-1968-0226281-1/
- https://www.ams.org/journals/tran/1968-133-01/S0002-9947-1968-0226281-1/S0002-9947-1968-0226281-1.pdf

Independent publisher archive corroboration: https://www.jstor.org/stable/i334276 shows volume 133, issue 1, August 1968, author/title/pages and archive DOI `10.2307/1994937`. This archive evidence is supplementary to the AMS evidence above.

Usage: `paper/appendices/family_proof.tex:26` explicitly takes the strict-sign formulation through AMY16 Theorem 21 and Lemma 22. The parent citation auditor independently read the AMY16 arXiv full version v2 and confirmed `(4 e k m/l)^l` for `m >= l` and the rank-counting application. Thus the manuscript's cited restatement is checked; this agent did not inspect Warren's original proof. Original-publication access remains unresolved, which is not evidence of fabrication.

Required corrections: none to current Warren metadata. Recommended version precision is in the AMY16 entry: pin arXiv `1503.07648v2`, since Theorem 21/Lemma 22 are those full-version numbers; the conference PDF calls them Theorem 23/Lemma 24. Optional Warren DOI enrichment can use the now-verified `10.1090/S0002-9947-1968-0226281-1`; retain the original-full-text access limitation and do not present that article as downloaded/read.

## Forster02 — verified

All supplied fields match the publisher's live indexed record: Jürgen Forster; *A linear lower bound on the unbounded error probabilistic communication complexity*; Journal of Computer and System Sciences; 65(4), 612–625; December 2002; DOI `10.1016/S0022-0000(02)00019-3`.

Primary source: https://www.sciencedirect.com/science/article/pii/S0022000002000193

Usage: `paper/appendices/comparisons.tex:84` says the manuscript uses Forster's spectral method and supplies its geometric step itself. Related work attributes normalization/spectral lower bounds. The publisher abstract confirms that this is the paper introducing the relevant spectral lower bound and halfspace-margin connection. No gross misattribution found. Direct publisher HTML/PDF retrieval failed, so this is bibliographic/abstract-level verification, not a line-by-line comparison of the manuscript's generalized real-matrix theorem with the original paper.

Required corrections: none. Version anchor: 2002 journal article DOI already present.

## HHM23 — verified metadata and relevant preprint attribution; original ACM text inaccessible

Title and all three authors match primary sources: *A Borsuk-Ulam lower bound for sign-rank and its applications*, Hamed Hatami, Kaave Hosseini, Xiang Meng. ECCC TR22-130 is a real preprint dated 15 September 2022; STOC 2023 is independently confirmed by the official conference table of contents. The existing 2023 year refers to conference publication, while the note correctly labels the 2022 preprint.

Primary evidence:

- https://eccc.weizmann.ac.il/report/2022/130/
- https://eccc.weizmann.ac.il/report/2022/130/download/ (17-page preprint successfully read)
- https://acm-stoc.org/stoc2023/toc.html (official conference title, author list, abstract and ACM DOI link)
- https://acm-stoc.org/stoc2023/stoc23-program.html

The conference's own link establishes DOI `10.1145/3564246.3585210`; the ACM article returned HTTP 403. The root auditor subsequently retrieved the live [publisher-deposited Crossref record](https://api.crossref.org/works/10.1145%2F3564246.3585210); I inspected its saved JSON (`HHM23-crossref.json`). It confirms ACM, all three authors, title, 2023 date and pages `463–471`. This resolves the initial exact-pagination metadata gap. The final published full text was not directly inspected; the primary preprint was.

Usage: `paper/appendices/related_work.tex:21` describes earlier topological sign-rank bounds. The primary preprint and official conference abstract explicitly cover a Borsuk-Ulam method for sign-rank. This accurately characterizes the work. The broader negative claim about not supplying a particular explicit constant-rectangle flip-family selection was not exhaustively re-proved by this citation metadata audit.

Required corrections: none demonstrated. Recommended enrichments: add DOI `10.1145/3564246.3585210`; use the full conference title if desired; retain the ECCC preprint note and avoid relabeling it as a 2023 ECCC report. No version suffix exists on the inspected ECCC report page.

## Scope and reproducibility

This audit does not establish that every argument in the manuscript is correct, nor that Lean formalizes every paper claim. It verifies real sources and relevant attribution, with access limits listed above. No mathematical statement or source file was changed. Parent citation audit holds the direct AMY16 theorem-number and Warren-restatement check.
