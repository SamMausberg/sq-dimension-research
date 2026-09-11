"""Create the release archive from explicitly selected source and data files."""
from pathlib import Path
import hashlib, json, shutil, zipfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT.parent
files=[]
for name in ['paper.pdf','paper.tex','preamble.tex','abstract.tex','references.bib','paper.bbl','README.md','VERIFICATION.md','CHANGES.md','build.sh']:
    files.append(ROOT/name)
for folder in ['sections','appendices','figures']:
    files.extend(sorted((ROOT/folder).glob('*.tex')))
for name in ['recompute_constants.py','render_figures.py','validate_build.py','package_release.py','constants.json','statement_inventory.json','number_mapping.json','build_report.json','visual_review.json','bibliography_inventory.json']:
    files.append(ROOT/'checks'/name)
for p in sorted((ROOT/'logs').glob('*.log')):
    if 'preview' not in p.name:
        files.append(p)
for name in ['template_flip','rectify_round','implication_map','cap_geometry','order_median']:
    files.append(ROOT/'renders'/f'{name}.png')
for start in range(0,59,12):
    files.append(ROOT/'renders'/f'pages_{start+1:02d}_{min(59,start+12):02d}.png')
files.extend(sorted((ROOT/'renders').glob('page_[0-9][0-9].png')))
for p in (ROOT/'supplement'/'experiments').rglob('*'):
    if p.is_file() and '__pycache__' not in p.parts and p.suffix not in {'.pyc','.pyo'}:
        files.append(p)
files=sorted(set(files))
assert all(p.is_file() for p in files)
assert not any(p.suffix.lower() in {'.ttf','.otf','.pfb','.pfa','.woff','.woff2','.lean'} for p in files)
manifest={'author':'Samuel Mausberg','paper_sha256':hashlib.sha256((ROOT/'paper.pdf').read_bytes()).hexdigest(),'files':[{'path':str(p.relative_to(ROOT)),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files]}
manifest_path=ROOT/'MANIFEST.json'
manifest_path.write_text(json.dumps(manifest,indent=2)+'\n')
files.append(manifest_path)
archive=OUT/'Samuel_Mausberg_SQ_Paper_Source_and_Verification.zip'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=8) as z:
    for p in files:
        z.write(p,Path('Samuel_Mausberg_SQ_Paper')/p.relative_to(ROOT))
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
pdf=OUT/'Samuel_Mausberg_SQ_Dimension_Complexity.pdf'
shutil.copy2(ROOT/'paper.pdf',pdf)
shutil.copy2(ROOT/'VERIFICATION.md',OUT/'SQ_Paper_VERIFICATION.md')
shutil.copy2(ROOT/'CHANGES.md',OUT/'SQ_Paper_CHANGES.md')
print(json.dumps({'pdf':str(pdf),'archive':str(archive),'archive_bytes':archive.stat().st_size,'files':len(files),'paper_sha256':manifest['paper_sha256']},indent=2))
