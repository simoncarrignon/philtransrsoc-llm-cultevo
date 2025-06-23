import pickle
import argparse
import os

parser = argparse.ArgumentParser(description='get top ten')
parser.add_argument('--outdir', action="store", dest='outdir', default='.')
args = parser.parse_args()
outdir=args.outdir

allstatements=pickle.load(open(os.path.join(outdir,"variantsbeta.pkl"),"rb"))
sorted_items = sorted(allstatements.items(), key=lambda item: item[1]['counter'], reverse=True)

for i in range(10):
    print(sorted_items[i][1]["statement"])
