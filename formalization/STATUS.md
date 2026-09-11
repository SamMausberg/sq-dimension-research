# Lean verification

**Passed on 2026-09-11.** Both active libraries, `SQDC` and `Turn2`, compile. All nine named supporting lemmas pass the axiom audit. This is a partial formalization; it is not a machine-checked proof of the complete paper. See [COVERAGE.md](COVERAGE.md).

The verified environment uses:

- Lean `4.34.0-rc2`, commit `6a10ac8c22beadecabdbb0919c2b50214762f91d`.
- Lake `5.0.0-src+6a10ac8`.
- Mathlib `2631d1cc8c2ace6c6a900425d6e5d2b5963966e9`.
- Eight transitive packages, all pinned in [lake-manifest.json](lake-manifest.json).

Validation ran in native WSL Ubuntu storage. SHA-256 checks confirm that every verified Lean source and configuration file matches the delivered repository. The [verification report](../audits/setup-2026-09-11/lean/verification.json), [build log](../audits/setup-2026-09-11/lean/build.log), and [statement comparison](../audits/setup-2026-09-11/lean/statement_comparison.json) record the result. The earlier unavailable-toolchain log is preserved in [audits/prior/lean-unavailable.log](../audits/prior/lean-unavailable.log).

## Reproduce

With elan and Python installed, run from this directory:

```sh
lake exe cache get \
  Mathlib.Analysis.SpecialFunctions.Sqrt \
  Mathlib.MeasureTheory.Integral.Bochner.Basic \
  Mathlib.Tactic.Linarith \
  Mathlib.Tactic.Ring \
  Mathlib.Analysis.SpecialFunctions.Log.Basic
python3 verify.py --output ../work/lean-verification.json
```

The committed toolchain and manifest select the exact versions. The cache command retrieves the 2,594 Mathlib/dependency modules needed by the current imports. `verify.py` builds both local libraries and runs [AxiomAudit.lean](AxiomAudit.lean); any build failure, missing audit coverage, or unapproved axiom returns a nonzero status. A failed rerun removes its previous output report.

## Proof and axiom checks

The audit prints all nine named lemmas and independently inspects every theorem declaration defined in the two local modules, including private declarations and compiler-generated helpers. The current compiler inventory contains 30 theorem declarations. None depends on `sorryAx` or a custom axiom. `L3_preserves_positive_rectangle` uses no axioms; the other eight named lemmas use only Lean's ordinary `propext`, `Classical.choice`, and `Quot.sound` assumptions.

Warnings are treated as errors. Two local `unusedSectionVars` style-linter exceptions retain the original inherited instance parameters of `query_decomposition` and `L1_peeling_error`; proof-hole warnings remain errors. All nine theorem statements and proof bodies are unchanged apart from whitespace. Imports, comments, and audit organization were updated.
