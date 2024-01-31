import pickle

allstatements=pickle.load(open("variantsbeta.pkl","rb"))
sorted_items = sorted(allstatements.items(), key=lambda item: item[1]['counter'], reverse=True)

for i in range(10):
    print(sorted_items[i][1]["statement"])
