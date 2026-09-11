Build from this directory using:

  pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex
  pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex
  pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex

The supplied paper.bbl permits compilation without BibTeX. To regenerate it, run bibtex paper after the first TeX pass. All inputs are relative; no shell escape or external fonts are needed. The full research repository contains the numerical scripts, historical outputs, and verification ledger.
