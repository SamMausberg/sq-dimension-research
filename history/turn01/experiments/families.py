from __future__ import annotations
import itertools, math
import numpy as np

def plane(q: int):
    if q < 2 or any(q % a == 0 for a in range(2, math.isqrt(q) + 1)):
        raise ValueError('This generator uses a prime field, not an arbitrary prime power.')
    reps = []
    for t in itertools.product(range(q), repeat=3):
        if not any(t): continue
        first = next(v for v in t if v)
        if first == 1: reps.append(t)
    V = np.array(reps, dtype=np.int64)
    P = ((V @ V.T) % q == 0).astype(np.int64)
    return V, P

