from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from dotenv import load_dotenv

from utils.llm.brace_handling_functions import (
    escape_braces,
    _has_placeholders,
    _has_named_placeholders
)

from typing import (
    Union,
    Tuple,
    Sequence,
    List,
    Dict
)


class Placeholder:

    """
    Placeholder

    Attributes:
        parent (LLM): The parent LLM object.
        placeholder_prompt (str): The placeholder prompt template.

    Methods:
        run: Triggers the LLM with the user data.
    
    Usage:

    >>> llm = LLM('You are a helpful assistant')

    >>> p = llm.set_placeholder('Say hi')
    >>> p.run()
    >>> llm.memory
    
    >>> p = llm.set_placeholder('Tell a joke about a {}')
    >>> p.run(['cat'])  # 'cat' works as well
    >>> llm.memory

    >>> p = llm.set_placeholder('Tell a joke about a {} and a {}')
    >>> p.run(['dog', 'cat'])
    >>> llm.memory

    >>> p = llm.set_placeholder('Tell a joke about a {bird} and a {mammal}')
    >>> p.run({'bird': 'eagle', 'mammal': 'dog'})
    >>> llm.memory

    """

    def __init__(self, parent, placeholder_prompt):
        self.parent = parent
        self.prompt = placeholder_prompt

    def run(self, user_data=None):

        if _has_named_placeholders(self.prompt):
            if isinstance(user_data, dict):
                user_data = {k: escape_braces(v) for k, v in user_data.items()}
                return self.parent._trigger_llm(self.prompt.format(**user_data))
            else:
                raise ValueError("User data must be a dict.")
            
        elif _has_placeholders(self.prompt):
            if isinstance(user_data, str): user_data = [user_data]
            if isinstance(user_data, (List, Tuple)):
                user_data = [escape_braces(item) for item in user_data]
                return self.parent._trigger_llm(self.prompt.format(*user_data))
            else:
                raise ValueError("User data must be a list.")
            
        else:
            return self.parent._trigger_llm(self.prompt)

class LLM:

    """
    Large Language Model OpenAI Endpoint

    Attributes:
        system_prompt (str): The system message template.
        model (str): The model name to use.
        temperature (float): The temperature to use for the model's generation.
        memory (List[Tuple[str, str]]): The conversation history.

    Methods:
        
        __call__: Generates a response from the model.
        set_placeholder: Generates a Placeholder object.
        _trigger_llm: Internal method to trigger the LLM with the provided user message.

    Usage:

    ### Instantiation
    >>> llm = LLM('You are a helpful assistant')

    ### Generating a response
    >>> llm('Say hi')
    >>> <output>
    >>> p = llm.set_placeholder('Say hi')
    >>> p = llm.set_placeholder('Tell a joke about {}')
    >>> p = llm.set_placeholder('Tell a joke about {topic}')

    ### Displaying the history
    >>> llm.memory

    """

    def __init__(
        self,
        system_prompt: str = None,
        model: str = "gpt-3.5-turbo",
        temperature: float = 0.5
    ):

        self.model = model
        self.temperature = temperature
        self._start_endpoint()
        
        load_dotenv()
        
        self.system_prompt = system_prompt
        self._start_memory()

        self.previous_message = None
    
    def __call__(
        self, 
        user_data: Union[
            List[str],
            Dict[str, str], 
            str
        ] = None
    ):

        if not user_data:
            user_data = self.previous_message
            
            if user_data:
                return self._trigger_llm(user_data)

        if isinstance(user_data, str):
            user_message = escape_braces(user_data)
            return self._trigger_llm(user_message)

    def _trigger_llm (
        self,
        user_message
    ):

        user_message = escape_braces(user_message)
        self.previous_message = user_message

        self.memory.append(
            ("user", user_message),
        )

        self.prompt_template = ChatPromptTemplate.from_messages(
            self.memory
        )
        
        parser = StrOutputParser()
        chain = self.prompt_template | self.endpoint | parser
        llm_answer = chain.invoke({})

        self.memory.append(
            ("system", llm_answer),
        )

        return llm_answer

    def set_placeholder(
        self,
        placeholder_prompt: str
    ):

        return Placeholder(self, placeholder_prompt)
    
    def _start_memory(
        self
    ):

        self.memory = [
            ("system", self.system_prompt),
        ]
    
    def _start_endpoint(
        self
    ):

        self.endpoint = ChatOpenAI(
            model=self.model,
            temperature=self.temperature
        )
    
    