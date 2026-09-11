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
