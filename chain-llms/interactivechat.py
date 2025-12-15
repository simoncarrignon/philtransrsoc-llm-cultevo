import openai
import argparse

client = openai.OpenAI(
    base_url="http://localhost:8080/v1",
    api_key="sk-no-key-required"
)

def chat_with_gpt(prompt):
  response = client.chat.completions.create(
      model="Qwen/Qwen2.5-7B-GGUF",
      messages=[{"role": "user", "content": prompt}],
      max_tokens=50
  )
  answer = response.choices[0].message.content
  return answer

def main():
    parser = argparse.ArgumentParser(description='Chat with GPT.')
    args = parser.parse_args()

    while True:
        prompt = input("Enter your prompt: ")
        if prompt == "/end":
            break
        result = chat_with_gpt(prompt)
        print(result)

if __name__ == "__main__":
    main()
