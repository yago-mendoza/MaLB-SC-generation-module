import re

def segment_solidity_contracts(solidity_code):
    """
    Segments the provided Solidity code into individual contracts.

    Args:
        solidity_code (str): The complete Solidity code as a string.

    Returns:
        List[str]: A list of strings, each representing a separate contract.
    """
    # Regular expression to match each contract
    contract_regex = r'(\bcontract\b\s+\w+\s*\{[\s\S]*?\})'
    
    # Find all matches of contracts in the Solidity code
    contracts = re.findall(contract_regex, solidity_code)
    
    return contracts

from datapipe import DataPipe as dp

solidity_file = dp.read(index=0, dir=dp.contracts_dir)
contract = segment_solidity_contracts(solidity_file)[0]

print('Loading DSPy module...')
import dspy
print('DSPy module loaded successfully.')
from typing import List

model = dspy.OpenAI(model="gpt-3.5-turbo-0125", max_tokens=300, temperature=1)
dspy.settings.configure(lm=model, max_tokens=1024)

class Auditor(dspy.Signature):
    """Think like a software engineer.
    Highlight a different aspects of the contract in terms of security against attacks.
    Talk in terms of specific contract variables, functions, and other elements.
    Be as specific as possible."""
    source_code: str = dspy.InputField(desc="The source code of the contract to be audited.")
    contract: str = dspy.InputField(desc="The contract to be audited.")
    findings: str = dspy.OutputField(desc="Exhaustive improvement points regarding the security of the specified contract.")
    
class AuditorPipeline(dspy.Module):
    def __init__(self, n=6):
        super().__init__()
        self.n_auditors = n
        self.auditor = dspy.ChainOfThought(Auditor, n=self.n_auditors)
        print(f"Initialized AuditorPipeline with {self.n_auditors} auditors.")
    
    def forward(self, contract):
        print("Starting forward pass")
        print(f"Auditing...")
        findings = self.auditor(source_code=solidity_file, contract=contract).completions.findings
        print(f"Generated {self.n_auditors} findings.")
        return dspy.Prediction(findings=findings)
    
pipeline = AuditorPipeline()
auditors_results = pipeline(contract=contract).findings

print(auditors_results)

class SummarizeStrings(dspy.Signature):
    """Get list of strings and generate a non-redundant list of all isolated facts"""
    input_strings: List[str]= dspy.InputField(desc="List of strings to be summarized")
    summary: List[str] = dspy.OutputField(desc="Non-redundant summary of the input strings")

summarize = dspy.TypedChainOfThought(SummarizeStrings)
response = summarize(input_strings=auditors_results).summary

for el in response: print(el)
print('#'*40)

class SummarizeStrings(dspy.Signature):
    """Filter out all strings that are not security tips or matters that need to be addressed.
    Phrase them in a way that is mandatory and specific about steps to follow.
    Be specific about WHAT, WHERE and WHY."""
    input_strings: List[str]= dspy.InputField(desc="List of strings")
    summary: List[str] = dspy.OutputField(desc="A list of recommendations only")

summarize = dspy.TypedChainOfThought(SummarizeStrings)
response = summarize(input_strings=auditors_results).summary

for el in response: print(el)
print('#'*40)
# for _ in range(len(response.summary)):
#     print(response.summary[_])

# class SecurityOutput(dspy.Signature):
#     contract: str = dspy.InputField(desc="Specific contract where the issue was detected.")

#     correctness: str = dspy.OutputField(desc="A score reflecting the validity of the identified issue.")
#     severity: str = dspy.OutputField(desc="A score indicating how critical the vulnerability is to the contract’s overall security.")
#     profitability: str = dspy.OutputField(desc="A score that could represent the economic impact of the vulnerability, such as the cost of an exploit.")
    
#     vulnerability: str = dspy.Outputfield(desc="The type of potential security flaw discovered by the auditor.")
#     auditor: str = dspy.OutputField(desc="Insights from the AI auditor regarding how the vulnerability could be exploited.")
#     critic: str = dspy.OutputField(desc="A critique of the auditor's findings, addressing the accuracy and relevance of the reported vulnerability.")
    
# class GasConsumptionOutput:
#     gas_usage: str = dspy.OutputField(desc="An estimate of the gas required to execute the function.")
#     savings: str = dspy.OutputField(desc="Estimates the potential reduction in gas usage (and thus cost) if the auditor's suggestions are implemented, highlighting the economic impact of optimization.")