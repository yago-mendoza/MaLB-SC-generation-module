from models.llama3_model import LLaMAModel
from models.openai_model import OpenAIModel


# test_model = OpenAIModel(temperature=0)
# test_model.set_prompt("Write a short haiku about {0}")
# response = test_model.generate_response("cats")

# Example usage for the ChatGPT generated DSPY_SKETCH
# from malb_modules.RP.dspy_sketch import SmartContractAgent
# llm_model = OpenAIModel()  # This would be your GPT-3 or other LLM model initialized
# agent = SmartContractAgent(llm_model)
# description = "Please explain me how to boil an egg."
# result = agent.process_description(description)
# print(result)