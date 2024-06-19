from src.modules.M2 import InferRequirements
from src.modules.M3 import GenerateAttributes

from InteractionApp.src.coalitions.CompilableEntity import CompilableEntity

from datetime import datetime

class ParsingTeam:

    def __init__(self):

        self.requirements = []
        self.attributes = []

        # Initialize the modules as AbstractModules
        self.InferRequirements = CompilableEntity(
            module=InferRequirements,
            load_path="src/modules/modules_fabric/M2_InferRequirements_opt.json",  # Assuming a config or model path if required
            model="gpt-3.5-turbo-0125",  # Assuming model parameter if required
            out="requirements"  # Output type as expected from the module
        )

        self.GenerateAttributes = CompilableEntity(
            module=GenerateAttributes,
            load_path="src/modules/modules_fabric/M31_GenerateAttributes_opt.json",  # Assuming a config or model path if required
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