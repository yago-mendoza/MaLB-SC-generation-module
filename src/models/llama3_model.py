import ollama

from models.base_model import LanguageModel

### API KEY MANAGEMENT ###
# No API key required for LLaMA API.


class LLaMAModel(LanguageModel):
    def __init__(self, model_name):
        self.model_name = model_name

    def set_prompt(self, prompt_template: str) -> None:
        """This function sets the prompt template for generating responses.

        Args:
            prompt_template (str): The template string for prompts with placeholders like {0}, {1}, etc.

        Returns:
            None
        """
        self.prompt_template = prompt_template

    def set_prompt(self, prompt_template: str) -> None:
        """
        Set the prompt template for generating responses.
        :param prompt_template: The template string for prompts with placeholders like {0}, {1}, etc.
        """
        self.prompt_template = prompt_template

    def generate_response(self, *args: str) -> str:
        response = ollama.chat(
            model="llama3",
            messages=[
                {
                    "role": "user",
                    "content": self.prompt_template.format(args),
                },
            ],
        )
        # Placeholder for API call
        return f"Response from {self.model_name}: {response['message']['content']}"
