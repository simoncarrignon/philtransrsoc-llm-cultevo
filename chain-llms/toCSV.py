import pickle
import argparse
import os

parser = argparse.ArgumentParser(description='output to csv')
parser.add_argument('--outdir', action="store", dest='outdir', default='.')
args = parser.parse_args()
outdir=args.outdir

allsteps=pickle.load(open(os.path.join(outdir,"alltstepbeta.pkl"),'rb'))
tsteps=len(allsteps)
maxt=len(allsteps[tsteps-1])
headers=["traits"+str(i) for i in range(maxt)]
print(",".join(headers))
for i in allsteps:
    print(','.join([str(c) for c in i]))

