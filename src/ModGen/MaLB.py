import json
import re
from datetime import datetime

from utils.datapipe import DataPipe
from utils.hline import hline

class MALB :

    descriptions_dir = '../InteractionApp/output/descriptions'

    def __init__(
        self,
        session: str = None
    ):
        # If no argument is inserted, session will be named as "mm.dd_hh.mm.ss"
        if not session:
            session = datetime.now().strftime("%m.%d_%H.%M.%S")
        self.set_session(str(session))

    def set_session(
        self,
        session: str
    ) -> None:
        if re.search(r'[<>:"/\\|?*]', session):
            raise ValueError("Session name contains prohibited characters.")
        self.session = session if session else ''
        self.set_dirs()
    
    def set_dirs(
        self
    ) -> None:
        self.dirs = {}

        # Initial conditions
        self.dirs['descriptions'] = f'../InteractionApp/output/descriptions'
        self.dirs['features'] = f'../InteractionApp/output/features'

        # Other directories
        self.dirs['contracts'] = f'generation_module/output/{self.session}/contracts'
        self.dirs['compiler'] = f'static_linting/output/{self.session}/compiler_execution_logs'
        self.dirs['solhint'] = f'static_linting/output/{self.session}/solhint_execution_logs'
    
    def generate_contracts(
        self,
        n_description: int = -1,
        n_contracts: int = 10,
        reasoning_technique: str = 'ZSGen',
        language_model: str = 'gpt-3.5-turbo-0125',
        contract_extension: str = 'sol',
        datetime_identifiers: bool = True,
        numeric_identifiers: bool = False,
        contract_prefix: str = 'contract'
    ) -> None:
        from generation_module.syntax_generator import SyntaxGenerator

        hline('Retrieving Initial Conditions') 
        self.initial_conditions = (
                DataPipe(self.dirs['descriptions']).load(n_description),
                DataPipe(self.dirs['features']).load(n_description)
            )
        
        hline('Setting up the generator') 
        syntax_generator = SyntaxGenerator(
            initial_conditions = self.initial_conditions,
            language_model=language_model,
            reasoning_technique=reasoning_technique,
            verbose_policy=3
        )

        hline('Setting the contract dump directory') 
        dp_contract_dump = DataPipe(
            self.dirs['contracts'],
            verbose_policy=0
        )

        hline('Generating and dumping contracts') 
        for i in range(n_contracts):

            print('~')

            code = syntax_generator.generate()

            if numeric_identifiers and datetime_identifiers:
                raise ValueError("Both numeric_identifiers and datetime_identifiers cannot be true at the same time.")

            if numeric_identifiers:
                dp_contract_dump.dump(
                    code,
                    filename=f'{contract_prefix}_{i}.{contract_extension}'
                )

            if datetime_identifiers:
                dp_contract_dump.dump(
                    code,
                    extension=contract_extension
                )
            
        print('~')

if __name__ == '__main__':

    main_thread = MALB(session='0125')

    main_thread.generate_contracts(
        reasoning_technique='ZSGen',
        language_model='gpt-3.5-turbo-0125',
        n_contracts = 2
    )



    
        

# ddp = DataPipe()
# ddp.set('../InteractionApp/output/descriptions')
# description = ddp.load(-1)

# fdp = DataPipe()
# fdp.set('../InteractionApp/output/features')
# features = fdp.load(-1)

# ### ZSGen Contract Generation --------------------------------------







# code = generate_syntax((description, features), reasoning='ZSGen')
# dp.set('generation_module/output/contracts')
# dp.dump(code, 'sol')

### Checker Execution ----------------------------------------------

# from static_linting.syntax_checker import SolidityCompiler
# compiler = SolidityCompiler(verbose_policy=1)

# from static_linting.solhint_analyzer import SolhintAnalyzer
# solhint = SolhintAnalyzer(verbose_policy=1)

# dp = DataPipe(verbose_policy=1)
# dp.set('generation_module/output/contracts')
# contracts = dp.fetch_all_files()

# compiler_pipe = DataPipe('static_linting/output/compiler_execution_log', verbose_policy=1)
# solhint_pipe = DataPipe('static_linting/output/solhint_execution_log', verbose_policy=1)

# n_contracts = len(contracts)
# n_contracts_compiled = 0

# contract_data = []

# for contract in contracts:

#     filename, source_code = contract.values()

#     data_point = {"length": len(source_code)}

#     compiler_report = compiler.compile(source_code)
#     compiler_pipe.dump(compiler_report, f"contract_{filename[:-4]}.json")

#     if compiler_report.success:

#         n_contracts_compiled += 1

#         solhint_report = solhint.analyze(source_code)
#         solhint_pipe.dump(solhint_report, f"solhint_{filename[:-4]}.json")

#         data_point["nerrors"] = solhint_report.nerrors
#         data_point["nwarnings"] = solhint_report.nwarnings
    
#     contract_data.append(data_point)

### Plotting ----------------------------------------------








# from static_linting.syntax_checker import CompilationReport
# from static_linting.solhint_analyzer import SolhintReport

# fetched_files = DataPipe('static_linting/output/compiler_execution_log').fetch_all_files()
# a = [CompilationReport(fetched_file.content) for fetched_file in fetched_files]

# fetched_files = DataPipe('static_linting/output/solhint_execution_log').fetch_all_files()
# compilation_reports = [SolhintReport(fetched_file.content) for fetched_file in fetched_files]









# import matplotlib.pyplot as plt
# import pandas as pd

# df = pd.DataFrame(contract_data)

# # Replace NaN values with 0 for nerrors and nwarnings
# df['nerrors'] = df['nerrors'].fillna(0).astype(int)
# df['nwarnings'] = df['nwarnings'].fillna(0).astype(int)

# # Plotting the data
# fig, ax1 = plt.subplots(figsize=(14, 8))

# # Length plot
# ax1.bar(df.index, df['length'], color='b', label='Length')
# ax1.set_xlabel('Contract Index')
# ax1.set_ylabel('Length', color='b')
# ax1.tick_params(axis='y', labelcolor='b')

# # Create a second y-axis for the errors and warnings
# ax2 = ax1.twinx()
# ax2.plot(df.index, df['nerrors'], color='r', marker='o', linestyle='-', label='Errors')
# ax2.plot(df.index, df['nwarnings'], color='g', marker='x', linestyle='--', label='Warnings')
# ax2.set_ylabel('Number of Errors/Warnings', color='r')
# ax2.tick_params(axis='y', labelcolor='r')

# # Add legend
# fig.legend(loc='upper right', bbox_to_anchor=(0.9, 0.9))

# plt.title('Contract Data: Length, Errors, and Warnings')
# plt.show()

# import numpy as np
# import pandas as pd
# import matplotlib.pyplot as plt
# import seaborn as sns
# from scipy.stats import ttest_ind, pearsonr, spearmanr, mannwhitneyu

# # Sample data for two sets
# data1 = contract_data[:16]
# data2 = contract_data[16:34]
# data2 = contract_data[34:]

# # Convert to DataFrame
# df1 = pd.DataFrame(data1)
# df2 = pd.DataFrame(data2)

# # Fill NaN values
# df1 = df1.fillna(0)
# df2 = df2.fillna(0)

# # Normalize errors and warnings
# df1['normalized_errors'] = df1['nerrors'] / df1['length']
# df1['normalized_warnings'] = df1['nwarnings'] / df1['length']
# df2['normalized_errors'] = df2['nerrors'] / df2['length']
# df2['normalized_warnings'] = df2['nwarnings'] / df2['length']

# # Descriptive Statistics
# desc1 = df1.describe()
# desc2 = df2.describe()

# # Correlation Analysis
# pearson_corr1, _ = pearsonr(df1['length'], df1['nerrors'])
# pearson_corr2, _ = pearsonr(df2['length'], df2['nerrors'])

# spearman_corr1, _ = spearmanr(df1['length'], df1['nerrors'])
# spearman_corr2, _ = spearmanr(df2['length'], df2['nerrors'])

# # Hypothesis Testing
# t_stat, p_value = ttest_ind(df1['length'], df2['length'])
# u_stat, p_value_mw = mannwhitneyu(df1['length'], df2['length'])

# # Regression Analysis
# # Assuming `statsmodels` is installed
# import statsmodels.api as sm

# X1 = sm.add_constant(df1['length'])
# y1 = df1['nerrors']
# model1 = sm.OLS(y1, X1).fit()

# X2 = sm.add_constant(df2['length'])
# y2 = df2['nerrors']
# model2 = sm.OLS(y2, X2).fit()

# # Visualizations
# plt.figure(figsize=(14, 8))

# # Histograms
# plt.subplot(2, 2, 1)
# sns.histplot(df1['length'], color='b', label='Set 1 Length', kde=True)
# sns.histplot(df2['length'], color='r', label='Set 2 Length', kde=True)
# plt.legend()

# plt.subplot(2, 2, 2)
# sns.histplot(df1['nerrors'], color='b', label='Set 1 Errors', kde=True)
# sns.histplot(df2['nerrors'], color='r', label='Set 2 Errors', kde=True)
# plt.legend()

# # Scatter Plots
# plt.subplot(2, 2, 3)
# plt.scatter(df1['length'], df1['nerrors'], color='b', label='Set 1')
# plt.scatter(df2['length'], df2['nerrors'], color='r', label='Set 2')
# plt.xlabel('Length')
# plt.ylabel('Errors')
# plt.legend()

# # Box Plots
# plt.subplot(2, 2, 4)
# sns.boxplot(data=[df1['length'], df2['length']], palette=['b', 'r'])
# plt.xticks([0, 1], ['Set 1', 'Set 2'])
# plt.ylabel('Length')

# plt.tight_layout()
# plt.show()











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


















