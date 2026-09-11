# Formalization status

These are the actual earlier Lean source drafts recovered from this project's archives. They are preserved for continuation, not offered as a machine-checked proof of the paper. Their statement names refer to earlier numbering; see the source comments and the paper's numbering map.

The project pins Mathlib in `lakefile.toml` and a Lean toolchain in `lean-toolchain`. A fresh attempt in this revision found no `lake` executable. Fetching the elan bootstrap failed at DNS resolution for raw.githubusercontent.com. No compilation, no-sorry audit, or axiom audit completed.

Build in a networked environment after installing elan:

```sh
cd formalization
lake update
lake build
```

A successful build and statement comparison are required before citing these files as formal verification. The archived sources do not cover the complete query lower bound or the complete paper.
