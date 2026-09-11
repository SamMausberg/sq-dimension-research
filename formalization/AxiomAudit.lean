import Lean
import Turn2

/-!
Audit every theorem in the active partial formalization.

Run `lake env lean AxiomAudit.lean` after `lake build SQDC Turn2` to print the
transitive axioms of the current compiled declarations. The companion verifier
rejects proof holes and any axioms outside Lean's ordinary trusted assumptions.
-/

#print axioms SQDC.query_decomposition
#print axioms SQDC.finite_energy_count
#print axioms SQDC.barrier_algebra
#print axioms SQDC.relu_odd_part
#print axioms SQDC.Turn2.L1_peeling_error
#print axioms SQDC.Turn2.L1_peeling_budget
#print axioms SQDC.Turn2.L2_elimination_potential
#print axioms SQDC.Turn2.L3_preserves_positive_rectangle
#print axioms SQDC.Turn2.L4_two_grid_lines

-- Also inspect every compiler theorem declaration from the two local modules,
-- including private theorems, attributed declarations, and generated helpers.
open Lean in
run_cmd do
  let env := (← getEnv).setExporting false
  let modules : Array Name := #[`SQDC, `Turn2]
  let allowed : Array Name := #[`propext, `Classical.choice, `Quot.sound]
  let moduleNames := env.header.moduleNames
  for modName in modules do
    if (env.getModuleIdx? modName).isNone then
      throwError "Missing audited module: {modName}"
  let mut audited : Nat := 0
  for (name, info) in env.constants do
    if info.isTheorem then
      let some idx := env.getModuleIdxFor? name | continue
      if modules.contains moduleNames[idx]! then
        let axioms ← collectAxioms name
        let unexpected := axioms.filter fun ax => !allowed.contains ax
        unless unexpected.isEmpty do
          throwError "Unapproved axioms in {name}: {unexpected.toList}"
        audited := audited + 1
  if audited == 0 then
    throwError "No theorem declarations found in audited modules"
  logInfo m!"AUDITED_DECLARATIONS={audited}"
