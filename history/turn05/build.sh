#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p logs renders
pdflatex -interaction=nonstopmode -halt-on-error paper.tex > logs/build-pass1.log
if command -v bibtex8 >/dev/null 2>&1; then
  bibtex8 paper > logs/bibliography.log
else
  bibtex paper > logs/bibliography.log
fi
pdflatex -interaction=nonstopmode -halt-on-error paper.tex > logs/build-pass2.log
pdflatex -interaction=nonstopmode -halt-on-error paper.tex > logs/build-final.log
python checks/validate_build.py
