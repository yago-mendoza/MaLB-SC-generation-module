from utils.verbose_logger import VerboseLogger
from typing import List, Dict, Any, Tuple
from pathlib import Path

from alignment_module.inquisition.dspy_components.ContractFeatureClass import ContractFeature
from alignment_module.inquisition.dspy_components.GenerateQuestions import GenerateQuestions

print("Importing DSPy...")
import dspy
print("DSPy imported.")

import tempfile

optimised_module_path = (
    "alignment_module/inquisition/dspy_components/teleprompted_model.json"
)


class Inquisitor(VerboseLogger):

    def __init__(
        self,
        gpt_openai_model: str = "gpt-3.5-turbo",
        temperature: float = 0.7,
        max_tokens: int = 300,
        verbose_policy: int = 1
    ) -> None:
        
        VerboseLogger.__init__(self)
        self.verbose_policy = verbose_policy
        self.gpt_openai_model = gpt_openai_model
        self.temperature = temperature
        self.max_tokens = max_tokens

        self.log("Inquisitor initialized", 1)
    
    def set_initial_conditions(
        self,
        initial_conditions: Tuple[str, List[Dict[str, Any]]],
    ) -> None:

        # now we exrpess the import in multiple lines for better dispaly

        description, feature_dicts = initial_conditions
        features = [ContractFeature(**feature) for feature in feature_dicts]
        self.initial_conditions = (description, features)
        self.log("Initial conditions set", 2)

    def generate_questions_for_feature(
        self, 
        description: str, 
        feature: Dict[str, Any], 
    ) -> List[str]:
        
        lm = dspy.OpenAI(
            model=self.gpt_openai_model,
            max_tokens=self.max_tokens,
            temperature=self.temperature
        )
        dspy.settings.configure(lm=lm, max_tokens=1024)

        # Import the question generation module and load the optimized version.

        global optimised_module_path
        generator = GenerateQuestions()
        load_path = optimised_module_path

        try:
            with tempfile.NamedTemporaryFile(delete=False) as temp_file:
                json_content = Path(load_path).read_text()
                temp_file.write(json_content.encode())
                temp_file.flush()

            generator.load(Path(temp_file.name))
        except KeyError as e:
            self.log(f"KeyError encountered: {e}. Please check the JSON content.", 0)
            raise
        finally:
            Path(temp_file.name).unlink()

        return generator.forward(
            description=description,
            feature=feature
        ).questions

    def formulate_questions(
        self,
        initial_conditions: Tuple[str, List[Dict[str, Any]]]
    ) -> Dict[str, List[str]]:

        self.set_initial_conditions(initial_conditions)

        self.log("Formulating questions...", 2)
        description, features = self.initial_conditions
        questions_dict = {}
        for i, feature in enumerate(features):
            self.log(f"Generating questions for feature {i+1}/{len(features)}", 1)
            feature_name = feature.Name
            feature_dict = feature.dict()
            questions = self.generate_questions_for_feature(description, feature_dict)
            questions_dict[feature_name] = questions
        return questions_dict
