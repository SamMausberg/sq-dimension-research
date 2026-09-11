#!/usr/bin/env python3
"""Seeded finite checks of referee inequalities and new structural reductions."""
import itertools,json,math
from fractions import Fraction as F
from pathlib import Path
import numpy as np
from scipy.special import betainc
ROOT=Path(__file__).resolve().parent/'results'
rng=np.random.default_rng(2026091107)
counts={}
# All four answer endpoints in both acceptance implications.
cases=0
for _ in range(20000):
    r=F(int(rng.integers(1,100)),100);u=F(int(rng.integers(1,100)),100)
    tau=r*u*F(int(rng.integers(1,100)),800)
    a=F(int(rng.integers(0,1001)),1000);s=a*u
    for eu,es in itertools.product([-1,1],repeat=2):
        uh=u+eu*tau;sh=s+es*tau
        if sh>=r*uh/2:assert a>=r/4
        if a>=3*r/4:assert sh>=r*uh/2
        cases+=1
counts['acceptance_endpoint_cases']=cases
# Peeling/error budgets and multiplicative elimination potential.
for _ in range(2000):
    K=int(rng.integers(2,300));target=int(rng.integers(K));remaining=list(range(K));total=0.
    while len(remaining)>1:
        rest=[x for x in remaining if x!=target];remove=rng.choice(rest,int(rng.integers(1,len(rest)+1)),replace=False)
        b=len(remove)/len(remaining);total+=b;remaining=[x for x in remaining if x not in remove]
    assert total<=math.log(K)+1e-12
counts['elimination_sequences']=2000
# Grid empty rows, no negative 2x2, all-positive candidate, exact strictification.
empty=[]
for N in range(2,9):
    data=np.load(ROOT/f'family_N{N}.npz');A=data['A'];Fmat=data['template'];k=(Fmat==-1).sum(1)
    empty.append({'N':N,'empty_template_rows':int((k==0).sum()),'incidences':int(k.sum())})
    assert int(k.sum())==2*N**4-(N*(N+1)//2)**2
    assert np.all(A[k==0]==1)
    assert np.any(np.all(A==1,axis=1))
for _ in range(500):
    U=rng.integers(-3,4,size=(10,4));V=rng.integers(-3,4,size=(4,10));scores=U@V
    out=np.where(scores>=0,1,-1)
    shifted=scores+.5
    assert np.all(out*shifted>0)
counts['strictification_tests']=500;counts['empty_rows']=empty
# Exact singleton-star query property on every negative atom in the small families.
star=0
for N in range(2,6):
    A=np.load(ROOT/f'family_N{N}.npz')['A']
    for target in rng.choice(len(A),min(30,len(A)),replace=False):
        for p in np.flatnonzero(A[target]==-1):
            candidates=np.flatnonzero(A[:,p]==-1)
            for _ in range(5):
                chosen=candidates[rng.integers(0,2,size=len(candidates)).astype(bool)]
                union=np.any(A[chosen]==-1,axis=0) if len(chosen) else np.zeros(A.shape[1],bool);union[p]=False
                intersection=union&(A[target]==-1)
                truth=(A[target]==-1).copy();truth[p]=False
                assert np.array_equal(intersection,truth if target in chosen else np.zeros_like(truth));star+=1
counts['star_union_tests']=star
# Exact uniform cube rectangle enumeration for n=1,3, and finite concentration tails.
for n in [1,3]:
    X=np.array(list(itertools.product([-1,1],repeat=n)));A=np.where(X@X.T>0,1,-1);K=len(X);area=0
    for bits in range(1,1<<K):
        ids=[i for i in range(K) if bits>>i&1]
        for c in [-1,1]:area=max(area,len(ids)*int(np.all(A[ids]==c,axis=0).sum()))
    assert area/K**2<=math.exp(-n/4)
counts['exhaustive_cube_dimensions']=[1,3]
# Every arbitrary-product PG bound has an explicit probabilistic witness.
pg=0
for q in [2,3,5,7]:
    V=[]
    for a in itertools.product(range(q),repeat=3):
        if not any(a):continue
        lead=next(z for z in a if z);inv=pow(lead,-1,q);b=tuple(z*inv%q for z in a)
        if b not in V:V.append(b)
    V=np.array(V);P=((V@V.T)%q==0).astype(int);K=len(V);Delta=q+1
    assert np.all(P.sum(0)==Delta) and np.all(P.sum(1)==Delta)
    for _ in range(100):
        mu=rng.dirichlet(np.full(K,.4));nu=rng.dirichlet(np.full(K,.4));p=float(nu@P@mu)
        if p>=.5:
            x=int(np.argmax(nu@P));neighbors=np.flatnonzero(P[:,x]);j=neighbors[np.argmax(nu[neighbors])]
            witness=nu[j]*max(float(mu@P[j]),1-float(mu@P[j]));assert witness>=1/(4*Delta)-1e-12
        else:
            expectation=(1-p)/(2*Delta)*(1-1/(2*Delta))**Delta;assert expectation>=1/(8*Delta)-1e-12
        pg+=1
counts['arbitrary_product_PG_tests']=pg
counts['cap_fraction_d6']=float(.5*betainc(2.5,.5,1/12))
counts['all_assertions_passed']=True
(ROOT/'finite_checks.json').write_text(json.dumps(counts,indent=2));print(json.dumps(counts,indent=2))
