#!/usr/bin/env python3
"""CPU-only rectangle SQ learner with certified rational sampling laws.

The LP proposes a finite mixture. Integer arithmetic certifies its coverage.
All reported oracle answers are exact Fractions, not sample estimates.
This implements the rectangle-minimax replacement, not an isotropic transform.
"""
from __future__ import annotations
import argparse, csv, json, math, platform, time
from fractions import Fraction
from pathlib import Path
import numpy as np
from scipy.optimize import linprog
from scipy.sparse import csr_matrix, hstack

BASE = Path(__file__).resolve().parent
OUT = BASE / 'results'
OUT.mkdir(exist_ok=True)
RHO = 32768
EPS = Fraction(1, 10)
P_CAP = 1 + math.ceil(4 * RHO * math.log(8 / float(EPS)))
TAU = EPS / (24 * P_CAP)


def construct(N: int, seed: int):
    if N < 1:
        raise ValueError('N must be positive')
    pts = np.array([(x,y) for x in range(1,N+1) for y in range(1,2*N*N+1)], dtype=np.int64)
    lines = pts.copy()
    inc = lines[:,0,None]*pts[None,:,0]+lines[:,1,None] == pts[None,:,1]
    F = np.where(inc,-1,1).astype(np.int8)
    rng = np.random.default_rng(seed)
    A = F.copy()
    A[inc & (rng.integers(0,2,size=inc.shape)==1)] = 1
    assert int(inc.sum()) == 2*N**4-(N*(N+1)//2)**2
    U = np.stack([pts[:,0]**2,pts[:,0]*pts[:,1],pts[:,1]**2,pts[:,0],pts[:,1],np.ones(len(pts),dtype=np.int64)],axis=1)
    # Twice the coefficient vector, so everything here is integral.
    V = np.stack([2*lines[:,0]**2,-4*lines[:,0],2*np.ones(len(lines),dtype=np.int64),4*lines[:,0]*lines[:,1],-4*lines[:,1],2*lines[:,1]**2-1],axis=1)
    assert np.all(F*(V@U.T)>0)
    assert np.all((A==1) | (F==-1))
    assert np.max((F==-1).astype(np.int64)@(F==-1).astype(np.int64).T-np.diag(inc.sum(1))) <= 1
    return pts,lines,F,A


class CertifiedSampler:
    def __init__(self,A:np.ndarray,seed:int):
        self.A=A; self.K,self.X=A.shape
        self.rng=np.random.default_rng(seed)
        self.catalog=[]; seen=set()
        def add(S,T,c):
            S=np.asarray(S,dtype=np.int64);T=np.asarray(T,dtype=np.int64)
            if not len(S) or not len(T): return
            sb=np.zeros(self.X,dtype=bool);tb=np.zeros(self.K,dtype=bool)
            sb[S]=1;tb[T]=1
            key=(np.packbits(sb).tobytes(),np.packbits(tb).tobytes(),int(c))
            if key in seen:return
            assert np.all(A[np.ix_(T,S)]==c)
            seen.add(key); self.catalog.append((sb,tb,int(c)))
        # These alone guarantee coverage >= 1/(2|U|), enough for N <= 5.
        for x in range(self.X):
            for c in [-1,1]:add([x],np.flatnonzero(A[:,x]==c),c)
        for j in range(self.K):
            for c in [-1,1]:
                S=np.flatnonzero(A[j]==c)
                if len(S):add(S,np.flatnonzero(np.all(A[:,S]==c,axis=1)),c)
        # Additional genuinely monochromatic rectangles improve progress.
        for _ in range(400):
            mode=int(self.rng.integers(2))
            prob=float(self.rng.choice([.01,.025,.05,.1,.2,.35,.5,.75]))
            if mode==0:
                T=np.flatnonzero(self.rng.random(self.K)<prob)
                if not len(T):continue
                S=np.flatnonzero(np.all(A[T]==1,axis=0))
                if len(S):T=np.flatnonzero(np.all(A[:,S]==1,axis=1));add(S,T,1)
            else:
                S=np.flatnonzero(self.rng.random(self.X)<prob)
                if not len(S):continue
                T=np.flatnonzero(np.all(A[:,S]==1,axis=1))
                if len(T):S=np.flatnonzero(np.all(A[T]==1,axis=0));add(S,T,1)
        self.S=np.stack([a[0] for a in self.catalog])
        self.T=np.stack([a[1] for a in self.catalog])
        self.C=np.array([a[2] for a in self.catalog],dtype=np.int8)
        self.cache={}; self.certificates=[]; self.lp_seconds=0.

    def law(self,U,V):
        key=(np.packbits(U).tobytes(),np.packbits(V).tobytes())
        if key in self.cache:return self.cache[key]
        xs=np.flatnonzero(U); vs=np.flatnonzero(V); k=len(vs)
        masses=self.T[:,vs].sum(axis=1)
        good=np.flatnonzero((masses>0)&np.any(self.S[:,xs],axis=1))
        coverage=self.S[good][:,xs].T.astype(float)*(masses[good]/k)[None,:]
        mat=hstack([-csr_matrix(coverage),csr_matrix(np.ones((len(xs),1)))],format='csr')
        objective=np.zeros(len(good)+1);objective[-1]=-1
        t=time.monotonic()
        res=linprog(objective,A_ub=mat,b_ub=np.zeros(len(xs)),A_eq=csr_matrix(np.r_[np.ones(len(good)),0.][None,:]),b_eq=[1.],bounds=[(0,None)]*len(good)+[(0,1)],method='highs')
        self.lp_seconds+=time.monotonic()-t
        if not res.success:raise RuntimeError(res.message)
        active=np.flatnonzero(res.x[:-1]>1e-12)
        ids=good[active]
        weights=np.maximum(1,np.rint(res.x[active]*(1<<30)).astype(np.int64))
        denominator=int(weights.sum())
        numer=self.S[ids][:,xs].T.astype(np.int64)@(weights*masses[ids])
        # A proof certificate, not a floating tolerance check.
        assert all(int(v)*RHO>=denominator*k for v in numer)
        cert_id=len(self.certificates)
        self.certificates.append({'id':cert_id,'U':xs.tolist(),'V':vs.tolist(),'rectangles':ids.tolist(),'integer_weights':weights.tolist(),'denominator':denominator,'minimum_coverage_numerator':int(numer.min()),'coverage_denominator':denominator*k,'lp_objective_float':float(res.x[-1])})
        result=(ids,np.cumsum(weights,dtype=np.int64),denominator,cert_id)
        self.cache[key]=result
        return result

    def sample(self,U,V,rng):
        ids,cum,den,cid=self.law(U,V)
        j=int(ids[np.searchsorted(cum,int(rng.integers(den)),side='right')])
        return U & self.S[j],V & self.T[j],int(self.C[j]),cid,j

    def save(self,path):
        catalog=[{'S':np.flatnonzero(s).tolist(),'T':np.flatnonzero(t).tolist(),'color':int(c)} for s,t,c in self.catalog]
        path.write_text(json.dumps({'rho':RHO,'catalog':catalog,'certificates':self.certificates,'lp_seconds':self.lp_seconds},separators=(',',':')))


def learn(A,sampler,target,weights,seed,keep_trace=True):
    weights=np.asarray(weights,dtype=np.int64)
    if np.any(weights<0) or not int(weights.sum()):raise ValueError('Invalid distribution')
    den=int(weights.sum());h=A[target]
    U=np.ones(A.shape[1],dtype=bool);V=np.ones(A.shape[0],dtype=bool)
    g=np.ones(A.shape[1],dtype=np.int8)
    rng=np.random.default_rng(seed)
    rounds=queries=peels=eliminations=rejects=0; trace=[]; reasons='budget'
    budget=math.ceil(8*RHO*(math.log(A.shape[0])+math.log(8/float(EPS))+1+math.log(2/float(EPS))))
    def mass(S):return Fraction(int(weights[S].sum()),den)
    for _ in range(budget):
        if not U.any():reasons='empty';break
        u=mass(U);queries+=1
        if u<=EPS/4:reasons='residual';break
        S,T,c,cid,rid=sampler.sample(U,V,rng)
        s=mass(S);queries+=1;rounds+=1
        record={'round':rounds,'u':str(u),'s':str(s),'V_size':int(V.sum()),'T_size':int(T.sum()),'certificate':cid,'rectangle':rid,'color':c}
        if s < u/Fraction(2*RHO):
            rejects+=1;record['action']='reject'
        else:
            w=mass(S & (h!=c));queries+=1;record['wrong_mass']=str(w)
            a=s/u;b=Fraction(int(T.sum()),int(V.sum()))
            if w<=2*TAU:
                g[S]=c;U[S]=False;peels+=1;record['action']='peel';record['progress']=str(a)
                assert a>=Fraction(1,4*RHO)
            else:
                assert not T[target]
                V[T]=False;eliminations+=1;record['action']='eliminate';record['progress']=str(b)
                assert V[target]
        if keep_trace:trace.append(record)
    error=mass(g!=h)
    assert peels<=P_CAP
    if reasons!='budget':assert error<=EPS/2
    return {'target':int(target),'seed':int(seed),'support':np.flatnonzero(weights).tolist(),'weights':weights[weights>0].tolist(),'weight_denominator':den,'error':float(error),'error_exact':str(error),'rounds':rounds,'queries':queries,'peels':peels,'eliminations':eliminations,'rejects':rejects,'termination':reasons,'trace':trace}


def path_rank_certificate(F,A):
    K,X=A.shape
    adj=[set() for _ in range(X)]
    for row in F:
        neg=np.flatnonzero(row==-1)
        if len(neg)==2:
            u,v=map(int,neg);adj[u].add(v);adj[v].add(u)
        else:assert len(neg)<=2
    assert max(map(len,adj))<=2
    order=[];seen=set()
    for start in range(X):
        if start in seen or len(adj[start])>1:continue
        prev=None;cur=start
        while cur not in seen:
            order.append(cur);seen.add(cur)
            nxt=[v for v in adj[cur] if v!=prev]
            if not nxt:break
            prev,cur=cur,nxt[0]
    assert len(order)==X, 'Cycle: this rank-three certificate would not apply'
    pos={x:i+1 for i,x in enumerate(order)}
    t=np.array([pos[x] for x in range(X)],dtype=np.int64)
    phi=np.stack([np.ones(X,dtype=np.int64),t,t*t],axis=1)
    W=[]
    for row in A:
        neg=sorted(pos[int(x)] for x in np.flatnonzero(row==-1))
        if not neg:W.append([1,0,0])
        elif len(neg)==1:
            i=neg[0];W.append([2*i*i-1,-4*i,2])
        else:
            i,j=neg;assert j==i+1
            W.append([(2*i+1)**2-4,-4*(2*i+1),4])
    W=np.array(W,dtype=np.int64)
    assert np.all(A*(W@phi.T)>0)
    return order,phi,W


def rank_two_exhaust(A):
    """Exact criterion with an all-positive row: signed negative sets form a chain."""
    K,X=A.shape;full=(1<<X)-1
    assert np.any(np.all(A==1,axis=1))
    sets=sorted({sum(1<<int(x) for x in np.flatnonzero(row==-1)) for row in A} - {0,full})
    if not sets:return 1,1,None
    def nested(a,b):return (a & b)==a or (a & b)==b
    tested=0
    # Complementing every selected set preserves chain feasibility.
    for orient in range(1<<max(0,len(sets)-1)):
        chosen=[sets[0]]+[s if not(orient>>(i-1)&1) else full^s for i,s in enumerate(sets[1:],start=1)]
        tested+=1
        if all(nested(a,b) for i,a in enumerate(chosen) for b in chosen[i+1:]):
            chain=sorted(set(chosen),key=int.bit_count)
            used=0;order=[]
            for s in chain+[full]:
                order.extend(x for x in range(X) if ((s^used)>>x)&1)
                used=s
            assert len(order)==X
            for s in sets:
                labels=[(s>>x)&1 for x in order]
                assert sum(a!=b for a,b in zip(labels,labels[1:]))<=1
            return 2,tested,order
    return 3,tested,None


def exact_ranks():
    records=[]
    for seed in range(24):
        pts,lines,F,A=construct(2,7000+seed)
        for name,B in ([('random',A)] if seed else [('F',F),('all_flipped',np.ones_like(A)),('random',A)]):
            order,phi,W=path_rank_certificate(F,B)
            rank,tested,order2=rank_two_exhaust(B)
            records.append({'kind':name,'seed':7000+seed,'sign_rank':rank,'orientation_assignments_tested':tested,'rank3_point_order':order,'rank2_point_order':order2,'embedding_rank3':phi.tolist(),'weights_rank3':W.tolist(),'matrix':B.tolist()})
    (OUT/'exact_signranks_N2.json').write_text(json.dumps(records,indent=2))
    return records


def make_dist(X,support,values=None):
    """Build an integer-mass distribution, retaining support/value alignment."""
    support=list(map(int,support))
    w=np.zeros(X,dtype=np.int64)
    if not support:
        w[0]=1
        return w
    if any(x < 0 or x >= X for x in support):
        raise ValueError('Support point outside domain')
    vals=[1]*len(support) if values is None else list(map(int,values))
    if len(vals)!=len(support):
        raise ValueError('Weights and support must have equal length')
    for x,v in zip(support,vals):
        w[x]+=max(1,v)
    return w


def run_search(quick=False):
    start=time.monotonic();summary=[];run_id=0
    raw=open(OUT/'runs.jsonl','w')
    for N in [2,3,4,5]:
        pts,lines,F,A=construct(N,20260910+N);X=len(pts)
        np.savez_compressed(OUT/f'family_N{N}.npz',points=pts,lines=lines,F=F,A=A)
        sampler=CertifiedSampler(A,9900+N);rng=np.random.default_rng(8800+N)
        rows=np.argsort((A==-1).sum(1))[::-1][:min(8,len(A))]
        pool=[]
        def evaluate(target,w,seed,tag):
            nonlocal run_id
            rec=learn(A,sampler,int(target),w,seed)
            rec.update({'N':N,'id':run_id,'tag':tag});run_id+=1
            raw.write(json.dumps(rec,separators=(',',':'))+'\n');raw.flush()
            pool.append(rec)
            return rec
        # Listed attacks, always with support at most 20.
        for j in rows[:3]:
            inc=np.flatnonzero(F[j]==-1);neg=np.flatnonzero(A[j]==-1)
            flip=np.flatnonzero((F[j]==-1)&(A[j]==1))
            for tag,S in [('line_uniform',inc),('negative_only',neg),('two_points',rng.choice(X,2,replace=False)),('three_points',rng.choice(X,3,replace=False))]:
                if len(S):evaluate(j,make_dist(X,S[:20]),11,'attack_'+tag)
            if len(neg) and len(flip):evaluate(j,make_dist(X,[neg[0],flip[0]],[1,1]),11,'attack_split_negative_flipped')
        # Parallel slopes and deliberately unbalanced two-point mixtures.
        for _ in range(4):
            j=int(rng.choice(rows));slope=int(lines[j,0]);parallel=np.flatnonzero(lines[:,0]==slope)
            S=np.flatnonzero(np.any(F[parallel[:5]]==-1,axis=0))
            if len(S):evaluate(j,make_dist(X,rng.choice(S,min(20,len(S)),replace=False)),12,'attack_parallel')
            neg=np.flatnonzero(A[j]==-1);pos=np.flatnonzero(A[j]==1)
            if len(neg) and len(pos):evaluate(j,make_dist(X,[neg[0],pos[0]],[24999,975001]),13,'attack_small_negative_mass')
        # Separate maximizations of error and rounds with common random numbers.
        bests=[]
        restarts=2 if quick else 4
        steps=4 if quick else 10
        for objective in ['error','rounds']:
            best=None
            for restart in range(restarts):
                j=int(rng.choice(rows));k=int(rng.integers(2,min(20,X)+1));S=rng.choice(X,k,replace=False)
                vals=np.maximum(1,np.rint(rng.lognormal(0,2,k)*1000)).astype(np.int64)
                w=np.zeros(X,dtype=np.int64);w[S]=vals
                cur=evaluate(j,w,20+restart,f'{objective}_restart')
                def score(r):return (r[objective],r['rounds'] if objective=='error' else r['error'])
                for step in range(steps):
                    for _ in range(2):
                        wn=w.copy();support=np.flatnonzero(wn)
                        a,b=rng.choice(support,2,replace=False)
                        if rng.random()<.5:
                            total=int(wn[a]+wn[b]);wa=int(rng.integers(1,max(2,total)));wn[a]=wa;wn[b]=max(1,total-wa)
                        else:
                            if rng.random()<.5:
                                new=int(rng.integers(X))
                                if not wn[new]:wn[new]=wn[a];wn[a]=0
                            else:wn[a]=max(1,int(wn[a]*float(rng.choice([.01,.1,.5,2,10,100]))))
                        cand=evaluate(j,wn,20+restart,f'{objective}_coordinate')
                        if score(cand)>score(cur):cur=cand;w=wn
                if best is None or score(cur)>score(best):best=cur
            bests.append(best)
        for best in bests:
            w=np.zeros(X,dtype=np.int64);w[best['support']]=best['weights']
            for seed in [101,102,103,104,105]:evaluate(best['target'],w,seed,'heldout_best_'+('error' if best is bests[0] else 'rounds'))
        worst_error=max(pool,key=lambda r:(r['error'],r['rounds']))
        worst_round=max(pool,key=lambda r:r['rounds'])
        totalround=sum(r['rounds'] for r in pool)
        rec={'N':N,'M':N**3,'K':X,'runs':len(pool),'max_error':worst_error['error'],'max_error_exact':worst_error['error_exact'],'max_rounds':worst_round['rounds'],'max_queries':max(r['queries'] for r in pool),'peel_fraction':sum(r['peels'] for r in pool)/totalround,'elimination_fraction':sum(r['eliminations'] for r in pool)/totalround,'reject_fraction':sum(r['rejects'] for r in pool)/totalround,'verification_test_fraction':0.,'worst_error_id':worst_error['id'],'worst_round_id':worst_round['id'],'certified_LP_states':len(sampler.certificates),'lp_seconds':sampler.lp_seconds}
        summary.append(rec);sampler.save(OUT/f'certificates_N{N}.json')
        print(json.dumps(rec),flush=True)
    raw.close()
    with open(OUT/'summary.csv','w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(summary[0]));w.writeheader();w.writerows(summary)
    (OUT/'summary.json').write_text(json.dumps(summary,indent=2))
    meta={'python':platform.python_version(),'numpy':np.__version__,'rho':RHO,'epsilon':str(EPS),'peel_cap':P_CAP,'tolerance':str(TAU),'seconds':time.monotonic()-start,'quick':quick,'number_runs':run_id,'exact_oracle':True,'isotropic_transform_used':False,'method':'rectangle LP with exact integer coverage certificate'}
    (OUT/'metadata.json').write_text(json.dumps(meta,indent=2))
    print(json.dumps(meta),flush=True)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--quick',action='store_true');parser.add_argument('--ranks-only',action='store_true');args=parser.parse_args()
    ranks=exact_ranks();print('Exact N=2 ranks:',[r['sign_rank'] for r in ranks],flush=True)
    if not args.ranks_only:run_search(args.quick)
