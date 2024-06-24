# Import necessary modules and functions
from dotenv import load_dotenv
from generation_module.llm.LLM import LLM, Conversation
from generation_module.reasoning_layers.prompts.USER_TRIGGER import USER_MESSAGE_PROMPT_CREATE
from generation_module.reasoning_layers.prompts.SYSTEM import PROMPT_DEVELOPER
from typing import List, Dict, Any, Tuple
import re

class ConversationController:
    def __init__(self, agents):
        self.agents = agents
        self.current_turn = 0
    
    def next_turn(self):
        self.current_turn = (self.current_turn + 1) % len(self.agents)
        return self.agents[self.current_turn]

def is_conversation_complete(response):
    # Lógica para determinar si la conversación ha terminado
    return "CONVERSATION_END" in response

class AutomatedConversation:
    def __init__(self, system_prompts: List[str], language_model: str = "gpt-3.5-turbo", temperature: float = 0.7):
        # Inicializar los agentes con sus respectivos prompts del sistema
        self.agents = [
            Conversation(system_prompt=prompt, language_model=language_model, temperature=temperature)
            for prompt in system_prompts
        ]
        self.controller = ConversationController(self.agents)
    
    def run_conversation(self, initial_prompt: str, max_turns: int = 10) -> Tuple[List[str], str]:
        conversation_history = [initial_prompt]
        final_response = ""
        for _ in range(max_turns):
            current_agent = self.controller.next_turn()
            response = current_agent(initial_prompt)
            conversation_history.append(response)
            if is_conversation_complete(response):
                final_response = response
                break
            initial_prompt = response  # Actualizar el prompt para el siguiente turno

        # Obtener el resumen y limpiar el código
        summary, cleaned_code = self.generate_summary_and_clean_code(final_response)
        return conversation_history, summary, cleaned_code

    def generate_summary_and_clean_code(self, final_response: str) -> Tuple[str, str]:
        # Generar el resumen basado en la respuesta final
        summary = "Resumen de la conversación: \n" + final_response

        # Limpiar el código removiendo los marcadores específicos
        cleaned_code = re.sub(r"```solidity|```", "", final_response).strip()
        return summary, cleaned_code

    def display_conversation(self, conversation_history: List[str]):
        for message in conversation_history:
            print(message)