# Exact-title and citation audit — 11 September 2026

All **34 original bibliography entries** were checked again against live primary
records and accessible title pages. They represented **36 individual papers**:
the original Renegar entry combined three articles. The bibliography now has
**36 separate entries**, and all **69 citation occurrences** resolve to them.
No fabricated work was found.

The [complete title table](TITLES.md) gives every primary-source title and link.
[Machine-readable comparisons](titles.json) verify all 36 final titles against
those source titles. [The change ledger](changes.json) records every field edit;
18 entries were updated or added, including the two new Renegar keys.

## Corrections

- Protected **Euclidean** in BDES02 and CMW25 and **Hamming** in GHIS25 so
  `plainnat` preserves these proper names in the PDF.
- Matched HHM23's **Borsuk-Ulam** hyphen to the publisher record and inspected
  preprint title page.
- Corrected MC12 to **Cyril Cohen, Assia Mahboubi**, following the actual published
  PDF and its arXiv v2 copy. Added the verified LMCS volume, issue/article, pages,
  and DOI. The catalogue records reverse the byline; this source disagreement is
  documented rather than silently treated as agreement.
- Replaced Renegar's combined series shorthand with the complete published
  titles, individual page ranges, and DOIs of Parts I, II, and III. The existing
  `Renegar92` key now identifies Part I; `Renegar92II` and `Renegar92III` identify
  the remaining parts. The manuscript's series citation includes all three.
- Expanded 11 conference names to the publisher's precise proceedings titles.

Ordinary title case versus sentence case is a bibliography-style choice. The
existing `plainnat` sentence-case style is retained, with proper names, acronyms,
math notation, Roman part numbers, and sentence boundaries protected. The title
comparison ignores case, whitespace, and BibTeX grouping/protection only; it does
not discard or rewrite title words or punctuation.

## Source choices and limits

The cited **VALG v2 PDF includes the subtitle** “and Demonstrations on COLT 2026
Open Problems”; the arXiv landing record omits it. The bibliography retains the
full title of the version actually cited. MC12 follows its PDF byline, as noted
above. Other recorded differences include title-case styling, conventional
personal-name spelling, preprint dates versus publication years, and local PDF
page numbers versus published proceedings pagination.

BF13's proceedings title is correctly the shorter *Statistical Active Learning
Algorithms*. The identified extended arXiv v4 has a longer title and a 2014
revision date; its existing version note identifies the source of Appendix A.
No missing DOI, page range, or author initial was invented to fill a metadata gap.

Some older publisher PDFs could not be opened. Their exact titles and publication
fields were checked through primary publisher records or publisher-deposited DOI
metadata, with accessible author copies used where available. Renegar's titles
and pagination follow the publisher's records. Each detailed report states its
actual access limits. This is a bibliographic audit, not a new independent proof
of every cited theorem or a guarantee that third-party metadata is error-free.

| Report | Original citation keys |
| --- | --- |
| [Early and foundational](primary/early.json) | FKS26, HHPTZ22, APP05, Warren68, AMY16, Feldman17, Forster02, AKMSS21, HHM23 |
| [Theory](primary/theory.json) | GHIS25, FHV26, DKT22, MC12, GGM86, HILL99, Renegar92, Vorobjov21, BHKR26 |
| [Dimension and SQ](primary/mid.json) | BHHLT26, VALG26, BDES02, KMS20, CMW25, Kearns98, Feldman08, Feldman11 |
| [Learning](primary/learning.json) | DV04, BF13, GSS13, FGV21, KM25, MKAS21, ABBBN21, ABM22 |
| [Renegar's individual articles](primary/renegar-detail.json) | Renegar92, Renegar92II, Renegar92III |

Evidence filenames in these reports identify local downloads used during the
audit. Third-party papers are not redistributed in this repository; the primary
URLs are the portable references.

## Source preservation and PDF validation

[Source comparison](source_preservation.json) checks all 44 TeX inputs against
commit `58b258762351f7bc5d3be95a91e06700e1fae63f`. Exactly one citation-key list
changed; all mathematical statements, formulas, proof prose, and other TeX input
remain byte-for-byte identical. [Citation structure](citation_structure.json)
records every citation occurrence and confirms no missing or uncited entry.

The rebuilt PDF's [final validation](paper/FINAL_VALIDATION.md),
[build report](paper/final_build.json), [visual/structural report](paper/final_validation.json),
and [source comparison](paper/source_comparison.json) document the delivered
reading copy. Earlier setup evidence remains a historical snapshot in
[`../setup-2026-09-11/`](../setup-2026-09-11/README.md).
