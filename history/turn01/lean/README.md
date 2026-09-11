# Formalization status: UNCOMPILED SOURCE DRAFT

No successful compiler run took place. Neither `lean` nor `lake` is installed in
this execution environment. Fetching a toolchain also failed because the
container could not resolve external hosts. See `../logs/lean_build.log`.

The source contains definitions for finite probability distributions, strict dc,
bounded SQ queries, real-response adaptive decision trees, history-dependent
valid oracles, and distribution-independent deterministic and arbitrary-seed
randomized learning. It includes proof-script drafts for the finite counting
consequence of Lemma 1, the algebraic consequence of Theorem 2, the query
decomposition, and the scalar ReLU identity in Proposition 8.

The main spectral and coupling theorems are NOT formalized. This is not a
machine-checked formalization of the paper. No `sorry` or extra axioms were
intentionally introduced, but an uncompiled source is not a verified artifact.

Target toolchain: `leanprover/lean4:v4.34.0-rc2`, read from the official Mathlib
master lean-toolchain on 2026-09-10. The dependency currently tracks master,
NOT a locked commit. A future successful build must preserve lake-manifest.json
and record its Mathlib commit before it is called reproducible.

On a machine with the specified Lean toolchain and network access:

    lake update
    lake exe cache get
    lake build
    lake env lean SQDC.lean

These are build instructions, not claims that these commands succeeded here.
