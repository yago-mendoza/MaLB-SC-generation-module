from importlib import import_module
from utils.verbose_logger import VerboseLogger

from typing import (
    List,
    Dict,
    Any,
    Tuple

)


class SyntaxGenerator(VerboseLogger):

    def __init__(
        self,
        initial_conditions: Tuple[str, List[Dict[str, Any]]],
        language_model: str = "gpt-3.5-turbo",
        reasoning_layer: str = "ZSGen",
        verbose_policy: int = 1
    ) -> None:
        VerboseLogger.__init__(self)
        self.verbose_policy = verbose_policy
        
        self.language_model = language_model

        self.default_reasoning_layer = "ZSGen"
        self.set_reasoning_layer(reasoning_layer)
        self.set_initial_conditions(initial_conditions)

        self.log("Syntax Generator initialized", 1)

    def set_initial_conditions(
        self,
        initial_conditions: Tuple[str, List[Dict[str, Any]]]
    ) -> None:
        self.initial_conditions = initial_conditions
        self.log("Initial conditions set", 2)

    def set_reasoning_layer(
        self,
        reasoning_layer: str
    ) -> None:
        try:
            self.reasoning_layer = getattr(
                import_module(f"generation_module.reasoning_layers.{reasoning_layer}_layer"),
                reasoning_layer
            )
            self.log(f"Reasoning technique set to {reasoning_layer}", 2)
        except AttributeError as e:
            self.set_reasoning_layer(self.default_reasoning_layer)
            self.log(f"Error setting reasoning layer: {e}", 1)
            self.log("Layer not found, using default", 1)
            raise

    def generate(
        self
    ) -> str:
        self.log(f"Retrieved reasoning layer {self.reasoning_layer.__name__}", 2)
        self.log("Generating code...", 3)

        code = self.reasoning_layer(
            initial_conditions=self.initial_conditions,
            language_model=self.language_model
        )
        
        self.log(f"Code generated: {len(code)} characters in total", 1)
        return code
