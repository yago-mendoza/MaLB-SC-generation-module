from typing import List

print("Loading DSPy library...")
import dspy
print("DSPy succesfully loaded.")

class AssessFactualitySignature(dspy.Signature):
    f"""
    Assess the factuality of answers to YES/NO questions based on the codebase status.
    """
    source_code: str = dspy.InputField(desc="Source code of the smart contract.")
    questions: List[str] = dspy.InputField(desc="List of questions to be assessed.")
    factuality: List[bool] = dspy.OutputField(desc="List of boolean answers indicating factuality.")

class AssessFactuality(dspy.Module):
    f"""
    Assess the factuality of answers to questions about a specific contract feature implementation.
    """
    def __init__(self) -> None:
        super().__init__()
        self.assess_factuality = dspy.functional.TypedChainOfThought(AssessFactualitySignature)

    def forward(self, source_code: str, questions: List[str]) -> List[bool]:
        return self.assess_factuality(source_code=source_code, questions=questions)

