#!/usr/bin/env python3
"""Independently audit saved rectangle laws, trajectories and finite inequalities.

Integer and Fraction computations certify the saved oracle/mixture assertions.
Floating-point tests of transcendental inequalities are explicitly separate.
"""
from __future__ import annotations
import json, math, platform
from fractions import Fraction
from pathlib import Path
import numpy as np
import scipy
from rectangle_sq import RHO, EPS, TAU, P_CAP, rank_two_exhaust, make_dist

OUT=Path(__file__).resolve().parent/'results'

def indices_mask(n,indices):
    a=np.zeros(n,dtype=bool);a[indices]=True;return a

def audit():
    count={'certificates':0,'coverage_coordinates':0,'trajectories':0,'proposal_rounds':0,
           'rank_certificates':0,'robust_acceptance_endpoint_cases':0,
           'entropy_ball_cases':0,'energy_cases':0,'elimination_sequences':0}
    stored={}
    for N in [2,3,4,5]:
        z=np.load(OUT/f'family_N{N}.npz');A=z['A'];F=z['F'];K,X=A.shape
        assert np.all(A[F==1]==1)
        cert=json.loads((OUT/f'certificates_N{N}.json').read_text())
        for rect in cert['catalog']:
            assert np.all(A[np.ix_(rect['T'],rect['S'])]==rect['color'])
        for c in cert['certificates']:
            U,V=c['U'],c['V'];den=sum(c['integer_weights']);assert den==c['denominator']
            assert len(c['rectangles'])==len(c['integer_weights']) and min(c['integer_weights'])>0
            vs=set(V);nums=[]
            for x in U:
                val=sum(int(w)*len(vs.intersection(cert['catalog'][j]['T']))
                        for j,w in zip(c['rectangles'],c['integer_weights']) if x in cert['catalog'][j]['S'])
                assert val*RHO>=den*len(V)
                nums.append(val);count['coverage_coordinates']+=1
            assert min(nums)==c['minimum_coverage_numerator']
            assert den*len(V)==c['coverage_denominator']
            count['certificates']+=1
        stored[N]=(A,cert)
    for line in (OUT/'runs.jsonl').read_text().splitlines():
        rec=json.loads(line);A,cert=stored[rec['N']];K,X=A.shape
        w=np.zeros(X,dtype=np.int64);w[rec['support']]=rec['weights'];den=int(w.sum())
        assert len(rec['support'])<=20 and den==rec['weight_denominator']
        h=A[rec['target']];g=np.ones(X,dtype=np.int8);U=np.ones(X,dtype=bool);V=np.ones(K,dtype=bool)
        total_wrong=Fraction(0);mult=Fraction(1);progress=0.;peels=elim=reject=0
        def mass(mask):return Fraction(int(w[mask].sum()),den)
        for t in rec['trace']:
            c=cert['certificates'][t['certificate']];r=cert['catalog'][t['rectangle']]
            assert c['U']==np.flatnonzero(U).tolist() and c['V']==np.flatnonzero(V).tolist()
            assert t['rectangle'] in c['rectangles']
            S=U & indices_mask(X,r['S']);T=V & indices_mask(K,r['T'])
            u=mass(U);s=mass(S);color=r['color'];wrong=mass(S & (h!=color))
            assert u==Fraction(t['u']) and s==Fraction(t['s']) and t['color']==color
            assert int(V.sum())==t['V_size'] and int(T.sum())==t['T_size']
            assert u>EPS/4
            if t['action']=='reject':
                assert s<u/(2*RHO);reject+=1
            else:
                assert s>=u/(2*RHO) and wrong==Fraction(t['wrong_mass'])
                if t['action']=='peel':
                    assert wrong<=2*TAU and s/u>=Fraction(1,4*RHO)
                    assert Fraction(t['progress'])==s/u
                    total_wrong+=wrong;progress+=float(s/u);g[S]=color;U[S]=False;peels+=1
                else:
                    assert t['action']=='eliminate' and wrong>2*TAU and not T[rec['target']]
                    b=Fraction(int(T.sum()),int(V.sum()));assert b==Fraction(t['progress']) and b<1
                    mult/=1-b;progress+=float(b);V[T]=False;elim+=1
                assert V[rec['target']]
            count['proposal_rounds']+=1
        assert mult==Fraction(K,int(V.sum()))
        assert peels==rec['peels'] and elim==rec['eliminations'] and reject==rec['rejects']
        assert peels<=P_CAP and peels+elim+reject==rec['rounds']
        assert total_wrong<=3*TAU*P_CAP
        assert mass(g!=h)==Fraction(rec['error_exact'])==total_wrong+mass(U & (h!=1))
        assert progress<=math.log(K)+math.log(8/float(EPS))+1+1e-12
        assert rec['termination'] in ['residual','empty']
        if rec['termination']=='residual':assert mass(U)<=EPS/4
        else:assert not np.any(U)
        assert rec['queries']==2*rec['rounds']+peels+elim+(rec['termination']=='residual')
        assert mass(g!=h)<=EPS/2
        if rec['tag']=='attack_small_negative_mass':
            assert mass(h==-1)==Fraction(24999,1000000)
        count['trajectories']+=1
    for rec in json.loads((OUT/'exact_signranks_N2.json').read_text()):
        A=np.array(rec['matrix'],dtype=np.int64);phi=np.array(rec['embedding_rank3'],dtype=np.int64);W=np.array(rec['weights_rank3'],dtype=np.int64)
        assert np.all(A*(W@phi.T)>0)
        rank,tested,_=rank_two_exhaust(A)
        assert rank==rec['sign_rank'] and tested==rec['orientation_assignments_tested']
        count['rank_certificates']+=1
    # Regression: paired input order must not relabel distribution weights.
    assert make_dist(5,[4,1],[2,7]).tolist()==[0,7,0,0,2]
    rng=np.random.default_rng(20260911)
    # Check the endpoint algebra of the adversarial-tolerance acceptance test.
    # r in (0,1], t=tau/u <= r/8, a in [0,1], and both answer errors +/-tau.
    for _ in range(5000):
        r=Fraction(int(rng.integers(1,1001)),1000)
        z=Fraction(int(rng.integers(0,1001)),1000);t=r*z/8
        a=Fraction(int(rng.integers(0,1001)),1000)
        for eu in [-t,t]:
            for es in [-t,t]:
                accepted=a+es>=r*(1+eu)/2
                if accepted:assert a>=r/4
                if a>=3*r/4:assert accepted
                count['robust_acceptance_endpoint_cases']+=1
    # Exact partition and error summation for randomly assigned finite peel sets.
    for _ in range(1000):
        X=int(rng.integers(1,41));p=int(rng.integers(1,11))
        w=rng.integers(0,1001,size=X);w[0]+=1;den=int(w.sum())
        owner=rng.integers(-1,p,size=X);h=rng.choice([-1,1],size=X);colors=rng.choice([-1,1],size=p)
        g=np.array([1 if t==-1 else colors[t] for t in owner]);actual=int(w[g!=h].sum())
        wrong=sum(int(w[(owner==t)&(h!=colors[t])].sum()) for t in range(p))
        residual=int(w[owner==-1].sum());assert actual<=wrong+residual
    count['peeling_partition_cases']=1000
    for I in range(1,201):
        for j in [0,I//10,I//4,(I-1)//2]:
            eta=j/I
            H=0. if j==0 else -eta*math.log2(eta)-(1-eta)*math.log2(1-eta)
            ball=sum(math.comb(I,t) for t in range(j+1))
            assert math.log2(ball)<=H*I+1e-10
            count['entropy_ball_cases']+=1
    for _ in range(500):
        z=int(rng.integers(2,20));k=int(rng.integers(1,30))
        mu=rng.random(z);mu/=mu.sum();res=rng.normal(size=(z,k));a=rng.uniform(-1,1,z)
        G=res.T@(mu[:,None]*res);lam=float(np.linalg.eigvalsh(G)[-1]);c=res.T@(mu*a)
        assert float(c@c)<=lam*float(mu@(a*a))+1e-10
        tau=float(rng.uniform(.001,2));assert np.count_nonzero(abs(c)>tau)*tau*tau<=lam+1e-10
        count['energy_cases']+=1
    for _ in range(1000):
        K=int(rng.integers(2,10000));v=K;total=0.;mult=Fraction(1)
        while v>1 and rng.random()<.9:
            remove=int(rng.integers(1,v));b=Fraction(remove,v);total+=float(b);mult/=1-b;v-=remove
        assert mult==Fraction(K,v) and total<=math.log(K)+1e-10
        count['elimination_sequences']+=1
    # Uniform shattered-set rectangle masses and the elementary counting estimate.
    for v in range(1,101):
        assert max(Fraction(s,v*2**s) for s in range(1,v+1))==Fraction(1,2*v)
    for q in range(1,101):
        for v in range(1,q+1):
            k=sum(math.comb(q,i) for i in range(v+1))
            assert math.log(k)<=v*math.log(math.e*q/v)+1e-10
    count['shattered_rectangle_cases']=100
    count['sauer_counting_bound_cases']=5050
    # Constants for the self-contained geometric proof and the global tail bound.
    caplower=8/(15*math.pi*12**2.5)
    assert caplower/48>2**-18
    assert TAU<=EPS/8 and TAU<=EPS/Fraction(64*RHO)
    for K in [1,2,16,54,128,250,10**9]:
        B=math.log(K)+math.log(8/float(EPS))+1
        rounds=math.ceil(8*RHO*(B+math.log(2/float(EPS))))
        assert math.exp(B-rounds/(8*RHO))<=float(EPS)/2+1e-12
    out={'all_assertions_passed':True,'seed':20260911,'counts':count,
         'python':platform.python_version(),'numpy':np.__version__,'scipy':scipy.__version__,
         'geometric_rectangle_lower_bound':caplower/48,
         'notes':'Mixture coverage, trajectories, sign certificates, and local tolerance inequalities use exact arithmetic; energy, entropy, log and cap checks use floating-point tolerances.'}
    (OUT/'verification.json').write_text(json.dumps(out,indent=2));print(json.dumps(out,indent=2))

if __name__=='__main__':audit()
