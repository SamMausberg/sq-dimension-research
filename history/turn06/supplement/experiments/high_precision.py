"""High-precision Newton solve of Barthe's convex log-partition objective."""
import mpmath as mp
import numpy as np

def solve(V):
    mp.mp.dps=120
    k,d=V.shape
    Y=mp.matrix([[mp.mpf(float(z)) for z in row] for row in V])
    # Exact-to-working-precision initial covariance preconditioning.
    ev,Q=mp.eigsy(Y.T*Y)
    B=Q*mp.diag([1/mp.sqrt(e) for e in ev])*Q.T
    Y=Y*B
    t=mp.matrix(k,1)
    def calc(t,hessian=False):
        w=[mp.exp(t[i]) for i in range(k)]
        S=Y.T*mp.diag(w)*Y;inv=S**-1
        C=Y*inv*Y.T
        lev=[w[i]*C[i,i] for i in range(k)]
        f=mp.log(mp.det(S))-mp.mpf(d)/k*sum(t)
        g=mp.matrix([lev[i]-mp.mpf(d)/k for i in range(k-1)])
        if not hessian:return f,g,S
        H=mp.matrix(k-1,k-1)
        for i in range(k-1):
            for j in range(k-1):H[i,j]=(lev[i] if i==j else 0)-w[i]*w[j]*C[i,j]**2
        return f,g,H,S
    if k == d+1:
        # Cauchy--Binet: omitted-row minors give the exact optimizer.
        logs=[]
        for omitted in range(k):
            block=mp.matrix([[Y[i,j] for j in range(d)] for i in range(k) if i!=omitted])
            determinant=mp.det(block)
            if determinant == 0: raise RuntimeError('Input rows not in general position')
            logs.append(2*mp.log(abs(determinant)))
        t=mp.matrix([a-logs[-1] for a in logs])
    for it in range(400):
        f,g,H,S=calc(t,True)
        if max(abs(z) for z in g)<mp.mpf('1e-24'):break
        # A tiny positive regularizer handles almost flat early iterates. Limit
        # log-weight movement so Newton cannot jump to a numerically singular face.
        ridge=mp.mpf('1e-40')
        try: step=mp.lu_solve(H,-g)
        except ZeroDivisionError:
            step=mp.lu_solve(H+ridge*mp.eye(k-1),-g)
        maxstep=max(abs(z) for z in step)
        if maxstep>10:step=step*(10/maxstep)
        if sum(g[i]*step[i] for i in range(k-1)) >= 0:
            step=-g
        dg=sum(g[i]*step[i] for i in range(k-1));scale=mp.mpf(1)
        for _ in range(150):
            trial=mp.matrix(t)
            for i in range(k-1):trial[i]+=scale*step[i]
            nf,_,_=calc(trial)
            if nf<=f+mp.mpf('0.01')*scale*dg:break
            scale/=2
        else:raise RuntimeError('High-precision line search failed')
        t=trial
    f,g,S=calc(t)
    ev,Q=mp.eigsy(S)
    T=B*Q*mp.diag([1/mp.sqrt(e) for e in ev])*Q.T
    Z=mp.matrix([[mp.mpf(float(z)) for z in row] for row in V])*T
    for i in range(k):
        norm=mp.sqrt(sum(Z[i,j]**2 for j in range(d)))
        for j in range(d):Z[i,j]/=norm
    cov=Z.T*Z/k;ev,_=mp.eigsy(cov)
    err=float(max(abs(e-mp.mpf(1)/d) for e in ev))
    if err>1e-10:raise RuntimeError(f'High-precision residual {err}')
    return T,err,it+1,'high_precision_newton'

def apply(T,V,U):
    Z=mp.matrix([[mp.mpf(float(z)) for z in row] for row in V])*T
    X=mp.matrix([[mp.mpf(float(z)) for z in row] for row in U])*(T**-1).T
    def normalized(B):
        out=np.zeros((B.rows,B.cols))
        for i in range(B.rows):
            norm=mp.sqrt(sum(B[i,j]**2 for j in range(B.cols)))
            for j in range(B.cols):out[i,j]=float(B[i,j]/norm)
        return out
    return normalized(Z),normalized(X)
