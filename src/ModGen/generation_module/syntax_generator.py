from importlib import import_module
from utils.verbose_logger import VerboseLogger

from typing import (
    List,
    Dict,
    Any,
    Tuple
)

class SyntaxGenerator (VerboseLogger):

    def __init__ (
        self,
        initial_conditions: Tuple[str, List[Dict[str, Any]]],
        language_model: str = "gpt-3.5-turbo",
        reasoning_technique: str = "ZSGen",
        verbose_policy = 1
    ) -> None:
        VerboseLogger.__init__(self)
        self.verbose_policy = verbose_policy
        
        self.set_initial_conditions(initial_conditions)
        self.set_reasoning_technique(reasoning_technique)

        self.log("Syntax Generator initialized", 1)

    def set_initial_conditions(
        self,
        initial_conditions: Tuple[str, List[Dict[str, Any]]],
    ) -> None:
        self.initial_conditions = initial_conditions
        self.log("Initial conditions set", 2)
    
    def set_reasoning_technique(
        self,
        reasoning_technique: str = None
    ) -> None:
        if not reasoning_technique: reasoning_technique = "ZSGen"
        self.reasoning_technique = reasoning_technique
        self.log(f"Reasoning technique set to {reasoning_technique}", 2)

    def generate(
        self
    ) -> str:
        ReasoningLayer = getattr(
            import_module(f"generation_module.reasoning_layers.{self.reasoning_technique}_layer"),
            self.reasoning_technique
            )

        self.log("Retrieved reasoning layer {self.reasoning_technique}", 2)
        self.log("Generating code...", 3)
        code = ReasoningLayer(self.initial_conditions)
        self.log(f"Code generated : {len(code)} characters in total", 1)

        return code