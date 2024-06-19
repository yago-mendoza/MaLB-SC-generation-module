from typing import List, Dict, Any, Tuple
from pathlib import Path
from utils.verbose_logger import VerboseLogger

from alignment_module.scrutiny.dspy_components.AssessFactuality import AssessFactuality

import dspy
import tempfile
import copy

class Scrutineer(VerboseLogger):

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

        self.log("Scrutineer initialized", 1)
    
    def set_config(
        self,
        n_chunks: int = 5
    ):
        self.n_chunks = n_chunks
    
    def clone(
        self,
        count: int
    ) -> List['Scrutineer']:
        clones = []
        for _ in range(count):
            new_instance = Scrutineer(
                gpt_openai_model=self.gpt_openai_model,
                temperature=self.temperature,
                max_tokens=self.max_tokens,
                verbose_policy=self.verbose_policy
            )
            # Copy all attributes deeply
            new_instance.__dict__ = copy.deepcopy(self.__dict__)
            clones.append(new_instance)
        return clones
    
    def answer_questions(
        self, 
        source_code: str, 
        questions_chunk: List[str]
    ) -> List[bool]:
        
        lm = dspy.OpenAI(
            model=self.gpt_openai_model,
            max_tokens=self.max_tokens,
            temperature=self.temperature
        )
        dspy.settings.configure(lm=lm, max_tokens=1024)

        scrutineer = AssessFactuality()
        return scrutineer.forward(
            source_code=source_code,
            questions=questions_chunk
        ).factuality

    def fill_survey(
        self, 
        questions: List[str],
        source_code: str
    ) -> List[bool]:
        
        # Chuncks the questions for Scrutineer efficient processing
        
        if questions == []:
            return []

        questions_chunks = [
            questions[i:i + self.n_chunks] for i in range(0, len(questions), 5)
        ]

        factuality = []
        for questions_chunk in questions_chunks:
            factuality.extend(
                self.answer_questions(source_code, questions_chunk)
            )
        
        return factuality