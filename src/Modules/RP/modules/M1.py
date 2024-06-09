import dspy

class validate_topic(dspy.Signature):
    """Does the text deliver a detailed engineer's functional description of how one particular smart contract is designed to work programmatically post-deployment?"""
    smart_contract_description: str = dspy.InputField(desc="A description of a Smart Contract")
    boolean_assessment: bool = dspy.OutputField(desc="True/False indicating if text is about Smart Contracts")

class ValidateTopic(dspy.Module):
    """A module to verify if the description consists of a precise functional description of how a specific smart contract should work."""
    def __init__(self):
        super().__init__()
        self.generate_answer = dspy.functional.TypedChainOfThought(validate_topic)

    def forward(self, smart_contract_description: str) -> bool:
        return self.generate_answer(smart_contract_description=smart_contract_description)
