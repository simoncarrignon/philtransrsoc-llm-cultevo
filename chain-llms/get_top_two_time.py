import pickle
import argparse
import os

parser = argparse.ArgumentParser(description='output top trait')
parser.add_argument('--outdir', action="store", dest='outdir', default='.')
args = parser.parse_args()
outdir=args.outdir

allsteps=pickle.load(open(os.path.join(outdir,"alltstepbeta.pkl"),'rb'))
allstatements=pickle.load(open(os.path.join(outdir,"variantsbeta.pkl"),"rb"))
tsteps=len(allsteps)
for stepi in allsteps:
    top=stepi.index(max(stepi))
    print(allstatements[top]["statement"])


