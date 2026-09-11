#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p logs
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex > logs/build-pass1.log
if [[ "${REBUILD_BIB:-0}" == "1" ]]; then
  bibtex paper > logs/bibliography.log
fi
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex > logs/build-pass2.log
pdflatex -no-shell-escape -interaction=nonstopmode -halt-on-error paper.tex > logs/build-final.log
