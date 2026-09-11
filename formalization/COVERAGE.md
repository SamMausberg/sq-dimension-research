# Formalization coverage

**Both modules compile, and all nine named lemmas pass the axiom audit.** The formalization verifies the supporting facts below. It does not verify the complete paper or establish the upstream hypotheses of its conditional lemmas. Build evidence and reproduction commands are in [STATUS.md](STATUS.md).

| Source | Checked definition or theorem | Mathematical scope |
|---|---|---|
| `SQDC.lean` | Finite distributions, Boolean loss, bounded SQ queries, adaptive real-response trees, valid policies, deterministic/randomized learning, strict dimension | Definitions in Section 2; definitions alone are not correctness or existence theorems |
| `SQDC.lean` | `query_decomposition` | Boolean-query algebraic decomposition used in Theorem 29 |
| `SQDC.lean` | `finite_energy_count` | Finite counting consequence of Lemma 25; assumes the energy bound |
| `SQDC.lean` | `barrier_algebra` | Algebraic consequence of Theorem 26; assumes the coupling-derived inequality |
| `SQDC.lean` | `relu_odd_part` | Elementary scalar identity from the historical shallow-network argument |
| `Turn2.lean` | `L1_peeling_error`, `L1_peeling_budget` | Finite partition accounting in Theorem 1; the budget result assumes the per-piece and residual bounds |
| `Turn2.lean` | `L2_elimination_potential` | Elimination-potential estimate in Theorem 1; assumes positivity and the stated recurrence |
| `Turn2.lean` | `L3_preserves_positive_rectangle` | Preservation under monotone flips in Theorem 4; no rectangle existence or size bound |
| `Turn2.lean` | `L4_two_grid_lines` | Integer affine-line intersection fact used throughout |

The cap construction, probabilistic counting, complete rectangle learner, succinct algorithm, PRF reduction, engineered simulation, and new query lower bound are not fully formalized. The spectral energy estimate and adaptive-coupling argument are not established by these files. The coordinate-embedding existence proof needed to justify the intended dimension interpretation also remains absent.

The SQ learning predicates permit arbitrary real tolerance parameters. Any future learning theorem must supply the appropriate nonnegative-tolerance assumptions; a negative tolerance permits vacuous oracle quantification. This does not affect the nine checked supporting lemmas.

Original theorem names and inherited parameters are preserved for compatibility with the archived sources. The axiom audit covers 30 compiler theorem declarations, including generated helpers, and permits only `propext`, `Classical.choice`, and `Quot.sound`. The full paper still requires independent mathematical review.
