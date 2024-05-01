import ollama
from models.base_model import LanguageModel

# 1. Downloadad Ollama into the PC and run .exe.
# 1.1. It can be run in terminal via "ollama run llama3"
#      >>> ollama run llama3 --message "Why is the sky blue?"
# 1.2. It can be run as a library inside Python.


class LLaMAModel(LanguageModel):
    def __init__(self, model_name):
        self.model_name = model_name

    def generate_response(self, prompt):
        response = ollama.chat(
            model="llama3",
            messages=[
                {
                    "role": "user",
                    "content": prompt,
                },
            ],
        )
        # Placeholder for API call
        return f"Response from {self.model_name}: {response['message']['content']}"
