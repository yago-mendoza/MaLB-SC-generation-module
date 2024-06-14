from utils.datapipe import DataPipe

ddp = DataPipe()
ddp.set('../InteractionApp/output/descriptions')
description = ddp.load(-1)

fdp = DataPipe()
fdp.set('../InteractionApp/output/features')
features = fdp.load(-1)

from generation_module.syntax_generator import generate_syntax

# code = generate_syntax((description, features), reasoning='ZSGen')
# dp.set('generation_module/output/contracts')
# dp.dump(code, 'sol')


# We get the contracts and generate syntax checks

cdp = DataPipe()
cdp.set('generation_module/output/contracts')
contracts = cdp.load_all_files()

from static_linting.syntax_checker import SolidityCompiler

cel = DataPipe()
cel.set('generation_module/output/compiler_execution_log')
for contract in contracts[:5]:

    # compiler = SolidityCompiler('0.8.4')
    # output = compiler.compile(contract)
    # print(len(output))
    # cel.dump(output, 'json')

    pass

from static_linting.solhint_analyzer import SolhintAnalyzer


from ModGen.utils.llm.LLM import LLM
llm = LLM('You are a helpful assistante')

# SolhintAnalyzer.debug_mode = False
# solhint_report = SolhintAnalyzer.analyze(source_code, pathlib.Path('output/solhint_report.json'))




# def __init__(self):
#     self.endpoints = [
#         Endpoint("Generate a smart contract."),
#         Endpoint("Rewrite the prompt and remove information unrelated to the question therein."),
#         Endpoint("Rephrase and expand the question before generating the final answer."),
#         Endpoint("Read the question again before generating the final answer."),
#         Endpoint("Observe the question and generate a short-term plan."),
#         Endpoint("Decides if it needs to ask follow-up questions for a given prompt."),
#         Endpoint("Expresses its thought process before delivering the final answer ('Lets think step by step')"),
#         Endpoint("Generates a plan to solve the problem and carries it out step by step."),
#         Endpoint("Generates multiple CoTs and chooses the best one."),
#         Endpoint("Generates multiple reasoning chains and appends all of them into a given prompt.")
    
# Al generar el contrato, diversos agentes lo criticarán:
# - Compleción y coherencia
# - Consolidación y modularidad
# - Seguridad ante potenciales ataques
# - Eficiencia y optimización
# La tabla de features servirá para hacer referencia explícita en la terminal.

"""

Olvida Sony.
Cómo lo explicaras en la uni?
Si el mapa mental académico makes sense, para Sony también.

Hay varios requisitos, algunos (todos ellos) opcionales:

    - Usar DSPy en mayor medida (se encuentra en el título de la tesis)
    - Aprovechar la clase LLM (LangChain) que he hecho hoy
    - Hacer el análisis de distribución sigmoide

    Adicionalmente
        - ¿Qué hago con lo que desarrollé hasta el día de ayer, con DSPy?
          A lo mejor, coge lo más bonito hasta ahora y desecha el resto.
        - Si queda tiempo, inventas más ablation. Anda que me faltan métodos.
        - Generar mucho, programa elige, check syntax.
        - Cuan efectivo es por cuantos tokens usa.

Ahora toca idear este plan conceptual.
Algunos consejos:
- Se sincero.
- Super simple primero. Luego cuando esté claro el flow, refuerzas.
- Amaña los resultados.

Amaña los resultados.

# Problemas que a veces presentan los Smart Contracts resultantes
# - Some logics are indicated, but unimplemented.

# We have to assess that the results are indeed aligned with the initial description
# Make sure its runnable.

# ZSGen : Generate a Smart Contracs

# Testar en alguna parte para una tabla de (True/False en %)
# S2A : Rewrite the prompt and remove information unrelated to the question therein.
# RaR : Rephrase and expand the question before generating the final answer.
# Re2 : Read the question again before generating the final answer.

# ReAct : muchos agentes proponen una frase corta de como mejorar el código.
# Observe and generate a short term plan.

# Self-Ask : Decides if it needs to ask follow-up questions for a given prompt.
# CoT : Expresses its thought process before delivering the final answer ("Lets think step by step")
# Plan and Solve : Generates a plan to solve the problem and carries it out step by step.
    # Let's first understand the problem and devise a plan to solve it.
    # Then, let's carry out the plan and solve the problem step by step
# Self-Consistency : Generates multiple CoTs and chooses the best one.
# MetaReasoning over Multiple CoTs : Generates multiple reasoning chains and appends all of them into a given prompt.


Data seralization for ablation.
I mean I know I want data sturctured in a centralized for each run, but i dont know how, if on agents, if on system, or whatever.

I would like to have a router so that agents can decide what to do in the fly.
I would like that agents, if requried, for implementing logic, can prompt the user via /inputs (globaly offable)

I would like to find a reliable way to make sure that the code actually matches the origina ldescription; i have some ideas:
- # Reversing CoT : Explains what the code does and compares it with the initial description.
- # ChainOfVerification (COVE) : Generates multiple answers to a given question and creates a list of related questions that would help verify the correctness of the answer.

Maybe I would benefit from generating a lot and then choosing the better generations¿?

I have a function that tries to compile the code, which is a requisite for the final result of course.
But I dont know at what point or what component shoudl be doing that.

Here below is the impleentation for the moment. Agent, DataStructures classes arent implemented.



# Auditor(es): aspectos mal / mal alineados (creeis que necesitais mas informacion¿?

# Builder : description -> code
# Observer : description, code -> misalignments
# Short term planer : misalignments -> plan
# Critic : plan -> 

# Que varios con tareas predetermiandas se vayan pasando un prompt hasta que les guste a tdoos

# Define una clase abstracta ABC llamada BaseAgent.
# Un agente 

# Un agente que sepa qué cosas puede hacer.
# Que sepa qué tiene (descripcion, argumentos) y que sepa qué quiere lograr.




class Discussion:
    
    def __init__ (self):
        self.a = Agent()
        self.b = Agent()
    def run (self):
        answer_a = self.a('')
        for _ in range(5):
            answer_b = self.b(answer_a)
            print(f'A: {answer_b}')
            answer_a = self.a(answer_b)
            print(f'B: {answer_a}')
            

class Agent:

    def __init__(self):
        
        self.quest = "Decide what is the best ice-cream taste."
        self.const = "any"
        self.style = "Use very short sentences ever time you speak"
    
    def build_system_prompt(self):
        system_prompt = self.quest + ' ' + self.style
        return system_prompt

    def load_llm(self):
        self.llm = LLM(self.build_system_prompt())

    def load_artifact():
        pass
    
    def __call__(self, data):
        return self.llm(data)

class Agent:

    def __init__(self):

        self.llm = LLM("Guess the animal I am thinking about by asking questions.")

        self.options = "un string pidiendole opciones"
    
    def build_prompt(self, additional):
        r = f"{self.memory}{additional}"
        print(r)
        print(type(r))
        return r

    def decide_next_step(self):

        decision = self.llm(self.build_prompt(self.options))
        print(f'[Decision][{decision}]')

        if decision == '1':
            self.ask()
        elif decision == '2':
            self.guess()
        elif decision == '3':
            self.reflect()

    def prompt_user(self):
        return input('>')
    
    def ask(self):
        question = self.llm(self.build_prompt("Ask a short question"))
        self.memory.append(f'GPT: {question}')
        self.memory.append(f'User: {self.prompt_user()}')
        self.decide_next_step()
    
    def guess(self):
        guess = self.llm(self.build_prompt("Basing on all we know, guess an animal"))
        self.memory.append(f"GPT: {guess}")
        result = self.prompt_user()
        self.memory.append(f"User: {result}")
        if result == 'no':
            self.memory.append('Sys: Be careful, GPT. Only 2 guesses left.')
        self.decide_next_step()
    
    def reflect(self):
        reflection = self.llm(self.build_prompt("Reflect on the current situation"))
        self.memory.append(f'GPT: {reflection}')
        self.decide_next_step()
        


"""


















