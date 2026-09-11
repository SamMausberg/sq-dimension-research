#!/usr/bin/env python3
"""Compile the current paper without shell escape and check release diagnostics."""
from __future__ import annotations
import argparse,json,re,shutil,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main()->None:
    ap=argparse.ArgumentParser();ap.add_argument('--directory',type=Path,default=ROOT/'paper');ap.add_argument('--bibtex',action='store_true');ap.add_argument('--report',type=Path,default=ROOT/'audits/current/build.json');a=ap.parse_args()
    directory=a.directory.resolve();logdir=a.report.parent/'logs';logdir.mkdir(parents=True,exist_ok=True)
    cmd=['pdflatex','-no-shell-escape','-interaction=nonstopmode','-halt-on-error','paper.tex']
    for iteration in range(3):
        r=subprocess.run(cmd,cwd=directory,capture_output=True,text=True)
        (logdir/f'{directory.name}_pdflatex_{iteration+1}.log').write_text(r.stdout+r.stderr)
        if r.returncode:raise SystemExit(f'pdflatex pass {iteration+1} failed; see {logdir}')
        if iteration==0 and a.bibtex:
            bib=shutil.which('bibtex') or shutil.which('bibtex.original')
            if not bib:raise SystemExit('No BibTeX executable found; the supplied .bbl can be used without --bibtex.')
            r=subprocess.run([bib,'paper'],cwd=directory,capture_output=True,text=True)
            (logdir/f'{directory.name}_bibtex.log').write_text(r.stdout+r.stderr)
            if r.returncode:raise SystemExit('BibTeX failed.')
    log=(directory/'paper.log').read_text(errors='replace');aux=(directory/'paper.aux').read_text()
    result=dict(errors=len(re.findall(r'^!',log,re.M)),undefined_references=len(re.findall(r'Reference .* undefined',log)),undefined_citations=len(re.findall(r'Citation .* undefined',log)),overfull_boxes=len(re.findall('Overfull',log)),duplicate_anchors=len(re.findall('destination with the same identifier',log)),pages=int(re.search(r'Output written on paper.pdf \((\d+) pages',log)[1]),main_pages=int(re.search(r'\\newlabel\{main-end\}\{\{[^}]*\}\{(\d+)\}',aux)[1]),shell_escape=False,command=cmd)
    assert all(result[k]==0 for k in ['errors','undefined_references','undefined_citations','overfull_boxes','duplicate_anchors']),result
    assert result['main_pages']<=16,result
    a.report.parent.mkdir(parents=True,exist_ok=True);a.report.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
if __name__=='__main__':main()
