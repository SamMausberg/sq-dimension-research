#!/usr/bin/env python3
"""Adversarially optimized product distributions and exact rectangle masses.
Every reported upper bound is the exact largest rectangle mass for its saved
rational product distribution. It is not the infimum over product distributions.
"""
import json,math,time
from pathlib import Path
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog
from threadpoolctl import threadpool_limits
threadpool_limits(1)
OUT=Path(__file__).resolve().parent/'results'

def rect_data(B):
    k,l=B.shape
    bits=((np.arange(1,1<<k)[:,None]>>np.arange(k))&1).astype(np.int64)
    allowp=(bits@(B==-1).astype(np.int64)==0).astype(np.int64)
    allowm=(bits@(B==1).astype(np.int64)==0).astype(np.int64)
    return np.vstack([bits,bits]),np.vstack([allowp,allowm])

def optimize(B,cycles=5):
    k,l=B.shape;R,C=rect_data(B);p=np.full(k,1/k);q=np.full(l,1/l)
    for _ in range(cycles):
        coef=R*(C@q)[:,None]
        z=linprog(np.r_[np.zeros(k),1.],A_ub=np.c_[coef,-np.ones(len(R))],b_ub=np.zeros(len(R)),A_eq=np.r_[np.ones(k),0][None,:],b_eq=[1.],bounds=[(0,1)]*(k+1),method='highs')
        assert z.success;p=z.x[:k]
        coef=C*(R@p)[:,None]
        z=linprog(np.r_[np.zeros(l),1.],A_ub=np.c_[coef,-np.ones(len(R))],b_ub=np.zeros(len(R)),A_eq=np.r_[np.ones(l),0][None,:],b_eq=[1.],bounds=[(0,1)]*(l+1),method='highs')
        assert z.success;q=z.x[:l]
    return float(np.max((R@p)*(C@q))),p,q

def run():
    rng=np.random.default_rng(2026091139);results=[]
    for N in range(2,9):
        path=OUT/f'family_N{N}.npz'
        while not path.exists():time.sleep(.5)
        z=np.load(path);A=z['A'];K,X=A.shape;k=min(10,K);l=min(10,X)
        best=None
        for restart in range(10):
            cols=rng.choice(X,l,replace=False)
            candidates=np.flatnonzero(np.any(A[:,cols]==-1,axis=1))
            if len(candidates)>=k:rows=rng.choice(candidates,k,replace=False)
            else:rows=np.unique(np.r_[candidates,rng.choice(K,k,replace=False)])[:k]
            if len(rows)<k:rows=rng.choice(K,k,replace=False)
            val,p,q=optimize(A[np.ix_(rows,cols)])
            for step in range(4):
                rr=rows.copy();cc=cols.copy()
                if step%2:
                    available=np.flatnonzero(np.any(A[rr]==-1,axis=0));available=np.setdiff1d(available,cc)
                    if len(available):cc[int(rng.integers(l))]=rng.choice(available)
                else:
                    available=np.flatnonzero(np.any(A[:,cc]==-1,axis=1));available=np.setdiff1d(available,rr)
                    if len(available):rr[int(rng.integers(k))]=rng.choice(available)
                vv,pp,qq=optimize(A[np.ix_(rr,cc)])
                if vv<val-1e-9:val,p,q,rows,cols=vv,pp,qq,rr,cc
            if best is None or val<best[0]:best=(val,p,q,rows,cols)
        val,p,q,rows,cols=best;den=10**8
        pw=np.rint(p*den).astype(np.int64);pw[np.argmax(pw)]+=den-int(pw.sum())
        qw=np.rint(q*den).astype(np.int64);qw[np.argmax(qw)]+=den-int(qw.sum())
        R,C=rect_data(A[np.ix_(rows,cols)]);mass=(R@pw)*(C@qw);idx=int(np.argmax(mass));f=Fraction(int(mass[idx]),den*den)
        record={'N':N,'rows':rows.tolist(),'columns':cols.tolist(),'row_weights':pw.tolist(),'column_weights':qw.tolist(),'denominator':den,'upper_bound_exact':str(f),'upper_bound':float(f),'universal_lower_bound':'1/32768','max_rectangle_rows':rows[R[idx].astype(bool)].tolist(),'max_rectangle_columns':cols[C[idx].astype(bool)].tolist(),'restarts':10,'coordinate_support_steps':4,'alternating_LP_cycles':5}
        results.append(record);print(json.dumps(record),flush=True)
    (OUT/'rectangle_witnesses.json').write_text(json.dumps(results,indent=2))
if __name__=='__main__':run()
