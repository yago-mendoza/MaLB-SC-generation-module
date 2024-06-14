from src.modules.M1 import ValidateTopic
from src.modules.M4 import GenerateQuestions, UpdateDescription, Reflexion

from src.coalitions.PseudoAgent import PseudoAgent

from datetime import datetime

class CoordinationTeam:

    ERROR_101 = "This is not technical enough. Please, repeat it."
    LEN_THRESHOLD = 750

    def __init__(self):
        self.reset()

    def reset(self):
        self.TOPIC_VALIDATED = False
        self.FORWARD_CALL_COUNT = 0
        self.DESCRIPTIONS = []
        self.QUESTIONS = []
        self.BACK_DATA = []
        self.POST = 0
        # Initialize other parameters

    def initialize_modules(self, api_key, model):
        self.api_key = api_key  # Unused
        self.model = model 

        # -------------- Modules -------------- #

        self.ValidateTopic = PseudoAgent(
            module=ValidateTopic,
            load_path="src/modules/modules_fabric/M11_ValidateTopic_opt.json",
            model=self.model,
            out="boolean_assessment"
        )
        
        self.GenerateQuestions = PseudoAgent(
            module=GenerateQuestions,
            load_path="src/modules/modules_fabric/M4_GenerateQuestions_opt.json",
            model=self.model,
            out="questions"
        )
        
        self.UpdateDescription = PseudoAgent(
            module=UpdateDescription,
            model=self.model,
            out="new_description"
        )

        self.Reflect = PseudoAgent(
            module=Reflexion,
            model=self.model,
            out="insights"
        )

    def last_msg(self, role):
        last = [msg['content'] for msg in self.messages if msg['role'] == role][-1]
        return last

    @staticmethod
    def format_list(out, prefix=None):
        if isinstance(prefix, str) and isinstance(out, list):
            bullet_list = "\n".join(f"- {item}" for item in out)
            return f"{prefix}:\n{bullet_list}"
    
    def keep(self, label, object):
        self.BACK_DATA.append((label, object, datetime.now(),))

    def send(self, messages):

        self.messages = messages
        self.FORWARD_CALL_COUNT += 1
        
        if not self.TOPIC_VALIDATED:

            out = self.ValidateTopic.execute(self.last_msg('user'))
            
            if out is True:

                self.TOPIC_VALIDATED = True
                self.DESCRIPTIONS.append(self.last_msg('user'))
                self.keep("Initial User Description", self.DESCRIPTIONS[-1])
                self.QUESTIONS = self.GenerateQuestions.execute(
                    self.DESCRIPTIONS[-1],
                )
                self.keep("System Queries", self.QUESTIONS)
                return CoordinationTeam.format_list(
                    self.QUESTIONS,
                    "Okay, so let's start with some questions"
                    )
            else:
                return self.ERROR_101
        
        else:

            answer = self.last_msg('user')
            self.keep("User Insights", answer)

            new_description = self.UpdateDescription.execute(
                self.DESCRIPTIONS[-1],
                ' '.join(self.QUESTIONS),
                answer)
            
            self.DESCRIPTIONS.append(new_description)
            self.keep("System Updated Description", self.DESCRIPTIONS[-1])

            if len(new_description) > self.LEN_THRESHOLD:

                self.POST += 1
                if self.POST > 1:
                    return "Okay, your final description has been created, incorporating all of the insights you've shared throughout our conversation. You can find it in the history section. To start a new one, clear the chat with the button below and provide a new starting point description."
            
                self.REFLEXION = self.Reflect.execute(
                    self.DESCRIPTIONS[-1],
                )
                self.keep("Reflexion", self.DESCRIPTIONS[-1])
                return CoordinationTeam.format_list(
                    self.REFLEXION,
                    "I still have some questions about how certain aspects of the Smart Contract behave. If these are important for understanding its functionality, would you be able to clarify them for me?"
                    )
            
            else:

                self.QUESTIONS = self.GenerateQuestions.execute(
                    self.DESCRIPTIONS[-1],
                )
                self.keep("System Queries", self.QUESTIONS)
                return CoordinationTeam.format_list(
                    self.QUESTIONS,
                    "Excellent. Just some additional questions"
                    )




