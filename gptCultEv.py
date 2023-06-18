
#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
#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

import openai
import sys,os
import random
import pickle
import time
import requests


from multiprocessing import Pool

# Set up the OpenAI API client
print("get connection")
openai.api_key = os.environ["OPENAI_API_KEY"]
print("done")


def create_image_url(prompt):
    response = openai.Image.create(
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
    except ValueError:
        print("not good")
        #return random.randint(1,maxind)
        return None

def chat_with_gpt(prompt):
  response = openai.ChatCompletion.create(
    model="gpt-4-0613",
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
           time.sleep(5)
           num=None
    return num 

def main():
    print("letsdoothis")
    mu=0.1
    n=50
    tstep=10
    N=100
    suggest = [ " The world is the third planet from the sun in our solar system. It is the only known planet with life, and it has a diverse range of ecosystems and climates.",
               "The world has a circumference of approximately 40,075 kilometers (24,901 miles) at the equator and a diameter of about 12,742 kilometers (7,918 miles).",
               "The world has a total surface area of approximately 510.1 million square kilometers (196.9 million square miles), of which about 71% is covered by water and the remaining 29% is land.",
               "The world's population is currently estimated to be over 7.9 billion people, spread across nearly 200 countries and territories.",
               "The world is believed to be around 4.54 billion years old and has gone through numerous geological changes and events throughout its history, including volcanic eruptions, earthquakes, and ice ages." ]
    pre="Between these statements, which one do you think is more susceptible to interest a human?"
    #post="Pick the statement you think is most interesting, modify it to make it even more interesting and write it back to me. Do not include anything else in your answer except your modified statement; never mention the fact that your are an AI, just write your modified statement" 
    post="In your answer do not include anything else that the index of the statement you pick. Do not include anything else. Only the number and nothing else, no justification or any other character that isn't a number"
    modpost="modify this statement to make it more interesting but not long. Your answer should be more than 200 letters. Do not include anything else than your modified statement; never mention the fact that your are an AI, just write your modified statement" 
    with Pool(processes=10) as pool:
        for t in range(0,tstep):
            print(str(t)+" =============="+"\n")
            prompt=pre
            for s in range(0,len(suggest)):
                prompt=prompt+"\n"+str(s)+" : "+suggest[s]
            prompt=prompt+"\n"+post
            #print(prompt)
            #results = pool.map(chat_with_gpt, [prompt]*N)
            selind = pool.map(get_number_from_prompt, [(prompt,len(suggest))]*N)
            #print(results)
            #selind = list(map(lambda x: checkind(x, len(results)), results))
            #print(selind)
            ninov=max(N*mu,1)
            sel=random.sample(range(len(selind)),int(ninov))
            print(sel)
            for ns in sel:
                new = chat_with_gpt(suggest[selind[int(ns)]]+"\n"+modpost)
                # Now you can call the function with a prompt
                print(new)
                url = create_image_url(new)
                download_image(url, "output"+str(len(suggest))+".png")
                suggest.append(new)
            with open('variants.pkl', 'wb') as outp:
                pickle.dump(suggest, outp, pickle.HIGHEST_PROTOCOL)
    

if __name__ == "__main__":
    main()
