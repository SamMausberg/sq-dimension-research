#!/usr/bin/env python3
"""Build all active Lean proofs and check every theorem's transitive axioms."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCES = {"SQDC.lean": "SQDC", "Turn2.lean": "SQDC.Turn2"}
TRUSTED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def run(*args: str) -> str:
    result = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    print(result.stdout, end="", flush=True)
    if result.returncode:
        raise SystemExit(result.returncode)
    return result.stdout


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Write a JSON verification report")
    args = parser.parse_args()
    if args.output:
        args.output.unlink(missing_ok=True)
    expected = {
        f"{namespace}.{name}"
        for filename, namespace in SOURCES.items()
        for name in re.findall(
            r"^\s*(?:theorem|lemma)\s+(\w+)",
            (ROOT / filename).read_text(encoding="utf-8"),
            re.MULTILINE,
        )
    }
    if not expected:
        raise SystemExit("No theorem declarations found in active sources")
    version = run("lake", "env", "lean", "--version").strip()
    run("lake", "build", "SQDC", "Turn2")
    output = run("lake", "env", "lean", "-DwarningAsError=true", "AxiomAudit.lean")
    audited = {
        name: sorted(filter(None, (item.strip() for item in axioms.split(","))))
        for name, axioms in re.findall(r"'([^']+)' depends on axioms:\s*\[([^]]*)\]", output)
    }
    for name in re.findall(r"'([^']+)' does not depend on any axioms", output):
        audited[name] = []
    declaration_counts = re.findall(r"AUDITED_DECLARATIONS=(\d+)", output)
    if len(declaration_counts) != 1 or int(declaration_counts[0]) < len(expected):
        raise SystemExit("Compiler declaration audit is missing or incomplete")
    if set(audited) != expected:
        raise SystemExit(
            f"Axiom audit coverage mismatch: missing={sorted(expected - set(audited))}, "
            f"unexpected={sorted(set(audited) - expected)}"
        )
    for name, axioms in audited.items():
        unexpected = set(axioms) - TRUSTED_AXIOMS
        if unexpected:
            raise SystemExit(f"Unapproved axioms in {name}: {sorted(unexpected)}")
    manifest = json.loads((ROOT / "lake-manifest.json").read_text(encoding="utf-8"))
    mathlib = next(package for package in manifest["packages"] if package["name"] == "mathlib")
    report = {
        "status": "passed",
        "lean_version": version,
        "mathlib_revision": mathlib["rev"],
        "targets": ["SQDC", "Turn2"],
        "warnings_as_errors": True,
        "theorem_count": len(audited),
        "compiler_theorem_declarations_audited": int(declaration_counts[0]),
        "axioms": audited,
        "source_sha256": {
            name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
            for name in [
                *SOURCES,
                "AxiomAudit.lean",
                "lakefile.toml",
                "lean-toolchain",
                "lake-manifest.json",
                "verify.py",
            ]
        },
        "scope": f"{len(audited)} supporting lemmas; not a formal verification of the full paper.",
    }
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Verified {len(audited)} theorems; all axioms are in the trusted allowlist.")


if __name__ == "__main__":
    main()
