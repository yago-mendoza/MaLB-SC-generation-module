from dotenv import load_dotenv
from utils.llm.LLM import LLM
import re

# para estas clases no habrá logs, sino que sacaran su proceso de pensamiento a alguna parte via datapipe

def ZSGen(
    initial_conditions,
    language_model="gpt-3.5-turbo"
):
    description, features = initial_conditions
    load_dotenv()
    
    system_prompt = f"""
        You are a proficient Solidity developer.\
        You won't stop coding until all logics are fully developed.\
        Write only code, no yapping."
    """

    user_message = """
        Description: {} \
        Features: {} \
        Write a Smart Contract basing on the Features.
    """

    llm = LLM(
        system_prompt=system_prompt,
        language_model=language_model
    )

    plc = llm.set_placeholder(user_message)
    out = plc.run(description, features)

    out = re.sub(r"```solidity|```", "", out).strip()

    return out
