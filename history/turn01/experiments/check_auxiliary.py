"""Additional seeded finite checks of geometric, minimax, gradient and prior steps."""
from __future__ import annotations
import itertools, json, math
from fractions import Fraction
from pathlib import Path
import numpy as np
from scipy.optimize import linprog
from families import plane
rng=np.random.default_rng(20260911)
OUT=Path(__file__).resolve().parent/'results'; OUT.mkdir(exist_ok=True)

isotropy=[]
for d in [2,3,4]:
    for trial in range(4):
        K=3*d+2; V=rng.normal(size=(d,K)); shape=np.eye(d)
        mindet=min(abs(float(np.linalg.det(V[:,ix]))) for ix in itertools.combinations(range(K),d))
        assert mindet>1e-10
        # A numerical search for the radial transform, not a convergence theorem.
        for iteration in range(20000):
            inv=np.linalg.inv(shape); denominator=np.sum(V*(inv@V),axis=0)
            new=d/K*((V/denominator)@V.T)
            new/=np.linalg.det(new)**(1/d)
            if np.linalg.norm(new-shape)<1e-12: shape=new; break
            shape=new
        eig,O=np.linalg.eigh(shape); T=(O*(1/np.sqrt(eig)))@O.T
        U=T@V; U/=np.linalg.norm(U,axis=0)
        residual=float(np.linalg.norm(U@U.T-K/d*np.eye(d),2)); assert residual<1e-8
        Z=rng.normal(size=(10,d)); M=np.sign(Z@V)
        E=Z@np.linalg.inv(T); E/=np.linalg.norm(E,axis=1)[:,None]
        assert np.array_equal(np.sign(E@U),M)
        A=M*rng.uniform(1,5,M.shape)
        lhs=np.sum(E*(A@U.T),axis=1)
        assert np.all(lhs>=K/d-1e-8)
        spectral_lower=math.sqrt(10*K)/np.linalg.norm(A,2)
        assert spectral_lower<=d+1e-8
        mu=rng.dirichlet(np.ones(10)); G=M.T@(mu[:,None]*M)
        weighted_lower=math.sqrt(K/np.linalg.eigvalsh(G)[-1]); assert weighted_lower<=d+1e-8
        isotropy.append(dict(d=d,K=K,trial=trial,iterations=iteration+1,
            max_isotropy_error=residual,min_determinant=mindet,
            spectral_lower=float(spectral_lower),weighted_lower=float(weighted_lower)))

minimax=[]
for trial in range(100):
    N=5; k=6; features=rng.uniform(-1,1,(N,k)); h=rng.choice([-1,1],N)
    pay=h[:,None]*np.column_stack([features,-features]); J=2*k
    # Maximize t, subject to payoff*lambda >= t, lambda >=0, sum lambda=1.
    primal=linprog(np.r_[np.zeros(J),-1], A_ub=np.column_stack([-pay,np.ones(N)]),
        b_ub=np.zeros(N),A_eq=np.r_[np.ones(J),0][None,:],b_eq=[1],
        bounds=[(0,None)]*J+[(None,None)],method='highs')
    # Minimize v, subject to payoff.T*D <= v, D >=0, sum D=1.
    dual=linprog(np.r_[np.zeros(N),1], A_ub=np.column_stack([pay.T,-np.ones(J)]),
        b_ub=np.zeros(J),A_eq=np.r_[np.ones(N),0][None,:],b_eq=[1],
        bounds=[(0,None)]*N+[(None,None)],method='highs')
    assert primal.success and dual.success
    gap=abs(float(primal.x[-1]-dual.x[-1])); assert gap<1e-8
    assert np.min(pay@primal.x[:-1])>=primal.x[-1]-1e-8
    minimax.append(dict(trial=trial,value=float(primal.x[-1]),gap=gap))

for _ in range(1000):
    R=float(np.exp(rng.uniform(-8,8))); alpha=float(rng.uniform(.5,1))
    M=max(0.,alpha*R-math.sqrt(R))+float(rng.uniform(0,3))
    assert R<=4+4*M+1e-10
    S=int(rng.integers(1,101)); B=float(rng.uniform(.1,3))
    delta=float(rng.uniform(.001,B*math.sqrt(S))); tau=delta/(B*math.sqrt(S))
    error=B*rng.uniform(-tau,tau,S)
    assert np.linalg.norm(error)<=delta+1e-10

# Exact prior-conditioning counterexample on four domain points.
X=np.array(list(itertools.product((-1,1),repeat=2)),dtype=np.int64)
p=Fraction(1,100); prior=[1-p,p]; good=Fraction(0)
for gi in range(2):
    for xi in range(4):
        pred=X[:,gi]*X[xi,gi]*X[xi,1]
        corr=int(pred@X[:,1])
        if corr>0: good+=prior[gi]/4
assert good==p
conditioned=Fraction(1); assert conditioned!=good

cube=np.array(list(itertools.product((-1.,1.),repeat=3))); h=np.prod(cube,axis=1)
res=linprog(np.zeros(3),A_ub=-h[:,None]*cube,b_ub=-np.ones(8),bounds=[(None,None)]*3,method='highs')
assert res.status==2  # Infeasible homogeneous linear representation of cubic parity.
for _ in range(100):
    W=rng.normal(size=(8,3)); v=rng.normal(size=8)
    f=np.maximum(cube@W.T,0)@v; fm=np.maximum(-cube@W.T,0)@v
    assert np.allclose(f-fm,cube@(v@W))
    assert np.mean(np.where(f>=0,1,-1)!=h)>=1/8

# Numerically audit the certificate-space dimension bound for target-dependent D.
_,P=plane(2); N=P.shape[0]
for _ in range(100):
    K=int(rng.integers(1,30)); ids=rng.integers(0,N,K)
    mu=rng.dirichlet(np.full(N,1.)); D=rng.dirichlet(np.ones(N),size=K).T
    pos=P[:,ids]; joint=np.vstack([D*pos,D*(1-pos)]); p0=np.r_[mu/2,mu/2]
    rho=joint/p0[:,None]-1; G=rho.T@(p0[:,None]*rho)
    lam=float(np.linalg.eigvalsh(G)[-1]); R=K/lam
    assert np.allclose(p0@rho,0,atol=1e-10)
    assert np.diag(G).min()>=1-1e-10 and R<=2*N-1+1e-8

cover_checks=[]
for q in [2,3,5,7,11]:
    _,P=plane(q); N=P.shape[0]; H=2*P-1; epsilon=.2; delta=epsilon/2
    s=int(math.ceil((4*math.log(N)+2)/epsilon))
    assert N*N*math.exp(-delta*s)<=math.exp(-1)+1e-12
    for trial in range(2):
        D=rng.dirichlet(np.full(N,.4)); distances=(1-H.T@(D[:,None]*H))/2
        for attempt in range(100):
            sample=rng.choice(N,s,p=D)
            _, reps, inverse=np.unique(H[sample].T,axis=0,return_index=True,return_inverse=True)
            gap=max(float(distances[j,reps[inverse[j]]]) for j in range(N))
            if gap<=delta+1e-10: break
        else: raise RuntimeError('Failed to find the probabilistically guaranteed finite cover')
        assert len(reps)<=1+s+s*(s-1)//2
        assert gap<=delta+1e-10
        for target in range(N):
            cors=H[:,reps].T@(D*H[:,target]); best=float(cors.max()); tau=epsilon/2
            # Every output that any valid response vector can make a maximizer.
            eligible=cors>=best-2*tau-1e-12
            assert np.all((1-cors[eligible])/2<=epsilon+1e-9)
        cover_checks.append(dict(q=q,trial=trial,sample_length=s,cover_size=len(reps),
            maximum_cover_distance=gap,attempts=attempt+1))

out=dict(seed=20260911,isotropy_checks=isotropy,
    maximum_isotropy_residual=max(r['max_isotropy_error'] for r in isotropy),
    minimax_checks=100,maximum_minimax_gap=max(r['gap'] for r in minimax),
    algebra_gradient_checks=1000,prior_probability=str(good),replaced_prior_probability=str(conditioned),
    parity_linear_program_status=int(res.status),relu_odd_part_checks=100,
    certificate_dimension_checks=100,fixed_distribution_cover_checks=cover_checks,all_assertions_passed=True,
    limits='Isotropy iteration and LP tests are finite numerical checks, not formal certificates of the universal theorems.')
(OUT/'auxiliary_summary.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps(out,indent=2))
