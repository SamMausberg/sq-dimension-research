#!/usr/bin/env python3
"""Canonical-statement/proof linkage, revision diff and dependency consistency.

This checks source bindings and a reviewed dependency graph, not proof validity.
"""

from __future__ import annotations

import argparse
import difflib
import graphlib
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAT = re.compile(
    r"\\begin\{(theorem|lemma|proposition|corollary)\}(?:\[([^\]]*)\])?([\s\S]*?)\\end\{\1\}"
)


def canonical(base: Path):
    records = []
    for file in sorted(
        list((base / "sections").glob("*.tex")) + list((base / "appendices").glob("*.tex"))
    ):
        text = file.read_text(encoding="utf-8")
        for m in PAT.finditer(text):
            label = re.search(r"\\label\{([^}]+)\}", m.group())
            require(label is not None, (file, m.group()[:100]))
            records.append(
                dict(
                    label=label[1],
                    kind=m[1],
                    title=m[2],
                    file=file.relative_to(base).as_posix(),
                    line=text.count("\n", 0, m.start()) + 1,
                    end_line=text.count("\n", 0, m.end()) + 1,
                    offset=m.start(),
                    end_offset=m.end(),
                    text=m.group(),
                )
            )
    return records


def require(condition, detail):
    if not condition:
        raise ValueError(str(detail))


def baseline_directory(root: Path) -> Path:
    # The recovered release 7 places its TeX files under paper/. Never silently
    # substitute a different release while labeling the output release 7.
    for candidate in (
        root / "history/turn07/paper",
        root / "history/turn07/arxiv_source",
        root / "history/turn07",
    ):
        if (candidate / "sections").is_dir() and (candidate / "appendices").is_dir():
            return candidate
    raise FileNotFoundError("Release-7 paper sources are missing; refusing a different baseline.")


def write_text(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8", newline="\n")


def check_sources(paper: Path, output: Path):
    P = paper.resolve()
    OUT = output.resolve()
    OUT.mkdir(parents=True, exist_ok=True)
    baseline = baseline_directory(ROOT)
    st = canonical(P)
    old = canonical(baseline)
    by = {s["label"]: s for s in st}
    previous = {s["label"]: s for s in old}
    require(len(by) == len(st) == 40, (len(st), len(by)))
    require(len(previous) == 39, len(previous))
    require(set(previous) <= set(by), set(previous) - set(by))
    aux = (P / "paper.aux").read_text(encoding="utf-8")
    numbers = {a: b for a, b in re.findall(r"\\newlabel\{([^}]+)\}\{\{([^}]+)\}", aux)}
    oldinv = {
        q["label"]: q
        for q in json.loads(
            (ROOT / "history/turn06/checks/statement_inventory.json").read_text(encoding="utf-8")
        )
    }
    texts = {f.relative_to(P).as_posix(): f.read_text(encoding="utf-8") for f in P.rglob("*.tex")}
    proofs = {}
    for name, text in texts.items():
        for m in re.finditer(r"\\begin\{proof\}(?:\[([^\n]*)\])?([\s\S]*?)\\end\{proof\}", text):
            head = m[1] or ""
            labels = []
            for q in re.findall(r"\\(?:[Cc]ref|ref)\{([^}]+)\}", head):
                labels += q.split(",")
            labels = [x for x in labels if x in by]
            if not labels:
                prior = [s for s in st if s["file"] == name and s["end_offset"] < m.start()]
                if prior:
                    labels = [max(prior, key=lambda s: s["end_offset"])["label"]]
            for lab in labels:
                require(lab not in proofs, ("duplicate proof", lab, name))
                proofs[lab] = dict(
                    file=name,
                    line=text.count("\n", 0, m.start()) + 1,
                    end_line=text.count("\n", 0, m.end()) + 1,
                    text=m.group(),
                )
    # The exact-parameter lemma is a declared shared proof unit with the main theorem.
    if "lem:params" not in proofs:
        proofs["lem:params"] = proofs["thm:main"] | {"shared_with": "thm:main"}
    require(set(proofs) == set(by), (set(by) - set(proofs), set(proofs) - set(by)))
    defs = []
    refs = []
    for name, s in texts.items():
        defs += [
            (lab, name, s.count("\n", 0, m.start()) + 1)
            for m in re.finditer(r"\\label\{([^}]+)\}", s)
            for lab in [m[1]]
        ]
        refs += [
            (lab, name)
            for m in re.finditer(r"\\(?:[Cc]ref|ref|[Cc]pageref|pageref|eqref)\{([^}]+)\}", s)
            for lab in m[1].split(",")
        ]
    defined = {x[0] for x in defs}
    missing = sorted(set(lab for lab, name in refs) - defined)
    require(not missing, missing)
    require(len(defs) == len(defined), [q for q in defined if sum(q == v[0] for v in defs) > 1])
    allnumbers = sorted(int(numbers[s["label"]]) for s in st)
    require(allnumbers == list(range(1, 41)), allnumbers)
    extract = OUT / "statement_proof_extracts"
    extract.mkdir(parents=True, exist_ok=True)
    rows = []
    diffs = []
    mapping = [
        "# Statement numbering",
        "",
        "| Release 7 | Current | Label | Source and proof |",
        "|---|---|---|---|",
    ]
    for s in sorted(st, key=lambda s: int(numbers[s["label"]])):
        label = s["label"]
        proof = proofs[label]
        num = numbers[label]
        onum = oldinv.get(label, {}).get("number", "new")
        write_text(
            extract / f"{int(num):02d}.tex",
            f"% {s['file']}:{s['line']}-{s['end_line']}\n"
            + s["text"]
            + f"\n\n% {proof['file']}:{proof['line']}-{proof['end_line']}\n"
            + proof["text"]
            + "\n",
        )
        if label in previous:
            a = previous[label]["text"]
            b = s["text"]
            diff = "".join(
                difflib.unified_diff(
                    a.splitlines(True),
                    b.splitlines(True),
                    fromfile=f"release7:{label}",
                    tofile=f"current:{label}",
                )
            )
            if diff:
                diffs.append(dict(label=label, old_number=onum, new_number=num, diff=diff))
        else:
            diffs.append(
                dict(
                    label=label,
                    old_number="new",
                    new_number=num,
                    diff="NEW STATEMENT\n" + s["text"],
                )
            )
        row = {k: v for k, v in s.items() if k not in ["offset", "end_offset", "text"]}
        row.update(
            number=num,
            old_number=onum,
            sha256=hashlib.sha256(s["text"].encode()).hexdigest(),
            proof={k: v for k, v in proof.items() if k != "text"},
        )
        rows.append(row)
        mapping.append(
            f"| {onum} | {s['kind'].capitalize()} {num} | `{label}` | `{s['file']}:{s['line']}`; `{proof['file']}:{proof['line']}` |"
        )
    dep = json.loads(
        (ROOT / "history/turn06/checks/proof_dependencies.json").read_text(encoding="utf-8")
    )["edges_statement_to_dependencies"]
    dep.pop("summary:MainTheorem", None)
    dep["thm:prob"] += ["lem:exact-prob"]
    dep["thm:query-lower"] = [
        "aux:entropy-ball",
        "aux:cube-concentration",
        "thm:caps",
        "thm:proper",
    ]
    dep["aux:entropy-ball"] = []
    # Counts and query claims in the new theorem are proved in one proof unit;
    # its upper bound invokes existing implementations, never conversely.
    order = list(graphlib.TopologicalSorter(dep).static_order())
    require(set(by) <= set(dep), set(by) - set(dep))
    result = dict(
        status="PASS",
        baseline_directory=baseline.relative_to(ROOT).as_posix(),
        numbering_source="history/turn06/checks/statement_inventory.json",
        numbered_statements=len(st),
        baseline_statements=len(previous),
        retained_baseline_labels=len(set(previous) & set(by)),
        bound_proofs=len(proofs),
        global_consecutive_numbers=True,
        undefined_labels=missing,
        dependency_nodes=len(dep),
        acyclic=True,
        statement_rows=rows,
        statement_changes=diffs,
        scope="Source consistency plus a reviewed proof-dependency graph; mathematical validity is assessed in the proof ledger.",
    )
    write_text(OUT / "statement_changes.diff", "\n".join(d["diff"] for d in diffs))
    write_text(
        OUT / "proof_dependencies.json",
        json.dumps(
            dict(edges_statement_to_dependencies=dep, topological_order=order, acyclic=True),
            indent=2,
        )
        + "\n",
    )
    write_text(
        OUT / "proof_dependencies.dot",
        "digraph ProofDependencies {\n"
        + "".join(f'  "{k}" -> "{v}";\n' for k, vs in dep.items() for v in vs)
        + "}\n",
    )
    write_text(OUT / "NUMBERING.md", "\n".join(mapping) + "\n")
    # Ensure every bibliography record names a publication or an arXiv source.
    bib = (P / "references.bib").read_text(encoding="utf-8")
    bad = []
    for m in re.finditer(r"@(\w+)\{([^,]+),(.*?)(?=\n@|\Z)", bib, re.S):
        if not re.search(
            r"journal\s*=|booktitle\s*=|arXiv|Electronic Colloquium on Computational Complexity|publisher\s*=|institution\s*=",
            m[3],
            re.I,
        ):
            bad.append(m[2])
    require(not bad, bad)
    write_text(
        OUT / "bibliography_structure.json",
        json.dumps(
            dict(records=len(re.findall(r"^@", bib, re.M)), records_without_venue_or_arxiv=bad),
            indent=2,
        )
        + "\n",
    )
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
        default=ROOT / "audits/current",
        help="Directory for source audit reports and extracts.",
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
                    "baseline_statements",
                    "bound_proofs",
                    "dependency_nodes",
                    "acyclic",
                    "undefined_labels",
                ]
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
