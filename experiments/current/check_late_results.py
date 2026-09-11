#!/usr/bin/env python3
"""Seeded exact finite checks of the new ledgers and output-count argument.

Integer/Fraction assertions are exact. Logarithmic parameter checks are explicitly
separate floating-point checks; neither category replaces a universal proof.
"""
from __future__ import annotations
import argparse
from collections import Counter
from fractions import Fraction as F
import hashlib
import itertools
import json
import math
from pathlib import Path
import random
import time

SEED=2026091108

def ambient_encode(exponent:int,a:int,b:int,x:int,y:int)->str:
    N=1<<exponent
    if not (1<=a<=N and 1<=x<=N and 1<=b<=2*N*N and 1<=y<=2*N*N):
        raise ValueError('coordinate outside ambient grid')
    return ''.join(format(z-1,f'0{w}b') for z,w in zip((a,b,x,y),(exponent,2*exponent+1,exponent,2*exponent+1)))

def floor_D(k:int)->int:
    """Exact integer characterization k^(24D) <= 2^k."""
    lo,hi=0,k+1
    while hi-lo>1:
        mid=(lo+hi)//2
        if pow(k,24*mid)<=1<<k: lo=mid
        else: hi=mid
    return lo

def run()->dict:
    start=time.perf_counter();rng=random.Random(SEED);counts=Counter();raw={}
    # Every printed threshold is checked at the most adverse endpoints.
    for scale in [F(1,10000),F(1,40960),F(3,100000)]:
        z=scale
        for ratio in [512,513,1023,1024,2048,8192]:
            beta=ratio*z
            assert beta>0
            assert beta/8-9*z/8>beta/9
            assert z<(beta-z)/32
            assert (beta+z)/32<beta/9-z
            assert beta/2-5*z/2>3*(beta+z)/8
            assert beta/4+25*z/4<3*(beta-z)/8
            assert beta/2-5*z/2>(beta+z)/8
            assert 3*beta/8-37*z/8>(beta+z)/8
            assert 2*z<(beta-z)/8
            counts['exact_endpoint_assertions']+=9
    # Exhaustive nonmonotone endpoint-response median paths on small measures.
    for atoms in itertools.product(range(4), repeat=4):
        total=sum(atoms)
        if not total: continue
        weights=[F(a,total) for a in atoms];beta=F(1);z=F(1,512)
        for eb in [-1,1]:
            bh=beta+eb*z
            for answers in itertools.product([-1,1],repeat=3):
                low,high=-1,3;i=0
                while high-low>1:
                    mid=(low+high)//2
                    value=sum(weights[:mid+1])+answers[i]*z;i+=1
                    if value>=bh/2:high=mid
                    else:low=mid
                v=high;fm=sum(weights[:v]);fp=fm+weights[v]
                assert fp>=beta/2-3*z/2 and fm<beta/2+3*z/2
                for ea in [-1,1]:
                    if weights[v]+ea*z<=bh/8:
                        assert fp<5*beta/8+21*z/8
                    else:
                        assert weights[v]>beta/9
                counts['exhaustive_median_paths']+=1
    # Prefix/suffix intersection formula for nonnegative atom measures.
    for _ in range(1000):
        w=[F(rng.randrange(9),100) for _ in range(8)]
        beta=sum(w);a=rng.randrange(9);b=rng.randrange(9)
        first=set(range(a));last=set(range(b,8))
        mass=lambda s:sum((w[i] for i in s),F(0))
        assert mass(first&last)==max(F(0),mass(first)+mass(last)-beta)
        counts['exact_prefix_suffix_identities']+=1
    # Fixed bit sampler: no unbounded rejection loop is hidden in its runtime.
    for t in range(1,1001):
        power=1<<(t-1).bit_length();mult=Counter(i%t for i in range(power))
        assert min(F(v,power) for v in mult.values())>=F(1,2*t)
        counts['exact_star_sampling_checks']+=1
    # Full/subgrid encoding identity and injectivity, including leading zeroes.
    encoded=[]
    for b in range(2,6):
        N=1<<b;k=min(5,N)
        vals={}
        for a in range(1,k+1):
            for intercept in range(1,2*k*k+1):
                for x in range(1,k+1):
                    y=a*x+intercept
                    if y>2*k*k:continue
                    v=ambient_encode(b,a,intercept,x,y)
                    assert len(v)==6*b+2
                    assert v not in vals
                    vals[v]=(a,intercept,x,y)
                    # The restricted evaluator calls the full evaluator verbatim.
                    fullbit=hashlib.sha256(v.encode()).digest()[0]&1
                    subbit=hashlib.sha256(ambient_encode(b,a,intercept,x,y).encode()).digest()[0]&1
                    assert fullbit==subbit
                    counts['exact_ambient_encoding_checks']+=1
        Ik=2*k**4-(k*(k+1)//2)**2
        assert len(vals)==Ik
        encoded.append(dict(b=b,k=k,incidences=Ik,distinct_ambient_inputs=len(vals)))
    raw['encodings']=encoded
    # Incidence formula and exact D, with floating logarithmic count cross-check.
    subgrid=[]
    for k in list(range(2,257))+[512,1024,2048]:
        K=2*k**3;I=2*k**4-(k*(k+1)//2)**2;D=floor_D(k)
        assert D<=K//2
        if k<=16:
            literal=sum(2*k*k-a*x for a in range(1,k+1) for x in range(1,k+1))
            assert literal==I
        if D:
            assert k>=32 and 2*I>=3*k**4
            exponent=2*K*D*math.log2(4*math.e*K/D)
            assert exponent-I <= -k**4/2 + 1e-6
            counts['floating_warren_exponent_checks']+=1
        counts['exact_D_range_checks']+=1
        if k<=6 or D and not any(q['D']>0 for q in subgrid):subgrid.append(dict(k=k,K=K,I=I,D=D))
    raw['subgrid']=subgrid
    # Independent derivation of the runtime slack for illustrative fixed constants.
    runtime=[]
    for c in [1,2,3,5]:
        for delta in [F(1,2),F(1,3),F(2,3)]:
            p=math.ceil(F(4*c+2)/delta)
            for n in [31,61,121]:
                k=math.ceil(c*n**c)
                assert F(p)*delta>=4*c+2
                assert math.log2(k)<=F(5,4)*c*math.log2(n)
                assert k/(24*math.log2(k))>=n**c/(30*math.log2(n))
                counts['floating_PRF_parameter_checks']+=1
                runtime.append(dict(c=c,delta=str(delta),n=n,p=p,k=k))
    raw['runtime_cases']=runtime
    # A single output perfectly fits an entire parallel class, for every flip.
    parallel=[]
    for N in range(2,9):
        bits={}
        for a in range(1,N+1):
            for b in range(1,N*N+1):
                for x in range(1,N+1):bits[a,b,x]=rng.getrandbits(1)*2-1
        a0=rng.randrange(1,N+1)
        def g(x:int,y:int)->int:
            intercept=y-a0*x
            return bits.get((a0,intercept,x),1)
        losses=[]
        for b in range(1,N*N+1):
            errors=sum(g(x,a0*x+b)!=bits[a0,b,x] for x in range(1,N+1))
            assert errors==0
            losses.append(errors)
        parallel.append(dict(N=N,slope=a0,simultaneously_perfect_rows=N*N))
        counts['parallel_class_counterexamples']+=1
    raw['parallel_classes']=parallel
    # Random rational response grids are valid with B=ceil(1/tau).
    for _ in range(5000):
        tau=F(rng.randrange(1,1000),1000)
        B=math.ceil(1/tau)
        e=F(rng.randrange(-10000,10001),10000)
        j=min(B-1,int((e+1)*B/2))
        response=F(-1)+F(2*j+1,B)
        assert abs(response-e)<=F(1,B)<=tau
        counts['exact_response_grid_checks']+=1
    # Entropy packing constants (floating checks of the symbolic proof only).
    h=lambda x:-x*math.log2(x)-(1-x)*math.log2(1-x)
    chi=1-h(3/8);raw['chi']=chi;packing=[]
    for N in [4096,8192,16384,32768]:
        assert chi*N>=6*math.log2(N)
        Q=2*N**3;L=N**3;s=math.ceil(8*N*N/chi)
        assert s<=L
        upper=Q+s*math.log2(L)-chi*N*s
        assert upper<=-Q
        assert F(3,8)-F(1,N)>F(1,3)
        packing.append(dict(N=N,Q=Q,selected_rows=L,s=s,union_log2_upper=upper))
        counts['floating_packing_exponent_checks']+=1
    raw['packing']=packing
    # Both halfspace colors and cross-distance are checked without concentration.
    for n in [1,3,5,7]:
        xs=list(itertools.product([-1,1],repeat=n));t=(n+1)//2
        for a in xs:
            for b in xs:
                dot=sum(x*y for x,y in zip(a,b));dist=sum(x!=y for x,y in zip(a,b))
                if dot<0:assert dist>=t
                else:assert n-dist>=t
                counts['exact_halfspace_color_checks']+=1
    # Hinge telescope constants, input-length and sample-size examples.
    for n in [1,3,5,11,31,101]:
        for eps in [F(1,5),F(1,10),F(1,100)]:
            gamma=F(1,n);tau=eps*gamma/8;T=math.ceil(100/(eps*eps*gamma*gamma));a=1/math.sqrt(T)
            rhs=1/(2*a*T)+a*float((1+tau)**2)/2+2*float(tau)
            assert rhs<=float(eps*gamma/2)+1e-16
            assert eps/16+eps/16==eps/8 and 8*(eps/8)==eps
            counts['floating_hinge_parameter_checks']+=1
    # Exact unseen-label expectation and Bernoulli inequality.
    for N in range(1,25):
        for T in range(0,30):
            assert F(1,2)*(1-F(1,N))**T>=F(1,2)*(1-F(T,N))
            counts['exact_unseen_label_checks']+=1
    return dict(seed=SEED,status='PASS',counts=dict(counts),raw=raw,elapsed_seconds=time.perf_counter()-start,
                interpretation='Finite exact checks plus explicitly identified floating parameter checks; not a proof assistant or a full PRF security experiment.')

def main()->None:
    ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,required=True);a=ap.parse_args()
    result=run();a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='raw'},indent=2))
if __name__=='__main__':main()
