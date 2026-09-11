from pathlib import Path
root=Path(__file__).resolve().parent
baseline=root/'turn2_baseline'
old=(baseline/'main.tex').read_text()
def section(a,b):return old[old.index(a):old.index(b)]
pre=old[:old.index('\\begin{document}')]
pre=pre.replace('booktabs,array,tikz','booktabs,array,tikz,longtable,enumitem')
pre=pre.replace('\\date{September 10, 2026}','\\date{September 10, 2026\\\\Third research draft}')
pre+='\\newtheorem*{parameterlemma}{Lemma 9.1 (Exact parameters)}\n\\setlist[itemize]{topsep=3pt,itemsep=2pt}\n'
abstract=r'''\begin{abstract}
If every product distribution on a finite truth table has a monochromatic rectangle of mass at least $1/\rho$, one distribution-independent SQ learner uses $O(\rho(\log|H|+\log(1/\epsilon)))$ queries of tolerance $\Omega(\epsilon/(\rho\log(1/\epsilon)))$ to achieve expected error at most $\epsilon$ against every valid adaptive oracle. This rectangle theorem has two consequences. First, the random monotone incidence flips of Hatami et al., on $2M$ points, are SQ-learnable with $O(\log M)$ queries at fixed accuracy while their dimension is $\Omega(M^{1/3}/\log M)$, their exact probabilistic dimension is $\Omega(M^{1/3}/\log^2M)$, and their averaged probabilistic dimension is $\Omega_\eta(M^{1/3}/\log M)$ for every fixed $\eta<1/2$. Second, a cap implementation for fixed-dimensional templates is polynomial-time in the supplied table, admits a deterministic version, and yields a proper learner with $O(\log M+1/\epsilon+\log(1/\epsilon))$ queries. We prove that the rectangle condition is sufficient but not necessary, quantify marginal adaptation, and refute a source-description-length repair when computation is free. The high-dimension selection is not efficiently explicit. The specified Gaussian-initialized plain-SGD question remains open. Exact oracle and finite-coverage CPU audits were executed; the pinned Lean sources remain uncompiled.
\end{abstract}
'''
defs=section('\\section{Definitions and quantifiers}','\\section{The rectangle learner}')
defs=defs.replace('Let $X$ and the nonempty indexed class', 'Let $X$ be nonempty and finite, and let the nonempty indexed class')
defs=defs.replace('For the probabilistic variants we fix $\\sign(0)=+1$, without changing the strict definition above.','For the probabilistic variants we use $\\sign(0)=+1$, without changing the strict definition above. Appendix~\\ref{app:referee} verifies that both lower bounds also hold under the opposite tie rule or when zeros are counted as errors.')
main=section('\\section{The rectangle learner}','\\section{The incidence-flip family}')
beg=main.index('\\begin{theorem}')
end=main.index('\\end{theorem}',beg)+len('\\end{theorem}')
oldtheorem=main[beg:end]
newtheorem=r'''\begin{theorem}[Distribution-independent rectangle learner]\label{thm:main}
Suppose $\rho\ge1$ and $\rect(H)\ge1/\rho$. For every $0<\epsilon<1/4$, one randomized algorithm satisfies \eqref{eq:guarantee} with
\[
 m=O\!\left(\rho(\log K+\log(1/\epsilon))\right),\qquad
 \tau=\Omega\!\left(\frac{\epsilon}{\rho\log(1/\epsilon)}\right).
\]
Query count is a worst-case bound. The learner is explicit from the truth table and a valid lower bound on $\rect(H)$; the general implementation may solve exponential-size linear programs.
\end{theorem}
\begin{parameterlemma}
The theorem holds with
\begin{align}
 r&=1/\rho,&P&=1+\lceil4\rho\ln(8/\epsilon)\rceil,&\tau&=\epsilon/(24P),\label{eq:params1}\\
 B&=\ln K+\ln(8/\epsilon)+1,&R&=\lceil8\rho(B+\ln(2/\epsilon))\rceil,&m&=3R+1.\label{eq:params2}
\end{align}
\end{parameterlemma}'''
main=main[:beg]+newtheorem+main[end:]
main=main.replace('\\paragraph{Algorithm.}','\\paragraph{Algorithm RECTIFY.}')
# Recover actual old algorithm paragraph regardless of formatting.
pos=main.find('\\paragraph{Algorithm}')
if pos>=0:main=main[:pos]+main[pos:].replace('\\paragraph{Algorithm}','\\paragraph{Algorithm RECTIFY}',1)
# Box the algorithm without splitting its environment across pages.
a=main.find('\\paragraph{Algorithm RECTIFY')
if a<0:a=main.find('\\paragraph{Algorithm.')
if a>=0:
    e=main.find('\\end{enumerate}',a)+len('\\end{enumerate}')
    body=main[a:e]
    body=body.replace('\\paragraph{Algorithm RECTIFY.}','\\textbf{RECTIFY: rectangle peeling and elimination.}\\par\\smallskip').replace('\\paragraph{Algorithm.}','\\textbf{RECTIFY: rectangle peeling and elimination.}\\par\\smallskip')
    main=main[:a]+'\\begin{center}\\fbox{\\begin{minipage}{.94\\linewidth}\n'+body+'\n\\end{minipage}}\\end{center}\n'+main[e:]
main=main.replace('There is no candidate verification test, conditional-label query, isotropic transform, or unsafe subspace restriction.', 'This general implementation requires no candidate test, conditional-label oracle, isotropic transform, or subspace restriction. Section~\\ref{sec:caps} supplies the separate cap implementation.')
main=main.replace('\\begin{proof}\nFor each rectangle let', '\\begin{proof}\nThis minimax device is also used in \\citet[Theorem~3.1]{HHPTZ22}; we include the proof and the rational feasibility detail. For each rectangle let',1)
construction=section('\\section{The incidence-flip family}','\\section{Probabilistic dimension under the actual definitions}')
construction=construction.replace('Section~\\ref{sec:cap}','Appendix~\\ref{app:oldgeometry}')
prob=section('\\section{Probabilistic dimension under the actual definitions}','\\section{A direct check through randomized statistical dimension}')
rsd=section('\\section{A direct check through randomized statistical dimension}','\\section{The geometric proposal: repairs and attacks}')
# Keep only the standalone old Proposition 14 and Proposition 15, with proofs, in appendices.
cap=section('\\section{The geometric proposal: repairs and attacks}','\\section{Why spectral certificates could not see this}')
a=cap.index('\\begin{proposition}');e=cap.index('\\end{proof}',a)+len('\\end{proof}')
cap=cap[a:e]
pg=section('\\section{Why spectral certificates could not see this}','\\section{The SGD question and the exact transfer}')
a=pg.index('\\begin{proposition}');e=pg.index('\\end{proof}',a)+len('\\end{proof}');pg=pg[a:e]
# Lean lemmas retain their literal statements and proofs from the previous paper.
lean=section('\\section{Finite Lean targets and verification status}','\\section{What remains open}')
lean=lean.replace('\\section{Finite Lean targets and verification status}','\\section{Finite Lean targets and verification status}\\label{app:lean}')
# Replace obsolete execution report while leaving exact mathematical L1--L4 statements.
lean=lean.replace(r'The actual commands \texttt{lake --version}, \texttt{lake build}, and \texttt{lean --version} each returned command-not-found and exit 127.', r'In this turn, \texttt{lake --version} returned command-not-found and exit 127. No further compiler or installation effort was attempted. The previous turn also recorded unavailable build commands.')
lean=lean.replace(r'\texttt{2631d1cc8c2ace6c6a900425d6e5d2b5963966e9}', r'\begin{center}\small\texttt{2631d1cc8c2ace6c6a900425d6e5d2b5963966e9}\end{center}').replace(r'\texttt{leanprover/lean4:v4.34.0-rc2}', r'{\small\texttt{leanprover/lean4:v4.34.0-rc2}}')
root.joinpath('old_lean_section.tex').write_text(lean)
bib=old[old.index('\\begin{thebibliography}'):old.index('\\end{thebibliography}')]
bib=bib.replace('\\begin{thebibliography}{12}','\\begin{thebibliography}{16}')
# New references if not already included.
extra=r'''
\bibitem[Diakonikolas et al.(2022)]{DKT22} Ilias Diakonikolas, Christos Tzamos, and Daniel M. Kane. A Strongly Polynomial Algorithm for Approximate Forster Transforms and its Application to Halfspace Learning. arXiv:2212.03008, 2022. \url{https://arxiv.org/abs/2212.03008}.
\bibitem[Mahboubi and Cohen(2012)]{MC12} Assia Mahboubi and Cyril Cohen. Formal proofs in real algebraic geometry: from ordered fields to quantifier elimination. arXiv:1201.3731, 2012. \url{https://arxiv.org/abs/1201.3731}.
'''
open_section=r'''\section{Open problems and limits}
The statistical-query implications to $\dc$, $\dc_{1/2}$ and $\dc^{C\epsilon}$ are refuted. The proper--improper issue for this family is settled on the proper-learning side. Neither result settles learning by the particular online Gaussian-initialized bias-free ReLU dynamics.

An efficiently computable, total, high-sign-rank matrix with polynomial inverse rectangle ratio remains the explicit-construction problem investigated here. The exhaustive generator in Theorem~\ref{thm:description} is not a solution under that computational meaning of explicitness. A parameter measuring rectangle-type product-distribution structure may still characterize distribution-independent SQ complexity, but $\rect^{-1}$ alone cannot: cube halfspaces and parities both have exponentially small rectangles, while only the latter have the corresponding SQ obstruction. Such a characterization would need an additional feature or an optimized representation of the task.

The joint dependence on query count and tolerance in Theorem~9 remains unoptimized. The projective-plane example proves a linear lower bound on $m/\tau^2$, not a matching lower bound for the theorem's full parameter tradeoff. Finite-bit computation or expanded-circuit size, rather than source-program length alone, is necessary for a meaningful resource-aware repair. No general polynomial-dimension theorem under those stronger charges is proved. Finally, the Lean sources have not been compiled in this environment; they are not a verified formalization of the new main results.
'''
content=pre+'\\begin{document}\n\\maketitle\n'+abstract+'\\input{intro.tex}\n'+defs+main+construction+prob+rsd+'\\input{caps.tex}\n\\input{proper.tex}\n\\input{landscape.tex}\n\\input{resources.tex}\n'+open_section+'\n\\appendix\n\\input{referee.tex}\n\\input{convex.tex}\n\\input{concentration.tex}\n\\input{verification.tex}\n\\input{old_lean_section.tex}\n\\section{Retained independent geometric bounds}\\label{app:oldgeometry}\n\\setcounter{theorem}{13}\n'+cap+'\n'+pg+'\n\\section{Retained barrier, plane, and transcript results}\\label{sec:retained}\n\\setcounter{theorem}{0}\n\\input{retained.tex}\n'+bib+extra+'\\end{thebibliography}\n\\end{document}\n'
content=content.replace('APPRS05','APPRS05')
root.joinpath('main.tex').write_text(content)
import shutil
for name in ['retained.tex','figure.tex']:shutil.copy(baseline/name,root/name)
print('assembled',len(content),'bytes')
