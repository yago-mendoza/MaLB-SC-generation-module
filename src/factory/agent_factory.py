from models.openai_model import OpenAILangchainModel
from models.llama3_model import LLaMAModel
from agents.basic_agent import BasicAgent

def create_agent(model_type, model_name):
    if model_type == 'openai':
        model = OpenAILangchainModel(model_name)
    elif model_type == 'llama':
        model = LLaMAModel(model_name)
    else:
        raise ValueError("Unsupported model type")
    return BasicAgent(model)