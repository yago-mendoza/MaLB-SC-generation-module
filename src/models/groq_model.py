import os

from groq import Groq
from models.base_model import LanguageModel
from utils.exceptions import ApiKeyNotFoundException

### API KEY MANAGEMENT ###
GROQ_APY_KEY = os.getenv("GROQ_API_KEY")
if not GROQ_APY_KEY:
    raise ApiKeyNotFoundException
client = Groq(
    api_key=os.environ.get("GROQ_API_KEY"),
)

class GroqModel(LanguageModel):
    def __init__(self, model_name):
        self.model_name = model_name

    def set_prompt(self, prompt_template: str) -> None:
        """
        Set the prompt template for generating responses.
        :param prompt_template: The template string for prompts with placeholders like {0}, {1}, etc.
        """
        self.prompt_template = prompt_template

    def generate_response(self, *args: str) -> str:
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": self.prompt_template.format(args),
                }
            ],
            model="mixtral-8x7b-32768",
        )

        return chat_completion.choices[0].message.content
