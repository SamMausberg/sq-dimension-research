#!/usr/bin/env python3
"""CPU checks for new finite inequalities, sample bound, and large-star code path."""

import csv
import hashlib
import itertools
import json
import math
import random
from fractions import Fraction as F
from pathlib import Path

from seeded_fast import KEY, SEED, Oracle, SeedClass, learn

OUT = Path(__file__).resolve().parent / "results" / "checks"
OUT.mkdir(parents=True, exist_ok=True)
rng = random.Random(SEED)
checks = 0
# Exhaust the tolerance endpoints of the inequalities used in order orientation.
for b in [F(512), F(513), F(1023), F(1024), F(10000)]:
    for eb, em, el in itertools.product([-1, 1], repeat=3):
        bh = b + eb
        z = F(1)
        assert b / F(2) - F(3, 2) - 1 > 3 * bh / 8
        assert b / F(4) + F(21, 4) + 1 < 3 * bh / 8
        assert b / F(8) - F(9, 8) > b / 9
        assert z < bh / 32 < b / 9 - z
        assert 2 * z < bh / 8
        assert b / F(2) - F(3, 2) + el > bh / 8
        assert b - (F(5, 8) * b + F(21, 8)) + em - el > bh / 8
        checks += 7
# All patterns and iid training-index sequences: exact unseen-label minimax expectation.
unseen = []
for N in [2, 3, 4]:
    for T in range(4):
        # Memorize seen labels and use +1 elsewhere. Under fair table this meets bound.
        err = F(0)
        count = 0
        for labs in itertools.product([-1, 1], repeat=N):
            for sample in itertools.product(range(N), repeat=T):
                seen = set(sample)
                err += F(sum(labs[i] == -1 for i in range(N) if i not in seen), N)
                count += 1
        err /= count
        exact = F(1, 2) * F(N - 1, N) ** T
        assert err == exact and exact >= F(1, 2) * (1 - F(T, N))
        unseen.append(dict(N=N, T=T, error=str(err), bound=str(exact)))
# Fixed real-grid sub-counting numbers. D=0 is intentionally reported, not hidden.
rows = []
for k in range(2, 7):
    K = 2 * k**3
    I = 2 * k**4 - (k * (k + 1) // 2) ** 2
    D = math.floor(k / (24 * math.log2(k)))
    brute = sum(
        1
        for a in range(1, k + 1)
        for b in range(1, 2 * k * k + 1)
        for x in range(1, k + 1)
        if a * x + b <= 2 * k * k
    )
    assert I == brute and I >= k**4 and D == 0
    rows.append(
        dict(
            k=k,
            rows=K,
            points=K,
            incidence_bits=I,
            D=D,
            half_k4=str(F(k**4, 2)),
            low_rank_event="empty: strict rank zero impossible",
        )
    )
with (OUT / "subgrid_counts.csv").open("w") as f:
    w = csv.DictWriter(f, fieldnames=rows[0])
    w.writeheader()
    w.writerows(rows)
# Stress a large-star branch beyond the tabulated N<=32 sweep.
N = 4096
cls = SeedClass(N)
p = (1, N + 1)
negative = [a for a in range(1, N + 1) if cls.label(a, N + 1 - a, p) == -1]
assert len(negative) >= N / 4
star = []
for seed in range(20):
    a = negative[seed]
    target = (a, N + 1 - a)
    points = [p, (1, 2 * N * N)]
    weights = [700, 300]
    O = Oracle(points, weights, target, cls, F(1, 10), "endpoint")
    pred, out = learn(cls, O, F(1, 10), True, seed)
    loss = F(sum(w for q, w, y in zip(points, weights, O.labels) if pred(q) != y), sum(weights))
    assert out["reason"] == "star_candidate" and loss == 0
    star.append(
        dict(
            seed=seed,
            target=target,
            output=out,
            queries=len(O.trace),
            error=str(loss),
            trace=O.trace,
        )
    )
(OUT / "large_star.json").write_text(
    json.dumps(
        dict(N=N, key_hex=KEY.hex(), negative_rows=len(negative), star_size=N, runs=star),
        separators=(",", ":"),
    )
)
(OUT / "unseen_exact.json").write_text(json.dumps(unseen, indent=2))
(OUT / "audit.json").write_text(
    json.dumps(
        dict(
            endpoint_algebra_checks=checks,
            unseen_cases=len(unseen),
            subgrids=len(rows),
            large_star_runs=len(star),
            large_star_negative_count=len(negative),
            all_passed=True,
        ),
        indent=2,
    )
)
print((OUT / "audit.json").read_text())
