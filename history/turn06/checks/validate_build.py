"""Validate the compiled manuscript, with no network or OCR dependencies."""
from pathlib import Path
import hashlib, json, re, sys
import fitz

ROOT = Path(__file__).resolve().parents[1]
log = (ROOT / 'paper.log').read_text(errors='replace')
aux = (ROOT / 'paper.aux').read_text()
pdf_path = ROOT / 'paper.pdf'
doc = fitz.open(pdf_path)
tex_paths = [ROOT/'paper.tex', ROOT/'preamble.tex', ROOT/'abstract.tex']
for sub in ('sections', 'appendices', 'figures'):
    tex_paths += sorted((ROOT/sub).glob('*.tex'))
source = '\n'.join(p.read_text() for p in tex_paths)
main_end = re.search(r'\\newlabel\{main-end\}\{\{[^}]*\}\{(\d+)\}', aux)
fig_labels = ['fig:template','fig:rectify','fig:cap','fig:order','fig:landscape']
figures = {}
for label in fig_labels:
    match = re.search(r'\\newlabel\{'+re.escape(label)+r'\}\{\{([^}]*)\}\{([^}]*)\}',aux)
    figures[label] = {
        'number': match.group(1) if match else None,
        'page': match.group(2) if match else None,
        'referenced_in_source': bool(re.search(r'\\(?:[Cc]ref|ref)\{[^}]*'+re.escape(label), source)),
    }
errors = re.findall(r'^!.*$',log,re.M)
undefined = [line for line in log.splitlines() if re.search(r'undefined|There were undefined',line,re.I)]
overfull = re.findall(r'Overfull \\[hv]box \(([^)]*)\)',log)
duplicate_anchors = [line for line in log.splitlines() if 'same identifier' in line or 'duplicate ignored' in line]
report = {
    'author': doc.metadata.get('author'),
    'title': doc.metadata.get('title'),
    'pages':len(doc),
    'main_text_last_page':int(main_end.group(1)) if main_end else None,
    'latex_errors': errors,
    'undefined_reference_or_citation_messages':undefined,
    'overfull_boxes':overfull,
    'duplicate_anchor_messages':duplicate_anchors,
    'figures': figures,
    'pdf_sha256':hashlib.sha256(pdf_path.read_bytes()).hexdigest(),
    'all_page_contact_sheets_present': all((ROOT/'renders'/f'pages_{i+1:02d}_{min(len(doc),i+12):02d}.png').exists() for i in range(0,len(doc),12)),
    'visual_review_matches_pdf': (ROOT/'checks'/'visual_review.json').exists() and json.loads((ROOT/'checks'/'visual_review.json').read_text()).get('pdf_sha256') == hashlib.sha256(pdf_path.read_bytes()).hexdigest(),
    'lint': {
        'raw_log':'logs/chktex-raw.log',
        'reviewed_log':'logs/chktex-reviewed.log',
        'note':'Raw style diagnostics were reviewed. The installation lacks a global resource file. No zero-warning raw lint claim is made.'
    },
    'proof_status_note':'Compilation and finite checks are not a machine-checked proof or external peer review.'
}
assert report['author']=='Samuel Mausberg', report['author']
assert report['main_text_last_page']<=30
assert not errors and not undefined and not overfull and not duplicate_anchors
assert all(v['number'] and v['referenced_in_source'] for v in figures.values()),figures
(ROOT/'checks'/'build_report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
