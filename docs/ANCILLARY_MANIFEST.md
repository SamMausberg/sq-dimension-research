# Ancillary-file manifest

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
| `audits/` | 91 |
| `docs/` | 9 |
| `experiments/` | 41 |
| `formalization/` | 7 |
| `history/` | 677 |
| `tools/` | 6 |
