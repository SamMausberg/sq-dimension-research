"""Regressions for false success, artifact mixing, and source-audit provenance."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tools import check_sources, make_manifest, run_checks


class CheckRunnerTests(unittest.TestCase):
    def test_nonempty_output_is_rejected_without_overwriting_prior_success(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary)
            prior = output / "run_manifest.json"
            prior.write_text('{"status": "PASS", "run_id": "previous"}', encoding="utf-8")
            old_bytes = prior.read_bytes()
            with self.assertRaisesRegex(ValueError, "not empty"):
                run_checks.run_checks(output)
            self.assertEqual(prior.read_bytes(), old_bytes)

    def test_failed_child_replaces_running_manifest_and_records_exit(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            constants = root / "history/turn06/checks/recompute_constants.py"
            constants.parent.mkdir(parents=True)
            constants.write_text("", encoding="utf-8")
            (root / "experiments").mkdir()
            output = root / "output"

            def failure(command, **kwargs):
                running = json.loads((output / "run_manifest.json").read_text(encoding="utf-8"))
                self.assertEqual(running["status"], "RUNNING")
                return subprocess.CompletedProcess(command, 9, "before failure\n", "check failed\n")

            with (
                patch.object(run_checks, "ROOT", root),
                patch.object(run_checks.subprocess, "run", side_effect=failure),
            ):
                with self.assertRaisesRegex(RuntimeError, "exit code 9"):
                    run_checks.run_checks(output, caps=True)
            report = json.loads((output / "run_manifest.json").read_text(encoding="utf-8"))
            self.assertEqual(report["status"], "FAILED")
            self.assertTrue(report["caps"])
            self.assertEqual(report["commands"][0]["exit_code"], 9)
            self.assertFalse((output / "results").exists())

    def test_preexecution_failure_has_failed_manifest(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            output = root / "output"
            with patch.object(run_checks, "ROOT", root):
                with self.assertRaises(FileNotFoundError):
                    run_checks.run_checks(output)
            report = json.loads((output / "run_manifest.json").read_text(encoding="utf-8"))
            self.assertEqual(report["status"], "FAILED")
            self.assertEqual(report["commands"], [])

    def test_child_environment_does_not_disable_assertions(self):
        with patch.dict(os.environ, {"PYTHONOPTIMIZE": "2"}):
            result = subprocess.run(
                [sys.executable, "-c", "assert False, 'assertions enabled'"],
                env=run_checks.child_environment(),
                capture_output=True,
                text=True,
            )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("assertions enabled", result.stderr)

    def test_optimized_driver_cannot_report_pass(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "optimized"
            result = subprocess.run(
                [
                    sys.executable,
                    "-O",
                    str(Path(run_checks.__file__).resolve()),
                    "--output",
                    str(output),
                ],
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("without Python -O", result.stderr)
            self.assertFalse((output / "run_manifest.json").exists())


class SourceAuditTests(unittest.TestCase):
    def test_release_seven_recovered_layout_is_selected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            paper = root / "history/turn07/paper"
            (paper / "sections").mkdir(parents=True)
            (paper / "appendices").mkdir()
            self.assertEqual(check_sources.baseline_directory(root), paper)

    def test_missing_release_seven_does_not_fall_back_to_six(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "history/turn06/sections").mkdir(parents=True)
            (root / "history/turn06/appendices").mkdir()
            with self.assertRaisesRegex(FileNotFoundError, "Release-7"):
                check_sources.baseline_directory(root)

    def test_utf8_sources_and_posix_paths_are_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            section = root / "sections/example.tex"
            section.parent.mkdir()
            section.write_text(
                "\\begin{theorem}[Mausberg's café]\n\\label{thm:test}Test.\\end{theorem}\n",
                encoding="utf-8",
            )
            records = check_sources.canonical(root)
            self.assertEqual(records[0]["title"], "Mausberg's café")
            self.assertEqual(records[0]["file"], "sections/example.tex")

    def test_failed_source_audit_overwrites_existing_pass_status(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "audit"
            output.mkdir()
            report = output / "source_consistency.json"
            report.write_text('{"status":"PASS"}', encoding="utf-8")
            result = subprocess.run(
                [
                    sys.executable,
                    "-O",
                    str(Path(check_sources.__file__).resolve()),
                    "--paper-directory",
                    str(Path(temporary) / "missing-paper"),
                    "--output",
                    str(output),
                ],
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(json.loads(report.read_text(encoding="utf-8"))["status"], "FAILED")


class PackageTests(unittest.TestCase):
    def test_render_failure_cannot_leave_package_pass_or_advertise_final_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            paper = root / "paper"
            paper.mkdir()
            for name in ("paper.tex", "paper.bbl", "paper.pdf", "references.bib"):
                (paper / name).write_text("placeholder", encoding="utf-8")
            output = root / "output"
            output.mkdir()
            report_path = output / "clean_package.json"
            report_path.write_text('{"status":"PASS"}', encoding="utf-8")
            script = f"""
import json
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
from tools import package_submission

root = Path({str(root)!r})
output = root / "output"

def compile_success(command, **kwargs):
    running = json.loads((output / "clean_package.json").read_text())
    assert running["status"] == "RUNNING"
    report = Path(command[command.index("--report") + 1])
    report.write_text(json.dumps(dict(status="PASS", pages=1)))
    return subprocess.CompletedProcess(command, 0)

fake_fitz = SimpleNamespace(open=lambda path: [None] if Path(path) == root / "paper/paper.pdf" else [])
with (
    patch.object(package_submission, "ROOT", root),
    patch.object(sys, "argv", ["package_submission.py", "--output", str(output)]),
    patch.object(subprocess, "run", side_effect=compile_success),
    patch.dict(sys.modules, {{"fitz": fake_fitz}}),
):
    package_submission.main()
"""
            process = subprocess.run(
                [sys.executable, "-X", "utf8", "-c", script],
                cwd=Path(__file__).resolve().parents[1],
                capture_output=True,
                text=True,
                encoding="utf-8",
            )
            self.assertNotEqual(process.returncode, 0)
            self.assertIn("page count differs", process.stderr)
            report = json.loads(report_path.read_text(encoding="utf-8"))
            self.assertEqual(report["status"], "FAILED")
            self.assertTrue(report["render_comparison_requested"])
            self.assertNotIn("PASS:", process.stdout)
            self.assertFalse((output / "paper.pdf").exists())
            self.assertFalse((output / "paper.tex").exists())
            compilation = json.loads((output / "package_compilation.json").read_text())
            self.assertEqual(compilation["status"], "PASS")


@unittest.skipUnless(shutil.which("git"), "Manifest membership requires Git.")
class ManifestTests(unittest.TestCase):
    def test_inventory_ignores_dependencies_and_detects_untracked_additions(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            subprocess.run(["git", "init", "--quiet", str(root)], check=True, capture_output=True)
            (root / ".gitignore").write_text("formalization/.lake/\nwork/\n", encoding="utf-8")
            source = root / "experiments/check.py"
            source.parent.mkdir()
            source.write_text("print('café')\n", encoding="utf-8")
            cache = root / "formalization/.lake/packages/mathlib/source.lean"
            cache.parent.mkdir(parents=True)
            cache.write_text("ignored dependency", encoding="utf-8")
            records = make_manifest.inventory(root)
            self.assertEqual([r["path"] for r in records], ["experiments/check.py"])
            expected = dict(file_count=1, groups={"experiments": 1}, files=records)
            make_manifest.check_manifest(expected, records)
            (root / "experiments/addition.py").write_text("pass\n", encoding="utf-8")
            with self.assertRaisesRegex(RuntimeError, "addition.py"):
                make_manifest.check_manifest(expected, make_manifest.inventory(root))
            source.write_text("changed\n", encoding="utf-8")
            with self.assertRaisesRegex(RuntimeError, "changed"):
                make_manifest.check_manifest(expected, make_manifest.inventory(root))

    def test_manifest_rejects_removed_or_duplicate_records(self):
        row = dict(path="tools/a.py", bytes=1, sha256="unused", group="tools")
        with self.assertRaisesRegex(RuntimeError, "removed"):
            make_manifest.check_manifest(dict(file_count=1, groups={"tools": 1}, files=[row]), [])
        with self.assertRaisesRegex(RuntimeError, "duplicate"):
            make_manifest.check_manifest(dict(files=[row, row]), [row])


if __name__ == "__main__":
    unittest.main()
