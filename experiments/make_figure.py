#!/usr/bin/env python3
"""Reproduce the vector template/flip figure from the reported experimental key."""

from pathlib import Path

from seeded_fast import KEY, SeedClass

N = 2
points = [(x, y) for x in range(1, N + 1) for y in range(1, 2 * N * N + 1)]
lines = [(a, b) for a in range(1, N + 1) for b in range(1, 2 * N * N + 1)]
C = SeedClass(N, KEY)
K = len(points)
s = [r"\begin{figure}[ht]", r"\centering", r"\begin{tikzpicture}[x=0.24cm,y=0.24cm]"]
for offset, label, template in [(0, r"Template $F$", True), (22, r"Keyed flip $A_s$", False)]:
    for i, (a, b) in enumerate(lines):
        for j, p in enumerate(points):
            negative = (p[1] == a * p[0] + b) if template else C.label(a, b, p) < 0
            if negative:
                s.append(f"\\fill ({offset + j},{K - i - 1}) rectangle ++(1,1);")
    s.append(f"\\draw[step=1,thin] ({offset},0) grid ({offset + K},{K});")
    s.append(f"\\node[above] at ({offset + K / 2},17) {{{label}}};")
s += [
    r"\end{tikzpicture}",
    r"\caption{The $N=2$ template and the keyed flip used in the CPU tests. Black cells are negative and white cells positive. Rows index lines and columns index points. Only black template cells may change. This small example illustrates the construction; the counting lower bound is asymptotic.}",
    r"\label{fig:template}",
    r"\end{figure}",
]
(Path(__file__).resolve().parents[1] / "paper" / "figure.tex").write_text("\n".join(s) + "\n")
print("template figure reproduced from key", KEY.hex())
