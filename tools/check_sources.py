#!/usr/bin/env python3
"""Statement inventory, cross-reference integrity, and Lean citation consistency.

Checks the modular manuscript (paper.tex, main.tex, appendices.tex), its
self-contained copy paper_single.tex, the bibliography, and every paper label
cited by the Lean formalization. This checks source bindings, not proof validity.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = ("main.tex", "appendices.tex")
PAT = re.compile(
    r"\\begin\{(theorem|lemma|proposition|corollary|remark|definition)\}"
    r"(?:\[([^\]]*)\])?([\s\S]*?)\\end\{\1\}"
)
REF = re.compile(r"\\(?:[Cc]ref|ref|[Cc]pageref|pageref|eqref)\{([^}]+)\}")
CITE = re.compile(r"\\cite[pt]?\*?(?:\[[^\]]*\])*\{([^}]+)\}")
# Labels quoted in Lean comments, e.g. `prop:geometry` or `eq:incidencecount`.
LEAN_LABEL = re.compile(r"`((?:thm|lem|prop|cor|rem|def|eq|app|sec|alg|fig):[A-Za-z0-9:_-]+)`")


def require(condition, detail):
    if not condition:
        raise ValueError(str(detail))


def write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8", newline="\n")


def canonical(base: Path, names=SOURCES):
    records = []
    for name in names:
        file = base / name
        if not file.is_file():
            continue
        text = file.read_text(encoding="utf-8")
        for m in PAT.finditer(text):
            label = re.search(r"\\label\{([^}]+)\}", m.group())
            require(label is not None, (name, m.group()[:100]))
            records.append(
                dict(
                    label=label[1],
                    kind=m[1],
                    title=m[2],
                    file=name,
                    line=text.count("\n", 0, m.start()) + 1,
                    end_line=text.count("\n", 0, m.end()) + 1,
                    text=m.group(),
                )
            )
    return records


def expand_single(paper: Path) -> str:
    """paper.tex with its \\input files and compiled bibliography inlined."""
    text = (paper / "paper.tex").read_text(encoding="utf-8")
    for command, name in (
        ("\\input{main}", "main.tex"),
        ("\\bibliography{references}", "paper.bbl"),
        ("\\input{appendices}", "appendices.tex"),
    ):
        require(text.count(command) == 1, ("paper.tex must contain once", command))
        text = text.replace(command, (paper / name).read_text(encoding="utf-8"))
    return text


def nonblank_lines(text: str) -> list[str]:
    return [line.rstrip() for line in text.splitlines() if line.strip()]


def lean_citations(formalization: Path) -> dict[str, list[str]]:
    cited: dict[str, list[str]] = {}
    for file in sorted(formalization.glob("**/*.lean")):
        if ".lake" in file.parts:
            continue
        for label in LEAN_LABEL.findall(file.read_text(encoding="utf-8")):
            cited.setdefault(label, []).append(file.relative_to(formalization).as_posix())
    return {label: sorted(set(files)) for label, files in sorted(cited.items())}


def check_sources(paper: Path, output: Path, formalization: Path | None = None):
    P = paper.resolve()
    OUT = output.resolve()
    OUT.mkdir(parents=True, exist_ok=True)
    st = canonical(P)
    require(st, "No labeled statements found")
    by = {s["label"]: s for s in st}
    require(len(by) == len(st), [s["label"] for s in st])

    texts = {name: (P / name).read_text(encoding="utf-8") for name in SOURCES}
    defs = [
        (m[1], name, text.count("\n", 0, m.start()) + 1)
        for name, text in texts.items()
        for m in re.finditer(r"\\label\{([^}]+)\}", text)
    ]
    defined = {x[0] for x in defs}
    require(
        len(defs) == len(defined),
        sorted({d[0] for d in defs if [x[0] for x in defs].count(d[0]) > 1}),
    )
    refs = {lab for text in texts.values() for m in REF.finditer(text) for lab in m[1].split(",")}
    missing = sorted(refs - defined)
    require(not missing, ("undefined references", missing))

    # Shared statement counter: numbers must be 1..n in source order.
    aux = (P / "paper.aux").read_text(encoding="utf-8")
    numbers = {a: b for a, b in re.findall(r"\\newlabel\{([^}]+)\}\{\{([^}]+)\}", aux)}
    statement_numbers = [int(numbers[s["label"]]) for s in st]
    require(statement_numbers == list(range(1, len(st) + 1)), statement_numbers)

    # The self-contained source must be exactly the modular source, expanded.
    single = P / "paper_single.tex"
    require(single.is_file(), "paper_single.tex is missing")
    require(
        nonblank_lines(expand_single(P)) == nonblank_lines(single.read_text(encoding="utf-8")),
        "paper_single.tex differs from paper.tex with main, bibliography, and appendices inlined",
    )

    # Every citation resolves; every bibliography record names a venue or an arXiv source.
    bib = (P / "references.bib").read_text(encoding="utf-8")
    keys = set(re.findall(r"^@\w+\{([^,]+),", bib, re.M))
    cited = {
        k.strip() for text in texts.values() for m in CITE.finditer(text) for k in m[1].split(",")
    }
    require(not cited - keys, ("citations without bibliography record", sorted(cited - keys)))
    bad = []
    for m in re.finditer(r"@(\w+)\{([^,]+),(.*?)(?=\n@|\Z)", bib, re.S):
        if not re.search(
            r"journal\s*=|booktitle\s*=|arXiv|Electronic Colloquium on Computational Complexity|publisher\s*=|institution\s*=",
            m[3],
            re.I,
        ):
            bad.append(m[2])
    require(not bad, bad)

    # Lean comments cite results by label; every cited label must exist in the paper.
    lean = lean_citations(formalization or ROOT / "formalization")
    unknown = {label: files for label, files in lean.items() if label not in defined}
    require(not unknown, ("Lean cites labels absent from the paper", unknown))

    rows = []
    mapping = [
        "# Statement numbering",
        "",
        "| Number | Kind | Title | Label | Source |",
        "|---|---|---|---|---|",
    ]
    for s in st:
        num = numbers[s["label"]]
        rows.append(
            {k: v for k, v in s.items() if k != "text"}
            | dict(number=int(num), sha256=hashlib.sha256(s["text"].encode()).hexdigest())
        )
        mapping.append(
            f"| {num} | {s['kind'].capitalize()} | {s['title'] or ''} | `{s['label']}` | `{s['file']}:{s['line']}` |"
        )
    result = dict(
        status="PASS",
        numbered_statements=len(st),
        consecutive_numbers=True,
        labels=len(defined),
        undefined_references=missing,
        single_source_matches_modular=True,
        bibliography_records=len(keys),
        cited_keys=len(cited),
        lean_cited_labels=lean,
        statement_rows=rows,
        scope="Source and citation consistency; mathematical validity is not checked here.",
    )
    write_text(OUT / "NUMBERING.md", "\n".join(mapping) + "\n")
    write_text(OUT / "source_consistency.json", json.dumps(result, indent=2) + "\n")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--paper-directory",
        type=Path,
        default=ROOT / "paper",
        help="Built TeX source tree containing paper.aux.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "work/paper/sources",
        help="Directory for source audit reports.",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    report = output / "source_consistency.json"
    write_text(report, json.dumps(dict(status="RUNNING"), indent=2) + "\n")
    try:
        result = check_sources(args.paper_directory, output)
    except BaseException as error:
        write_text(
            report,
            json.dumps(dict(status="FAILED", error=f"{type(error).__name__}: {error}"), indent=2)
            + "\n",
        )
        raise
    print(
        json.dumps(
            {
                k: result[k]
                for k in [
                    "status",
                    "numbered_statements",
                    "labels",
                    "bibliography_records",
                    "undefined_references",
                    "single_source_matches_modular",
                ]
            }
            | {"lean_cited_labels": len(result["lean_cited_labels"])},
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
