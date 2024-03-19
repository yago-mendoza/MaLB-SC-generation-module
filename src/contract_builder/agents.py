from langchain.schema.output_parser import StrOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_openai import OpenAI
from typing import Any
import requests
import os

# Set the OpenAI API key in the environment variables
with open(r"C:/openai_key/openai_key.txt") as f:
    os.environ["OPENAI_API_KEY"] = f.read().strip()

class ContractAgent:
    def __init__(self, name) -> None:
        """
        Initialize the contract agent with default settings.
        """
        self.name = name
        self.llm = OpenAI(
            model="gpt-3.5-turbo-instruct",
            temperature=0.8,
            max_tokens=32, # 2048
        )
        self.prompt_template = None
        self.last_response = ''
        # self.chain_synopsis = None
    
    def set_prompt(self, prompt_template: str) -> None:
        """
        Set the prompt template for generating responses.
        :param prompt_template: The template string for prompts with placeholders like {0}, {1}, etc.
        """
        # self.prompt_template = PromptTemplate.from_template(prompt_template)
        # self.chain_synopsis = (
        #     self.prompt_template  # Start with generating the prompt based on the template
        #     | self.llm  # Query the OpenAI model with the generated prompt
        #     | StrOutputParser()  # Parse the model's response into a string
        # )
        self.prompt_template = prompt_template

    def generate(self, *inputs: str) -> Any:
        """
        Generate a response based on the prompt template filled with inputs.
        :param inputs: Variable length argument list for words to fill in the prompt template.
        :return: The raw response from the language model.
        """
        # response = self.chain_synopsis.invoke({"text": inputs})
        # self.last_response = response  # Store the response
        # return response
        prompt = self.prompt_template.format(*inputs)
        json_response = self.llm.generate(prompts=[prompt])
        generated_text = json_response.flatten()[0].generations[0][0].text.strip()
        self.last_response = generated_text.strip()

    def connect_url(self, url):
        self.server_url = url
    
    def sendResponse(self):
        data = {"name": self.name, "generation": self.last_response}
        response = requests.post(f"{self.server_url}/agents/", json=data)
        return response.json()

    def getResponse(self, name=None):
        name = self.name if not name else name
        response = requests.get(f"{self.server_url}/agents/{name}")
        if response.status_code == 200:
            return response.json()
        else:
            return {"error": "Agent not found or server error"}

# From terminal usage example
agent = ContractAgent('Caleb')
agent.set_prompt("Write a haiku with {0}, {1} & {2}")
agent.generate('Egg', 'Bee', 'Ape') # restrictions
print(agent.last_response)
agent.connect_url("http://127.0.0.1:8000/")
agent.sendResponse()






