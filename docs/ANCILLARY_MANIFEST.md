# Ancillary-file manifest

`ANCILLARY_MANIFEST.json` records the relative POSIX path, byte size and SHA-256
of each indexed script, audit record, raw output, formalization and historical
snapshot. The index follows Git's tracked and nonignored files in the groups
below. It excludes the manifest pair, dependency/cache directories and TeX
auxiliaries. Historical material remains separate from current sources.

## Reproduction

From the repository root, after installing `requirements-dev.txt`:

```sh
python tools/run_checks.py --output work/checks
python tools/run_checks.py --output work/checks-with-caps --caps
python tools/build_paper.py --bibtex --report work/paper/build.json
python tools/check_sources.py --output work/paper/sources
python tools/package_submission.py --output dist
python tools/make_manifest.py --check
```

Each check output directory must be new or empty. Check commands write an explicit
RUNNING, FAILED or PASS manifest; existing results are never merged. The optional
cap sweep and the default finite/median checks are reported separately. Exact
arithmetic, numerical checks and elapsed times have their respective limitations.

See `formalization/STATUS.md` for the current compiler result and
`formalization/COVERAGE.md` for precisely which claims are formalized. A successful
build does not establish the entire paper. Historical snapshots do not override
the current manuscript. See the root license and citation files for current rights
and attribution terms; packaging does not publish or submit the paper.

After intentional source changes, regenerate this index with
`python tools/make_manifest.py`, review the diff, then rerun `--check`. Ignored
local outputs are not part of the research record unless explicitly added to Git.

## Indexed groups

| Group | Files |
|---|---:|
| `audits/` | 209 |
| `docs/` | 11 |
| `experiments/` | 41 |
| `formalization/` | 9 |
| `history/` | 677 |
| `tests/` | 1 |
| `tools/` | 6 |
