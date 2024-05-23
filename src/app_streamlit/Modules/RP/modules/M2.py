import dspy
from typing import List

class infer_requirements(dspy.Signature):
    """Extract requirements from a Smart Contract Description"""
    smart_contract_description: str = dspy.InputField(desc="A description of a Smart Contract")
    requirements: List[str] = dspy.OutputField(desc="A list object with extracted requirements")

class InferRequirements(dspy.Module):
    """A module to extract requirements from a Smart Contract Description"""
    def __init__(self):
        super().__init__()
        self.generate_answer = dspy.functional.TypedPredictor(infer_requirements)

    def forward(self, smart_contract_description: str) -> List[str]:
        return self.generate_answer(smart_contract_description=smart_contract_description)
