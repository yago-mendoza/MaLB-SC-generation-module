from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from dotenv import load_dotenv

from ModGen.utils.llm.LLM import LLM

def ZSGen(initial_conditions, model="gpt-3.5-turbo"):

    load_dotenv()

    description, features = initial_conditions

    initial_conditions = f"""
    Description: {description}
    Features: {features}
    """

    system_prompt = """
        You are a proficient Solidity developer.\
        You won't stop coding until all logics are fully developed.\
        Write only code, no yapping."
    """

    user_message = initial_conditions + f"Write a Smart Contract basing on {features}"

    llm = LLM(system_prompt)
    smart_contract_code = llm(user_message)
    
    return smart_contract_code
