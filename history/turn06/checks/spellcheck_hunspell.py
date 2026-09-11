from pathlib import Path
import ctypes, re, collections, subprocess,json
r=Path(__file__).resolve().parents[1]
lib=ctypes.CDLL('/lib/x86_64-linux-gnu/libhunspell-1.7.so.0')
lib.Hunspell_create.argtypes=[ctypes.c_char_p,ctypes.c_char_p];lib.Hunspell_create.restype=ctypes.c_void_p
lib.Hunspell_spell.argtypes=[ctypes.c_void_p,ctypes.c_char_p];lib.Hunspell_spell.restype=ctypes.c_int
lib.Hunspell_destroy.argtypes=[ctypes.c_void_p]
h=lib.Hunspell_create(b'/usr/share/hunspell/en_US.aff',b'/usr/share/hunspell/en_US.dic')
assert h
unknown=collections.Counter();locations=collections.defaultdict(list);total=0
files=[r/'abstract.tex',r/'acknowledgments.tex']+sorted((r/'sections').glob('*.tex'))+sorted((r/'appendices').glob('*.tex'))+sorted((r/'figures').glob('*.tex'))
for p in files:
 t=subprocess.run(['detex','-n','-l','-s',str(p)],capture_output=True,text=True,check=True).stdout
 for w in re.findall(r"[A-Za-z]+(?:'[A-Za-z]+)?",t):
  total+=1
  if len(w)>1 and not lib.Hunspell_spell(h,w.encode()):
   unknown[w]+=1
   if str(p.relative_to(r)) not in locations[w]:locations[w].append(str(p.relative_to(r)))
lib.Hunspell_destroy(h)
rep={'engine':'Hunspell 1.7 C API','dictionary':'en_US','tex_filter':'detex -n -l -s','files':len(files),'tokens_checked':total,'flagged_types':len(unknown),'flags':dict(unknown.most_common()),'locations':dict(locations)}
(r/'checks'/'spellcheck_raw.json').write_text(json.dumps(rep,indent=2)+'\n')
print('Tokens:',total,'flagged types:',len(unknown))
for w,k in unknown.most_common():print(w,k)
