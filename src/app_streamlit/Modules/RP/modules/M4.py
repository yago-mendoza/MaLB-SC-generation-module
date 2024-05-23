import dspy
from typing import List

class generate_questions(dspy.Signature):
    """
    Ask insightful questions about a Smart Contract description
    """
    smart_contract_description: str = dspy.InputField(desc="A description of a Smart Contract")
    questions: List[str] = dspy.OutputField(desc="The list of questions")

class GenerateQuestions(dspy.Module):
    def __init__(self):
        super().__init__()
        self.generate_answer = dspy.functional.TypedPredictor(generate_questions)
        
    def forward(self, smart_contract_description: str) -> List[str]:
        return self.generate_answer(smart_contract_description=smart_contract_description)

class reflexion(dspy.Signature):
    """
    You are a Software Engineer
    Provide 3 smart insights and observations pointing out incoherences or blatant issues with a Smart Contract description.
    """
    smart_contract_description: str = dspy.InputField(desc="A description of a Smart Contract")
    insights: List[str] = dspy.OutputField(desc="The list of 3 insights")

class Reflexion(dspy.Module):
    def __init__(self):
        super().__init__()
        self.generate_answer = dspy.functional.TypedPredictor(reflexion)
        
    def forward(self, smart_contract_description: str) -> List[str]:
        return self.generate_answer(smart_contract_description=smart_contract_description)

class update_description(dspy.Signature):
    """Does necessary changes to correct the description, keeping all previous and new information in a coherent way."""
    old_description: str = dspy.InputField(desc="Original Smart Contract description")
    question: str = dspy.InputField(desc="A question to further polish the description")
    answer: str = dspy.InputField(desc="The answer provided by the client")
    new_description: str = dspy.OutputField(desc="The newly writen description")

class UpdateDescription(dspy.Module):
    """A module that does minor changes to correct the description seamlessly."""
    def __init__(self, **kwargs):
        super().__init__()
        self.kwargs = kwargs
        self.generate_answer = dspy.functional.TypedChainOfThought(update_description)

    def forward(self, old_description: str, question: str, answer: str) -> str:
        return self.generate_answer(old_description=old_description, question=question, answer=answer)
    
class choose_best (dspy.Signature):
    """Choose the better description in terms of coherence, completeness of information and technicality."""
    description_a: str = dspy.InputField(desc="Description A")
    description_b: str = dspy.InputField(desc="Description B")
    assessment: bool = dspy.OutputField(desc="True if 'A' is better than 'B'")
class ChooseBest(dspy.Module):
    """A module that chooses the better description in terms of coherence, completeness of information and technicality."""
    def __init__(self):
        super().__init__()
        self.generate_answer = dspy.functional.TypedPredictor(choose_best)

    def forward(self, description_a: str, description_b: str) -> bool:
        answer = self.generate_answer(description_a=description_a, description_b=description_b)
        return answer

