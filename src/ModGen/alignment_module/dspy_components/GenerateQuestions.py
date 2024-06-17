from typing import List, Dict, Any, Tuple

import dspy
from dspy import teleprompt
from pathlib import Path

import json


class GenerateQuestionsSignature(dspy.Signature):
    f"""
    Generate YES/NO questions for a contract feature.
    """
    description: str = dspy.InputField(desc="Description of the contract logic.")
    feature: Dict[str, Any] = dspy.InputField(desc="Contract feature.")
    questions: List[str] = dspy.OutputField(desc="List of questions for the feature.")

class GenerateQuestions(dspy.Module):
    f"""
    Generate questions for a contract feature implementation.
    """
    def __init__(self) -> None:
        super().__init__()
        self.generate_answer = dspy.functional.TypedPredictor(GenerateQuestionsSignature)

    def forward(self, description: str, feature: Dict[str, Any]) -> List[str]:
        return self.generate_answer(description=description, feature=feature)

feature_questions_examples_path = Path("alignment_module/dspy_components/training_data/feature_questions_examples.json")
description_example_path = Path("alignment_module/dspy_components/training_data/description_example.sol")

def train():

    feature_nquestions_for_training = 4

    global feature_questions_examples_path
    global description_example_path
    
    with open(feature_questions_examples_path, "r") as f:
        examples_from_json = json.load(f)

    with open(description_example_path, "r") as f:
        description = f.readlines()

    examples_for_training = [
        dspy.Example(description=description, feature=feature, questions=questions).with_inputs("description", "feature")
        for feature, questions in examples_from_json.items()
    ]

    def metric(example, prediction, trace=None):
        condition_1 = len(prediction.questions) == 4
        condition_2 = all([len(question) < 70 for question in prediction.questions])
        return condition_1 and condition_2

    config = dict(max_bootstrapped_demos=len(examples_for_training)) # max_labeled_demos=4
    optimiser = teleprompt.BootstrapFewShot(
        metric=metric,
        **config
        )

    module = optimiser.compile(
        GenerateQuestions(),
        trainset=examples_for_training,
        valset=examples_for_training
        )

if __name__ == "__main__":
    train = True
    if train: train()
    



