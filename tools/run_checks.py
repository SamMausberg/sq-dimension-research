#!/usr/bin/env python3
"""Run the finite research checks in isolated directories with explicit outcomes."""

from __future__ import annotations

import argparse
import importlib.metadata
import json
import os
import platform
import shutil
import subprocess
import sys
import tempfile
import uuid
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def write_manifest(output: Path, report: dict) -> None:
    temporary = output / "run_manifest.json.tmp"
    temporary.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8", newline="\n")
    temporary.replace(output / "run_manifest.json")


def child_environment() -> dict[str, str]:
    env = os.environ.copy()
    # Retained scripts use assert for mathematical regressions. Never allow an
    # inherited optimization setting to remove them in a child interpreter.
    env.update(
        OMP_NUM_THREADS="1",
        OPENBLAS_NUM_THREADS="1",
        MKL_NUM_THREADS="1",
        PYTHONOPTIMIZE="0",
        PYTHONUTF8="1",
    )
    return env


def prepare_output(output: Path) -> Path:
    output = output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if any(output.iterdir()):
        raise ValueError(
            f"Output directory is not empty: {output}. Choose a new directory; "
            "existing results are never merged or overwritten."
        )
    return output


def run_checks(output: Path, caps: bool = False) -> dict:
    if not __debug__:
        raise RuntimeError("Verification must run without Python -O/-OO or PYTHONOPTIMIZE.")
    output = prepare_output(output)
    versions = {}
    for package in ("numpy", "scipy", "mpmath", "threadpoolctl"):
        try:
            versions[package] = importlib.metadata.version(package)
        except importlib.metadata.PackageNotFoundError:
            versions[package] = None
    report = dict(
        status="RUNNING",
        run_id=uuid.uuid4().hex,
        started_at=datetime.now(timezone.utc).isoformat(),
        caps=caps,
        python=platform.python_version(),
        platform=platform.platform(),
        dependencies=versions,
        assertions_enabled=True,
        commands=[],
        scope="Finite exact and numerical checks; not a full proof or a Lean build.",
    )
    write_manifest(output, report)

    def run(script: str, cwd: Path, log_name: str, *arguments: str) -> None:
        command = [sys.executable, "-X", "utf8", script, *arguments]
        record = dict(command=command, log=log_name, exit_code=None)
        report["commands"].append(record)
        write_manifest(output, report)
        process = subprocess.run(
            command,
            cwd=cwd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            env=child_environment(),
        )
        (output / log_name).write_text(
            process.stdout + process.stderr, encoding="utf-8", newline="\n"
        )
        record["exit_code"] = process.returncode
        write_manifest(output, report)
        if process.returncode:
            raise RuntimeError(f"{log_name}: failed with exit code {process.returncode}")

    try:
        with tempfile.TemporaryDirectory(prefix="sq-dc-check-") as temporary:
            work = Path(temporary)
            (work / "checks").mkdir()
            (work / "experiments").mkdir()
            shutil.copy2(ROOT / "history/turn06/checks/recompute_constants.py", work / "checks")
            for path in (ROOT / "experiments").glob("*.py"):
                shutil.copy2(path, work / "experiments")
            run(
                str(ROOT / "experiments/current/check_late_results.py"),
                work,
                "late_results.log",
                "--output",
                str(output / "late_results.json"),
            )
            run("checks/recompute_constants.py", work, "constants.log")
            for name in ("algebra_and_stress.py", "affine_checks.py"):
                run("experiments/" + name, work, name + ".log")
            run(
                "experiments/seeded_fast.py",
                work,
                "seeded_fast.log",
                "--N",
                "2",
                "3",
                "4",
                "5",
                "6",
                "7",
                "8",
                "16",
                "32",
            )
            if caps:
                run("experiments/run_keyed_caps.py", work, "keyed_caps.log")
            shutil.copy2(work / "checks/constants.json", output / "core_constants.json")
            shutil.copytree(work / "experiments/results", output / "results")
    except BaseException as error:
        report.update(
            status="FAILED",
            error=f"{type(error).__name__}: {error}",
            finished_at=datetime.now(timezone.utc).isoformat(),
        )
        write_manifest(output, report)
        raise
    report.update(status="PASS", finished_at=datetime.now(timezone.utc).isoformat())
    write_manifest(output, report)
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "work/checks",
        help="New or empty directory for this run; prior results are preserved.",
    )
    parser.add_argument(
        "--caps", action="store_true", help="Also rerun the slower keyed cap sweep."
    )
    args = parser.parse_args()
    report = run_checks(args.output, args.caps)
    print(f"PASS: {len(report['commands'])} commands. Results: {args.output.resolve()}")


if __name__ == "__main__":
    main()
