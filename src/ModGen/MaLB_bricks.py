import re
import random
from datetime import datetime

from utils.datapipe import DataPipe
from utils.hline import hline

from typing import (
    List,
    Dict,
    Any,
    Tuple

)


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

    def get_initial_conditions(
        self,
        n_description: int = -1
    ) -> Tuple[str, List[Dict[str, Any]]]:
        hline('Retrieving Initial Conditions') 
        return (
            DataPipe(self.dirs['descriptions']).load(n_description),
            DataPipe(self.dirs['features']).load(n_description)
        )
    
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
        self.dirs['surveys'] = f'output/{self.session}/alignment/surveys'
        self.dirs['filled_surveys'] = f'output/{self.session}/alignment/filled_surveys'
        self.dirs['alignment_logs'] = f'output/{self.session}/alignment/alignment_logs'

    def generate_contracts(
        self,
        n_description: int = -1,
        n_contracts: int = 10,
    
        language_model: str = 'gpt-3.5-turbo-0125',
        reasoning_layer: str = 'ZSGen',
        verbose_policy: int = 3,

        contract_extension: str = 'sol',
        datetime_identifiers: bool = True,
        numeric_identifiers: bool = False,
        contract_prefix: str = 'contract',

        hints = None

    ) -> None:
        from generation_module.syntax_generator import SyntaxGenerator
        
        hline('Setting up the generator') 
        hline(f'{reasoning_layer}_layer.py: loading endpoint libraries...') 
        syntax_generator = SyntaxGenerator(
            initial_conditions = self.get_initial_conditions(n_description),
            language_model=language_model,
            reasoning_layer=reasoning_layer,
            verbose_policy=verbose_policy
        )

        hline('Setting the contract dump directory') 
        dp_contract_dump = DataPipe(
            self.dirs['contracts'],
            verbose_policy=verbose_policy
        )

        hline('Generating and dumping contracts') 
        for i in range(n_contracts):
            hline(f'Contract {i+1}/{n_contracts}')

            code = syntax_generator.generate(hints=hints)

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
        analysis_coverage: float = 1.0,
        verbose_policy: int = 3
    ):
        from static_linting.syntax_checker import SolidityCompiler

        hline('Setting compiler environment') 
        compiler = SolidityCompiler(verbose_policy=verbose_policy)

        source_codes = DataPipe(
            self.dirs['contracts'],
            verbose_policy=verbose_policy
        ).fetch_all_files()

        source_codes = random.sample(
            source_codes,
            max(1, int(analysis_coverage * len(source_codes)))
        )

        dp_compiler_logs = DataPipe(
            self.dirs['compilation_logs'],
            verbose_policy=verbose_policy
        )

        dp_compiled_contracts = DataPipe(
            self.dirs['compiled_contracts'],
            verbose_policy=verbose_policy
        )

        dp_execution_log = DataPipe(
            self.dirs['execution_log'],
            verbose_policy=verbose_policy
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
        verbose_policy: int = 3
    ):
        from static_linting.solhint_analyzer import SolhintAnalyzer

        hline('Setting up the Solhint environment')
        solhint = SolhintAnalyzer(verbose_policy=verbose_policy)

        source_codes = DataPipe(
            self.dirs['compiled_contracts'],
            verbose_policy=verbose_policy
        ).fetch_all_files()

        dp_analysis_logs = DataPipe(
            self.dirs['analysis_logs'],
            verbose_policy=verbose_policy
        )

        dp_execution_log = DataPipe(
            self.dirs['execution_log'],
            verbose_policy=verbose_policy
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
        n_compiled_smart_contract: int = -1,
        gpt_openai_model: str = 'gpt-3.5-turbo-0125',
        temperature = 0.5,
        max_tokens = 300,
        view_points = 3,
        n_chunks = 5,
        verbose_policy: int = 3
    ):
        from alignment_module.inquisition.alignment_inquisitor import Inquisitor
        from alignment_module.scrutiny.alignment_scrutineer import Scrutineer


        hline('Setting up Inquisitor...')

        inquisitor = Inquisitor(
            gpt_openai_model=gpt_openai_model,
            temperature=temperature,
            max_tokens=max_tokens,
            verbose_policy=verbose_policy    
        )

        survey = inquisitor.formulate_questions(
            initial_conditions=self.get_initial_conditions(n_description)
        )

        DataPipe(
            self.dirs['surveys'], verbose_policy=verbose_policy
        ).dump(survey, extension='json')


        hline('Setting up Scrutineers...')

        base_scrutineer = Scrutineer(
            gpt_openai_model=gpt_openai_model,
            temperature=temperature,
            max_tokens=max_tokens,
            verbose_policy=verbose_policy
        )
        base_scrutineer.set_config(n_chunks=n_chunks)

        # Generate multiple scrutineers
        scrutineer_instances = base_scrutineer.clone(view_points)

        source_code = DataPipe(
            self.dirs['compiled_contracts'],
            verbose_policy=verbose_policy
        ).load(n_compiled_smart_contract)

        filled_survey = {question: [] for key in survey.keys() for question in survey[key]}

        questions = [question for key in survey.keys() for question in survey[key]]
        for i, scrutineer in enumerate(scrutineer_instances):
            hline(f'Scrutineer {i+1}/{len(scrutineer_instances)}')
            
            verdicts = scrutineer.fill_survey(
                source_code=source_code,
                questions=random.sample(questions, k=len(questions))
            )

            for question, answer in zip(questions, verdicts):
                filled_survey[question].append(answer)

        DataPipe(
            self.dirs['filled_surveys'], verbose_policy=verbose_policy
        ).dump(filled_survey, extension='json')

        # Execution Log

        log_data = {
            "true_density": 0,
            "pure_true": 0
        }
        
        true_density, pure_true = [], []
        for question, verdicts in filled_survey.items():
            true_density.append(verdicts.count(True) / len(verdicts))
            pure_true.append(1 if all(verdicts) else 0)

        log_data = {
            "true_density": sum(true_density) / len(true_density),
            "pure_true": sum(pure_true) / len(pure_true)
        }

        DataPipe(
            self.dirs["alignment_logs"],
            verbose_policy=verbose_policy
        ).dump(log_data, extension='json')
    



   

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

    # Note. In the future, these should be set via at a YAML, and
    # be accessible for every instance independently, instead of
    # being passed as sequential function arguments.

    # [!] Generates files for different production phases
    # [!] These are ".SOL" source code, ".JSON" logs, ...

    language_model = 'gpt-3.5-turbo-0125'
    n_description = -1
    verbose_policy = 3

    ''' ~ Targeting sessions for analysis '''
    session = '7503'  # <<<

    main_thread = MALB(session=session)


    ''' ~ Generation of brand-new smart contracts
    Results
    - contracts: output/{self.session}/generation/contracts
    '''
    generate_contracts = False
    n_contracts = 75
    reasoning_layer = 'ZSGen'
    hints = []


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

    gpt_openai_model = 'gpt-3.5-turbo-1106'  # or gpt-4-1106-preview
    temperature = 0.5
    max_tokens = 300

    n_compiled_smart_contract = -1
    view_points = 4
    n_chunks = 5


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
            hints=hints,
            verbose_policy=verbose_policy
                 
        )

    if compile_contracts:
        main_thread.compile_contracts(
            analysis_coverage = analysis_coverage
        )
        
    if analyze_contracts:
        main_thread.analyze_contracts(
            verbose_policy=verbose_policy
        )


    if align_contracts:
        main_thread.assess_alignment(
            n_description=n_description,
            n_compiled_smart_contract=n_compiled_smart_contract,
            gpt_openai_model=gpt_openai_model,
            temperature=temperature,
            max_tokens=max_tokens,
            view_points=view_points,
            n_chunks=n_chunks,
            verbose_policy=verbose_policy
        )






        



















