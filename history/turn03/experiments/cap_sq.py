#!/usr/bin/env python3
"""Finite cap-mixture implementation; exact rational SQ answers and coverage audits.

The transform is numerical. Its cap rectangles are checked against the integer truth
matrix and their *actual finite law* is certified by integer pointwise inequalities.
Thus statistical correctness does not depend on claiming exact floating isotropy.
No SGD. The oracle is a specified greedy endpoint adversary, not a global optimizer.
"""
from __future__ import annotations
import argparse, csv, json, math, platform, time, gzip, base64, hashlib
from collections import OrderedDict
import high_precision
from fractions import Fraction as Fq
from pathlib import Path
import numpy as np
from scipy.optimize import minimize, linprog
from scipy.special import betainc
from threadpoolctl import threadpool_limits
threadpool_limits(1)
OUT=Path(__file__).resolve().parent/'results';OUT.mkdir(exist_ok=True)
RHO=1<<20
EPS=Fq(1,10)
INNER=EPS/4
P=1+math.ceil(4*RHO*math.log(8/float(INNER)))
TAU=INNER/(24*P)
BUDGET=math.ceil(8*RHO*(math.log(1024)+math.log(8/float(INNER))+1+math.log(2/float(INNER))))


def family(N,seed):
    pts=np.array([(x,y) for x in range(1,N+1) for y in range(1,2*N*N+1)],dtype=np.int64)
    lin=pts.copy();inc=lin[:,0,None]*pts[None,:,0]+lin[:,1,None]==pts[None,:,1]
    template=np.where(inc,-1,1).astype(np.int8)
    rng=np.random.default_rng(seed);A=template.copy();A[inc & (rng.integers(2,size=inc.shape)==1)]=1
    # Bounded coordinates for numerically stable representation. Keep strict signs.
    x=pts[:,0]/N;y=pts[:,1]/(2*N*N)
    U=np.stack([x*x,x*y,y*y,x,y,np.ones(len(pts))],axis=1)
    a=lin[:,0]/(2*N);b=lin[:,1]/(2*N*N)
    V=np.stack([a*a,-2*a,np.ones(len(lin)),2*a*b,-2*b,b*b-1/(8*N**4)],axis=1)
    assert np.all(template*(V@U.T)>0)
    # Once-only seeded perturbation, verified to preserve every template entry.
    delta=1/(800*N**4)
    V=V+rng.uniform(-delta,delta,size=V.shape)
    assert np.all(template*(V@U.T)>0)
    return pts,lin,template,A,U,V


def radial_transform(V):
    """Convex Barthe objective optimized after an initial SVD preconditioner."""
    k,d=V.shape
    if k<=d:
        # Keep all surviving rows; reduce only to their common span.
        _,ss,W=np.linalg.svd(V,full_matrices=False)
        if np.min(ss)<1e-16:raise RuntimeError('Numerically singular small survivor set')
        T=(W.T/ss) # row-vector transform V @ T has orthonormal rows
        Z=V@T;Z/=np.linalg.norm(Z,axis=1)[:,None]
        return T,0.,0,'small_span'
    _,ss,W=np.linalg.svd(V,full_matrices=False)
    B=W.T/ss
    Y=V@B
    cache={}
    def fg(t):
        t=t-np.mean(t);shift=float(np.max(t));weights=np.exp(t-shift)
        S=Y.T@(weights[:,None]*Y)
        sign,ld=np.linalg.slogdet(S)
        if sign<=0:return 1e200,np.zeros(k)
        inv=np.linalg.inv(S)
        lev=weights*np.sum((Y@inv)*Y,axis=1)
        return float(ld+d*shift-(d/k)*np.sum(t)),lev-d/k
    res=minimize(fg,np.zeros(k),jac=True,method='L-BFGS-B',options={'maxiter':1500,'ftol':1e-13,'gtol':1e-9,'maxls':40})
    t=res.x-res.x.max();S=Y.T@(np.exp(t)[:,None]*Y)
    eig,Q=np.linalg.eigh(S)
    if np.min(eig)<=0:raise RuntimeError('No SPD covariance')
    T=B@(Q*(1/np.sqrt(eig)))@Q.T
    Z=V@T;Z/=np.linalg.norm(Z,axis=1)[:,None]
    cov=Z.T@Z/k
    resid=float(np.max(np.abs(np.linalg.eigvalsh(cov)-1/d)))
    if resid>1e-4:
        return high_precision.solve(V)
    return T,resid,int(res.nit),str(res.message)


class CapLaw:
    def __init__(self,A,U,V,seed):
        self.A=A;self.U0=U;self.V0=V;self.seed=seed;self.rng=np.random.default_rng(seed)
        self.cache=OrderedDict();self.certs=[];self.seconds=0.;self.max_resid=0.;self.fallbacks=0
        self.certstream=None
    def build(self,survivors):
        key=np.packbits(survivors).tobytes()
        if key in self.cache:
            self.cache.move_to_end(key)
            return self.cache[key]
        tic=time.monotonic();ids=np.flatnonzero(survivors);k=len(ids)
        T,resid,nit,msg=radial_transform(self.V0[ids]);deff=T.shape[1] if isinstance(T,np.ndarray) else T.cols
        self.max_resid=max(self.max_resid,resid)
        # For rectangular T, invert its action on the common row span.
        if not isinstance(T,np.ndarray):
            Z,Xp=high_precision.apply(T,self.V0[ids],self.U0);self.fallbacks+=1
        else:
            if T.shape[0]==T.shape[1]:Xp=self.U0@np.linalg.inv(T).T
            else:Xp=self.U0@np.linalg.pinv(T).T
            Z=self.V0[ids]@T;Z/=np.linalg.norm(Z,axis=1)[:,None]
            norms=np.linalg.norm(Xp,axis=1)
            if np.min(norms)==0:raise RuntimeError('A projected point is zero')
            Xp=Xp/norms[:,None]
        state_seed=int.from_bytes(hashlib.sha256(str(self.seed).encode()+key).digest()[:8],'little')
        state_rng=np.random.default_rng(state_seed)
        directions=np.vstack([Xp,state_rng.normal(size=(32,deff))])
        directions/=np.linalg.norm(directions,axis=1)[:,None]
        alpha=1/math.sqrt(2*deff);beta=math.sqrt(1-alpha*alpha)
        rectangles=[];bad=0
        for u in directions:
            S=Xp@u>=beta
            # The center point, whenever this is a centered direction, is included.
            plus=(Z@u)>alpha;minus=(Z@u)<-alpha
            side=plus if int(plus.sum())>=int(minus.sum()) else minus
            sign=1 if side is plus else -1
            rid=ids[side]
            if not len(rid) or not S.any():continue
            if not np.all(self.A[np.ix_(rid,np.flatnonzero(S))]==sign) and sign==1:
                bad+=1;continue
            if sign==1:
                rectangles.append((S.copy(),rid.copy(),1))
            else:
                # Template geometry yields either one point or one row. The A-table
                # checks below make this independent of floating sign tests.
                if len(rid)==1:
                    for c in [-1,1]:
                        Sc=S&(self.A[rid[0]]==c)
                        if Sc.any():rectangles.append((Sc,rid.copy(),c))
                elif int(S.sum())==1:
                    x=int(np.flatnonzero(S)[0])
                    for c in [-1,1]:
                        rr=rid[self.A[rid,x]==c]
                        if len(rr):rectangles.append((S.copy(),rr,c))
                else:
                    bad+=1
        if not rectangles:raise RuntimeError('No cap rectangles')
        # Repeated rectangles deliberately remain separate equally likely outcomes.
        # Dropping empty split branches only increases the normalized coverage.
        SM=np.stack([s for s,_,_ in rectangles]);mass=np.array([len(r) for _,r,_ in rectangles],dtype=np.int64)
        for s,rr,c in rectangles:assert np.all(self.A[np.ix_(rr,np.flatnonzero(s))]==c)
        numer=SM.T.astype(np.int64)@mass;den=len(rectangles)*k
        if int(numer.min())*RHO<den:
            raise RuntimeError(f'Finite cap law failed exact pointwise coverage: {numer.min()}/{den}, residual {resid}')
        cid=len(self.certs)
        meta={'id':cid,'survivors':ids.tolist(),'covariance_residual_float':resid,'optimizer_iterations':nit,'optimizer_message':msg,'dimension':deff,'discarded_numeric_rectangles':bad,'minimum_coverage_numerator':int(numer.min()),'coverage_denominator':den,'rectangle_count':len(rectangles)}
        packed=[]
        for ss,rr,cc in rectangles:
            tt=np.zeros(self.A.shape[0],bool);tt[rr]=True
            packed.append({'S':base64.b85encode(np.packbits(ss).tobytes()).decode(),'T':base64.b85encode(np.packbits(tt).tobytes()).decode(),'color':cc})
        if self.certstream is not None:
            self.certstream.write(json.dumps(dict(meta,rectangles=packed),separators=(',',':'))+'\n');self.certstream.flush()
        self.certs.append(meta)
        val=(rectangles,SM,cid);self.cache[key]=val
        if len(self.cache)>12:self.cache.popitem(last=False)
        self.seconds+=time.monotonic()-tic
        return val
    def sample(self,U,V,rng):
        rect,SM,cid=self.build(V)
        # Condition on a known nonempty point side, not on the unknown marginal.
        live=np.flatnonzero(np.any(SM[:,U],axis=1))
        if not len(live):raise RuntimeError('Coverage contradicts empty live catalog')
        j=int(live[int(rng.integers(len(live)))])
        s,rr,c=rect[j];tb=np.zeros(len(V),bool);tb[rr]=True
        return s&U,tb,c,cid,j
    def save(self,path):
        path.write_text(json.dumps({'rho':RHO,'certificates':self.certs,'max_residual':self.max_resid,'seconds':self.seconds,'high_precision_fallbacks':self.fallbacks},separators=(',',':')))


class Oracle:
    def __init__(self,weights,h,mode,trace):
        self.w=np.asarray(weights,dtype=np.int64);self.den=int(self.w.sum());self.h=h;self.mode=mode;self.trace=trace;self.count=0
    def mass(self,S):return Fq(int(self.w[S].sum()),self.den)
    def answer(self,S,kind,score=None):
        val=self.mass(S);choices=[val] if self.mode=='exact' else [val-TAU,val+TAU]
        if score is None:
            ans=choices[-1]
        else:ans=max(choices,key=lambda z:(score(z),z))
        self.count+=1;self.trace.append({'query':self.count,'kind':kind,'truth':str(val),'answer':str(ans),'endpoint':0 if ans==val else (-1 if ans<val else 1),'mask':base64.b85encode(np.packbits(S).tobytes()).decode()})
        assert abs(ans-val)<=TAU
        return ans


def proper_finish(A,target,S,T,O,eps,events):
    h=A[target];xs=np.flatnonzero(S);rows=np.flatnonzero(T)
    if len(xs)==1:p=int(xs[0]);assert h[p]==-1
    else:
        assert len(rows)==1
        j=int(rows[0]);loss=O.mass(A[j]!=h)
        ans=O.answer(A[j]!=h,'candidate',lambda z:(float(loss) if z<=eps/2 else 0.,int(z>eps/2)))
        if ans<=eps/2:return A[j].copy(),'rectangle_candidate'
        assert j!=target
        pool=xs.copy();neg=S&(h==-1);w=O.mass(neg);assert w>8*TAU
        assert int(neg.sum())==1
        while len(pool)>1:
            left=pool[:len(pool)//2];mask=np.zeros(A.shape[1],bool);mask[left]=True
            ans=O.answer(mask&(h==-1),'locate_atom')
            pool=left if ans>4*TAU else pool[len(pool)//2:]
        p=int(pool[0]);assert h[p]==-1
    events.append({'event':'negative_atom','point':p})
    candidates=np.flatnonzero(A[:,p]==-1)
    mask=np.ones(A.shape[1],bool);mask[p]=False
    beta=O.answer(mask&(h==-1),'negative_tail',lambda z:int(z<=eps/4))
    if beta>eps/4:
        while len(candidates)>1:
            left=candidates[:len(candidates)//2]
            union=np.any(A[left]==-1,axis=0);union[p]=False
            ans=O.answer(union&(h==-1),'identify_row')
            candidates=left if ans>eps/8 else candidates[len(candidates)//2:]
        j=int(candidates[0]);assert j==target
        return A[j].copy(),'identified_row'
    J=math.ceil(8/float(eps))+1
    for j in candidates[:J]:
        loss=O.mass(A[j]!=h)
        ans=O.answer(A[j]!=h,'star_candidate',lambda z:(float(loss) if z<=eps/2 else 0.,int(z>eps/2)))
        if ans<=eps/2:return A[j].copy(),'small_tail_candidate'
    raise AssertionError('Disjoint negative sets guarantee a passing candidate')


def learn(A,sampler,target,weights,seed,mode='endpoint',proper=False,keep=True):
    h=A[target];U=np.ones(A.shape[1],bool);V=np.ones(A.shape[0],bool);g=np.ones(A.shape[1],dtype=np.int8)
    rng=np.random.default_rng(seed);qtrace=[];events=[];O=Oracle(weights,h,mode,qtrace)
    rounds=peels=elims=rejects=0;reason='budget';rho=Fq(RHO);r=1/rho
    # For both variants use the same conservative inner tolerance.
    for _ in range(BUDGET):
        if not U.any():reason='empty';break
        current_error=O.mass(g!=h)
        def score_u(ans):
            if ans<=INNER/4:return (float(current_error),0)
            return (0.,1)
        uh=O.answer(U,'residual',score_u)
        if uh<=INNER/4:reason='residual';break
        S,T,c,cid,rid=sampler.sample(U,V,rng);rounds+=1
        u=O.mass(U);s=O.mass(S);w=O.mass(S&(h!=c));a=s/u;b=Fq(int(T.sum()),int(V.sum()))
        # Public-transcript endpoint policy: the marginal query reveals S but
        # not the privately sampled T or color. Use only its answer and the
        # previously revealed residual answer, never T, c, b or future draws.
        def action_score(sh):
            return (int(sh<r*uh/2),-float(sh))
        sh=O.answer(S,'rectangle_mass',action_score)
        event={'round':rounds,'U_mass':str(u),'S_mass':str(s),'V_size':int(V.sum()),'T_size':int(T.sum()),'certificate':cid,'rectangle':rid,'color':c}
        if sh<r*uh/2:
            rejects+=1;event['action']='reject'
        else:
            def score_w(ans):
                if ans<=2*TAU:return (float(w),0.)
                return (0.,1.)
            wh=O.answer(S&(h!=c),'mismatch',score_w)
            if wh<=2*TAU:
                assert a>=r/4 and w<=3*TAU
                peels+=1;event['action']='peel';event['wrong_mass']=str(w)
                if proper and c==-1:
                    g,reason=proper_finish(A,target,S,T,O,EPS,events)
                    events.append(event);break
                g[S]=c;U[S]=False
            else:
                assert not T[target];V[T]=False;assert V[target]
                elims+=1;event['action']='eliminate'
        events.append(event)
    error=O.mass(g!=h)
    if proper:
        # Before a negative peel, all assigned labels and the fallback are positive.
        assert np.any(np.all(A==g,axis=1))
        if reason!='budget':assert error<=EPS/2+TAU
    elif reason!='budget':assert error<=INNER/2
    return {'target':int(target),'seed':int(seed),'oracle':mode,'proper':proper,'support':np.flatnonzero(weights).tolist(),'weights':np.asarray(weights)[np.asarray(weights)>0].tolist(),'denominator':int(np.sum(weights)),'error_exact':str(error),'error':float(error),'rounds':rounds,'queries':O.count,'peels':peels,'eliminations':elims,'rejects':rejects,'termination':reason,'prediction':base64.b85encode(np.packbits(g==1).tobytes()).decode(),'queries_trace':qtrace if keep else [],'events':events if keep else []}


def make_dist(X,supp,rng,den=10**12):
    vals=rng.dirichlet(np.full(len(supp),.5));ws=np.maximum(1,np.floor(vals*den).astype(np.int64));ws[np.argmax(ws)]+=den-int(ws.sum())
    out=np.zeros(X,dtype=np.int64);out[supp]=ws;return out


def run(args):
    all_runs=[];summary=[];tic=time.monotonic();seed=2026091103
    raw=(OUT/'runs.jsonl').open('w')
    for N in args.N:
        rng=np.random.default_rng(seed+N);pts,lin,template,A,U0,V0=family(N,seed+10*N);X=len(pts)
        sampler=CapLaw(A,U0,V0,seed+20*N)
        sampler.certstream=gzip.open(OUT/f'cap_catalogs_N{N}.jsonl.gz','wt')
        np.savez_compressed(OUT/f'family_N{N}.npz',points=pts,lines=lin,template=template,A=A,U0=U0,V0=V0)
        eligible=np.flatnonzero((A==-1).sum(1)>=min(2,N))
        if not len(eligible):eligible=np.flatnonzero((A==-1).sum(1)>0)
        cases=[]
        # Structured attacks and prior-collapse stresses.
        for j in rng.choice(eligible,min(3,len(eligible)),replace=False):
            incident=np.flatnonzero(template[j]==-1);neg=np.flatnonzero(A[j]==-1)
            for supp,label in [(incident,'template_line'),(neg,'negative_only'),(rng.choice(X,min(3,X),replace=False),'three_points')]:
                if len(supp):cases.append((int(j),make_dist(X,supp,rng),label))
            # A tail just inside the stopping threshold probes endpoint sensitivity.
            p=int(neg[0]);pos=np.flatnonzero(A[j]==1);q=int(pos[0]);den=TAU.denominator*8
            if den>=2**62:raise RuntimeError('distribution denominator too large')
            w=np.zeros(X,dtype=np.int64);tail=INNER/4+TAU/2
            w[p]=int(tail*den);w[q]=den-w[p];cases.append((int(j),w,'threshold_tail'))
        # Random restarts followed by coordinate ascent on either error or rounds.
        for restart in range(args.restarts):
            j=int(rng.choice(eligible));supp=rng.choice(X,min(20,X),replace=False)
            forced=np.flatnonzero(A[j]==-1);supp[:min(len(forced),len(supp))]=forced[:min(len(forced),len(supp))];supp=np.unique(supp)
            w=make_dist(X,supp,rng)
            criterion='error' if restart%2==0 else 'rounds'
            search_proper=restart>=2
            def score(z):return (z['error'],z['rounds']) if criterion=='error' else (z['rounds'],z['error'])
            base=learn(A,sampler,j,w,seed+restart,'endpoint',search_proper,False)
            for step in range(args.steps):
                cand=w.copy();support=np.flatnonzero(cand)
                if rng.random()<.5 and len(support)>1:
                    aa,bb=rng.choice(support,2,replace=False);transfer=max(1,int(cand[aa]*rng.uniform(.1,.8)));cand[aa]-=transfer;cand[bb]+=transfer
                else:
                    aa=int(rng.choice(support));bb=int(rng.integers(X));cand[bb]+=cand[aa];cand[aa]=0
                z=learn(A,sampler,j,cand,seed+restart,'endpoint',search_proper,False)
                if score(z)>score(base):base=z;w=cand
            cases.append((j,w,'searched_'+('proper_' if search_proper else 'improper_')+criterion))
        start=len(all_runs)
        for ci,(j,w,label) in enumerate(cases):
            for proper in [False,True]:
                for mode in ['exact','endpoint']:
                    z=learn(A,sampler,j,w,seed+10000+ci,mode,proper,True);z.update(N=N,distribution=label)
                    raw.write(json.dumps(z,separators=(',',':'))+'\n');raw.flush();all_runs.append(z)
        sampler.save(OUT/f'cap_certificates_N{N}.json');sampler.certstream.close()
        for proper in [False,True]:
            for mode in ['exact','endpoint']:
                rr=[z for z in all_runs[start:] if z['proper']==proper and z['oracle']==mode]
                total=sum(z['rounds'] for z in rr)
                item={'N':N,'points':X,'proper':proper,'oracle':mode,'runs':len(rr),'max_error':max(z['error'] for z in rr),'max_rounds':max(z['rounds'] for z in rr),'max_queries':max(z['queries'] for z in rr),'peel_fraction':sum(z['peels'] for z in rr)/max(1,total),'elimination_fraction':sum(z['eliminations'] for z in rr)/max(1,total),'rejection_fraction':sum(z['rejects'] for z in rr)/max(1,total),'cap_certificates':len(sampler.certs),'max_isotropy_residual':sampler.max_resid}
                summary.append(item);print(json.dumps(item),flush=True)
        print(f'N={N} completed; elapsed {time.monotonic()-tic:.1f}s, transform/catalog time {sampler.seconds:.1f}s',flush=True)
    raw.close()
    (OUT/'summary.json').write_text(json.dumps(summary,indent=2))
    with (OUT/'summary.csv').open('w') as f:
        writer=csv.DictWriter(f,fieldnames=list(summary[0]));writer.writeheader();writer.writerows(summary)
    (OUT/'metadata.json').write_text(json.dumps({'seed':seed,'rho':RHO,'epsilon':str(EPS),'inner_epsilon':str(INNER),'tau':str(TAU),'P':P,'budget':BUDGET,'python':platform.python_version(),'numpy':np.__version__,'elapsed_seconds':time.monotonic()-tic,'runs':len(all_runs),'restarts':args.restarts,'coordinate_steps':args.steps,'notes':'Finite point-centered and Gaussian cap pool; exact pointwise certificate. Numerical radial isotropy, not an exact real transform. Public-transcript greedy endpoint adversary; no private row side/color is read during marginal answers. Not a worst-policy certificate.'},indent=2))

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--N',nargs='+',type=int,default=list(range(2,9)));ap.add_argument('--restarts',type=int,default=4);ap.add_argument('--steps',type=int,default=3);args=ap.parse_args();run(args)
