from agents.base_agent import Agent

class BasicAgent(Agent):
    def respond(self, input_text):
        return self.language_model.generate_response(input_text)
    
