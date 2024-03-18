import os

from langchain_openai import OpenAI

class ContractAgent:
    def __init__(self):
        self.last_response = ''
        self.llm = OpenAI(
            temperature=0.8,
            max_tokens=2048,
        )
        self.prompt_template = ""
    
    def set_prompt(self, prompt_template):
        self.prompt_template = prompt_template

    def get_response(self, *inputs):
        words = inputs[0]
        prompt = self.prompt_template.format(words='\n-'.join(words))
        response = self.llm.generate(prompts=[prompt])
        generated_text = ['generations'][0]['text'].strip()
        # token_usage = response['llm_output']['token_usage']
        self.last_response = generated_text
        return response

with open(r"C:/openai_key/openai_key.txt") as f:
    os.environ["OPENAI_API_KEY"] = f.read().strip()

agent = ContractAgent()
agent.set_prompt("Write a haiku containing the following words: {words}")
agent.get_response(['luna', 'cielo', 'sangre'])
print(agent.last_response)
