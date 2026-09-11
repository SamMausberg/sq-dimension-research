# Working on this research

Access to this private repository does not grant redistribution rights. Discuss
authorship, reuse permission, and any public release with Samuel Mausberg first.

- Edit the current manuscript in `paper/`, experiments in `experiments/`, and
  Lean sources in `formalization/`. Preserve existing theorem hypotheses and
  source attribution; explain any mathematical change explicitly in the review.
- Keep `history/` unchanged. Earlier snapshots are evidence of project development.
- Install `requirements-dev.txt`, run `make format` and `make lint`, then run the
  relevant research checks. Python commands in README work without Make.
- Use a fresh directory for each reproduction run. Retain seeds, parameters,
  exact arithmetic results, and failure records. Never label computation or
  source consistency as a proof of an unformalized theorem.
- Run `lake build SQDC Turn2` and the axiom audit when changing formalization.
  Document precisely which statements the checked Lean declarations cover.
- After intentional ancillary changes, regenerate `tools/make_manifest.py` and
  verify with `python tools/make_manifest.py --check`.

Do not commit virtual environments, dependency caches, access tokens, temporary
builds, or machine-specific paths. Pull requests should state what changed, why,
which commands passed, and which research questions remain unresolved.
