#!/usr/bin/env python3
"""Run current and retained checks in fresh directories, without changing old data."""
from __future__ import annotations
import argparse,json,os,shutil,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main()->None:
    ap=argparse.ArgumentParser();ap.add_argument('--output',type=Path,default=ROOT/'audits/current/reproduced');ap.add_argument('--caps',action='store_true',help='Also rerun the slower keyed cap sweep.');a=ap.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    commands=[]
    def run(cmd,cwd,filename):
        env=os.environ.copy();env.update(OMP_NUM_THREADS='1',OPENBLAS_NUM_THREADS='1',MKL_NUM_THREADS='1')
        proc=subprocess.run(cmd,cwd=cwd,capture_output=True,text=True,env=env)
        (a.output/filename).write_text(proc.stdout+proc.stderr);commands.append(dict(command=cmd,exit_code=proc.returncode))
        if proc.returncode:raise RuntimeError(f'{filename}: failed with {proc.returncode}')
    with tempfile.TemporaryDirectory(prefix='sq-dc-check-') as tmp:
        t=Path(tmp);(t/'checks').mkdir();(t/'experiments').mkdir()
        shutil.copy2(ROOT/'history/turn06/checks/recompute_constants.py',t/'checks')
        for f in (ROOT/'experiments').glob('*.py'):shutil.copy2(f,t/'experiments')
        run([sys.executable,str(ROOT/'experiments/current/check_late_results.py'),'--output',str(a.output.resolve()/'late_results.json')],t,'late_results.log')
        run([sys.executable,'checks/recompute_constants.py'],t,'constants.log')
        for f in ['algebra_and_stress.py','affine_checks.py']:
            run([sys.executable,'experiments/'+f],t,f+'.log')
        run([sys.executable,'experiments/seeded_fast.py','--N','2','3','4','5','6','7','8','16','32'],t,'seeded_fast.log')
        if a.caps:run([sys.executable,'experiments/run_keyed_caps.py'],t,'keyed_caps.log')
        shutil.copy2(t/'checks/constants.json',a.output/'core_constants.json')
        shutil.copytree(t/'experiments/results',a.output/'results',dirs_exist_ok=True)
    # Commands are informational; temporary paths in command logs need not persist.
    (a.output/'run_manifest.json').write_text(json.dumps(dict(status='PASS',commands=commands),indent=2)+'\n')
    print(f'PASS: {len(commands)} commands. Results: {a.output}')
if __name__=='__main__':main()
