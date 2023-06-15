
#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
#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

import openai
import sys,os
import random

from multiprocessing import Pool

# Set up the OpenAI API client
openai.api_key = os.environ["OPENAI_API_KEY"]

def checkind(ind):
    try:
        return int(ind)
    except ValueError:
        return random.randint(1,5)

def chat_with_gpt(prompt):
  response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[
      {"role": "user", "content": prompt}
    ]
  )
  answer = response.choices[0].message.content
  return answer

def main():
    print("letsdoothis")
    mu=0.1
    n=2
    suggest = [ " The world is the third planet from the sun in our solar system. It is the only known planet with life, and it has a diverse range of ecosystems and climates.",
               "The world has a circumference of approximately 40,075 kilometers (24,901 miles) at the equator and a diameter of about 12,742 kilometers (7,918 miles).",
               "The world has a total surface area of approximately 510.1 million square kilometers (196.9 million square miles), of which about 71% is covered by water and the remaining 29% is land.",
               "The world's population is currently estimated to be over 7.9 billion people, spread across nearly 200 countries and territories.",
               "The world is believed to be around 4.54 billion years old and has gone through numerous geological changes and events throughout its history, including volcanic eruptions, earthquakes, and ice ages." ]
    pre="Between these statements, which one do you think is more susceptible to interest a human?"
    post="Pick the statement you think is most interesting, modify it to make it even more interesting and write it back to me. Do not include anything else in your answer except your modified statement; never mention the fact that your are an AI, just write your modified statement" 
    post="In your answer do not include anything else  the number of the statement you pick. Do not include anything else. Only the number and nothing else, no justification or any other character that isn't a number"
    modpost="modify this statement to make it more interesting. Your answer should be more than 200 letters. Do not include anything else than your modified statement; never mention the fact that your are an AI, just write your modified statement" 
    with Pool(processes=n) as pool:
        for t in range(0,10):
            print(str(t)+" =============="+"\n")
            prompt=pre
            for s in range(0,len(suggest)):
                prompt=prompt+"\n"+str(s)+" : "+suggest[s]
            prompt=prompt+"\n"+post
            print(prompt)
            results = pool.map(chat_with_gpt, [prompt]*n)
            selind= list(map(checkind,results))
            print(selind)
            #sel=random.sample(range(len(selind)),len(selind)*mu)
            sel=random.sample(range(len(selind)),2)
            print(sel)
            for ns in sel:
                new = chat_with_gpt(suggest[selind[int(ns)]]+"\n"+modpost)
                suggest.append(new)
            print(suggest)

if __name__ == "__main__":
    main()
