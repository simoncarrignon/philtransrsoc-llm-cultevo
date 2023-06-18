import pickle

allsteps=pickle.load(open("alltstep.pkl",'rb'))
tsteps=len(allsteps)
maxt=len(allsteps[tsteps-1])
headers=["traits"+str(i) for i in range(maxt)]
print(",".join(headers))
for i in allsteps:
    print(','.join([str(c) for c in i]))

