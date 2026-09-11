#!/usr/bin/env python3
"""Index the ancillary research files, excluding the manifest itself and Git."""
from __future__ import annotations
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/ANCILLARY_MANIFEST.json'
EXCLUDE_SUFFIX={'.aux','.out','.toc','.blg','.pyc','.synctex.gz'}

def main():
    records=[]
    for top in ['experiments','audits','formalization','history','tools','docs']:
        for p in sorted((ROOT/top).rglob('*')):
            if not p.is_file() or p==OUT or p.name=='ANCILLARY_MANIFEST.md':continue
            if '__pycache__' in p.parts or p.suffix in EXCLUDE_SUFFIX:continue
            if p.suffix.lower() in {'.ttf','.otf','.woff','.woff2','.pfb','.pfa'}:raise RuntimeError(f'Font binary: {p}')
            data=p.read_bytes();records.append(dict(path=str(p.relative_to(ROOT)),bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),group=top))
    groups={g:sum(q['group']==g for q in records) for g in sorted(set(q['group'] for q in records))}
    OUT.write_text(json.dumps(dict(format_version=1,file_count=len(records),groups=groups,files=records),indent=2)+'\n')
    text='''# Ancillary-file manifest

`ANCILLARY_MANIFEST.json` lists the relative path, byte size and SHA-256 of each indexed script, audit record, raw output, draft formalization and historical snapshot. The manifest excludes itself, Git internals, cached bytecode and TeX auxiliaries. Current and historical material are distinct.

## Reproduction

From the repository root:

```sh
python -m pip install -r requirements.txt
python tools/run_checks.py --output /tmp/sq-dc-checks
python tools/run_checks.py --output /tmp/sq-dc-checks-with-caps --caps
python tools/build_paper.py --bibtex
python tools/check_sources.py
python -m pip install -r requirements-dev.txt
python tools/package_submission.py --output dist
```

The first check command reruns the finite ledgers, retained constants and algebra, affine certificates and the keyed median sweep. The second also reruns the slower keyed cap sweep. Both create fresh working directories and preserve prior raw outputs. Seeds, keys and tolerance parameters are specified in the scripts, paper and output manifests. Wall-clock measurements vary with the host.

The current paper is the mathematical specification. The historical snapshots preserve prior work, including failed approaches and the old SGD experiments; they do not override corrected statements. `formalization/STATUS.md` records the uncompiled status and exact coverage of the Lean drafts.

The compilation-only arXiv archive excludes these ancillary directories. The complete Git bundle and repository ZIP include them. No license or public submission is selected automatically.

## Indexed groups

| Group | Files |
|---|---:|
'''
    text+=''.join(f'| `{g}/` | {n} |\n' for g,n in groups.items())
    (ROOT/'docs/ANCILLARY_MANIFEST.md').write_text(text)
    print(f'Indexed {len(records)} ancillary files: {groups}')
if __name__=='__main__':main()
