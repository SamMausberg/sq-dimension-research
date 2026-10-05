#!/usr/bin/env python3
"""Finite checks accompanying the paper; not a formal verification.

Run with Python 3.10 or later. Uses only the standard library. Integer and
Fraction checks are exact. Entropy and logarithmic-budget checks are numerical
and are identified separately in the output. No cryptographic assumption or
infinite-instance theorem is validated by these tests.
"""
from __future__ import annotations

from fractions import Fraction as F
from itertools import product
from math import ceil, log, log2
import json
import random

COUNTS: dict[str, int] = {}


def record(name: str, count: int) -> None:
    COUNTS[name] = count


def incidence_count(n: int) -> int:
    return 2 * n**4 - (n * (n + 1) // 2) ** 2


def check_grid_and_representation() -> None:
    rng = random.Random(20261004)
    count = 0
    for n in range(2, 65):
        direct = sum(2 * n * n - a * x for a in range(1, n + 1)
                     for x in range(1, n + 1))
        assert direct == incidence_count(n) >= n**4
    record('exact_incidence_counts', 63)
    for n in range(2, 8):
        for a in range(1, n + 1):
            for b in range(1, 2 * n * n + 1):
                labels = [rng.choice((-1, 1)) for _ in range(n)]
                weights = [labels[t-1] + 2 * (a*t+b)**2
                           for t in range(1, n+1)]
                for x in range(1, n+1):
                    for y in range(1, 2*n*n+1):
                        residual = y-a*x-b
                        score = weights[x-1] - 4*b*y - 4*a*x*y + 2*y*y
                        assert score == labels[x-1] + 2*residual**2
                        target = labels[x-1] if residual == 0 else 1
                        assert target * score > 0
                        template = (a*x+b-y)**2 * 2 - 1
                        assert (template < 0) == (residual == 0)
                        count += 1
    record('exact_N_plus_3_and_template_scores', count)


def check_rectangle_endpoints() -> None:
    count = 0
    numerical = 0
    for exponent in range(3, 19):
        eps = F(1, 2**exponent)
        for rho in [1, 2, 16, 2**15, 2**18]:
            r = F(1, rho)
            # Binary-log ceilings are conservative, finitely computable budgets.
            p = 1 + 4*rho*(exponent+3)
            tau = eps/(24*p)
            u = eps/8
            assert tau <= eps/8 and tau <= r*eps/64
            assert tau/u <= r/8
            accepted_lower = r*u/2 - (1+r/2)*tau
            assert accepted_lower/u >= 5*r/16
            assert r*u/4 - (1+r/2)*tau >= r*u/16
            assert 3*p*tau == eps/8
            assert 3*p*tau + eps/4 + tau <= eps/2
            assert r - 2*tau/u >= 3*r/4
            count += 8
            for k in [1, 2, 16, 1000, 2**60]:
                b = log(k)+log(8/float(eps))+1
                rounds = ceil(8*rho*(b+log(2/float(eps))))
                assert b-float(r)*rounds/8 <= log(float(eps)/2)+1e-12
                numerical += 1
    record('exact_rectangle_endpoint_inequalities', count)
    record('numerical_rectangle_exponential_budgets', numerical)


def median_outputs(cdf: list[F], beta_hat: F, zeta: F,
                   lower: int, upper: int) -> set[int]:
    """All leaves obtained with endpoint/zero errors, allowing inconsistent replies."""
    if upper-lower == 1:
        return {upper}
    middle = (lower+upper)//2
    out: set[int] = set()
    for noise in (-zeta, F(0), zeta):
        if cdf[middle]+noise >= beta_hat/2:
            out |= median_outputs(cdf, beta_hat, zeta, lower, middle)
        else:
            out |= median_outputs(cdf, beta_hat, zeta, middle, upper)
    return out


def check_noisy_medians() -> None:
    beta = F(1, 2)
    zeta = beta/512
    count = 0
    for weights in product(range(5), repeat=5):
        if sum(weights) != 4:
            continue
        masses = [beta*w/4 for w in weights]
        cdf = [sum(masses[:i+1], F(0)) for i in range(5)]
        for beta_noise in (-zeta, F(0), zeta):
            beta_hat = beta+beta_noise
            for value in median_outputs(cdf, beta_hat, zeta, -1, 4):
                left = cdf[value-1] if value else F(0)
                right, atom = cdf[value], masses[value]
                assert right >= beta/2-3*zeta/2
                assert left < beta/2+3*zeta/2
                for atom_noise in (-zeta, F(0), zeta):
                    atom_hat = atom+atom_noise
                    if atom_hat <= beta_hat/8:
                        assert right < 5*beta/8+21*zeta/8
                    else:
                        assert atom > beta/9
                    count += 1
    record('exact_noisy_median_leaf_and_atom_cases', count)
    # Worst endpoint bounds for the orientation and heavy-atom tests.
    for ratio in [512, 513, 1023, 2048]:
        z = beta/ratio
        assert beta/2-5*z/2 > 3*(beta+z)/8
        assert beta/4+25*z/4 < 3*(beta-z)/8
        assert beta/8-9*z/8 > beta/9
        assert beta/2-5*z/2 > (beta+z)/8
        assert 3*beta/8-37*z/8 > (beta+z)/8
        assert (beta-z)/32 > z
        assert (beta+z)/32 < beta/9-z
    record('exact_median_orientation_endpoint_inequalities', 28)


def check_quantization() -> None:
    count = 0
    for numerator in range(1, 97):
        tau = F(numerator, 97)
        alphabet = ceil(1/tau)
        for j in range(-194, 195):
            value = F(j, 194)
            index = min(alphabet-1, int((value+1)*alphabet/2))
            answer = -1+F(2*index+1, alphabet)
            assert abs(value-answer) <= F(1, alphabet) <= tau
            count += 1
    record('exact_response_quantizer_cases', count)


def check_counting_constants() -> None:
    for i in range(1, 10001):
        c = i/10000
        x = c*c/32
        assert x*log2(8*2.718281828459045/x) <= c/2
    record('numerical_restricted_Warren_constant_cases', 10000)
    count = 0
    for c in range(1, 6):
        for n in [4, 7, 10, 31, 100]:
            a = F(1, 16)
            k = ceil(512*n**c/(a*a))
            rank = int(a*a*incidence_count(k)/(128*k**3))
            assert rank >= 4*n**c-1
            for delta in [F(1, 4), F(1, 2), F(3, 4)]:
                exponent = ceil(F(4*c+2)/delta)
                assert exponent*delta >= 4*c+2
                count += 1
    record('exact_PRF_rank_and_security_exponent_cases', count)
    # These are parameter identities, not a finite test of eventual k <= N or security.


def check_algebraic_transform_identity() -> None:
    vectors = [(F(1),F(0)), (F(0),F(1)), (F(1),F(1)), (F(1),F(-1))]
    count = 0
    for transform in [((1,0),(0,1)), ((2,1),(1,3)), ((3,-1),(2,1))]:
        transformed = [tuple(sum(F(transform[i][j])*v[j] for j in range(2))
                             for i in range(2)) for v in vectors]
        norms = [sum(t*t for t in v) for v in transformed]
        p = F(1)
        for q in norms:
            p *= q
        for i,j in product(range(2), repeat=2):
            numerator = 2*sum(v[i]*v[j]*(p/q) for v,q in zip(transformed,norms))
            numerator -= 4*p*(i==j)
            covariance = sum(v[i]*v[j]/q for v,q in zip(transformed,norms))/4
            assert numerator/(4*p) == 2*covariance-(i==j)
            if transform == ((1,0),(0,1)):
                assert numerator == 0
            count += 1
    record('exact_cleared_radial_equation_entries', count)


def main() -> None:
    check_grid_and_representation()
    check_rectangle_endpoints()
    check_noisy_medians()
    check_quantization()
    check_counting_constants()
    check_algebraic_transform_identity()
    result = {'status': 'passed', 'scope': 'finite checks, not formal verification',
              'seed': 20261004, 'checks': COUNTS}
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
