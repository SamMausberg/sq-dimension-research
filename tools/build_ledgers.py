#!/usr/bin/env python3
"""Generate the late-result inequality ledgers from one canonical data file."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
GROUPS=[]
def group(old,label,title,rows):
    GROUPS.append(dict(old=old,label=label,title=title,rows=[dict(id=f'{old}-{i+1}',inequality=a,adversary=b,randomness=c) for i,(a,b,c) in enumerate(rows)]))
group('5.3','lem:median','Integer medians',[
(r'$\zeta\ge0,\ \beta>0,\ \beta\ge512\zeta$.',r'Explicit parameter domain; no answer used.','None.'),
(r'$\widehat F(t)\ge\widehat\beta/2\Rightarrow F(t)\ge\beta/2-3\zeta/2$.',r'$\widehat F=F+\zeta$, $\widehat\beta=\beta-\zeta$ minimize the certified mass.','Pathwise.'),
(r'$\widehat F(t)<\widehat\beta/2\Rightarrow F(t)<\beta/2+3\zeta/2$.',r'$\widehat F=F-\zeta$, $\widehat\beta=\beta+\zeta$ maximize it.','Pathwise.'),
(r'$F(v)\ge\beta/2-3\zeta/2$, $F(v-1)<\beta/2+3\zeta/2$.',r'Binary search retains a certified lower and upper endpoint; replies need not be monotone.','Pathwise.'),
(r'$\widehat m\le\widehat\beta/8\Rightarrow m\le\beta/8+9\zeta/8$.',r'$\widehat m=m-\zeta$, $\widehat\beta=\beta+\zeta$.','Pathwise.'),
(r'$F(v)<5\beta/8+21\zeta/8$.',r'Add the preceding atom bound to $F(v-1)<\beta/2+3\zeta/2$.','None.'),
(r'$\widehat m>\widehat\beta/8\Rightarrow m>\beta/8-9\zeta/8>\beta/9$.',r'$\widehat m=m+\zeta$, $\widehat\beta=\beta-\zeta$; the last step uses $\beta>81\zeta$.','Pathwise.')])
group('5.4','thm:fast','Succinct learner',[
(r'$\zeta=\epsilon/4096$; raw and rounding errors are at most $\zeta/2$ each.',r'Triangle inequality; finite answer representation is part of the computational interface.','None.'),
(r'$\widehat\beta\le\epsilon/4\Rightarrow\beta\le\epsilon/4+\zeta$.',r'$\widehat\beta=\beta-\zeta$.','Pathwise.'),
(r'$\widehat\beta>\epsilon/4\Rightarrow\beta>1023\zeta>512\zeta$.',r'$\widehat\beta=\beta+\zeta$.','Pathwise.'),
(r'$\mu^-(P\cap Q)\ge\beta/2-3\zeta/2$ for two prefixes.',r'Intersection is the smaller prefix; apply both median lower bounds.','None.'),
(r'$\mu^-(P\cap Q)\le\beta/4+21\zeta/4$ for a prefix and a suffix.',r'Their intersection mass is $\max(0,\mu^-(P)+\mu^-(Q)-\beta)$.','None.'),
(r'$\widehat{\mu^-(P\cap Q)}-3\widehat\beta/8\ge(\beta-23\zeta)/8>0$ in the prefix case.',r'Intersection answer minus $\zeta$; total answer plus $\zeta$.','Pathwise.'),
(r'$3\widehat\beta/8-\widehat{\mu^-(P\cap Q)}\ge(\beta-53\zeta)/8>0$ in the suffix case.',r'Intersection answer plus $\zeta$; total answer minus $\zeta$.','Pathwise.'),
(r'$\widehat{\mu^-(P)}>\widehat\beta/8$ for the constant residual.',r'Lower observed mass is $\beta/2-5\zeta/2$; compare with $(\beta+\zeta)/8$.','Pathwise.'),
(r'$\widehat{\mu^-(Q\setminus P)}>\widehat\beta/8$ for the constant residual.',r'Even a difference of two answers is at least $3\beta/8-37\zeta/8$; $\beta>19\zeta$ suffices.','Pathwise.'),
(r'A wrong-slope residual atom is a singleton; one split answer is at most $2\zeta<\widehat\beta/8$.',r'Allow two endpoint errors if the split is obtained by subtraction; $\beta>17\zeta$.','Pathwise.'),
(r'$\zeta<\widehat\beta/32<\beta/9-\zeta$.',r'Use $\widehat\beta\in[\beta-\zeta,\beta+\zeta]$ and $\beta\ge512\zeta$; separates zero from a heavy atom.','Pathwise.'),
(r'Large outside negative mass is $>\epsilon/4-\zeta$; star-half queries are zero or that mass.',r'Every other line through the known point misses the target away from it; threshold $\epsilon/8$ remains separated by $\zeta$.','Pathwise.'),
(r'Small outside negative mass is $\le\epsilon/4+\zeta$.',r'The answer can underestimate by $\zeta$; the one-point predictor has this error.','Pathwise.'),
(r'$C_0=\max(64\lceil n\rceil,\lceil128/\epsilon\rceil)$; a smaller enumerated star contains the target.',r'Target loss answer is at most $\zeta<\epsilon/2$.','None.'),
(r'At most $8/\epsilon$ star rows have outside negative mass $>\epsilon/8$.',r'Their outside negative supports are disjoint and total mass is at most one.','None.'),
(r'At least $t/4-8/\epsilon\ge t/8$ rows pass; their loss is at most $3\epsilon/8+\zeta$.',r'On a regular star with $t>C_0$; answer at most $3\epsilon/8+2\zeta<\epsilon/2$.','None.'),
(r'Each row has sampling probability $\ge1/(2t)$; success per trial is $\ge1/16$.',r'Use $\lceil\log_2t\rceil$ bits reduced modulo $t$; the good-row count is pathwise.','Fresh learner bits.'),
(r'$J=\lceil16\ln(4/\epsilon)\rceil$; failure $\le(15/16)^J\le\epsilon/4$.',r'Independent trials; every good row passes every permitted loss answer.','Learner bits.'),
(r'$\E L\le\epsilon/2+\zeta+\epsilon/4<\epsilon$.',r'Any passed test certifies loss $\le\epsilon/2+\zeta$; failure output loss is at most one.','Learner bits only.'),
(r'$m=O(n^2+1/\epsilon+\log(1/\epsilon))$.',r'At most $O(n)$ slope stages and $O(n)$ binary queries per median; all integer tests use $O(n)$-bit coordinates.','None.')])
group('6.1','lem:subgrid','Counting on a subgrid',[
(r'$K_k=2k^3$, $I_k=2k^4-[k(k+1)/2]^2$.',r'Sum $2k^2-ax$ over $a,x\in[k]$; no oracle.','None.'),
(r'$D_k=\lfloor k/(24\log_2k)\rfloor\le K_k/2$.',r'For $D_k=0$ the nonpositive-rank event is empty.','None.'),
(r'$D_k\ge1\Rightarrow k\ge32\Rightarrow\log_2(8ek^3)\le4\log_2k$.',r'The implication is only a sufficient range check; it does not locate the first positive $D_k$.','None.'),
(r'$\log_2\#\{\sr\le D_k\}\le2K_kD_k\,4\log_2k\le2k^4/3$.',r'Warren applies to strict patterns of degree two in $2K_kD_k$ variables.','None.'),
(r'$k\ge3\Rightarrow I_k\ge3k^4/2$.',r'$(k+1)^2/(4k^2)\le1/2$ for $k\ge3$.','None.'),
(r'$\Pr[\sr\le D_k]\le2^{2k^4/3-I_k}\le2^{-5k^4/6}\le2^{-k^4/2}$.',r'All $I_k$ free positions are independent uniform bits.','Random flips.'),
(r'$\sr(A)\le D_k\iff\exists U,V:\ A_{ij}\sum_sU_{is}V_{sj}\ge1$.',r'Scale a strict factorization by its finite minimum signed score; coefficients are $-1,0,1$.','None.'),
(r'$(K_k^2)^{O(K_kD_k)}=2^{O(k^3D_k\log k)}=2^{O(k^4)}$.',r'Use the cited singly exponential existential-real decision bound with degree two and bounded coefficient length.','None.')])
group('6.2','thm:prf','Pseudorandom restriction',[
(r'$n=3b+1$, $N=2^b$, $k=\lceil c n^c\rceil\le N$ eventually.',r'Fix $c,\delta$ before the asymptotic limit.','None.'),
(r'$E_b(a,b_0,x,y)$ has $6b+2=2n$ bits and is injective.',r'Concatenate zero-based coordinates in widths $b,2b+1,b,2b+1$; keep this ambient encoding in every restriction.','None.'),
(r'Exactly $I_k\le2k^4$ function values determine the restricted matrix.',r'Query only incidences. Uniform oracle values at these distinct ambient inputs are independent fair bits.','Function oracle, not SQ.'),
(r'$2^{C_c n^{4c}}\le2^{n^{4c+2}}\le2^{\sigma^\delta}$ eventually.',r'$\sigma=n^p$, $p=\lceil(4c+2)/\delta\rceil$; the $n^2$ slack absorbs the fixed decision-procedure constant and reading cost.','None.'),
(r'$\Pr_s[\sr(A_s|_k)\le D_k]\le2^{-k^4/2}+\operatorname{negl}(\sigma)$.',r'Use the low-rank decision as the acceptance event; nonnegligible excess would distinguish from a random function.','Uniform key / random function.'),
(r'$\operatorname{negl}(n^p)=\operatorname{negl}(n)$.',r'For each desired exponent $q$, use the security estimate with exponent $q/p$; $p$ is fixed.','None.'),
(r'$\dc(H_{A_s})\ge D_k+1>k/(24\log_2k)$.',r'Restriction cannot increase sign-rank; use the complement of the low-rank event.','Good-key event.'),
(r'$\log_2k\le c\log_2n+\log_2(2c)\le(5/4)c\log_2n$.',r'For all sufficiently large $n$; the extra factor $c$ in $k$ is retained.','None.'),
(r'$k/(24\log_2k)\ge n^c/(30\log_2n)$.',r'Substitute $k\ge c n^c$ and the preceding logarithmic estimate.','None.')])
group('6.5','cor:fastprf','Joint good-key event',[
(r'$\Pr[\operatorname{Bin}(t,1/2)<t/4]\le e^{-t/16}$.',r'Multiplicative Chernoff with mean $t/2$ and relative deviation $1/2$.','Random incidence bits.'),
(r'$t\ge64\lceil n\rceil\Rightarrow2^ne^{-t/16}\le e^{-3n}$.',r'Union bound over all points; the regularity event is independent of $\epsilon$.','Random flips.'),
(r'Star-regularity is decidable in $2^{O(n)}\le2^{\sigma^\delta}$ time eventually.',r'Enumerate incidences using the same ambient encoding; transfer the bad-star event by PRF security.','Uniform key / function.'),
(r'$\Pr_s[\text{bad rank or bad stars}]=\operatorname{negl}(n)$.',r'Union bound, not independence of the events.','Uniform key.'),
(r'$m=O_\epsilon(n^2)$, $1/\tau=O_\epsilon(1)$, $\mathrm{TIME}=\operatorname{poly}_{c,\epsilon}(n)$.',r'Apply the proper succinct algorithm on regular keys; its deterministic improper version works for every key.','Learner bits for proper output.')])
group('7.1','thm:communication','Product-average communication',[
(r'$\Pr[L\le2c]\ge1/2$.',r'Markov on the cost of an exact deterministic protocol under the chosen product measure.','Product-distributed inputs.'),
(r'$\#\{\text{leaves of depth}\le2c\}\le2^{\lfloor2c\rfloor}$.',r'Prefix-free transcripts can be injected into strings of length $\lfloor2c\rfloor$.','None.'),
(r'$\max_Q(\mu\times\nu)(Q)\ge2^{-\lfloor2c\rfloor-1}\ge2^{-2c-1}$.',r'One shallow monochromatic leaf carries the average shallow mass. At $c=0$, all positive-mass inputs reach a zero-cost leaf.','Product inputs.'),
(r'$\Pr[\text{continue after }j\text{ stages}]\le(1-r)^j$.',r'Conditioning a product measure on a protocol cell preserves product form; each selected rectangle has conditional mass $\ge r$.','Product inputs.'),
(r'$\E[\text{bits}]\le2\sum_{j\ge0}(1-r)^j=2/r$.',r'Two membership bits per stage; complete zero-mass cells by a finite exact protocol.','Product inputs.'),
(r'$\rho=2^{2c+1}=2\cdot4^c$.',r'Substitute into the rectangle learner; its arbitrary-policy guarantee is unchanged.','RECTIFY draws.')])
group('7.9','thm:halfspaces','Cube halfspaces',[
(r'$\dc(H_n)\le n$ for odd $n$.',r'Identity embedding; dot products are odd integers and nonzero.','None.'),
(r'$\langle w,x\rangle<0\Rightarrow d_H(w,x)\ge(n+1)/2$.',r'Use $\langle w,x\rangle=n-2d_H(w,x)$.','None.'),
(r'$\langle w,x\rangle>0\Rightarrow d_H(-w,x)\ge(n+1)/2$.',r'Negate one side only; it is a measure-preserving bijection of the uniform cube.','None.'),
(r'$\alpha\le e^{-2s^2/n}$, with $s=\E d_H(Z,A)$.',r'Distance to $A$ changes by at most one per coordinate. Apply the lower bounded-differences tail at $s$.','Independent uniform cube coordinates.'),
(r'$s\le t\Rightarrow\beta\le e^{-2(t-s)^2/n}$.',r'Every point of the other set has distance at least $t$; apply the upper tail.','Uniform cube.'),
(r'$\alpha\beta\le e^{-2[s^2+(t-s)^2]/n}\le e^{-t^2/n}\le e^{-n/4}$.',r'$s^2+(t-s)^2\ge t^2/2$ and $t=(n+1)/2$. If $s\ge t$, use $\alpha\le e^{-2t^2/n}$ instead.','None.'),
(r'$F(v^*)=0$, $\|g\|\le1$, $\|\widehat g-g\|\le\tau$.',r'$\gamma=1/n$; coordinate query errors at either endpoint are divided by $\sqrt n$.','Pathwise SQ answers.'),
(r'$F(\bar v)\le1/(2aT)+a(1+\tau)^2/2+2\tau$.',r'Projected subgradient distance telescope; perturbation inner product is at most $2\tau$.','Pathwise.'),
(r'$T\ge100/(\epsilon^2\gamma^2)$, $a=T^{-1/2}$, $\tau=\epsilon\gamma/8$.',r'$(1+\tau)^2<4$ implies $F(\bar v)\le5/(2\sqrt T)+2\tau\le\epsilon\gamma/2$.','None.'),
(r'$L\le F(\bar v)/\gamma\le\epsilon/2$, $m=nT=O(n^3/\epsilon^2)$.',r'Every thresholding error incurs hinge cost at least $\gamma$.','Deterministic learner.')])
group('8.1','cor:engineered','Engineered full-batch simulation',[
(r'$\sup_O L_{01}(A^O)\le\epsilon/8$.',r'Use the deterministic improper learner, valid for every key. No expected-to-pathwise conversion is made.','None.'),
(r'$L_{\rm square}(A)\le\epsilon/16$.',r'For Boolean labels and predictions, half squared error is half classification error.','Pathwise.'),
(r'$\lambda=\tau_0/16$, $T^{\prime}=2k$, $m_s\lambda^2>C(k\log(1/\lambda)+\log(1/\delta))$.',r'Imported full-batch Theorem 3d: one sample is reused, with $\lambda$-grid gradients within $3\lambda/4$ of the clipped empirical gradient.','Sample and initialization.'),
(r'$p=\operatorname{poly}(k,1/\tau_0,r,\mathrm{TIME},1/\delta)$.',r'TIME includes the succinct learner and query evaluations. Set $r=1$ with an ignored bit, not an assumed $r=0$ case.','Ignored initialization bit.'),
(r'$\E_{S,R}\sup_{g_1,\ldots,g_{T\prime}}L_{\rm square}\le\epsilon/16+\delta=\epsilon/8$.',r'$\delta=\epsilon/16$. Retain the imported supremum inside the expectation, including its dependence on the whole sample.','Sample / initialization; arbitrary admissible gradients.'),
(r'$L_{01}(\1_{f\ge1/2})\le8L_{\rm square}(f)$.',r'A threshold error gives $|f-y|\ge1/2$ and half squared error at least $1/8$.','Pointwise.'),
(r'$\E L_{01}\le\epsilon$, $p,m_s=\operatorname{poly}_{c,\epsilon}(n)$, $T^{\prime}=O(n^2)$.',r'Only the time bound of the succinct learner and the imported polynomial are used; no polynomial in query count alone is substituted.','Sample / initialization.')])
group('10.3','prop:unseen','Unseen independent labels',[
(r'$\Pr[x\text{ unseen}]=(1-1/N)^T$.',r'The sample indices are iid uniform on a full template line.','Sample indices.'),
(r'$\E[L\mid\text{indices, observed labels, learner coins}]\ge\#\{\text{unseen}\}/(2N)$.',r'Each unseen label remains a fair independent bit because the learner was fixed independently of the table.','Unseen random flip bits.'),
(r'$\E L\ge\tfrac12(1-1/N)^T\ge\tfrac12(1-T/N)$.',r'Average the preceding identity; Bernoulli inequality.','Table, samples, learner coins.'),
(r'$\E L\le\epsilon\Rightarrow T\ge(1-2\epsilon)N$.',r'This is a uniform-over-tables or average-table premise, not a claim for each individually selected table.','None.'),
(r'$\epsilon<1/4,\ S\ge2\Rightarrow TS\ge N\ge\dc(H_A)/3$.',r'$\dc(H_A)\le2N+1\le3N$. Keep the table-independent learner premise.','None.')])

out=ROOT/'audits/current';out.mkdir(parents=True,exist_ok=True)
(out/'new_result_ledger.json').write_text(json.dumps(GROUPS,indent=2))
md=['# Adversarial re-verification of later results','',
    'Original numbering is from release 7. New numbers are in NUMBERING.md. Each row records a proof step, the adverse endpoint or other justification, and the randomness involved. These are mathematical checks and finite regression tests, not a machine-checked formalization.','',
    'Independent derivations were recorded in `independent_derivations.md` before comparing the corresponding source proofs. Source statements and proof bindings were then checked against the release archive.','']
tex=[r'\section{Endpoint and randomness ledgers for the later results}\label{app:newaudit}',
     r'Every row below is pathwise unless its randomness column says otherwise. Endpoint pairs may be mutually incompatible across rows; using them separately only strengthens each bound. Bounds involving imported simulation randomness retain the supremum inside the expectation. The first column uses local row identifiers; the electronic ledger also records the previous statement numbers.']
for g in GROUPS:
    md+=['## '+g['old']+': '+g['title'], '', '| ID | Inequality | Adverse answer / justification | Randomness |', '|---|---|---|---|']
    for r in g['rows']:
        md+=['| '+' | '.join(r[k].replace('|',r'\vert') for k in ['id','inequality','adversary','randomness'])+' |']
    md+=['']
    tex += [r'\subsection{\texorpdfstring{\Cref{'+g['label']+'}: '+g['title']+'}{'+g['title']+'}}',r'\begingroup\footnotesize\setlength{\tabcolsep}{3pt}\renewcommand{\arraystretch}{1.18}',
    r'\begin{longtable}{@{}p{.045\linewidth}p{.40\linewidth}p{.35\linewidth}p{.15\linewidth}@{}}',r'\toprule ID & Inequality & Adverse answer or justification & Randomness\\\midrule\endhead']
    for j,r in enumerate(g['rows'],1):
        tex += [f'{j} & {r["inequality"]} & {r["adversary"]} & {r["randomness"]}'+r'\\']
    tex += [r'\bottomrule\end{longtable}\endgroup']
(out/'NEW_RESULT_LEDGER.md').write_text('\n'.join(md)+'\n')
(ROOT/'paper/appendices/new_result_audit.tex').write_text('\n'.join(tex)+'\n')
print(f'Generated {len(GROUPS)} ledgers, {sum(len(g["rows"]) for g in GROUPS)} inequality rows.')
