#!/usr/bin/env python3
"""Produce and test a compilation-only arXiv source archive.

The full Git bundle is a separate release artifact. This command never publishes,
sends mail, or selects a license. It uses no shell escape.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def build_package(args: argparse.Namespace, out: Path) -> dict:
    paper = ROOT / "paper"
    for required in ("paper.tex", "paper.bbl", "paper.pdf", "references.bib"):
        if not (paper / required).is_file():
            raise SystemExit(f"Missing {required}; run tools/build_paper.py first.")
    selected = sorted(
        p
        for p in paper.rglob("*")
        if p.is_file() and (p.suffix in {".tex", ".bib", ".bbl"} or p.name == "README.txt")
    )
    for path in selected:
        if path.suffix == ".tex":
            text = path.read_text(encoding="utf-8")
            if "/mnt/data/" in text or "/home/oai/" in text or "\\write18" in text:
                raise SystemExit(f"Nonportable TeX input: {path}")
    archive = out / "arxiv_submission.tar.gz"
    with tarfile.open(archive, "w:gz") as tar:
        for path in selected:
            tar.add(path, arcname=str(path.relative_to(paper)), recursive=False)
    compilation_report = out / "package_compilation.json"
    with tempfile.TemporaryDirectory(prefix="sq-dc-arxiv-") as temporary:
        clean = Path(temporary)
        with tarfile.open(archive, "r:gz") as tar:
            tar.extractall(clean, filter="data")
        subprocess.run(
            [
                sys.executable,
                str(ROOT / "tools/build_paper.py"),
                "--directory",
                str(clean),
                "--report",
                str(compilation_report),
            ],
            check=True,
        )
        report = json.loads(compilation_report.read_text(encoding="utf-8"))
        report.update(
            archive_sha256=sha256(archive),
            source_files=len(selected),
            entry_point="paper.tex",
            clean_extraction=True,
        )
        if not args.skip_render_compare:
            try:
                import fitz
            except ImportError as exc:
                raise SystemExit(
                    "Install requirements-dev.txt or use --skip-render-compare."
                ) from exc
            expected, actual = fitz.open(paper / "paper.pdf"), fitz.open(clean / "paper.pdf")
            if len(expected) != len(actual):
                raise RuntimeError("Clean archive page count differs from the release PDF.")
            matches = []
            for index in range(len(expected)):
                text_match = expected[index].get_text() == actual[index].get_text()
                a = expected[index].get_pixmap(matrix=fitz.Matrix(1, 1), alpha=False)
                b = actual[index].get_pixmap(matrix=fitz.Matrix(1, 1), alpha=False)
                pixel_match = a.width == b.width and a.height == b.height and a.samples == b.samples
                if not text_match or not pixel_match:
                    raise RuntimeError(f"Clean archive differs visually on page {index + 1}.")
                matches.append(dict(page=index + 1, text_match=True, pixel_match=True))
            report["all_page_texts_match"] = True
            report["all_page_pixels_match_72dpi"] = True
            report["page_comparisons"] = matches
        report["render_comparison"] = "skipped" if args.skip_render_compare else "passed"
    shutil.copy2(paper / "paper.pdf", out / "paper.pdf")
    shutil.copy2(paper / "paper.tex", out / "paper.tex")
    for path in (ROOT / "submission").iterdir():
        if path.is_file():
            shutil.copy2(path, out / path.name)
    return report


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist")
    parser.add_argument(
        "--skip-render-compare",
        action="store_true",
        help="Skip optional PyMuPDF pixel comparison; compilation is still checked.",
    )
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    report_path = out / "clean_package.json"
    report = dict(status="RUNNING", render_comparison_requested=not args.skip_render_compare)
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8", newline="\n")
    try:
        report.update(build_package(args, out))
    except BaseException as error:
        report.update(status="FAILED", error=f"{type(error).__name__}: {error}")
        report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8", newline="\n")
        raise
    report["status"] = "PASS"
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(
        f"PASS: {out / 'arxiv_submission.tar.gz'}; "
        f"{report['source_files']} sources; {report['pages']} pages."
    )


if __name__ == "__main__":
    main()
