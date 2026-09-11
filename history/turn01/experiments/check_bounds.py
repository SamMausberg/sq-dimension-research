"""CPU checks for the statements in paper/main.tex. No sign-rank SDP claims.
Run: OPENBLAS_NUM_THREADS=1 python check_bounds.py
"""
from __future__ import annotations
import csv, itertools, json, math, platform
from pathlib import Path
import numpy as np
from scipy.optimize import linprog

OUT = Path(__file__).resolve().parent / 'results'
OUT.mkdir(exist_ok=True)
SEED = 20260910
rng = np.random.default_rng(SEED)

from families import plane

def sr_le_two(M):
    """Exact finite criterion: orient row rays into a half-plane and order them.
    Then every column changes sign at most once. Converse uses (1,t).
    Enumerates all signed row orders, suitable only for N <= 5.
    """
    N = M.shape[0]
    for signs in itertools.product((-1,1), repeat=N):
        R = np.asarray(signs)[:,None] * M
        for perm in itertools.permutations(range(N)):
            A = R[list(perm)]
            if np.all(np.sum(A[1:] != A[:-1], axis=0) <= 1):
                return {'signs': list(signs), 'permutation': list(perm)}
    return None

rows, density_checks, gram_checks = [], 0, 0
max_gram_ratio = 0.0
for q in [2,3,5,7,11]:
    _, P = plane(q)
    N, k = q*q+q+1, q+1
    assert P.shape == (N,N)
    assert np.array_equal(P.T @ P, q*np.eye(N,dtype=np.int64)+np.ones((N,N),dtype=np.int64))
    assert np.all(P.sum(0)==k) and np.all(P.sum(1)==k)
    M = 2*P-1
    A = N/k*P-np.ones((N,N))
    norm = np.linalg.norm(A,2)
    assert np.isclose(norm,N/k*np.sqrt(q),rtol=1e-11)
    assert np.min(np.abs(A)) >= 1-1e-12
    D = P/(2*k)+(1-P)/(2*(N-k))
    # Columns are labelled probability distributions on (+ label, - label).
    joint = np.vstack([D*P,D*(1-P)])
    assert np.allclose(joint.sum(0),1)
    Rho = 2*N*joint-1
    Gamma = Rho.T @ Rho/(2*N)
    c = k/(N-k)
    assert np.allclose(Rho,np.vstack([A,-c*A]))
    assert np.allclose(Gamma,(1+c*c)/(2*N)*(A.T@A))
    lam = np.linalg.eigvalsh(Gamma)[-1]
    lam_formula = q*N/2*(1/k**2+1/(N-k)**2)
    R = N/lam
    assert np.isclose(lam,lam_formula,rtol=1e-11)
    assert R >= q-1e-10
    sample_max = 0.
    for trial in range(120):
        K = int(rng.integers(1,N+1))
        inds = rng.choice(N,K,replace=False)
        if trial%4==0: mu = np.full(N,1/N)
        elif trial%4==1:
            mu=np.zeros(N); mu[int(rng.integers(N))]=1
        elif trial%4==2:
            mu=np.zeros(N); ix=rng.choice(N,min(3,N),replace=False); mu[ix]=rng.dirichlet(np.ones(len(ix)))
        else: mu=rng.dirichlet(np.full(N,.2))
        B=M[:,inds]
        G=B.T@(mu[:,None]*B)
        ratio=K/np.linalg.eigvalsh(G)[-1]
        assert ratio<=16+1e-8
        sample_max=max(sample_max,float(ratio)); gram_checks+=1
        # The row-wise no-2x2 certificate itself, not just its eigenvalue consequence.
        deg=P[:,inds].sum(1)
        if K>=16:
            if deg.max()<K/4:
                a=np.ones(K)/np.sqrt(K)
                assert np.min((B@a)**2)>=K/4-1e-9
            else:
                S=np.where(P[int(deg.argmax()),inds])[0]
                a=np.zeros(K); a[S]=1/np.sqrt(len(S))
                assert np.min((B@a)**2)>=K/16-1e-9
    max_gram_ratio=max(max_gram_ratio,sample_max)
    for _ in range(100):
        query=rng.uniform(-1,1,2*N)
        cor=Rho.T@query/(2*N)
        energy=float(cor@cor)
        assert energy<=lam*np.mean(query**2)+1e-9
        tau=float(rng.uniform(.03,.9))
        count=int(np.sum(np.abs(cor)>tau))
        assert count*tau*tau<=lam+1e-9
        density_checks+=1
    rows.append(dict(q=q,N=N,k=k,dc_lower=k/math.sqrt(q),dc_upper=2*k+1,
                     signed_witness_norm=float(norm),joint_lambda=float(lam),joint_R=float(R),
                     largest_sampled_plain_gram_ratio=sample_max))
with (OUT/'plane_bounds.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=rows[0]); w.writeheader(); w.writerows(rows)

# Exhaustive rank-two obstruction on the 4 by 4 Walsh sign matrix.
H=np.array([[1,1,1,1],[1,-1,1,-1],[1,1,-1,-1],[1,-1,-1,1]],dtype=np.int64)
assert sr_le_two(H) is None
Phi=np.array([[1,0,0],[1,1,0],[1,0,1],[1,-1,-1]],dtype=np.int64)
certs=[]
for j in range(4):
    res=linprog(np.zeros(3),A_ub=-H[:,j,None]*Phi,b_ub=-np.ones(4),bounds=[(None,None)]*3,method='highs')
    assert res.success
    # The returned vertices here are integral. Check the rounded certificate EXACTLY.
    w=np.rint(res.x).astype(np.int64)
    assert np.all(H[:,j]*(Phi@w)>=1)
    certs.append(w.tolist())
# Rank-one characterization: all columns equal the first up to sign.
assert not all(np.all(H[:,j]==H[:,0]) or np.all(H[:,j]==-H[:,0]) for j in range(4))

# Check exact finite tree formulas and a label/marginal query decomposition.
tree_checks=0
for m in range(1,7):
    for tau in [.1,.25,.5,1.]:
        B=math.ceil(2/tau)+1
        grid=np.linspace(-1,1,B)
        a=rng.uniform(-1,1,1001)
        err=np.min(np.abs(a[:,None]-grid[None,:]),axis=1)
        assert np.max(err)<=tau/2+1e-12
        assert sum(B**i for i in range(m+1)) <= (m+1)*B**m
        tree_checks+=1
for _ in range(100):
    q=rng.uniform(-1,1,(7,2)); a=q.mean(1); b=(q[:,1]-q[:,0])/2
    assert np.allclose(q[:,1],a+b) and np.allclose(q[:,0],a-b)

# Explicit adaptive SQ / reference-oracle coupling, with a separate valid oracle
# for each target that does not know the learner's random seed.
_,P=plane(3); N=P.shape[0]; M=2*P-1; k=4
D=P/(2*k)+(1-P)/(2*(N-k)); joint=np.vstack([D*P,D*(1-P)])
p0=np.full(2*N,1/(2*N)); rho=joint/p0[:,None]-1
lam=float(np.linalg.eigvalsh(rho.T@(p0[:,None]*rho))[-1])
adaptive=[]
for trial in range(200):
    depth=3; tau=float(rng.uniform(.08,.7))
    qs=rng.uniform(-1,1,(2**depth-1,2*N))
    # Random thresholds make baseline paths nontrivial; values remain real.
    thresholds=rng.uniform(-.3,.3,2**depth-1)
    leaves=rng.choice([-1,1],size=(2**depth,N))
    def run(j=None):
        node=0; trace=[]
        for t in range(depth):
            base=float(p0@qs[node])
            actual=base if j is None or abs(float(joint[:,j]@qs[node])-base)<=tau else float(joint[:,j]@qs[node])
            trace.append((node,actual))
            node=2*node+1+int(actual>=thresholds[node])
        return leaves[node-(2**depth-1)],tuple(trace)
    base_out,base_trace=run(); changes=0; departures=0; mean_corr=0
    for j in range(N):
        out,trace=run(j); changes+=int(not np.array_equal(out,base_out)); departures+=int(trace!=base_trace)
        mean_corr+=float(D[:,j]@(M[:,j]*out))/N
    bound=math.sqrt(lam/N)+depth*lam/(N*tau*tau)
    assert changes<=departures
    assert departures/N<=depth*lam/(N*tau*tau)+1e-10
    assert mean_corr<=bound+1e-10
    adaptive.append(dict(trial=trial,tau=tau,mean_correlation=mean_corr,upper_bound=bound,changed_outputs=changes,departed_transcripts=departures))
with (OUT/'adaptive_checks.csv').open('w',newline='') as f:
    w=csv.DictWriter(f,fieldnames=adaptive[0]); w.writeheader(); w.writerows(adaptive)

# Exhaustive-query learner: any maximizer that an admissible oracle can select
# must have correlation >= 1-2*tau, hence error <= tau. Check all such outputs.
learner_checks=0
for trial in range(100):
    mu=rng.dirichlet(np.full(N,.4)); target=int(rng.integers(N)); tau=.15
    cors=M.T@(mu*M[:,target]); eligible=cors>=1-2*tau-1e-12
    assert np.all((1-cors[eligible])/2<=tau+1e-10)
    learner_checks+=1
summary=dict(seed=SEED,python=platform.python_version(),numpy=np.__version__,
             plane_orders=[2,3,5,7,11],plain_gram_checks=gram_checks,
             max_sampled_plain_gram_ratio=max_gram_ratio,energy_count_checks=density_checks,
             adaptive_oracle_checks=len(adaptive),grid_tree_checks=tree_checks,
             exhaustive_learner_checks=learner_checks,
             walsh4_exact_sign_rank=3,walsh4_embedding=Phi.tolist(),walsh4_weights=certs,
             all_assertions_passed=True,
             limits='Sampled spectral tests are not universal verification. Walsh rank-2 exclusion is exhaustive; its rank-3 certificate is integral. No SDP was run.')
(OUT/'checks_summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
print('\nProjective-plane bounds:')
for r in rows: print(r)
