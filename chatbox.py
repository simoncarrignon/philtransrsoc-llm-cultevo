
#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
import openai
import sys,os

# Set up the OpenAI API client
openai.api_key = os.environ["OPENAI_API_KEY"]


def chat_with_gpt(prompt):
#    response = openai.Completion.create(
#        engine="text-davinci-003",
#        prompt=f"{prompt}\nChatbot:"
#    )
    #response = openai.ChatCompletion.create(
    #    model="gpt=3.5-turbo",
    #    messages=[{"role":"user","content":prompt+"\n"}]
    #)
  response = openai.ChatCompletion.create(
    model="gpt-4",
    messages=[
      {"role": "user", "content": prompt}
    ]
  )
  answer = response.choices[0].message.content
  return answer

def main():
    for line in sys.stdin:
        input_text = line.strip()
        if input_text.lower() == "quit":
            break

        response = chat_with_gpt(input_text)
        print(response)


if __name__ == "__main__":
    main()


