import re
import random
from datetime import datetime

from utils.datapipe import DataPipe
from utils.hline import hline

class MALB :

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

        # Contracts save folder
        self.dirs['contracts'] = f'output/{self.session}/generation/generated_contracts'

        # Compiler logs & Compiled contracts
        self.dirs['execution_log'] = f'output/{self.session}/compiler/execution_log'
        self.dirs['compilation_logs'] = f'output/{self.session}/compiler/compilation_logs'
        self.dirs['compiled_contracts'] = f'output/{self.session}/compiler/compiled_contracts'

        # Solhint logs
        self.dirs['analysis_logs'] = f'output/{self.session}/solhint/analysis_logs'
    
        # Alignment assessment
        self.dirs['alignment_questions'] = f'output/{self.session}/alignment/alignment_questions'

    def generate_contracts(
        self,
        n_description: int = -1,
        n_contracts: int = 10,

        contract_extension: str = 'sol',
        datetime_identifiers: bool = True,
        numeric_identifiers: bool = False,
        contract_prefix: str = 'contract',
    
        language_model: str = 'gpt-3.5-turbo-0125',
        reasoning_layer: str = 'ZSGen',
        verbose_policy: int = 3
    ) -> None:
        from generation_module.syntax_generator import SyntaxGenerator

        hline('Retrieving Initial Conditions') 
        initial_conditions = (
            DataPipe(self.dirs['descriptions']).load(n_description),
            DataPipe(self.dirs['features']).load(n_description)
        )
        
        hline('Setting up the generator') 
        hline(f'{reasoning_layer}_layer.py: loading endpoint libraries...') 
        syntax_generator = SyntaxGenerator(
            initial_conditions = initial_conditions,
            language_model=language_model,
            reasoning_layer=reasoning_layer,
            verbose_policy=3
        )

        hline('Setting the contract dump directory') 
        dp_contract_dump = DataPipe(
            self.dirs['contracts'],
            verbose_policy=0
        )

        hline('Generating and dumping contracts') 
        for i in range(n_contracts):
            hline(f'Contract {i+1}/{n_contracts}')

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

    def compile_contracts(
        self,
        analysis_coverage: float = 1.0
    ):
        from static_linting.syntax_checker import SolidityCompiler

        hline('Setting compiler environment') 
        compiler = SolidityCompiler(verbose_policy=1)

        source_codes = DataPipe(
            self.dirs['contracts'],
            verbose_policy=0
        ).fetch_all_files()

        source_codes = random.sample(
            source_codes,
            max(1, int(analysis_coverage * len(source_codes)))
        )

        dp_compiler_logs = DataPipe(
            self.dirs['compilation_logs'],
            verbose_policy=0
        )

        dp_compiled_contracts = DataPipe(
            self.dirs['compiled_contracts'],
            verbose_policy=0
        )

        dp_execution_log = DataPipe(
            self.dirs['execution_log'],
            verbose_policy=0
        )

        hline('Compiling contracts')

        n_success = 0
        for i, source_code in enumerate(source_codes):

            hline(f'Contract {i+1}/{len(source_codes)}')

            compiler.compile(source_code)
            dp_compiler_logs.dump(
                compiler.report,
                extension="json"
            )

            if compiler.report.success:
                n_success += 1

                dp_compiled_contracts.dump(
                    source_code,
                    extension="sol"
                )
        
        dp_execution_log.dump(
            {
                "n_contracts": len(source_codes),
                "n_success": n_success,
                "n_failure": len(source_codes) - n_success,
                "success_rate": round(n_success / len(source_codes), 4)
            },
            extension="json"
        )
    
    def analyze_contracts(
        self,   
    ):
        from static_linting.solhint_analyzer import SolhintAnalyzer

        hline('Setting up the Solhint environment')
        solhint = SolhintAnalyzer(verbose_policy=1)

        source_codes = DataPipe(
            self.dirs['compiled_contracts'],
            verbose_policy=0
        ).fetch_all_files()

        dp_analysis_logs = DataPipe(
            self.dirs['analysis_logs'],
            verbose_policy=0
        )

        dp_execution_log = DataPipe(
            self.dirs['execution_log'],
            verbose_policy=0
        )

        hline('Analyzing contracts')
        for i, source_code in enumerate(source_codes):
                
            hline(f'Contract {i+1}/{len(source_codes)}')

            solhint.analyze(source_code)
            dp_analysis_logs.dump(
                solhint.report,
                extension="json"
            )
    
    def assess_alignment(
        self,
        n_description: int = -1,
        # contracts or index for contracts to analyse <<<<<<<<<<<<<<<<<<<<
        verbose_policy: int = 3,

        gpt_openai_model: str = 'gpt-3.5-turbo-0125',
        temperature = 0.5,
        max_tokens = 300,
        feature_nquestions: int = 4,
        view_points: int = 3
    ):
        from alignment_module.alignment_assessor import AlignmentAssessor

        hline('Retrieving Initial Conditions') 
        initial_conditions = (
            DataPipe(self.dirs['descriptions']).load(n_description),
            DataPipe(self.dirs['features']).load(n_description)
        )

        hline('Setting up the assessor')
        hline('alignment_assessor.py: loading DSPy...') 
        alignment_assessor = AlignmentAssessor(
            initial_conditions = initial_conditions,
            gpt_openai_model=gpt_openai_model,
            temperature=temperature,
            max_tokens=max_tokens,
            view_points=view_points,
            feature_nquestions=feature_nquestions,
            verbose_policy=verbose_policy    
        )
        
        hline('Setting the questions dump directory') 
        dp_contract_dump = DataPipe(
            self.dirs['alignment_questions'],
            verbose_policy=0
        )

        hline('Generating and dumping questions') 
        questions = alignment_assessor.formulate_questions()

        dp_contract_dump.dump(
            questions,
            extension="json"
        )

        # Necesitarás poner como input de "assess_alingment" si referirte a un contrato particular, a todos, o como
        # porque las questions son para todo, generales del run, vale
        # pero luego los que las rpesonden las repsnderán en base a CADA contrato

        # Y ahora tocaría responder las preguntas...

        # class FactJudge(dspy.Signature):
        #     """Judge if the answer is factually correct based on the context."""

        #     context = dspy.InputField(desc="Context for the prediciton")
        #     question = dspy.InputField(desc="Question to be answered")
        #     answer = dspy.InputField(desc="Answer for the question")
        #     factually_correct = dspy.OutputField(desc="Is the answer factually correct based on the context?", prefix="Factual[Yes/No]:")

        # judge = dspy.ChainOfThought(FactJudge)

        # def factuality_metric(example, pred):
        #     factual = judge(context=example.context, question=example.question, answer=pred.answer)
        #     return int(factual=="Yes")

        # source_codes = DataPipe(
        #     self.dirs['compiled_contracts'],
        #     verbose_policy=0
        # ).fetch_all_files()




if __name__ == '__main__':


    ############################################################
    ############################################################
    #                                                          #
    #                     TESTING (show-off)                   #
    #                                                          #
    ############################################################
    ############################################################

    # [!] Generates files for different production phases
    # [!] These are ".SOL" source code, ".JSON" logs, ...

    language_model = 'gpt-3.5-turbo-0125'
    n_description = -1
    verbose_policy = 3

    ''' ~ Targeting sessions for analysis '''
    session = '7501'  # <<<

    main_thread = MALB(session=session)


    ''' ~ Generation of brand-new smart contracts
    Results
    - contracts: output/{self.session}/generation/contracts
    '''
    generate_contracts = False
    n_contracts = 75
    reasoning_layer = 'ZSGen'


    ''' ~ Seeing how many smart contracts compile
    Results:
    - compilation_logs: output/<session>/compiler/compilation_logs
    - compiled_contracts: output/<session>/compiler/compiled_contracts
    - execution_log: output/<session>/compiler/execution_log
    '''
    compile_contracts = False
    analysis_coverage = 1.0


    ''' ~ Checking the contracts for warnings or errors
    Results:
    - analysis_logs: output/<session>/solhint/analysis_logs
    '''
    analyze_contracts = False


    ''' ~ Assessing the alignment between description contracts 
    Results:
    - alignment_questions: output/<session>/alignment/alignment_questions
    '''
    align_contracts = True
    feature_nquestions = 4
    view_points = 3
    gpt_openai_model = 'gpt-3.5-turbo-1106'  # or gpt-4-1106-preview
    temperature = 0.5
    max_tokens = 300


    ##################################################################################
    ##############################
    ###########################
    ########################
    #####################
    ##################
    ###############
    ############
    #########
    ######
    ###

    if generate_contracts:
        main_thread.generate_contracts(
            n_description=n_description,
            n_contracts = n_contracts,
            language_model=language_model,
            reasoning_layer=reasoning_layer,
            verbose_policy=verbose_policy            
        )

    if compile_contracts:
        main_thread.compile_contracts(
            analysis_coverage = analysis_coverage
        )
        
    if analyze_contracts:
        main_thread.analyze_contracts()

    if align_contracts:
        main_thread.assess_alignment(
            n_description=n_description,
            gpt_openai_model=gpt_openai_model,
            temperature=temperature,
            max_tokens=max_tokens,
            feature_nquestions=feature_nquestions,
            view_points=view_points,
            verbose_policy=verbose_policy
        )











    #####################
    # ASSESSMENT ########
    #####################


    # AUI YAGO YAGO
    # AUI YAGO YAGO
    # AUI YAGO YAGO
    # AUI YAGO YAGO
    # AUI YAGO YAGO
    # AUI YAGO YAGO


    # a) Assessment (que un agente decida si está bien o no, aunque tenemos el tema de los warnings)
    # b) Imaginar cómo lo exponere
    # c) ...



    

# reducir '''solidity ''' en los generados y ver como afecta a la compialcion

# hacer la gracia esa escalera de coger 4 cuartiles segun longitud y graficar error medio para cada un (recta ascendiente)
# y puedo comparar modelos por ejemplo, es bastante buena

# para analsisi, primero generar los muchos datos
# luego, hacer carpeta de graficasión

# probar nuevos tipos de generación, more like ZSGen_layer 

# "Hierarchical Task Networks "
# "https://arxiv.org/pdf/2406.04784"

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





        



















