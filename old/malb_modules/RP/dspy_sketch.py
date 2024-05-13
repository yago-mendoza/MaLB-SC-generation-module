import dspy
from dspy import Signature, InputField, OutputField

class CheckRelevance(Signature):
    description = "Check if the description is relevant to smart contracts."
    input = InputField(desc="A textual description of a potential smart contract.")
    output = OutputField(desc="Boolean indicating if the text is relevant.")

class CheckCoherence(Signature):
    description = "Check if the smart contract description is coherent and consistent."
    input = InputField(desc="A verified smart contract description.")
    output = OutputField(desc="Tuple of coherence status and feedback if necessary.")

class ExtractInformation(Signature):
    description = "Extract key information fields from the smart contract description."
    input = InputField(desc="A coherent smart contract description.")
    output = OutputField(desc="JSON object containing structured information about the smart contract.")

class SmartContractAgent(dspy.Module):
    def __init__(self, llm_model):
        self.llm_model = llm_model
        self.relevance_checker = dspy.Module(CheckRelevance(), self.check_relevance)
        self.coherence_checker = dspy.Module(CheckCoherence(), self.check_coherence)
        self.info_extractor = dspy.Module(ExtractInformation(), self.extract_info)

    def check_relevance(self, description):
        # Use llm_model to determine relevance
        return self.llm_model.ask(description)

    def check_coherence(self, description):
        # Use llm_model to check coherence
        return self.llm_model.ask(description)

    def extract_info(self, description):
        # Use llm_model to extract structured info
        return self.llm_model.ask(description)

    def process_description(self, description):
        b = 4
        if not self.relevance_checker(description):
            a = 4
            return "Description is not relevant to smart contracts."
        
        coherence, feedback = self.coherence_checker(description)
        if not coherence:
            return f"Description lacks coherence: {feedback}"
        
        info_json = self.info_extractor(description)
        return info_json

