from models.base_model import LanguageModel


class OpenAILangchainModel(LanguageModel):
    def __init__(self, model_name):
        self.model_name = model_name
        # Initialization code for the OpenAI API can be added here

    def generate_response(self, prompt):
        # Placeholder for API call
        return f"Response from {self.model_name}: {prompt}"
