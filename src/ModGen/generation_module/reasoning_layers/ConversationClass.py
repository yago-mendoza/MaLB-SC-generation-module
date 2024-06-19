import datetime
import json
from typing import Optional, Any, Union, List, Dict
from langchain_openai import ChatOpenAI
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from dotenv import load_dotenv

from generation_module.llm.LLM import LLM

class Conversation(LLM):
    """
    A class to represent a conversation in a chatbot, with support for memory management and interaction with an LLM.

    Args:
        system_prompt (str): The system message template. Default is None.
        time_enabled (bool): Whether to enable timestamps for the conversation history. Default is False.
        autosave (bool): Whether to autosave the conversation history to a file. Default is False.
        save_filepath (str): The filepath to save the conversation history to. Default is None.
        language_model (str): The model name to use. Default is "gpt-3.5-turbo".
        temperature (float): The temperature to use for the model's generation. Default is 0.5.
        context_length (int): The maximum context length for the conversation. Default is 8192.
        rules (str): Rules for the conversation. Default is None.

    Methods:
        add(role: str, content: str): Add a message to the conversation history.
        delete(index: int): Delete a message from the conversation history.
        update(index: int, role: str, content: str): Update a message in the conversation history.
        query(index: int): Query a message in the conversation history.
        search(keyword: str): Search for a message in the conversation history.
        export_conversation(filename: str): Export the conversation history to a file.
        import_conversation(filename: str): Import a conversation history from a file.
        clear(): Clear the conversation history.
    """

    def __init__(
        self,
        system_prompt: Optional[str] = None,
        time_enabled: bool = False,
        autosave: bool = False,
        save_filepath: str = None,
        language_model: str = "gpt-3.5-turbo",
        temperature: float = 0.5,
        context_length: int = 8192,
        rules: str = None,
        *args,
        **kwargs,
    ):
        super().__init__(system_prompt, language_model, temperature)

        self.time_enabled = time_enabled
        self.autosave = autosave
        self.save_filepath = save_filepath
        self.context_length = context_length
        self.rules = rules

        self.conversation_history = []
        
        self._start_memory()
        
        if self.system_prompt:
            self.add("System", self.system_prompt)

        if self.rules:
            self.add("User", self.rules)

    def add(self, role: str, content: str):
        """Add a message to the conversation history"""
        message = {"role": role, "content": content}
        
        if self.time_enabled:
            message["timestamp"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        self.conversation_history.append(message)

        if self.autosave:
            self.save_as_json(self.save_filepath)

    def delete(self, index: int):
        """Delete a message from the conversation history"""
        self.conversation_history.pop(index)

    def update(self, index: int, role: str, content: str):
        """Update a message in the conversation history"""
        self.conversation_history[index] = {"role": role, "content": content}

    def query(self, index: int):
        """Query a message in the conversation history"""
        return self.conversation_history[index]

    def search(self, keyword: str):
        """Search for a message in the conversation history"""
        return [msg for msg in self.conversation_history if keyword in msg["content"]]

    def export_conversation(self, filename: str):
        """Export the conversation history to a file"""
        with open(filename, "w") as f:
            for message in self.conversation_history:
                f.write(f"{message['role']}: {message['content']}\n")

    def import_conversation(self, filename: str):
        """Import a conversation history from a file"""
        with open(filename) as f:
            for line in f:
                role, content = line.split(": ", 1)
                self.add(role, content.strip())

    def clear(self):
        """Clear the conversation history"""
        self.conversation_history = []