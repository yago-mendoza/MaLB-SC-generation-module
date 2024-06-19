# Import necessary modules and functions
from dotenv import load_dotenv
from generation_module.llm.LLM import LLM
import re
from typing import List, Dict, Any, Tuple
from generation_module.reasoning_layers.prompts.USER_TRIGGER import USER_MESSAGE_PROMPT_CREATE
from generation_module.reasoning_layers.prompts.SYSTEM import PROMPT_DEVELOPER

def ZSGen(
    initial_conditions: Tuple[str, List[Dict[str, Any]]],
    language_model: str = "gpt-3.5-turbo",
    hints: List[str] = []
) -> str:
    """
    Generates a response based on initial conditions and hints using a specified language model.
    
    Args:
        initial_conditions (Tuple[str, List[Dict[str, Any]]]): The initial description and features for the generation.
        language_model (str): The language model to use for generation. Default is "gpt-3.5-turbo".
        hints (List[str]): Optional hints to guide the generation process.

    Returns:
        str: The generated output, cleaned of any specific code markers.
    """
    description, features = initial_conditions
    
    # Load environment variables
    load_dotenv()

    # Prepare hints if provided
    if hints:
        hints_str = "\nHints (to bear in mind):\n{}".format("\n".join(hints))
    else:
        hints_str = ''

    # Initialize the language model with the system prompt and specified language model
    llm = LLM(
        system_prompt=PROMPT_DEVELOPER,
        language_model=language_model
    )

    # Set placeholder with user message prompt and hints
    plc = llm.set_placeholder(USER_MESSAGE_PROMPT_CREATE + hints_str)
    
    # Generate the output using the description and features
    output = plc.run(description, features)

    # Clean the output by removing specific code markers
    cleaned_output = re.sub(r"```solidity|```", "", output).strip()

    return cleaned_output

