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
TRUSTED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}
DECLARATION = re.compile(
    r"^\s*(?:@\[[^\]]*\]\s*)?(?:private\s+|protected\s+)?(?:theorem|lemma)\s+([\w.'₀-₉]+)",
    re.MULTILINE,
)


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


def module_name(path: Path) -> str:
    return ".".join(path.relative_to(ROOT).with_suffix("").parts)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Write a JSON verification report")
    args = parser.parse_args()
    if args.output:
        args.output.unlink(missing_ok=True)
    sources = [ROOT / "SQDC.lean", *sorted((ROOT / "SQDC").glob("**/*.lean"))]
    modules = {module_name(path) for path in sources}
    root_imports = set(
        re.findall(r"^import\s+(\S+)", (ROOT / "SQDC.lean").read_text(), re.MULTILINE)
    )
    if root_imports != modules - {"SQDC"}:
        raise SystemExit(
            f"SQDC.lean must import every module: missing={sorted(modules - {'SQDC'} - root_imports)}"
        )
    for path in sources:
        text = path.read_text(encoding="utf-8")
        if re.search(r"^\s*axiom\s", text, re.MULTILINE) or re.search(r"\bsorry\b", text):
            raise SystemExit(f"Axiom declaration or proof hole in {path.relative_to(ROOT)}")
    expected = {
        (module_name(path), name)
        for path in sources
        for name in DECLARATION.findall(path.read_text(encoding="utf-8"))
    }
    if not expected:
        raise SystemExit("No theorem declarations found in active sources")
    version = run("lake", "env", "lean", "--version").strip()
    run("lake", "build", "SQDC")
    output = run("lake", "env", "lean", "-DwarningAsError=true", "AxiomAudit.lean")
    audited: dict[str, dict] = {}
    for name, module, axioms in re.findall(r"AXIOMS (\S+) (\S+): \[([^]]*)\]", output):
        audited[name] = dict(
            module=module,
            axioms=sorted(filter(None, (item.strip() for item in axioms.split(",")))),
        )
    declaration_counts = re.findall(r"AUDITED_DECLARATIONS=(\d+)", output)
    if len(declaration_counts) != 1 or int(declaration_counts[0]) != len(audited):
        raise SystemExit("Compiler declaration audit is missing or incomplete")
    missing = sorted(
        f"{module}:{short}"
        for module, short in expected
        if not any(
            info["module"] == module and (name == short or name.endswith("." + short))
            for name, info in audited.items()
        )
    )
    if missing:
        raise SystemExit(f"Source theorems absent from the axiom audit: {missing}")
    for name, info in audited.items():
        unexpected = set(info["axioms"]) - TRUSTED_AXIOMS
        if unexpected:
            raise SystemExit(f"Unapproved axioms in {name}: {sorted(unexpected)}")
    manifest = json.loads((ROOT / "lake-manifest.json").read_text(encoding="utf-8"))
    mathlib = next(package for package in manifest["packages"] if package["name"] == "mathlib")
    report = {
        "status": "passed",
        "lean_version": version,
        "mathlib_revision": mathlib["rev"],
        "targets": ["SQDC"],
        "modules": sorted(modules),
        "warnings_as_errors": True,
        "source_theorem_count": len(expected),
        "compiler_theorem_declarations_audited": len(audited),
        "axioms": {name: audited[name] for name in sorted(audited)},
        "source_sha256": {
            path.relative_to(ROOT).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in [
                *sources,
                ROOT / "AxiomAudit.lean",
                ROOT / "lakefile.toml",
                ROOT / "lean-toolchain",
                ROOT / "lake-manifest.json",
                ROOT / "verify.py",
            ]
        },
        "scope": (
            f"{len(expected)} supporting theorems for finite steps of the paper; "
            "not a formal verification of the full paper."
        ),
    }
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(
        f"Verified {len(expected)} source theorems ({len(audited)} compiler declarations); "
        "all axioms are in the trusted allowlist."
    )


if __name__ == "__main__":
    main()
