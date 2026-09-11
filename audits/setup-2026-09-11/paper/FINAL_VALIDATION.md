# Final manuscript validation - 2026-09-11

The final `paper/paper.pdf` and `paper/paper.bbl` were regenerated from the checked sources with BibTeX and three pdfLaTeX passes, with shell escape disabled.

- **PASS:** 64 total pages, 13 main pages; zero errors, undefined references/citations, overfull boxes, or duplicate anchors.
- All 34 bibliography entries resolve. References on pages 14-16 were visually checked after regeneration.
- Source audit passes for 40 numbered statements, 40 bound proofs, and 51 nodes in an acyclic dependency graph. These are linkage checks, not a proof of mathematical validity.
- All 44 manuscript TeX inputs preserve their mathematical and prose content. Only the construction-proof hyperlink label was relocated, Figure 1 placement changed from `[t]` to `[H]`, and the short inequality was wrapped in `\mbox{...}` to prevent a page split.
- All 64 pages were rendered at 100 DPI. The only changed mathematical-body page layouts are pages 25-26; the remaining 59 non-bibliography page drawing streams match the original after normalizing PDF font-resource identifiers. Final inspection confirms Appendix E now contains its figure below its heading, the proof link targets Appendix F, and `signrank(F) <= 6` remains together.
- Nineteen underfull-box spacing notices remain in narrow table columns and bibliography lines. No clipping, overlap, missing glyphs, or other LaTeX warnings were observed in the final reviewed pages.

Detailed evidence: `final_build.json`, `final_content_comparison.json`, `final_validation.json`, `final_sources/source_consistency.json`, and `logs/`.
