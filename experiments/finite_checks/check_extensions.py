#!/usr/bin/env python3
"""Finite tests for the additional propositions. These are not proof verification.

Only the standard library is required. Rational games and geometric identities
are exact; entropy and exponential tail calculations are numerical.
"""
from __future__ import annotations
from fractions import Fraction as F
from itertools import product
from math import ceil, comb, exp, log, log2
import json
import random


def entropy(p: float) -> float:
    return 0.0 if p in (0.0, 1.0) else -p*log2(p)-(1-p)*log2(1-p)


def minmax_two_points(columns: list[tuple[F,F]]) -> F:
    """Min over a two-point marginal of the maximum column payoff, exactly."""
    candidates = {F(0), F(1)}
    for a in columns:
        for b in columns:
            denominator = a[0]-a[1]-b[0]+b[1]
            if denominator:
                t = (b[1]-a[1])/denominator
                if 0 <= t <= 1:
                    candidates.add(t)
    return min(max(t*a[0]+(1-t)*a[1] for a in columns) for t in candidates)


def maxmin_two_points(columns: list[tuple[F,F]]) -> F:
    """Max payoff secured by a mixture of at most two columns, exactly."""
    best = min(columns[0])
    for a in columns:
        for b in columns:
            candidates = {F(0), F(1)}
            denominator = a[0]-b[0]-a[1]+b[1]
            if denominator:
                t = (b[1]-b[0])/denominator
                if 0 <= t <= 1:
                    candidates.add(t)
            for t in candidates:
                best = max(best, min(t*a[0]+(1-t)*b[0], t*a[1]+(1-t)*b[1]))
    return best


def run() -> dict:
    counts: dict[str,int] = {}
    rng = random.Random(20261005)
    # A target's exact-success event contributes zero; on failure, one of the
    # two constants errs on at most half the marginal, for every enumerated label.
    k = 0
    for labels in product((-1,1), repeat=4):
        for weights in product(range(4), repeat=4):
            total = sum(weights)
            if not total:
                continue
            positive = sum(w for w,y in zip(weights,labels) if y == 1)
            fallback = min(F(positive,total), 1-F(positive,total))
            for p in (F(1,4), F(1,2), F(3,4), F(1)):
                assert (1-p)*fallback <= (1-p)/2
                k += 1
    counts['exact_constant_feature_fallback_cases'] = k

    # Columns are deterministic choices of one leaf for each random tree type.
    functions = list(product((-1,1), repeat=2))
    k = positive = 0
    for _ in range(200):
        leaves = [[rng.choice(functions), rng.choice(functions)] for _ in range(2)]
        h = rng.choice(functions)
        p = rng.choice((F(1,3),F(1,2),F(2,3)))
        columns = [tuple(h[z]*(p*leaves[0][i][z]+(1-p)*leaves[1][j][z])
                         for z in range(2)) for i,j in product(range(2),repeat=2)]
        primal, dual = minmax_two_points(columns), maxmin_two_points(columns)
        assert primal == dual
        positive += primal > 0
        k += 1
    counts['exact_transcript_minimax_games'] = k
    counts['positive_margin_games_among_these'] = positive

    k = 0
    for d in range(1,130):
        for t in range(1,d+1):
            assert (F(1)+F(t-1,d))/d <= F(2,d)
            k += 1
    counts['exact_classical_SQ_rectangle_inequalities'] = k

    k = 0
    for n in range(2,13):
        labels = {(a,b,x):rng.choice((-1,1)) for a in range(1,n+1)
                  for b in range(1,n*n+1) for x in range(1,n+1)}
        for (a,b,x),y in labels.items():
            ordinate = a*x+b
            assert 1 <= ordinate <= 2*n*n
            recovered_intercept = ordinate-a*x
            assert labels[(a,recovered_intercept,x)] == y
            k += 1
    counts['exact_same_slope_predictor_checks'] = k

    k = 0
    for n in (2,8,32,256,4096):
        L,Q = n**3,2*n**3
        for delta in (F(0),F(1,2),F(99,100)):
            g = ceil((1-delta)*L)
            assert (1-delta)*L <= g <= L
            assert F(g*n,32*(g+Q)) >= (1-delta)*n/96
            for a in (F(1,32),F(1,4),F(1,2),F(1)):
                threshold = int(a*a*g*n/(32*(g+Q)))
                assert threshold >= a*a*(1-delta)*n/96-1
                assert (g+Q)*threshold <= g*n
                k += 1
    counts['exact_prior_threshold_and_variable_counts'] = k

    k = 0
    for eta in (0.0,0.125,0.25,0.375):
        c = 1-entropy(eta)
        for bits in range(1,65):
            ball = sum(comb(bits,j) for j in range(int(eta*bits)+1))
            assert log2(ball) <= entropy(eta)*bits+1e-12
            x = c*c/32
            assert x*log2(8*exp(1)/x) <= c/2+1e-15
            k += 1
    counts['numerical_Hamming_and_Warren_bounds'] = k

    k = 0
    for eps in (F(0),F(1,10),F(1,4),F(49,100)):
        gamma = 1-2*eps
        for pairs in (1,2,16,1000,2**60):
            T = ceil(2*float(gamma)**-2*log(2*pairs))
            assert log(pairs)-T*float(gamma)**2/2 <= -log(2)+1e-12
            k += 1
    counts['numerical_transcript_concentration_budgets'] = k
    return {'status':'passed','scope':'finite exact and numerical tests, not formal verification',
            'seed':20261005,'checks':counts}


if __name__ == '__main__':
    print(json.dumps(run(),indent=2,sort_keys=True))
