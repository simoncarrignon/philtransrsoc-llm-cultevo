
#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
#sk-i4K49E7qoOstj0jSeDXHT3BlbkFJJYi0XmdAqlW26Bxg24

import openai
import sys,os
import random
import pickle
import time
import requests
import argparse

parser = argparse.ArgumentParser(description='gpt evol app')
parser.add_argument('--outdir', action="store", dest='outdir', default='.')
parser.add_argument('-t', action="store", dest='tstep', default=10)
parser.add_argument('-k', action="store", dest='K', default=20)
parser.add_argument('-N', action="store", dest='N', default=10)
parser.add_argument('-mu', action="store", dest='mu', default=0.1)
parser.add_argument('--image', action="store", dest='image', default=False)
args = parser.parse_args()
outdir=args.outdir
K=int(args.K)
N=int(args.N)
tstep=int(args.tstep)
N=int(args.N)
mu=float(args.mu)
printImage = args.image
print("Starting experiment with "+str(N)+" agents, "+str(K)+" slots"+ " to be stored in "+str(outdir))

from multiprocessing import Pool

# Set up the OpenAI API client
print("get connection")
openai.api_key = os.environ["OPENAI_API_KEY"]
print("done")


def create_image_url(prompt):
    response = openai.Image.create(
        model="dall-e-3",
        prompt=prompt,
        n=1,
        size="1024x1024"
    )
    image_url = response['data'][0]['url']
    return image_url

def download_image(url, filename):
    response = requests.get(url)

    # Check the status code of the response, 200 means the request was successful
    if response.status_code == 200:
        with open(filename, 'wb') as f:
            f.write(response.content)
    else:
        print(f"Failed to download image, status code: {response.status_code}")

def checkind(ind,maxind):
    #print(str(ind)+" : "+str(maxind))
    try:
        i= int(ind)
        if(i<=maxind and i>=0):
            return i
        else:
            return random.randint(1,maxind)
    except ValueError as e:
        print("not good"+str(ind))
        #return random.randint(1,maxind)
        time.sleep(10)
        return None

def chat_with_gpt(prompt):
  response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo-1106",
    messages=[
      {"role": "user", "content": prompt}
    ]
  )
  answer = response.choices[0].message.content
  return answer

def get_number_from_prompt(args):
    prompt, maxind = args
    num=None
    while num is None:
        try:
           print("api call:"+str(len(prompt)))
           resnum=chat_with_gpt(prompt)
           num=checkind(resnum,maxind)
           print("done")
        except Exception as e:
           print(e) 
           print("nonum") 
           time.sleep(10)
           num=None
    return num 

def main():
    print("letsdoothis")
    isRandom=False
    statments=["Incorporating a rainbow of fruits and vegetables into your meals ensures you receive a spectrum of vitamins and minerals, vital for boosting immunity and enhancing your energy levels, contributing to an overall healthier you.",
    "Regular consumption of whole grains, lean proteins, and healthy fats forms the cornerstone of a nutritionally sound diet, playing a pivotal role in heart health and long-term disease prevention.",
    "Hydration is a key component of a healthy lifestyle; drinking adequate water daily aids in digestion, nutrient absorption, and maintaining a balanced metabolism, which is essential for weight management.",
    "Engaging in mindful eating practices, such as savoring each bite and listening to your body's hunger cues, can significantly improve your relationship with food and support a healthy, balanced lifestyle.",
    "Incorporating moderate, regular physical activity alongside a diet rich in vegetables, fruits, and whole grains can dramatically improve your physical and mental health, leading to a more active and fulfilling life.",
    "Limiting processed foods and sugars while prioritizing fresh, whole ingredients can lead to improved mental clarity, better sleep patterns, and an overall enhancement in life quality.",
    "Understanding the nutritional content of your meals, including macronutrient ratios and calorie density, is crucial for making informed food choices that support a healthy and balanced diet.",
    "Innovating in the kitchen by experimenting with international cuisines can introduce a variety of healthy and flavorful ingredients into your diet, making healthy eating a delightful experience.",
    "Focusing on portion control is as important as food quality; eating in moderation ensures you get the necessary nutrients without excess calories, aiding in effective weight management.",
    "Embracing a plant-based diet, rich in legumes, nuts, seeds, and whole grains, can provide substantial health benefits, including lowered risk of chronic diseases and improved digestion and metabolism."]
    pre="Between these statements, which one do you think is most convincing?"
    preneut="Choose between these statements:"
    #post="Pick the statement you think is most interesting, modify it to make it even more interesting and write it back to me. Do not include anything else in your answer except your modified statement; never mention the fact that your are an AI, just write your modified statement" 
    post="In your answer do not include anything else that the index of the statement you pick. Do not explain your choice or include anything. Only the number and nothing else, no justification or any other words or letter that isn't a number"
    modpostbias="Modify this statement to make it more convincing and effective to promote public health. You can add or remove any information if you think this make it more attractive but your answer should stay short and never be more than 200 letters. Do not include anything else than your modified statement; never mention the fact that your are an AI" 
    modpostneut="modify this statement. Your answer should not be more than 200 letters. Do not include anything else than your modified statement; never mention the fact that your are an AI" 
    suggest = {i: {'statement': statement, 'counter': round(N/len(statments))} for i, statement in enumerate(statments)}

    allsel=list()
    exptype="beta"
    allsuggests=list()
    with Pool(processes=10) as pool:
        for t in range(0,tstep):
            print(str(t)+" =============="+"\n")
            if exptype == "beta":
                prompt=pre
            else:
                prompt=preneut
            for s in suggest.keys():
                if(suggest[s]['counter']>0):prompt=prompt+"\n"+str(s)+" : "+suggest[s]["statement"]
            prompt=prompt+"\n"+post
            #print(prompt)
            #results = pool.map(chat_with_gpt, [prompt]*N)
            if isRandom:
                weights = [suggest[i]['counter'] for i in suggest.keys()]
                selind = random.choices(range(len(suggest)),weights=weights,k=N)
            else: 
                selind = pool.map(get_number_from_prompt, [(prompt,len(suggest.keys()))]*N)
            allsel.append(selind)
            for s in suggest.keys():
                suggest[s]['counter']=0
            for index in selind:
                try:
                    suggest[index]['counter'] += 1
                except:
                    print(index)
            print(len(selind))
            #print(results)
            #selind = list(map(lambda x: checkind(x, len(results)), results))
            #print(selind)
            ninov=max(N*mu,1)
            #sel=random.sample(range(len(selind)),int(ninov))
            weights = [suggest[i]['counter'] for i in suggest.keys()]
            sel = random.choices(list(suggest.keys()), weights=weights, k=int(ninov))
            for ns in sel:
                new=None
                while new is None:
                    modpost=""
                    try:
                        if exptype == "beta":
                            modpost=modpostbias
                        else:
                            modpost=modpostneut
                        new = chat_with_gpt(suggest[ns]["statement"]+"\n"+modpost)
                        #new="new prompt"+str(max(suggest.keys()) + 1)
                        # Now you can call the function with a prompt
                        print(new)
                        #suggest.append(new)
                        new_key = max(suggest.keys()) + 1
                        suggest[new_key] = {'statement': new, 'counter': 1}
                    except Exception as e:
                        print("no news yet: "+str(ns))
                        print(str(selind))
                        print(suggest)
                        print(e)
                        new=None
                        time.sleep(10)
            if t % 5 == 0:
                try: 
                    print("createimage")
                    url = create_image_url(suggest[max(suggest.keys())]['statement'])
                    download_image(url, "output"+exptype+'_'+str(max(suggest.keys()))+".png")
                    print("done")
                except:
                    print("notdone")
            with open('variants'+exptype+'.pkl', 'wb') as outp:
                pickle.dump(suggest, outp, pickle.HIGHEST_PROTOCOL)
            allsuggests.append( [suggest[s]['counter'] for s in suggest.keys()])
            with open('alltstep'+exptype+'.pkl', 'wb') as tstp:
                pickle.dump(allsuggests, tstp, pickle.HIGHEST_PROTOCOL)
            print(allsuggests)

    

if __name__ == "__main__":
    main()
