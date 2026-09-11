#!/usr/bin/env python3
"""Seed-known SQ learning by order medians. CPU, exact rational answers.
The learner receives no table or samples. Oracle simulation and validation know D,h.
The keyed hash is an experimental instantiation, not a proved cryptographic PRF.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import hmac
import json
import math
import random
import struct
import time
from fractions import Fraction as Q
from pathlib import Path
from typing import Callable

KEY = hashlib.sha256(b"sq-dc-turn4-main-key-20260910").digest()
SEED = 202609104
OUT = Path(__file__).resolve().parent / "results" / "fast"
OUT.mkdir(parents=True, exist_ok=True)
Point = tuple[int, int]


class SeedClass:
    def __init__(self, N: int, key: bytes = KEY):
        self.N = N
        self.key = key
        self.calls = 0

    def bit(self, a: int, b: int, p: Point) -> int:
        self.calls += 1
        msg = b"SQDC4\0" + struct.pack(">QQQQQ", self.N, a, b, p[0], p[1])
        return hmac.new(self.key, msg, hashlib.sha256).digest()[0] & 1

    def label(self, a: int, b: int, p: Point) -> int:
        return 1 if p[1] != a * p[0] + b or self.bit(a, b, p) else -1

    def pred(self, a: int, b: int) -> Callable[[Point], int]:
        assert 1 <= a <= self.N and 1 <= b <= 2 * self.N * self.N
        return lambda p: self.label(a, b, p)


class Oracle:
    def __init__(self, points, weights, target, cls, eps, mode="endpoint"):
        self.points = [tuple(map(int, p)) for p in points]
        self.weights = list(map(int, weights))
        self.den = sum(self.weights)
        assert self.den > 0 and min(self.weights) >= 0
        self.labels = [cls.label(*target, p) for p in self.points]
        self.tau = eps / 4096
        self.mode = mode
        self.trace = []
        self.seconds = 0.0

    def ask(self, fun, kind, meta=None):
        t = time.perf_counter()
        meta = {} if meta is None else meta
        mask = [bool(fun(p, y)) for p, y in zip(self.points, self.labels)]
        truth = Q(sum(w for w, b in zip(self.weights, mask) if b), self.den)
        choices = [truth] if self.mode == "exact" else [truth - self.tau, truth + self.tau]
        threshold = Q(meta["threshold"]) if "threshold" in meta else None

        def score(z):
            if kind == "loss":
                return (truth if z <= threshold else Q(0), int(z > threshold), z)
            if kind in ("total", "tail"):
                return (int(z <= threshold), -z)
            if kind == "median":
                # Current public bracket and queried midpoint determine next lengths.
                lo, hi, mid = meta["lo"], meta["hi"], meta["mid"]
                return (
                    int((z >= threshold) != (truth >= threshold)),
                    mid - lo if z >= threshold else hi - mid,
                    z,
                )
            if threshold is not None:
                return (int((z > threshold) != (truth > threshold)), z)
            return (z,)

        ans = max(choices, key=score)
        assert abs(ans - truth) <= self.tau
        self.trace.append(
            dict(
                kind=kind,
                meta=meta,
                mask="".join("1" if b else "0" for b in mask),
                truth=str(truth),
                answer=str(ans),
            )
        )
        self.seconds += time.perf_counter() - t
        return ans


def learn(cls: SeedClass, O: Oracle, eps=Q(1, 10), proper=True, seed=0):
    """Returns an evaluable predictor plus public output description.
    All branch thresholds use answers, never oracle truth or support.
    """
    N = cls.N
    rng = random.Random(seed)
    stages = []
    beta = O.ask(lambda p, y: y == -1, "total", {"threshold": str(eps / 4)})
    plus = cls.pred(1, 2 * N * N)
    if beta <= eps / 4:
        return plus, dict(kind="line", a=1, b=2 * N * N, reason="small_negative", stages=stages)

    def median(f, lo, hi, name):
        lo -= 1
        while hi - lo > 1:
            mid = (lo + hi) // 2
            z = O.ask(
                lambda p, y: y == -1 and f(p) <= mid,
                "median",
                dict(variable=name, lo=lo, hi=hi, mid=mid, threshold=str(beta / 2)),
            )
            if z >= beta / 2:
                hi = mid
            else:
                lo = mid
        return hi

    def atom(f, v, name):
        return O.ask(
            lambda p, y: y == -1 and f(p) == v,
            "atom",
            dict(variable=name, value=v, threshold=str(beta / 8)),
        )

    def locate(mask, coord, lo, hi, name):
        while lo < hi:
            mid = (lo + hi) // 2
            z = O.ask(
                lambda p, y: y == -1 and mask(p) and p[coord] <= mid,
                "locate",
                dict(variable=name, lo=lo, hi=hi, mid=mid, threshold=str(beta / 32)),
            )
            if z > beta / 32:
                hi = mid
            else:
                lo = mid + 1
        return lo

    def output_line(a, b, reason):
        return cls.pred(a, b), dict(kind="line", a=a, b=b, reason=reason, stages=stages)

    def heavy(p):
        stages.append(dict(stage="heavy", point=p))
        tail = O.ask(
            lambda z, y: y == -1 and z != p, "tail", {"point": p, "threshold": str(eps / 4)}
        )
        count = min(N, (p[1] - 1) // p[0])
        assert count >= 1
        if tail > eps / 4:
            lo, hi = 1, count
            while lo < hi:
                mid = (lo + hi) // 2

                def union(z, y):
                    if y != -1 or z == p or z[0] == p[0]:
                        return False
                    num = z[1] - p[1]
                    den = z[0] - p[0]
                    return num % den == 0 and lo <= num // den <= mid

                z = O.ask(
                    union,
                    "star_split",
                    dict(point=p, lo=lo, hi=hi, mid=mid, threshold=str(eps / 8)),
                )
                if z > eps / 8:
                    hi = mid
                else:
                    lo = mid + 1
            return output_line(lo, p[1] - lo * p[0], "star_identified")
        if not proper:
            return (lambda z: -1 if z == p else 1), dict(
                kind="point", point=p, reason="small_tail_improper", stages=stages
            )
        n = math.ceil(math.log2(2 * N**3))
        cut = max(64 * n, math.ceil(128 / float(eps)))
        if count <= cut:
            candidates = range(1, count + 1)
        else:
            candidates = [
                1 + rng.getrandbits((count - 1).bit_length()) % count
                for _ in range(math.ceil(16 * math.log(4 / float(eps))))
            ]
        for a in candidates:
            b = p[1] - a * p[0]
            if cls.label(a, b, p) != -1:
                continue
            pred = cls.pred(a, b)
            z = O.ask(lambda q, y: pred(q) != y, "loss", dict(a=a, b=b, threshold=str(eps / 2)))
            if z <= eps / 2:
                return output_line(a, b, "star_candidate")
        # Only the large-star randomized branch can fail for a regular key.
        return output_line(1, 2 * N * N, "star_sampling_failure")

    pivot = median(lambda p: p[0], 1, N, "x")
    mass = atom(lambda p: p[0], pivot, "x")
    if mass > beta / 8:
        y = locate(lambda p: p[0] == pivot, 1, 1, 2 * N * N, "y_at_x")
        return heavy((pivot, y))
    lo, hi = 1, N
    while lo < hi:
        a = (lo + hi) // 2
        residual = lambda p: p[1] - a * p[0]
        v = median(residual, 1 - N * N, 2 * N * N, "residual_" + str(a))
        mv = atom(residual, v, "residual_" + str(a))
        if mv > beta / 8:
            lv = O.ask(
                lambda p, y: y == -1 and residual(p) == v and p[0] <= pivot,
                "split_atom",
                dict(a=a, v=v, pivot=pivot, threshold=str(beta / 8)),
            )
            if lv >= beta / 8 and mv - lv >= beta / 8:
                return output_line(a, v, "constant_residual")
            x = locate(lambda p: residual(p) == v, 0, 1, N, "x_at_residual")
            return heavy((x, a * x + v))
        val = O.ask(
            lambda p, y: y == -1 and p[0] <= pivot and residual(p) <= v,
            "orientation",
            dict(a=a, v=v, pivot=pivot, threshold=str(3 * beta / 8)),
        )
        stages.append(dict(stage="slope", lo=lo, hi=hi, a=a, median=v, answer=str(val)))
        if val > 3 * beta / 8:
            lo = a + 1
        else:
            hi = a - 1
        assert lo <= hi
    b = median(lambda p: p[1] - lo * p[0], 1 - N * N, 2 * N * N, "final_intercept")
    return output_line(lo, b, "slope_identified")


def evaluate(cls, target, points, weights, mode="endpoint", proper=True, seed=0):
    eps = Q(1, 10)
    O = Oracle(points, weights, target, cls, eps, mode)
    before = cls.calls
    t = time.perf_counter()
    pred, desc = learn(cls, O, eps, proper, seed)
    wall = time.perf_counter() - t
    err = Q(
        sum(w for p, w, y in zip(points, weights, O.labels) if pred(tuple(p)) != y), sum(weights)
    )
    if desc["reason"] != "star_sampling_failure":
        assert err <= eps / 2 + eps / 4096, (desc, err)
    return dict(
        N=cls.N,
        target=target,
        mode=mode,
        proper=proper,
        seed=seed,
        points=points,
        weights=weights,
        error=str(err),
        error_float=float(err),
        queries=len(O.trace),
        wall_seconds=wall,
        oracle_seconds=O.seconds,
        nonoracle_seconds=max(0.0, wall - O.seconds),
        hash_evaluations=cls.calls - before,
        output=desc,
        trace=O.trace,
    )


def run(args):
    allrows = []
    raw = (OUT / "runs.jsonl").open("w")
    rng = random.Random(SEED)
    for N in args.N:
        cls = SeedClass(N)
        cases = []
        # Prefer a long line with many surviving negatives for the all-light test.
        targets = [(1, 1), (max(1, N // 3), 1), (N, 1)]
        for a, b in targets:
            inc = [(x, a * x + b) for x in range(1, N + 1) if a * x + b <= 2 * N * N]
            neg = [p for p in inc if cls.label(a, b, p) == -1]
            if not neg:
                continue
            cases.append(((a, b), neg[:20], [1] * min(20, len(neg)), "negative_uniform"))
            cases.append(((a, b), inc[:20], [1] * min(20, len(inc)), "template_uniform"))
            pos = (1, 2 * N * N)
            cases.append(((a, b), [neg[0], pos], [1, 999], "small_negative"))
            # One heavy point and a genuine negative tail.
            tail = [p for p in neg if p != neg[0]][:18]
            cases.append(
                (
                    (a, b),
                    [neg[0]] + tail + [pos],
                    [500] + [max(1, 400 // max(1, len(tail)))] * len(tail) + [100],
                    "heavy_tail",
                )
            )
            cases.append(((a, b), [neg[0], pos], [700, 300], "single_negative"))
        # Random restarts and coordinate ascent jointly search D and endpoint policy.
        for rr in range(args.restarts):
            target = targets[rr % len(targets)]
            a, b = target
            line = [(x, a * x + b) for x in range(1, N + 1) if a * x + b <= 2 * N * N]
            pts = rng.sample(line, min(18, len(line))) + [(1, 2 * N * N)]
            ws = [rng.randrange(1, 1000) for _ in pts]
            base = evaluate(cls, target, pts, ws, "endpoint", True, SEED + rr)
            for _ in range(args.steps):
                cand = ws.copy()
                i, j = rng.sample(range(len(cand)), 2)
                t = max(1, cand[i] // 2)
                cand[i] -= t
                cand[j] += t
                z = evaluate(cls, target, pts, cand, "endpoint", True, SEED + rr)
                if (z["error_float"], z["queries"]) > (base["error_float"], base["queries"]):
                    ws = cand
                    base = z
            cases.append((target, pts, ws, "searched"))
        rows = []
        for ci, (target, pts, ws, name) in enumerate(cases):
            for mode in ["exact", "endpoint"]:
                z = evaluate(cls, target, pts, ws, mode, True, SEED + ci)
                z["distribution"] = name
                raw.write(json.dumps(z, separators=(",", ":")) + "\n")
                raw.flush()
                rows.append(z)
                allrows.append(z)
        summary = dict(
            N=N,
            runs=len(rows),
            max_error=max(z["error_float"] for z in rows),
            max_queries=max(z["queries"] for z in rows),
            max_wall_seconds=max(z["wall_seconds"] for z in rows),
            max_nonoracle_seconds=max(z["nonoracle_seconds"] for z in rows),
            all_light_successes=sum(
                z["output"]["reason"] in ("slope_identified", "constant_residual") for z in rows
            ),
        )
        print(json.dumps(summary), flush=True)
    raw.close()
    sums = []
    for N in args.N:
        rr = [z for z in allrows if z["N"] == N]
        sums.append(
            dict(
                N=N,
                runs=len(rr),
                max_error=max(z["error_float"] for z in rr),
                max_queries=max(z["queries"] for z in rr),
                max_wall_seconds=max(z["wall_seconds"] for z in rr),
                max_nonoracle_seconds=max(z["nonoracle_seconds"] for z in rr),
                slope_search_runs=sum(
                    bool(z["output"]["stages"])
                    and any(s["stage"] == "slope" for s in z["output"]["stages"])
                    for z in rr
                ),
            )
        )
    with (OUT / "summary.csv").open("w") as f:
        w = csv.DictWriter(f, fieldnames=list(sums[0]))
        w.writeheader()
        w.writerows(sums)
    (OUT / "metadata.json").write_text(
        json.dumps(
            dict(
                key_hex=KEY.hex(),
                random_seed=SEED,
                epsilon="1/10",
                tau="1/40960",
                runs=len(allrows),
                note="HMAC-SHA256 experimental keyed hash; no security claim. Public-query endpoint adversary; finite search, not global worst case.",
            ),
            indent=2,
        )
    )
    # Independent arithmetic audit of every stored response and output.
    checks = 0
    for z in allrows:
        cls = SeedClass(z["N"])
        ys = [cls.label(*z["target"], tuple(p)) for p in z["points"]]
        for q in z["trace"]:
            val = Q(sum(w for w, b in zip(z["weights"], q["mask"]) if b == "1"), sum(z["weights"]))
            assert val == Q(q["truth"]) and abs(Q(q["answer"]) - val) <= Q(1, 40960)
            checks += 1
        d = z["output"]
        assert d["kind"] == "line"
        er = Q(
            sum(
                w
                for p, w, y in zip(z["points"], z["weights"], ys)
                if cls.label(d["a"], d["b"], tuple(p)) != y
            ),
            sum(z["weights"]),
        )
        assert er == Q(z["error"])
    (OUT / "audit.json").write_text(
        json.dumps(
            dict(runs=len(allrows), query_checks=checks, proper_outputs=len(allrows), passed=True),
            indent=2,
        )
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--N", nargs="+", type=int, default=[2, 3, 4, 5, 6, 7, 8, 16, 32])
    p.add_argument("--restarts", type=int, default=3)
    p.add_argument("--steps", type=int, default=4)
    run(p.parse_args())
