#!/usr/bin/env python3
"""Deterministic finite checks for constants and threshold inequalities.
These checks complement the symbolic proofs; they are not formal verification.
"""
from fractions import Fraction as F
from pathlib import Path
from math import ceil, floor, log, log2, sqrt, pi, comb, gamma
from itertools import product
import json, sys, random
from scipy.integrate import quad
root=Path(__file__).resolve().parents[1]
out=root/'checks'/'constants.json'
rng=random.Random(20260910)
counts={}; parameters=[]
for rho in [1,2,16,2**15,2**18]:
 for e in [F(1,5),F(1,10),F(1,100),F(1,1000)]:
  eps=float(e);r=F(1,rho);P=1+ceil(4*rho*log(8/eps));tau=e/(24*P)
  B=log(16)+log(8/eps)+1;R=ceil(8*rho*(B+log(2/eps)))
  assert tau<=e/8 and tau<=r*e/64
  u=e/8
  assert (r*u/2-(1+r/2)*tau)/u>=5*r/16
  assert 3*r*u/4-tau-r*(u+tau)/2>=r*u/16
  assert 3*P*tau==e/8
  assert 3*P*tau+e/4+tau<=e/2
  assert B-float(r)*R/8<=log(eps/2)+1e-10
  parameters.append(dict(rho=rho,epsilon=str(e),P=P,tau=str(tau),B=B,R=R,m=3*R+1))
counts['rectangle_parameter_cases']=len(parameters)
threshold_count=0
for beta in [F(512),F(513),F(1023),F(1024),F(10**4)]:
 for eb,em,el in product([-1,1],repeat=3):
  bh=beta+eb
  assertions=[beta/2-F(3,2)-1>3*bh/8,
              beta/4+F(21,4)+1<3*bh/8,
              beta/8-F(9,8)>beta/9,
              F(1)<bh/32<beta/9-1,
              F(2)<bh/8,
              beta/2-F(3,2)+el>bh/8,
              beta-(F(5,8)*beta+F(21,8))+em-el>bh/8]
  assert all(assertions);threshold_count+=len(assertions)
counts['exact_median_endpoint_inequalities']=threshold_count
c6=quad(lambda t:(1-t*t)**1.5,sqrt(F(11,12)),1,epsabs=1e-16)[0]*gamma(3)/(sqrt(pi)*gamma(2.5))
ball=8/(15*pi*12**2.5)
assert c6>=ball and c6/48>2**-18
r6=F(1,16*6*(32*6+1)**6)
for d in range(1,20):
 assert F(16,17*d)-F(1,8*d)>F(3,4*d)
 assert F(16,15*d)>F(1,d)
counts['covariance_cases']=19
subgrid=[]
for N in range(2,17):
 I=2*N**4-(N*(N+1)//2)**2
 incidence=sum(max(0,2*N*N-a*x) for a in range(1,N+1) for x in range(1,N+1))
 empty=sum(1 for a in range(1,N+1) for b in range(1,2*N*N+1) if a+b>2*N*N)
 assert incidence==I>=N**4 and empty==N*(N+1)//2
 subgrid.append(dict(N=N,I=I,empty_rows=empty,D=floor(N/(24*log2(N)))))
first=next(k for k in range(2,10000) if floor(k/(24*log2(k)))>=1)
for k in [first,256,512,1024,4096,1000000]:
 D=floor(k/(24*log2(k)));K=2*k**3;I=2*k**4-(k*(k+1)//2)**2
 assert k>=32 and log2(8*2.718281828459045*k**3)<=4*log2(k)
 assert 2*K*D*log2(4*2.718281828459045*K/D)-I<=-k**4/2
counts['subgrid_enumerations']=len(subgrid)
plane=[]
for q in [2,3,5,7,11,101,1009]:
 ratio=F(2)/(q*(F(1,(q+1)**2)+F(1,q**4)))
 assert ratio>=q
 assert F(1,8*(q+1))<=F(q,(q+1)**2)
 # Eliminating R gives dc <= 11 + 8 M <= 19 M for M>=1.
 for M in [F(1),F(3,2),F(10),F(10000)]: assert 11+8*M<=19*M
 plane.append(dict(q=q,R=str(ratio)))
counts['plane_cases']=len(plane)
for n in [1,3,9,31,101]:
 for e in [0.2,0.1,0.01]:
  g=1/n;ta=e/(8*n);T=ceil(100/(e*e*g*g));a=1/sqrt(T)
  bound=1/(2*a*T)+a*(1+ta)**2/2+2*ta
  assert bound<=e*g/2+1e-15
counts['hinge_constant_cases']=15
for theta in [0.0624,0.01,0.001]: assert 15*log(8/theta)/4>18
for n in [1,10,100,1000]: assert n*log(2)-4*n<=-3*n
summary=dict(seed=20260910,counts=counts,all_passed=True,
 constants=dict(c6=c6,inverse_coverage_exact=48/c6,r6=str(r6),inverse_r6=r6.denominator,
 five_ball_lower=ball,five_ball_flip_lower=ball/48,first_positive_D_k=first,
 covariance_lower_factor=16/17-1/8,proper_mass_ratio_min=15*log(128)/4),
 rectangle_parameters=parameters,subgrid=subgrid,planes=plane)
out.write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:summary[k] for k in ['seed','counts','all_passed','constants']},indent=2))
