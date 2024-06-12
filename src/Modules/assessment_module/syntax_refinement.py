from typing import List
from datapipe import DataPipe as dp
print('Loading DSPy module...')
import dspy
print('DSPy module loaded successfully.')

model = dspy.OpenAI(model="gpt-3.5-turbo-0125", max_tokens=300, temperature=1)
dspy.settings.configure(lm=model, max_tokens=1024)

def assess_suitability(description, source_code, features):

    # Define the signatures for the intermediate steps
    class GenerateFeatureReflection(dspy.Signature):
        """Generates a reflection on a specific feature of the code. Nothing else. Just that specific feature."""
        code: str = dspy.InputField(desc="The code to be checked")
        feature: str = dspy.InputField(desc="The specific feature to check")
        reflections: str = dspy.OutputField(desc="Reflection on the feature implementation")

    class GenerateFinalAssessment(dspy.Signature):
        """Assesses the implementation of a specific feature (and no other) of the code, basing on previous reflections."""
        code: str = dspy.InputField(desc="The code to be checked")
        description: str = dspy.InputField(desc="Description of what the code should do")
        feature: str = dspy.InputField(desc="The specific feature to check")
        reflections: List[str] = dspy.InputField(desc="Reflection on the feature")
        assessment: str = dspy.OutputField(desc="Final assessment of the code")
        to_do: str = dspy.OutputField(desc="Specific step-by-step instructions to improve the code")
        is_adequate: bool = dspy.OutputField(desc="Boolean indicating if the code is adequate")

    # Define the multi-hop pipeline
    class CodeAssessmentPipeline(dspy.Module):
        def __init__(self, n=3):
            super().__init__()
            self.n_auditors = n
            self.generate_reflection = dspy.ChainOfThought(GenerateFeatureReflection, n=self.n_auditors)
            self.generate_final_assessment = dspy.TypedChainOfThought(GenerateFinalAssessment)
            print(f"Initialized CodeAssessmentPipeline with {self.n_auditors} auditors.")

        def forward(self, code, description, feature):
            print("Starting forward pass")
            print(f"Reflecting...")
            reflections = self.generate_reflection(code=code, feature=feature).completions.reflections
            print(f"Generated {self.n_auditors} reflections for the feature.")
            print("Generating final assessment...")
            final_assessment = self.generate_final_assessment(code=code, description=description, feature=feature, reflections=reflections)
            print(f"Final assessment achieved.")
            print(f"Adequate: {final_assessment.is_adequate}")
            return dspy.Prediction(reflections=reflections, assessment=final_assessment.assessment, to_do=final_assessment.to_do, is_adequate=final_assessment.is_adequate)

    pipeline = CodeAssessmentPipeline()

    features_assessment = []

    # Applies the assessment pipeline to each feature, and saves the results.

    for i, feature in enumerate(features):
        pred = pipeline(code=source_code, description=description, feature=str(feature))
        features_assessment.append(
            {
                "n": str(i+1),
                "reflection": pred.reflections,
                "assessment": pred.assessment,
                "to_do": pred.to_do,
                "is_adequate": pred.is_adequate
            }
        )

    return features_assessment