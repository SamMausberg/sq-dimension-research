# Repository guide

## Reading paths

- **Read the research:** `paper/paper.pdf`, then `paper/summary.tex` and the relevant
  proofs under `paper/appendices/`.
- **Assess the evidence:** `VERIFICATION.md`, `audits/citation-titles-2026-09-11/README.md`,
  `audits/setup-2026-09-11/README.md`,
  `audits/current/NEW_RESULT_LEDGER.md`, and `formalization/COVERAGE.md`.
- **Reproduce or develop:** `docs/REPRODUCIBILITY.md`, `CONTRIBUTING.md`, and `tools/`.
- **Trace an idea:** `docs/TOPIC_INDEX.md`, then the specific snapshot in `history/`.
- **Prepare publication:** `submission/PRE_SUBMISSION_CHECKLIST.md` and
  `LICENSE_STATUS.md`; repository setup does not resolve the remaining scholarly
  or publication decisions.

## Layout

```text
sq-dimension-research/
├── README.md                  Research entry point
├── CITATION.cff               Machine-readable citation with preferred manuscript citation
├── LICENSE                   All-rights-reserved notice
├── CONTRIBUTING.md            Research and review conventions
├── requirements*.txt          Python dependency pins
├── pyproject.toml             Active-code formatting and lint rules
├── Makefile                   Convenience commands; Python equivalents are documented
├── .github/                   CI and repository ownership
├── paper/
│   ├── paper.tex              Sole current manuscript entry point
│   ├── paper.pdf              Retained reading copy
│   ├── sections/              Main argument
│   ├── appendices/            Deferred proofs and supporting material
│   └── figures/               Editable native TikZ source
├── experiments/
│   ├── current/               Revision 8 finite checks
│   ├── *.py                   Active shared experiments and oracle simulators
│   └── results/               Retained reference data
├── formalization/             Lean proofs, configuration, lockfile, and axiom audit
├── tools/                     Reproduction, builds, source checks, integrity, packaging
├── tests/                     Verification-tool regressions
├── audits/
│   ├── citation-titles-2026-09-11/  Latest citation/title and PDF checks
│   ├── setup-2026-09-11/      Fresh setup evidence
│   ├── current/               Original revision 8 ledgers and records
│   └── prior/                 Earlier reviews
├── docs/                      Guides, topic index, previews, provenance, manifest
├── submission/                Prepared publication text and author checklist
└── history/turn01…turn07/      Preserved prior source snapshots
```

## Preservation rules

Current Python sources are formatted consistently with Ruff. Historical code is
kept exactly as archived. The existing experiment filenames remain stable because
reproduction scripts and historical references use them. Aesthetic renaming would
make those references harder to follow.

Generated virtual environments, Lake caches, TeX auxiliaries, and temporary runs
are ignored by Git. Use `work/` for local experiments and `dist/` for locally
packaged submission files. New verification evidence goes in a dated audit folder;
old logs are never silently relabeled as current results.
