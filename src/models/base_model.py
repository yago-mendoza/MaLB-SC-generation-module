from abc import ABC, abstractmethod


class LanguageModel(ABC):
    @abstractmethod
    def generate_response(self, prompt):
        pass
