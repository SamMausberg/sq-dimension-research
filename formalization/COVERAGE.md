# Formalization draft coverage

**Uncompiled source only.** This table describes the source text, not successful theorem checking.

| Source | Definitions or proof-script drafts | Current mathematical location |
|---|---|---|
| `SQDC.lean` | finite distributions, Boolean loss, bounded SQ queries, adaptive real-response trees, valid policies, deterministic/randomized learning, strict dimension | Definitions in Section 2 |
| `SQDC.lean` | `finite_energy_count`, `barrier_algebra` | Lemma 25 and the algebraic consequence of Theorem 26 |
| `SQDC.lean` | query decomposition and scalar ReLU odd-part identity | Theorem 29's decomposition; historical shallow-network argument |
| `Turn2.lean` | `L1_peeling_error`, `L1_peeling_budget` | Finite partition accounting in Theorem 1 |
| `Turn2.lean` | `L2_elimination_potential` | Elimination potential in Theorem 1 |
| `Turn2.lean` | `L3_preserves_positive_rectangle` | Monotone-flip step in Theorem 4 |
| `Turn2.lean` | `L4_two_grid_lines` | Integer-line intersection fact used throughout |

The cap construction, probabilistic counting, succinct algorithm, PRF reduction, engineered simulation, and new query lower bound are not fully formalized in these files. The proof scripts contain no intentional `sorry` declarations, but text scanning cannot replace compilation and an axiom audit. Original numbering is preserved in historical source comments.
