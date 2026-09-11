#!/usr/bin/env python3
"""Independent exact audit of cap laws, SQ replies, predictions and witnesses."""
import base64,csv,gzip,json,math
from fractions import Fraction as F
from pathlib import Path
import numpy as np
import mpmath as mp
ROOT=Path(__file__).resolve().parent/'results'
def bits(s,k):return np.unpackbits(np.frombuffer(base64.b85decode(s),dtype=np.uint8))[:k].astype(bool)
def main():
    meta=json.loads((ROOT/'metadata.json').read_text());tau=F(meta['tau']);rho=meta['rho'];eps=F(meta['epsilon']);theta=F(meta['inner_epsilon'])
    mp.mp.dps=70
    assert meta['P']==1+int(mp.ceil(4*rho*mp.log(8/(mp.mpf(theta.numerator)/theta.denominator))))
    counts={'runs':0,'queries':0,'endpoint_queries':0,'catalogs':0,'rectangles':0,'pointwise_constraints':0,'proper_outputs':0,'peels':0,'eliminations':0,'rejections':0,'product_witnesses':0}
    families={};max_resid=0.;minimum_coverage=1.;term={}
    wanted={N:set() for N in range(2,9)};selected={N:{} for N in range(2,9)}
    with (ROOT/'runs.jsonl').open() as handle:
        for line in handle:
            z=json.loads(line)
            for e in z['events']:
                if 'round' in e:wanted[z['N']].add((e['certificate'],e['rectangle']))
    for N in range(2,9):
        dat=np.load(ROOT/f'family_N{N}.npz');A=dat['A'];K,Q=A.shape;families[N]=A
        assert np.all((A==1)|(A==-1));neg=(A==-1).astype(np.int64)
        overlap=neg@neg.T;np.fill_diagonal(overlap,0);assert overlap.max()<=1
        with gzip.open(ROOT/f'cap_catalogs_N{N}.jsonl.gz','rt') as f:
            for line in f:
                z=json.loads(line);surv=np.zeros(K,bool);surv[z['survivors']]=True
                numer=np.zeros(Q,np.int64)
                for rid,rr in enumerate(z['rectangles']):
                    S=bits(rr['S'],Q);T=bits(rr['T'],K);c=rr['color']
                    assert np.all(~T|surv);assert S.any() and T.any();assert np.all(A[np.ix_(T,S)]==c)
                    numer[S]+=int(T.sum());counts['rectangles']+=1
                    if (z['id'],rid) in wanted[N]:selected[N][(z['id'],rid)]=(rr['S'],rr['T'],c)
                den=len(z['rectangles'])*int(surv.sum())
                assert den==z['coverage_denominator'];assert numer.min()==z['minimum_coverage_numerator']
                assert np.all(numer*rho>=den)
                minimum_coverage=min(minimum_coverage,float(numer.min()/den))
                counts['catalogs']+=1;counts['pointwise_constraints']+=Q
                max_resid=max(max_resid,z['covariance_residual_float'])
        print('catalogs N',N,'complete',flush=True)
    with (ROOT/'runs.jsonl').open() as f:
        for line in f:
            z=json.loads(line);A=families[z['N']];K,Q=A.shape;h=A[z['target']]
            weights=np.zeros(Q,np.int64);weights[z['support']]=z['weights'];den=int(weights.sum())
            assert den==z['denominator'];assert len(z['support'])<=20;assert np.min(weights)>=0
            prediction=np.where(bits(z['prediction'],Q),1,-1)
            loss=F(int(weights[prediction!=h].sum()),den)
            assert loss==F(z['error_exact']);assert float(loss)==z['error']
            if z['proper']:
                assert np.any(np.all(A==prediction,axis=1));counts['proper_outputs']+=1
                if z['termination']!='budget':assert loss<=eps/2+tau
            elif z['termination']!='budget':assert loss<=theta/2
            assert z['rounds']==z['peels']+z['eliminations']+z['rejects']
            U=np.ones(Q,bool);V=np.ones(K,bool);greplay=np.ones(Q,np.int8)
            rounds=[e for e in z['events'] if 'round' in e]
            for event in rounds:
                ss,tt,c=selected[z['N']][(event['certificate'],event['rectangle'])]
                S=bits(ss,Q)&U;T=bits(tt,K)
                assert np.all(~T|V) and c==event['color']
                assert F(event['U_mass'])==F(int(weights[U].sum()),den)
                assert F(event['S_mass'])==F(int(weights[S].sum()),den)
                assert event['V_size']==int(V.sum()) and event['T_size']==int(T.sum())
                if event['action']=='eliminate':assert not T[z['target']];V[T]=False
                elif event['action']=='peel':
                    wrong=F(int(weights[S&(h!=c)].sum()),den)
                    assert wrong==F(event['wrong_mass']) and wrong<=3*tau
                    assert F(int(weights[S].sum()),den)>=F(event['U_mass'])/(4*rho)
                    if not(z['proper'] and c==-1):greplay[S]=c;U[S]=False
            if not z['proper']:assert np.array_equal(greplay,prediction)
            gpublic=np.ones(Q,np.int8);stage=-1;currentS=None
            for qnum,q in enumerate(z['queries_trace'],1):
                assert q['query']==qnum
                mask=bits(q['mask'],Q);truth=F(int(weights[mask].sum()),den);ans=F(q['answer'])
                assert truth==F(q['truth']);assert abs(ans-truth)<=tau
                if z['oracle']=='exact':assert ans==truth and q['endpoint']==0
                else:
                    assert abs(ans-truth)==tau;assert q['endpoint']==(1 if ans>truth else -1)
                    if q['kind']=='rectangle_mass':assert ans==truth-tau
                    if q['kind']=='residual':
                        error=F(int(weights[gpublic!=h].sum()),den)
                        def score(a):return (float(error),0) if a<=theta/4 else (0.,1)
                        assert ans==max([truth-tau,truth+tau],key=lambda a:(score(a),a))
                    if q['kind'] in ['candidate','star_candidate']:
                        def score(a):return (float(truth) if a<=eps/2 else 0.,int(a>eps/2))
                        assert ans==max([truth-tau,truth+tau],key=lambda a:(score(a),a))
                    if q['kind']=='negative_tail':
                        assert ans==max([truth-tau,truth+tau],key=lambda a:(int(a<=eps/4),a))
                    if q['kind'] in ['locate_atom','identify_row']:assert ans==truth+tau
                    if q['kind']=='mismatch':
                        # This choice uses only the query expectation and public threshold.
                        candidates=[truth-tau,truth+tau]
                        def score(a):return (float(truth),0.) if a<=2*tau else (0.,1.)
                        expected=max(candidates,key=lambda a:(score(a),a));assert ans==expected
                    counts['endpoint_queries']+=1
                if q['kind']=='rectangle_mass':
                    stage+=1;currentS=mask
                if q['kind']=='mismatch':
                    event=rounds[stage];c=event['color']
                    assert np.array_equal(mask,currentS&(h!=c))
                    assert (ans<=2*tau)==(event['action']=='peel')
                    if event['action']=='peel':gpublic[currentS]=c
                counts['queries']+=1
            assert len(z['queries_trace'])==z['queries']
            counts['peels']+=z['peels'];counts['eliminations']+=z['eliminations'];counts['rejections']+=z['rejects'];counts['runs']+=1
            term[z['termination']]=term.get(z['termination'],0)+1
    witnesses=json.loads((ROOT/'rectangle_witnesses.json').read_text())
    # Shape is intentionally independent of the optimization code.
    if isinstance(witnesses,dict):witnesses=witnesses.get('results',witnesses.get('witnesses'))
    for z in witnesses:
        N=z['N'];A=families[N]
        rows=z['rows'];cols=z['columns'];rw=np.array(z['row_weights'],dtype=np.int64);cw=np.array(z['column_weights'],dtype=np.int64);den=z['denominator']
        assert int(rw.sum())==den and int(cw.sum())==den
        B=A[np.ix_(rows,cols)];best=0
        for mask in range(1,1<<len(rows)):
            ids=[i for i in range(len(rows)) if (mask>>i)&1];mass=int(rw[ids].sum())
            for color in [-1,1]:
                selected_cols=np.all(B[ids]==color,axis=0)
                best=max(best,mass*int(cw[selected_cols].sum()))
        assert F(best,den*den)==F(z['upper_bound_exact'])
        assert float(F(best,den*den))==z['upper_bound']
        counts['product_witnesses']+=1
    result={'all_assertions_passed':True,**counts,'minimum_certified_pointwise_coverage':minimum_coverage,'required_coverage':1/rho,'max_numerical_covariance_residual':max_resid,'termination_counts':term,'note':'Exact finite-law and oracle audits do not assert that a floating transform is an exact real optimum; product global optimality is not asserted.'}
    (ROOT/'audit.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2),flush=True)
if __name__=='__main__':main()
