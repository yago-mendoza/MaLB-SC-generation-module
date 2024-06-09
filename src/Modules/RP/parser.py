from Modules.RP.modules.M2 import InferRequirements
from Modules.RP.modules.M3 import GenerateAttributes

from Modules.abstract_module import ReFactAgent

class ParserTeam:

    def __init__(self):

        self.requirements = []
        self.attributes = []

        # Initialize the modules as AbstractModules
        self.InferRequirements = ReFactAgent(
            module=InferRequirements,
            load_path="Modules/RP/modules_fabric/M2_InferRequirements_opt.json",  # Assuming a config or model path if required
            model="gpt-3.5-turbo-0125",  # Assuming model parameter if required
            out="requirements"  # Output type as expected from the module
        )

        self.GenerateAttributes = ReFactAgent(
            module=GenerateAttributes,
            load_path="Modules/RP/modules_fabric/M31_GenerateAttributes_opt.json",  # Assuming a config or model path if required
            model="gpt-3.5-turbo-0125",  # Assuming model parameter if required
            out="structured_requirement"  # Output type as expected from the module
        )

    def get_requirements(self, description):
        self.requirements = self.InferRequirements.execute(description)
        return self.requirements

    def get_attributes(self, requirements, description):
        self.attributes = []
        for requirement in requirements:
            attribute = self.GenerateAttributes.execute(description, requirement)
            self.attributes.append(attribute)
        return self.attributes