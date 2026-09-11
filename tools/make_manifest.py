#!/usr/bin/env python3
"""Generate or verify an ancillary-file manifest, respecting Git ignore rules."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = "docs/ANCILLARY_MANIFEST.json"
GROUPS = {"experiments", "audits", "formalization", "history", "tools", "docs", "tests"}
EXCLUDED_PARTS = {".git", ".lake", ".venv", "__pycache__", ".ruff_cache", ".pytest_cache"}
EXCLUDED_SUFFIXES = {".aux", ".out", ".toc", ".blg", ".pyc"}
FONT_SUFFIXES = {".ttf", ".otf", ".woff", ".woff2", ".pfb", ".pfa"}


def inventory(root: Path) -> list[dict]:
    # Include untracked additions so --check also detects files awaiting staging.
    # Git's ignore rules exclude installed dependencies and local rerun outputs.
    result = subprocess.run(
        ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
        cwd=root,
        capture_output=True,
        check=True,
    )
    paths = sorted(set(result.stdout.decode("utf-8").split("\0")) - {""})
    records = []
    for name in paths:
        relative = Path(name)
        if relative.parts[0] not in GROUPS:
            continue
        if name == MANIFEST:
            continue
        if EXCLUDED_PARTS.intersection(relative.parts):
            continue
        if relative.suffix in EXCLUDED_SUFFIXES or name.endswith(".synctex.gz"):
            continue
        path = root / relative
        if path.is_symlink():
            raise RuntimeError(f"Ancillary symlink cannot be indexed safely: {name}")
        if not path.is_file():
            raise RuntimeError(f"Tracked ancillary file is missing: {name}")
        if relative.suffix.lower() in FONT_SUFFIXES:
            raise RuntimeError(f"Font binary is not an ancillary source: {name}")
        data = path.read_bytes()
        records.append(
            dict(
                path=relative.as_posix(),
                bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest(),
                group=relative.parts[0],
            )
        )
    return records


def check_manifest(expected: dict, records: list[dict]) -> None:
    stored = expected.get("files", [])
    if len({item["path"] for item in stored}) != len(stored):
        raise RuntimeError("Manifest contains duplicate paths.")
    actual = {item["path"]: item for item in records}
    previous = {item["path"]: item for item in stored}
    added = sorted(actual.keys() - previous.keys())
    removed = sorted(previous.keys() - actual.keys())
    changed = sorted(
        name for name in actual.keys() & previous.keys() if actual[name] != previous[name]
    )
    counts = dict(sorted(Counter(item["group"] for item in records).items()))
    count_mismatch = expected.get("file_count") != len(records) or expected.get("groups") != counts
    if added or removed or changed or count_mismatch:
        raise RuntimeError(
            json.dumps(
                dict(
                    added=added,
                    removed=removed,
                    changed=changed,
                    count_mismatch=count_mismatch,
                ),
                indent=2,
            )
        )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check", action="store_true", help="Verify hashes and file membership without writing."
    )
    args = parser.parse_args()
    records = inventory(ROOT)
    if args.check:
        check_manifest(json.loads((ROOT / MANIFEST).read_text(encoding="utf-8")), records)
        print(f"PASS: {len(records)} ancillary files match the manifest.")
        return
    groups = dict(sorted(Counter(item["group"] for item in records).items()))
    (ROOT / MANIFEST).write_text(
        json.dumps(
            dict(
                format_version=2,
                file_count=len(records),
                groups=groups,
                files=records,
            ),
            indent=2,
        )
        + "\n",
        encoding="utf-8",
        newline="\n",
    )
    print(f"Indexed {len(records)} ancillary files: {groups}")


if __name__ == "__main__":
    main()
