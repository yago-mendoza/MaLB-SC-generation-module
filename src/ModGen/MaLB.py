import json
import re
import random
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

        # Contracts save folder
        self.dirs['contracts'] = f'generation_module/output/{self.session}/contracts'

        # Compiler logs & Compiled contracts
        self.dirs['execution_log'] = f'static_linting/output/compiler/{self.session}/execution_log'
        self.dirs['compilation_logs'] = f'static_linting/output/compiler/{self.session}/compilation_logs'
        self.dirs['compiled_contracts'] = f'static_linting/output/compiler/{self.session}/compiled_contracts'

        # Solhint logs
        self.dirs['analysis_logs'] = f'static_linting/output/solhint/{self.session}/analysis_logs'
    
    def generate_contracts(
        self,
        n_description: int = -1,
        n_contracts: int = 10,
        reasoning_layer: str = 'ZSGen',
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
        hline(f'{reasoning_layer}_layer.py: loading endpoint libraries...') 
        syntax_generator = SyntaxGenerator(
            initial_conditions = self.initial_conditions,
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


if __name__ == '__main__':


    ############################################################
    ############################################################
    #                                                          #
    #                     TESTING (show-off)                   #
    #                                                          #
    ############################################################
    ############################################################


    session = '0225'  # ideally change with Reasoning Layers + conduct ablation

    main_thread = MALB(session=session)

    #####################
    # GENERATION ########
    #####################

    # > Creating brand-new smart contracts
    if False:
        main_thread.generate_contracts(
            reasoning_layer='ZSGen',
            language_model='gpt-3.5-turbo-0125',
            n_contracts = 100
        )

    #####################
    # COMPILATION #######
    #####################
    
    # > Seeing how many of them compile
    if False:
        main_thread.compile_contracts(
            analysis_coverage = 1.0
        )
        # results: static_linting/output/compiler/<session>
    
    #####################
    # LINTING ###########
    #####################

    # > Checking the contracts for warnings or errors
    if False:
        main_thread.analyze_contracts()
        # results: static_linting/output/solhint/<session>

    #####################
    # ASSESSMENT ########
    #####################

    # a) Assessment (que un agente decida si está bien o no, aunque tenemos el tema de los warnings)
    # b) Imaginar cómo lo exponere
    # c) ...

    

    ############################################################
    ############################################################
    #                                                          #
    #                          Ablation                        #
    #                                                          #
    ############################################################
    ############################################################


    # > Analyzing the contract lengths
    if False:
        """
        Displays some general statistics in the terminal, about the length distribution for the given contracts.
        """
        from utils.sttmd.contracts_stats import contracts_stats
        main_thread = MALB(session=session)
        contracts_stats(main_thread)
    
    # > Multi-plotting contract lengths
    if False:
        """
        I can generate multiple sets of contract source codes and compare
        them in a same graph, as either 'norm', 'lognorm' or 'hist',
        being able to target separatedly.
        """
        from utils.sttmd.contracts_plot import contracts_plot
        main_thread = MALB(session=session)

        contracts = DataPipe(
            main_thread.dirs['compiled_contracts']
        ).fetch_all_files()

        # more can be added, to compare different distributions
        contracts_plot(
            contracts_sets=[contracts],
            norm_flags=[True],
            lognorm_flags=[True],
            hist_flags=[True],
            main_thread=main_thread
        )

    # > Analyzing the contract lintings
    if True:
        """
        Displays some general statistics in the terminal, about the linting results for the given contracts.
        """
        from utils.sttmd.solhint_breakdown import solhint_breakdown
        main_thread = MALB(session=session)
        solhint_breakdown(main_thread)

        






        



















