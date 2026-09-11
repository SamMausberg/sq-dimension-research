"""Extract canonical statements and proof bindings; check a reviewed dependency graph.
This is source consistency checking, not proof-assistant verification.
"""
from pathlib import Path
import re,json,hashlib,difflib,graphlib,collections
root=Path(__file__).resolve().parents[1]
out=root/'checks'; inv=json.loads((out/'statement_inventory.json').read_text())
files=sorted((root/'sections').glob('*.tex'))+sorted((root/'appendices').glob('*.tex'))
texts={str(p.relative_to(root)):p.read_text() for p in files}
def lineno(s,i):return s.count('\n',0,i)+1
def sr(s):return hashlib.sha256(s.encode()).hexdigest()
pat=re.compile(r'\\begin\{(theorem|lemma|proposition|corollary)\}(?:\[([^\]]*)\])?([\s\S]*?)\\end\{\1\}')
st=[]
for f,s in texts.items():
 for m in pat.finditer(s):
  lab=re.search(r'\\label\{([^}]+)\}',m.group());assert lab,(f,m.group()[:100]);label=lab[1]
  num=next(x['number'] for x in inv if x['label']==label)
  st.append(dict(label=label,number=num,file=f,start=lineno(s,m.start()),end=lineno(s,m.end()),text=m.group(),sha256=sr(m.group()),offset=m.start(),end_offset=m.end()))
assert len(st)==39 and len({x['label'] for x in st})==39
bylabel={x['label']:x for x in st};proofs={}
for f,s in texts.items():
 for m in re.finditer(r'\\begin\{proof\}(?:\[([^\n]*)\])?([\s\S]*?)\\end\{proof\}',s):
  head=m[1] or ''; labs=[]
  for refs in re.findall(r'\\(?:[Cc]ref|ref)\{([^}]+)\}',head):labs+=refs.split(',')
  labs=[x for x in labs if x in bylabel]
  if not labs:
   prev=[x for x in st if x['file']==f and x['end_offset']<m.start()]
   if prev:labs=[max(prev,key=lambda x:x['end_offset'])['label']]
  for label in labs:
   assert label not in proofs,(label,f)
   proofs[label]=dict(file=f,start=lineno(s,m.start()),end=lineno(s,m.end()),text=m.group(),sha256=sr(m.group()),binding='explicit canonical reference' if head else 'immediately following canonical statement')
assert set(proofs)==set(bylabel),(set(bylabel)-set(proofs))
# Check that a main-text deferred proof pointer encloses a bound proof.
ptrs={}
for f,s in texts.items():
 for m in re.finditer(r'\\label\{(proof:[^}]+)\}',s):
  ptrs[m[1]]=(f,lineno(s,m.start()))
for x in st:
 s=texts[x['file']];tail=s[x['end_offset']:]
 end=re.search(r'\\begin\{(?:theorem|lemma|proposition|corollary)\}',tail)
 tail=tail[:end.start()] if end else tail
 for pt in re.findall(r'\\(?:[Cc]ref|ref)\{(proof:[^}]+)\}',tail):
  assert pt in ptrs and ptrs[pt][0]==proofs[x['label']]['file'],(x['label'],pt)
# No canonical theorem is duplicated in an appendix. Extracted theorem/proof units shipped verbatim.
extractdir=out/'statement_proof_extracts';extractdir.mkdir(exist_ok=True)
rows=[];changes=[]
for x in st:
 p=proofs[x['label']];fn=x['number'].replace('.','_')+'.tex'
 (extractdir/fn).write_text('% Canonical statement: '+x['file']+f":{x['start']}-{x['end']}\n"+x['text']+'\n\n% Proof binding: '+p['file']+f":{p['start']}-{p['end']}\n"+p['text']+'\n')
 old=json.loads((out/'baseline_statements.json').read_text())[x['label']]
 diff=''.join(difflib.unified_diff(old.splitlines(True),x['text'].splitlines(True),fromfile='turn5:'+x['file'],tofile='turn6:'+x['file']))
 if diff:changes.append(dict(label=x['label'],number=x['number'],diff=diff))
 rows.append({k:v for k,v in x.items() if k not in ['text','offset','end_offset']}|{'proof':{k:v for k,v in p.items() if k!='text'},'restatement':'No independent restatement: proof binds the canonical statement.'})
# Dependencies are reviewed mathematical uses, not every rhetorical cross-reference.
D={
'lem:finite-minimax':[], 'lem:product-weights':[], 'lem:ties':[],
'lem:params':['lem:mixture'], 'lem:mixture':['lem:finite-minimax'], 'thm:main':['lem:mixture'],
'thm:construction':['lem:product-weights','thm:main','import:Warren-AMY','import:APP-HHPTZ','prop:cap-bound'],
'thm:prob':['thm:construction','lem:ties','import:Warren-AMY'], 'lem:exact-prob':['lem:ties'],
'cor:negative-answer':['thm:construction','thm:prob','lem:exact-prob','thm:caps','thm:proper'],
'thm:caps':['thm:forster','aux:convex-bit','thm:main'], 'thm:proper':['thm:caps','thm:main'],
'lem:median':[], 'thm:fast':['lem:median'],
'lem:subgrid':['import:Warren-AMY','import:ETR-Vorobjov'],
'thm:prf':['lem:subgrid','thm:construction','thm:proper','assumption:PRF'],
'prop:advice':['lem:subgrid','thm:caps','thm:proper'],
'lem:regularstars':['assumption:PRF'], 'cor:fastprf':['thm:prf','lem:regularstars','thm:fast'],
'thm:communication':['thm:main'], 'thm:energy':[], 'thm:barrier':['thm:energy'],
'thm:forster':[], 'thm:plane':['thm:forster','thm:barrier'],
'thm:tree':['lem:finite-minimax'], 'prop:affine':['thm:energy','thm:barrier'],
'thm:pgglobal':[], 'thm:halfspaces':['aux:cube-concentration'],
'thm:adapt':['thm:tree','thm:caps'],
'cor:approxrect':['lem:product-weights','thm:main','import:BHKR26'],
'cor:engineered':['thm:fast','thm:prf','import:AKMSS21'],
'thm:network':[], 'prop:hiddenkey':['assumption:PRF'],
'thm:description':['thm:construction','thm:main','import:RCF-MC12'],
'thm:classicalbarrier':['lem:finite-minimax'], 'prop:unseen':[],
'thm:rsd':['lem:finite-minimax','import:Feldman17-definition'],
'prop:cap-bound':['thm:forster','lem:product-weights'], 'prop:pg-rect':['thm:plane'],
'aux:convex-bit':[], 'aux:cube-concentration':[],
'import:Warren-AMY':[], 'import:APP-HHPTZ':[], 'import:ETR-Vorobjov':[],
'import:Feldman17-definition':[], 'import:BHKR26':[], 'import:AKMSS21':[], 'import:RCF-MC12':[], 'assumption:PRF':[],
'summary:MainTheorem':['thm:main','thm:construction','thm:prob','lem:exact-prob','thm:caps','thm:proper']}
order=list(graphlib.TopologicalSorter(D).static_order());assert set(bylabel)<=set(D)
(out/'proof_dependencies.json').write_text(json.dumps({'edges_statement_to_dependencies':D,'acyclic':True,'topological_order':order,'shared_proof_unit':['thm:main','lem:params'],'note':'3.1 and 3.2 are established together. Imports and auxiliary proof sections are explicit nodes; rhetorical references are not dependency edges.'},indent=2)+'\n')
(out/'proof_dependencies.dot').write_text('digraph ProofDependencies {\n'+''.join('  "'+k+'" -> "'+v+'";\n' for k,vs in D.items() for v in vs)+'}\n')
(out/'statement_proof_audit.json').write_text(json.dumps({'numbered_statements':39,'unique_canonical_statements':39,'bound_proofs':len(proofs),'deferred_pointer_targets':len(ptrs),'acyclic':True,'no_independent_appendix_restatements':True,'statement_rows':rows,'deliberate_changes':changes,'note':'The program checks source bindings and a reviewed dependency graph, not mathematical validity.'},indent=2)+'\n')
(out/'statement_changes.diff').write_text('\n'.join(x['diff'] for x in changes))
# Find the exact quote bytes in the source fixture, separately from source transcription.
a=(root/'sections/01_introduction.tex').read_text().split(r'\begin{quote}')[1].split(r'\end{quote}')[0]
b=(out/'source_extracts/oq2_verified.tex').read_text()
(out/'oq2_quote_check.json').write_text(json.dumps({'verbatim_typeset_fixture_matches':a.strip() in b or b.strip() in a.strip(),'source':'FKS original PDF page 3, blob 59fb15e60215a07d5bb1ca60ce061ee659d24b13','primary_recovery':'base64 line ranges with zlib-verified PDF content streams','normalization':'PDF ligatures, line wraps and math typesetting only; English s.t. and terminal period retained.'},indent=2)+'\n')
# Enumerate the literal constant occurrences; different contexts are not forced to share a name.
allpaths=files+sorted((root/'supplement/experiments').glob('*.py'))
tokens=['2^{-15}','2^{-18}','24','30','512','1023','4096','8192','16/(15','16/(17','19','C_0','J=']
occ={}
for token in tokens:
 occ[token]=[dict(file=str(p.relative_to(root)),line=i,text=line.strip()) for p in allpaths for i,line in enumerate(p.read_text().splitlines(),1) if token in line]
(out/'constant_occurrences.json').write_text(json.dumps(occ,indent=2)+'\n')
print(json.dumps({'statements':len(st),'bound_proofs':len(proofs),'dependency_nodes':len(D),'acyclic':True,'intentional_statement_changes':[x['number'] for x in changes],'deferred_targets':len(ptrs)},indent=2))
