# https://platform.openai.com/account/usage

import os

from langchain.schema.output_parser import StrOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_core.runnables import RunnableLambda
from langchain_openai import OpenAI

promptTemplate = """
Write a solidity contract for the following coin: {coin}

And with these restrictions:
{text}
"""

prompt_simplification_synopsis = PromptTemplate.from_template(promptTemplate)

with open(r"C:/openai_key/openai_key.txt") as f:
    os.environ["OPENAI_API_KEY"] = f.read().strip()

# Initialize the OpenAI wrapper with specified parameters.
llm = OpenAI(
    temperature=0.8,
    max_tokens=2048,
)

# Define a <chain of operations> for generating the contract.
chain_synopsis = (
    RunnableLambda(lambda x: {"coin": "dogecoin", "text": "\n".join(x["text"])})
    | prompt_simplification_synopsis  # Generate the prompt based on restrictions
    | llm  # Query the OpenAI model with the prompt
    | StrOutputParser()  # Parse the model's response into a string
)

# Invoke the chain with specific restrictions.
output = chain_synopsis.invoke(
    {
        "text": [
            "Needs to last for 30 days",
            "There can't be more than 1000 copies",
            "The coin must be divisible",
        ]
    }
)

print(output)