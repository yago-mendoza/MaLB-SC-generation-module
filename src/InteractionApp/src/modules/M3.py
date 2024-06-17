import dspy
from typing import List
from pydantic import BaseModel, Field

class PydanticRequirement(BaseModel):
    Name: str = Field(description="The given name")
    Scope: str = Field(description="The scope for the requirement")
    Input: List[str] = Field(description="Conceptual inputs")
    Constraints: List[str] = Field(description="Actual constraints")
    Output: List[str] = Field(description="Conceptual outputs")
    PrimaryScenario: str = Field(description="Intended scenario")
    AlternativeScenario: str = Field(description="Edge cases and undesired conditions")

class generate_attributes(dspy.Signature):
    """Generate attributes for the given smart contract description"""
    smart_contract_description: str = dspy.InputField(desc="Contextual smart contract")
    requirement_description: str = dspy.InputField(desc="The feature of the smart contract we want to expand into attributes")
    structured_requirement: PydanticRequirement = dspy.OutputField(desc="Structured list of requirement attributes")

class GenerateAttributes(dspy.Module):
    """A module to process multiple requirement descriptions into structured object."""

    def __init__(self):
        super().__init__()
        self.generate_answer = dspy.functional.TypedPredictor(generate_attributes)
    
    def forward(self, description: str, requirement: str) -> PydanticRequirement:
        pred = self.generate_answer(
            smart_contract_description=description,
            requirement_description=requirement
            )
        return pred


