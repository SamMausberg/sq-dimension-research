#!/usr/bin/env python3
"""Keyed-hash Proper RECTIFY, exact rational endpoint adversary, certified cap laws."""

import base64
import csv
import gzip
import json
import time
from fractions import Fraction
from pathlib import Path

import cap_sq as C
import numpy as np
from seeded_fast import KEY, SeedClass

OUT = Path(__file__).resolve().parent / "results" / "keyed_caps"
OUT.mkdir(parents=True, exist_ok=True)
SEED = 202609104


def audit_run(z, A):
    den = z["denominator"]
    w = np.zeros(A.shape[1], dtype=np.int64)
    w[z["support"]] = z["weights"]
    assert int(w.sum()) == den
    for q in z["queries_trace"]:
        mask = np.unpackbits(np.frombuffer(base64.b85decode(q["mask"]), dtype=np.uint8))[
            : A.shape[1]
        ].astype(bool)
        val = Fraction(int(w[mask].sum()), den)
        assert val == Fraction(q["truth"])
        assert abs(Fraction(q["answer"]) - val) == C.TAU
    g = np.where(
        np.unpackbits(np.frombuffer(base64.b85decode(z["prediction"]), dtype=np.uint8))[
            : A.shape[1]
        ],
        1,
        -1,
    )
    assert np.any(np.all(A == g, axis=1))
    loss = Fraction(int(w[g != A[z["target"]]].sum()), den)
    assert loss == Fraction(z["error_exact"])
    return len(z["queries_trace"])


def main():
    runs = []
    summary = []
    audit_queries = 0
    startall = time.perf_counter()
    with (OUT / "runs.jsonl").open("w") as raw:
        for N in range(2, 9):
            rng = np.random.default_rng(SEED + N)
            pts, lin, F, A, U, V = C.family(N, SEED + N)
            keyed = SeedClass(N, KEY)
            for j in range(len(lin)):
                for p in np.flatnonzero(F[j] == -1):
                    a, b = map(int, lin[j])
                    x, y = map(int, pts[p])
                    A[j, p] = keyed.label(a, b, (x, y))
            np.savez_compressed(
                OUT / f"family_N{N}.npz", points=pts, lines=lin, template=F, A=A, U0=U, V0=V
            )
            law = C.CapLaw(A, U, V, SEED + N * 17)
            law.certstream = gzip.open(OUT / f"cap_catalogs_N{N}.jsonl.gz", "wt")
            X = len(pts)
            eligible = np.flatnonzero((A == -1).sum(axis=1) > 0)
            best = sorted(map(int, eligible), key=lambda j: (-int((A[j] == -1).sum()), j))[:2]
            cases = []
            for j in best:
                neg = np.flatnonzero(A[j] == -1)
                inc = np.flatnonzero(F[j] == -1)
                for supp, name in [(neg, "negative_only"), (inc, "template_line")]:
                    cases.append((j, C.make_dist(X, supp, rng), name))
                pos = int(np.flatnonzero(A[j] == 1)[0])
                p = int(neg[0])
                den = C.TAU.denominator * 8
                w = np.zeros(X, dtype=np.int64)
                w[p] = int((C.INNER / 4 + C.TAU / 2) * den)
                w[pos] = den - w[p]
                cases.append((j, w, "endpoint_threshold_tail"))
            for restart in range(2):
                j = int(rng.choice(eligible))
                neg = np.flatnonzero(A[j] == -1)
                supp = np.unique(
                    np.concatenate([neg, rng.choice(X, min(20 - len(neg), X), replace=False)])
                )[:20]
                w = C.make_dist(X, supp, rng)
                seed = SEED + 100 + restart

                def score(z):
                    return (z["error"], z["rounds"]) if restart == 0 else (z["rounds"], z["error"])

                base = C.learn(A, law, j, w, seed, "endpoint", True, False)
                for step in range(3):
                    cand = w.copy()
                    ss = np.flatnonzero(cand)
                    aa = int(rng.choice(ss))
                    bb = int(rng.choice(ss)) if step % 2 else int(rng.integers(X))
                    if aa == bb:
                        bb = (bb + 1) % X
                    amt = max(1, int(cand[aa] * (0.2 + 0.15 * step)))
                    cand[aa] -= amt
                    cand[bb] += amt
                    if np.count_nonzero(cand) > 20:
                        continue
                    z = C.learn(A, law, j, cand, seed, "endpoint", True, False)
                    if score(z) > score(base):
                        w = cand
                        base = z
                cases.append((j, w, "searched_error" if restart == 0 else "searched_rounds"))
            nr = []
            for i, (j, w, name) in enumerate(cases):
                tic = time.perf_counter()
                z = C.learn(A, law, j, w, SEED + 1000 + i, "endpoint", True, True)
                z.update(
                    N=N,
                    distribution=name,
                    wall_seconds=time.perf_counter() - tic,
                    key_hex=KEY.hex(),
                )
                audit_queries += audit_run(z, A)
                raw.write(json.dumps(z, separators=(",", ":")) + "\n")
                raw.flush()
                nr.append(z)
                runs.append(z)
            law.certstream.close()
            law.save(OUT / f"cap_certificates_N{N}.json")
            row = dict(
                N=N,
                points=X,
                runs=len(nr),
                max_error=max(z["error"] for z in nr),
                max_rounds=max(z["rounds"] for z in nr),
                max_queries=max(z["queries"] for z in nr),
                max_wall_seconds=max(z["wall_seconds"] for z in nr),
                peels=sum(z["peels"] for z in nr),
                eliminations=sum(z["eliminations"] for z in nr),
                rejections=sum(z["rejects"] for z in nr),
                catalogs=len(law.certs),
            )
            summary.append(row)
            print(json.dumps(row), flush=True)
    with (OUT / "summary.csv").open("w") as f:
        w = csv.DictWriter(f, fieldnames=summary[0])
        w.writeheader()
        w.writerows(summary)
    cats = rects = constraints = 0
    for N in range(2, 9):
        data = np.load(OUT / f"family_N{N}.npz")
        A = data["A"]
        K, X = A.shape
        with gzip.open(OUT / f"cap_catalogs_N{N}.jsonl.gz", "rt") as f:
            for line in f:
                z = json.loads(line)
                nu = np.zeros(X, dtype=np.int64)
                sv = set(z["survivors"])
                for q in z["rectangles"]:
                    s = np.unpackbits(np.frombuffer(base64.b85decode(q["S"]), dtype=np.uint8))[
                        :X
                    ].astype(bool)
                    t = np.unpackbits(np.frombuffer(base64.b85decode(q["T"]), dtype=np.uint8))[
                        :K
                    ].astype(bool)
                    assert set(np.flatnonzero(t)).issubset(sv)
                    assert np.all(A[np.ix_(t, s)] == q["color"])
                    nu += s.astype(np.int64) * int(t.sum())
                    rects += 1
                den = len(z["rectangles"]) * len(sv)
                assert int(nu.min()) == z["minimum_coverage_numerator"]
                assert np.all(nu * C.RHO >= den)
                cats += 1
                constraints += X
    meta = dict(
        key_hex=KEY.hex(),
        key_derivation="SHA256(ASCII sq-dc-turn4-main-key-20260910)",
        seed=SEED,
        rho=C.RHO,
        epsilon=str(C.EPS),
        inner_epsilon=str(C.INNER),
        tau=str(C.TAU),
        runs=len(runs),
        query_checks=audit_queries,
        catalogs=cats,
        rectangles=rects,
        pointwise_checks=constraints,
        elapsed_seconds=time.perf_counter() - startall,
        oracle="greedy public-history tolerance endpoints",
        cryptographic_claim="None for HMAC-SHA256; this is a reproducible keyed-hash instantiation, not a security experiment.",
    )
    (OUT / "audit.json").write_text(json.dumps(meta, indent=2))
    print(json.dumps(meta), flush=True)


if __name__ == "__main__":
    main()
