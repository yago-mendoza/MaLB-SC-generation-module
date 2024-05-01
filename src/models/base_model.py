from abc import ABC, abstractmethod


class LanguageModel(ABC):
    @abstractmethod
    def set_prompt(self, prompt_template: str) -> None:
        pass

    @abstractmethod
    def generate_response(self, *args: str) -> str:
        pass
