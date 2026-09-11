"""Seeded CPU-only online SGD, with exactly bias-free Gaussian-initialized ReLU.
The empirical adversary chooses a fixed D on pilot seeds, not a worst-case proof.
Run: OPENBLAS_NUM_THREADS=1 python sgd_cpu.py
"""
from __future__ import annotations
import csv, itertools, json, math, platform
from pathlib import Path
import numpy as np
from families import plane

OUT=Path(__file__).resolve().parent/'results'; OUT.mkdir(exist_ok=True)
N_BITS=3; WIDTH=8; STEPS=1200; ETA=.05
X=np.asarray(list(itertools.product((-1.,1.),repeat=N_BITS)))
PARAMETERS=N_BITS*WIDTH+WIDTH

def run_sgd(y: np.ndarray, D: np.ndarray, seed: int, steps: int=STEPS):
    if not np.isclose(D.sum(),1) or np.any(D<0): raise ValueError('Invalid probability vector')
    rng=np.random.default_rng(seed)
    W=rng.normal(0,1/math.sqrt(N_BITS),(WIDTH,N_BITS))
    v=rng.normal(0,1/math.sqrt(WIDTH),WIDTH)
    tail=np.zeros(len(X)); samples=rng.choice(len(X),size=steps,p=D)
    for t,idx in enumerate(samples,1):
        x=X[idx]; z=W@x; a=np.maximum(z,0); f=float(v@a)
        margin=float(y[idx]*f)
        # Stable logistic derivative with respect to f.
        d=-float(y[idx])*math.exp(-np.logaddexp(0.,margin))
        gv=d*a; gW=(d*v*(z>0))[:,None]*x[None,:]
        W-=ETA*gW; v-=ETA*gv
        if t>=steps//2: tail+=np.maximum(X@W.T,0)@v
    pred=np.where(tail>=0,1.,-1.)
    err=float(D@(pred!=y)); uniform_err=float(np.mean(pred!=y))
    return err,uniform_err,float(np.linalg.norm(W)),float(np.linalg.norm(v))

_,P=plane(2)
targets=[('parity_degree1',0,X[:,0]),('parity_degree3',0,np.prod(X,axis=1))]
for j in range(7):
    y=np.full(8,-1.); y[:7]=2*P[:,j]-1
    targets.append(('plane_q2',j,y))

rng=np.random.default_rng(20260910)
rows=[]; distlog=[]
for family,j,y in targets:
    uniform=np.full(8,1/8)
    sparse=.1*uniform
    support=rng.choice(8,2,replace=False); sparse[support]+=.45
    pos=y>0; neg=~pos
    balanced=np.where(pos,.5/max(int(pos.sum()),1),.5/max(int(neg.sum()),1))
    # Ten fixed candidates. Pilot and reporting seeds are disjoint.
    candidates=[uniform,balanced]+[rng.dirichlet(np.full(8,.25)) for _ in range(8)]
    pilot=[float(np.mean([run_sgd(y,D,10000+s,steps=600)[0] for s in range(2)])) for D in candidates]
    chosen=int(np.argmax(pilot)); adversarial=candidates[chosen]
    for name,D in [('uniform',uniform),('sparse_mixture',sparse),('adversarial_search',adversarial)]:
        distlog.append(dict(family=family,target_id=j,distribution=name,probabilities=D.tolist(),
                            adversary_candidate=chosen if name=='adversarial_search' else None,
                            pilot_candidate_errors=pilot if name=='adversarial_search' else None))
        for seed in range(5):
            err,uerr,wn,vn=run_sgd(y,D,seed)
            rows.append(dict(family=family,target_id=j,distribution=name,seed=seed,n=N_BITS,width=WIDTH,
                T=STEPS,S=PARAMETERS,eta=ETA,error=err,uniform_error=uerr,W_norm=wn,v_norm=vn))
with (OUT/'sgd_raw.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=rows[0]);w.writeheader();w.writerows(rows)
(OUT/'sgd_distributions.json').write_text(json.dumps(distlog,indent=2)+'\n')
summary=[]
for family in ['parity_degree1','parity_degree3','plane_q2']:
    for name in ['uniform','sparse_mixture','adversarial_search']:
        data=[r['error'] for r in rows if r['family']==family and r['distribution']==name]
        summary.append(dict(family=family,distribution=name,runs=len(data),mean_error=float(np.mean(data)),
                            min_error=float(np.min(data)),max_error=float(np.max(data)),
                            zero_error_runs=int(np.sum(np.array(data)==0))))
report=dict(python=platform.python_version(),numpy=np.__version__,cpu_only=True,
    architecture=[N_BITS,WIDTH,1],T=STEPS,S=PARAMETERS,eta=ETA,
    init_variance=[1/N_BITS,1/WIDTH],relu_derivative_at_zero=0,sign_at_zero=1,
    tail='sum of post-update f_theta(t), t from T//2 through T inclusive',
    distribution_seed=20260910,reporting_seeds=list(range(5)),pilot_seeds=[10000,10001],
    pilot_steps=600,adversary='max mean pilot error among ten fixed distributions; not certified worst case',
    target_extension='projective-plane q=2 uses first seven cube points; eighth label is -1',
    runs=len(rows),summary=summary,
    limits='These finite runs neither establish distribution-independent learning nor refute the SGD conjecture.')
(OUT/'sgd_summary.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
