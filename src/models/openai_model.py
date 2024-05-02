import os
from pathlib import Path

from langchain_openai import OpenAI
from utils.exceptions import ApiKeyNotFoundException

from models.base_model import LanguageModel

### API KEY MANAGEMENT ###
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if not OPENAI_API_KEY:
    raise ApiKeyNotFoundException


class OpenAIModel(LanguageModel):
    def __init__(
        self,
        model: str = "gpt-3.5-turbo-instruct",
        temperature: float = 0.8,
        max_tokens: int = 2048,
    ):
        """
        Initialize the OpenAI model with default settings.
        :param name: The name of the agent.
        :param model: Model identifier for the OpenAI API.
        :param temperature: Sampling temperature for generation randomness.
        :param max_tokens: Maximum number of tokens to generate.
        """
        self.llm = OpenAI(
            model=model,
            temperature=temperature,
            max_tokens=max_tokens,
        )
        self.prompt_template = None
        self.last_response = ""

    # Setting compatibility with quickly drafted DSPy file    
    def ask(self, prompt: str) -> str:
        self.set_prompt(prompt)
        return self.generate_response(prompt)

    def set_prompt(self, prompt_template: str) -> None:
        """
        Set the prompt template for generating responses.
        :param prompt_template: The template string for prompts with placeholders like {0}, {1}, etc.
        """
        self.prompt_template = prompt_template

    def generate_response(self, *args: str) -> str:
        """
        Generate a response based on the set prompt template, formatted with given input prompt.
        :param prompt: The input string to format the template.
        :return: The raw response from the language model.
        """
        if self.prompt_template is not None:
            filled_prompt = self.prompt_template.format(args)
        else:
            filled_prompt = args
        json_response = self.llm.generate(prompts=[filled_prompt])
        generated_text = json_response.flatten()[0].generations[0][0].text.strip()
        self.last_response = generated_text
        return generated_text
