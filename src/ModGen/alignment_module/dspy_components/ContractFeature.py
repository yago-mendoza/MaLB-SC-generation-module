from pydantic import BaseModel, Field
from typing import List

class ContractFeature(BaseModel):
    Name: str = Field(description="Name of the feature")
    Scope: str = Field(description="Scope of the feature")
    Input: List[str] = Field(description="Conceptual inputs")
    Constraints: List[str] = Field(description="Applied constraints")
    Output: List[str] = Field(description="Conceptual outputs")
    PrimaryScenario: str = Field(description="Primary scenario")
    AlternativeScenario: str = Field(description="Alternative scenario")