import Lean
import SQDC

/-!
Audit every theorem declared in the `SQDC` modules.

Run `lake env lean AxiomAudit.lean` after `lake build SQDC`. Every compiler theorem
declaration from a module under `SQDC` is inspected, including private theorems,
attributed declarations, and generated helpers. The command fails on any axiom
outside Lean's ordinary trusted assumptions; `sorryAx` is therefore rejected too.
The companion verifier checks that every source-level theorem was audited.
-/

open Lean in
run_cmd do
  let env := (← getEnv).setExporting false
  let allowed : Array Name := #[`propext, `Classical.choice, `Quot.sound]
  let moduleNames := env.header.moduleNames
  let modules := moduleNames.filter fun m => (`SQDC).isPrefixOf m
  if modules.size < 2 then
    throwError "Missing audited modules: {modules.toList}"
  let mut audited : Nat := 0
  for (name, info) in env.constants do
    if info.isTheorem then
      let some idx := env.getModuleIdxFor? name | continue
      if (`SQDC).isPrefixOf moduleNames[idx]! then
        let axioms ← collectAxioms name
        let unexpected := axioms.filter fun ax => !allowed.contains ax
        unless unexpected.isEmpty do
          throwError "Unapproved axioms in {name}: {unexpected.toList}"
        logInfo m!"AXIOMS {name} {moduleNames[idx]!}: {axioms.toList}"
        audited := audited + 1
  if audited == 0 then
    throwError "No theorem declarations found in audited modules"
  logInfo m!"AUDITED_MODULES={modules.toList}"
  logInfo m!"AUDITED_DECLARATIONS={audited}"
