#!/usr/bin/env python3
"""Independent CPU checks of the affine-line joint-distribution certificate."""
from __future__ import annotations
from fractions import Fraction as F
from pathlib import Path
import json, math
import numpy as np

out=Path(__file__).resolve().parent/'results'/'checks';out.mkdir(parents=True,exist_ok=True)
rows=[]
for p in (2,3,5,7,11):
    points=[(x,y) for x in range(p) for y in range(p)]
    lines=[(a,b) for a in range(p) for b in range(p)]
    P=np.array([[int((a*x+b-y)%p==0) for x,y in points] for a,b in lines],dtype=np.int64)
    K=p*p; J=np.ones((K,K),dtype=np.int64)
    blocks=np.kron(np.eye(p,dtype=np.int64),np.ones((p,p),dtype=np.int64))
    A=p*P-J
    assert np.array_equal(P@P.T,p*np.eye(K,dtype=np.int64)+J-blocks)
    assert np.array_equal(A@A.T,p*p*(p*np.eye(K,dtype=np.int64)-blocks))
    assert np.array_equal(A.sum(axis=1),np.zeros(K,dtype=np.int64))
    # Scaled residual likelihood ratios, with positive labels on the target line.
    scale=p-1
    Rplus=scale*A
    Rminus=-A
    for j,(a,b) in enumerate(lines):
        for i,(x,y) in enumerate(points):
            inside=bool(P[j,i])
            D=F(1,2*p) if inside else F(1,2*p*(p-1))
            plus=2*K*D-1 if inside else F(-1)
            minus=F(-1) if inside else 2*K*D-1
            assert scale*plus==int(Rplus[j,i])
            assert scale*minus==int(Rminus[j,i])
    Gscaled=Rplus@Rplus.T+Rminus@Rminus.T
    assert np.array_equal(Gscaled,(scale*scale+1)*(A@A.T))
    lam=F(p,2)*(1+F(1,(p-1)**2)); ratio=F(K)/lam
    assert ratio>=p
    rows.append({'p':p,'rows':K,'lambda':str(lam),'R':str(ratio),'integer_gram_verified':True})
prob=[]
for p in (1031,2053,4099,65537):
    assert all(p%d for d in range(2,math.isqrt(p)+1))
    t=(p/32)**.25; tau=1/t; gamma=1.05/t; alpha=F(2,3)
    assert gamma<.5
    R=2*p/(1+(p-1)**-2)
    lower=tau*tau*(float(alpha)*R-1/(4*gamma*gamma))
    conservative=float(alpha)*p/(t*t)-.25
    assert lower>=conservative and conservative>0
    prob.append({'p':p,'t':t,'tau':tau,'gamma':gamma,'query_lower_bound':lower,
                 'conservative_lower_bound':conservative})
result={'fields':rows,'success_probability_checks':prob,'all_passed':True}
(out/'affine.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
