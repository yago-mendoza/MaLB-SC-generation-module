from pathlib import Path
import tempfile
import dspy

description = "This is a smart contract description"

gpt3_turbo = dspy.OpenAI(model='gpt-3.5-turbo-1106', max_tokens=300, temperature=1)
dspy.settings.configure(lm=gpt3_turbo, max_tokens=1024)

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

# Use tempfile to create a temporary file
with tempfile.NamedTemporaryFile(delete=False) as temp_file:
    # Assume the content of the JSON is stored in the variable json_content
    json_content = Path("optimised_modules/M11_ValidateTopic_opt.json").read_text()
    temp_file.write(json_content.encode())
    temp_file.flush()

# Load the temporary file
loaded_optimized_validate_topic = ValidateTopic()
loaded_optimized_validate_topic.load(Path(temp_file.name))

# Get the result
result = loaded_optimized_validate_topic.forward(description)
print(result.boolean_assessment)

# Clean up the temporary file manually
Path(temp_file.name).unlink()