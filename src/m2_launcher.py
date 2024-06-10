from datapipe import DataPipe as dp

##########################
# GENERATION
##########################

from Modules.generation_module.SOTA_generator import SOTA

dp.set_dir('attributes')
requirements = dp.read(index=-1, json_joined=True)
SOTA(requirements) # generates and saves

##########################
# ASSESSMENT
##########################

# Syntax Check

from Modules.assessment_module.syntax_checker import check_syntax

dp.set_dir('contracts')
source_code = dp.read(index=-1)
is_syntax_correct = check_syntax(source_code) # -> bool

# SUITABILITY ASSESSMENT

from typing import List

import dspy

model = dspy.OpenAI(model="gpt-3.5-turbo-0125", max_tokens=300, temperature=1)
dspy.settings.configure(lm=model, max_tokens=1024)

class SmartContractCompliance(dspy.Signature):
    """Determines if a smart contract fulfills a given requirement."""
    description: str = dspy.InputField(desc="Description of the smart contract's purpose.")
    requirement: str = dspy.InputField(desc="Specific requirement the contract should fulfill.")
    contract_code: str = dspy.InputField(desc="The smart contract code.")
    complies: bool = dspy.OutputField(desc="True if the code complies, False otherwise.")

class ImprovementAdvice(dspy.Signature):
    """Provides a technical tip to improve a smart contract based on a failed requirement."""
    description: str = dspy.InputField(desc="Description of the smart contract's purpose.")
    requirement: str = dspy.InputField(desc="Specific requirement the contract failed to fulfill.")
    contract_code: str = dspy.InputField(desc="The smart contract code.")
    advice: str = dspy.OutputField(desc="Technical advice on how to improve the code.")

class SmartContractAnalyzer(dspy.Module):
    """Analyzes smart contract code against a requirement and determines compliance."""

    def __init__(self):
        super().__init__()
        self.compliance_checker = dspy.ChainOfThought(SmartContractCompliance)

    def forward(self, description: str, requirement: str, contract_code: str) -> bool:
        return self.compliance_checker(description=description, requirement=requirement, contract_code=contract_code)

class SmartContractAdvisor(dspy.Module):
    """Provides advice on how to improve a smart contract that fails to meet a requirement."""

    def __init__(self):
        super().__init__()
        self.advice_giver = dspy.ChainOfThought(ImprovementAdvice)

    def forward(self, description: str, requirement: str, contract_code: str) -> str:
        return self.advice_giver(description=description, requirement=requirement, contract_code=contract_code)

# Example Usage:
analyzer = SmartContractAnalyzer()
advisor = SmartContractAdvisor()

contract_code = smart_contract_code
requirement = requirements[0].multistring_json()
file_path = 'selected_description.json'
with open(file_path, 'r') as file:
    description = json.load(file)   

complies = analyzer(description=description, requirement=requirement, contract_code=contract_code)

if complies:
    print("The smart contract meets the requirement.")
else:
    advice = advisor(description=description, requirement=requirement, contract_code=contract_code)
    print(f"The smart contract does not meet the requirement. Here's a tip:\n{advice}")














# Definir el prompt template para reflexionar sobre el cumplimiento de los requisitos
prompt_template = ChatPromptTemplate.from_messages(
    [
        ("system", "You are an expert in smart contracts. You will review the smart contract code and determine if it fulfills the given requirement. Provide a detailed reflection on whether the code meets the requirement or not. If it does not, provide a technical tip on how to improve it."),
        ("user", "Description: {description}\nRequirement: {requirement}\nContract Code: {contract_code}")
    ]                       
)

model = ChatOpenAI(model="gpt-3.5-turbo")
parser = StrOutputParser()

chain = prompt_template | model | parser



requirement = requirements[0]

requirement_description = requirement.multistring_json()

reflection = chain.invoke({
    "description": description,
    "requirement": requirement_description,
    "contract_code": smart_contract_code
})

# Procesar la reflexión para obtener un booleano y un consejo técnico si es necesario
def process_reflection(reflection: str):
    if "does not meet" in reflection.lower():
        return False, reflection.split("Tip:")[-1].strip()
    return True, ""

# Obtener el resultado y el consejo técnico si aplica
meets_requirement, technical_tip = process_reflection(reflection)

# Imprimir los resultados
print(f"Meets requirement: {meets_requirement}")
if not meets_requirement:
    print(f"Technical tip: {technical_tip}")

# Guardar la reflexión en un archivo
reflection_data = {
    "requirement": requirement.name,
    "meets_requirement": meets_requirement,
    "reflection": reflection,
    "technical_tip": technical_tip if not meets_requirement else ""
}

from pathlib import Path

reflection_file_path = Path('reflection_result.json')
with open(reflection_file_path, 'w') as file:
    json.dump(reflection_data, file, indent=4)

print(f'Reflection result saved to {reflection_file_path}')










