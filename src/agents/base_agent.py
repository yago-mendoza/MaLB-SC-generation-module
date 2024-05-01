from abc import ABC, abstractmethod

class Agent(ABC):
    def __init__(self, language_model):
        self.language_model = language_model

    @abstractmethod
    def respond(self, input_text):
        pass