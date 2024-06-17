############################################################
############################################################
#                                                          #
#                          Ablation                        #
#                                                          #
############################################################
############################################################

from run_MaLB import MALB
from utils.datapipe import DataPipe

class SttmdRunner:

    ##################################################################################
    # Analysis Methods
    # These class methods call analysis functions from utils.sttmd. Each method:
    # - Imports the necessary analysis function.
    # - Initializes a thread to gather inputs.
    # - Fetches required data using DataPipe.
    # - Calls the analysis function with the gathered data and session information.
    # Some methods pass the session to the analysis function for 'savefig' purposes.
    ##################################################################################

    sessions = []
    @classmethod
    def set_sessions(cls, sessions):
        if isinstance(sessions, str):
            cls.sessions.append(sessions)
        elif isinstance(sessions, list):
            cls.sessions.extend(sessions)
    
    @classmethod
    def run_compiled_contract_lengths_stats (
        cls
    ):
        """
        Analyzes general statistics of compiled smart contracts, including duplicates and distribution fitting.

        Workflow:
        1. Imports the `compiled_contract_lengths_stats` function.
        2. Creates an `MALB` instance for the first session.
        3. Fetches all compiled contract files using `DataPipe`.
        4. Calls the `compiled_contract_lengths_stats` function with the fetched contracts.

        Inputs:

            - contracts (list): A list of compiled smart contracts.

        Outputs:
        
            Console Outputs:
            1. Number of duplicate contracts.
            2. Percentage of duplicate contracts.
            3. Mean contract length.
            4. Standard deviation of contract length.
            5. Results of the Kolmogorov-Smirnov test for normal distribution:
            - KS p-value for normal distribution.
            - Indication of whether the data follows a normal distribution.
            - Confidence interval for mean contract length (if data follows normal distribution).
            6. Results of the Kolmogorov-Smirnov test for log-normal distribution:
            - Shape, location, and scale parameters for log-normal distribution.
            - KS p-value for log-normal distribution.
            - Indication of whether the data follows a log-normal distribution.

            Image Outputs:
            - (No image outputs in this function.)

        """

        # 1. Importing the analysis program & creating threads -----------------------

        from utils.sttmd.compiled_contract_lengths_stats import compiled_contract_lengths_stats
        session = cls.sessions[0]
        ablation_thread = MALB(session=session)

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contracts = DataPipe(
            ablation_thread.dirs['compiled_contracts'],
            verbose_policy=0
        ).fetch_all_files()

        # 3. Running the analysis (only required args) -------------------------------

        compiled_contract_lengths_stats(contracts)
    
    ##################################################################################

    @classmethod
    def run_compiled_contract_lengths_distributions(
        cls,
        norm_flags,
        lognorm_flags,
        hist_flags,
        labels
    ):
        """
        Generates plots for contract lengths, fitting normal and log-normal distributions, and plotting histograms.

        Workflow:
        1. Imports the `multi_plotting_contract_lenghts` function.
        2. Creates an `MALB` instance for each session.
        3. Fetches all compiled contract files for each session using `DataPipe`.
        4. Calls the `multi_plotting_contract_lenghts` function with the fetched contract data and specified flags.

        Inputs:

            - contract_sets (list of lists): Batches of contract lengths.
            - norm_flags (list of bools): Flags indicating whether to fit a normal distribution for each batch.
            - lognorm_flags (list of bools): Flags indicating whether to fit a log-normal distribution for each batch.
            - hist_flags (list of bools): Flags indicating whether to plot a histogram for each batch.

        Outputs:

            Image Outputs:
            - Plot showing fitted normal and log-normal distributions, along with histograms of contract lengths.
              Dir: utils/sttmd/output_images/multi_plotting_contract_lenghts/

        """

        # 1. Importing the analysis program & creating threads -----------------------

        from utils.sttmd.compiled_contract_lengths_distributions import compiled_contract_lengths_distributions
        multi_plotting_threads = [MALB(session=session) for session in cls.sessions]

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contract_sets = [
            DataPipe(
                thread.dirs['compiled_contracts'],
                verbose_policy=0
            ).fetch_all_files() for thread in multi_plotting_threads
        ]

        # 3. Running the analysis (only required args) -------------------------------

        compiled_contract_lengths_distributions(
            contract_sets=contract_sets,
            norm_flags=norm_flags,
            lognorm_flags=lognorm_flags,
            hist_flags=hist_flags,
            labels=labels
        )
    
    @classmethod
    def run_compiled_contracts_linting_stats(
        cls
    ):
        """
        Analyzes linting reports of compiled smart contracts and generates general statistics.

        Workflow:
        1. Imports the `compiled_contracts_linting_stats` function.
        2. Creates an `MALB` instance for the first session.
        3. Fetches all compiled contract files and analysis logs using `DataPipe`.
        4. Calls the `compiled_contracts_linting_stats` function with the fetched contracts and analysis logs.

        Inputs:

            - compiled_contracts (list): A list of compiled smart contracts.
            - analysis_logs (list): A list of file paths to the Solhint analysis logs.

        """

        # 1. Importing the analysis program & creating threads -----------------------

        from utils.sttmd.compiled_contracts_linting_stats import compiled_contracts_linting_stats
        session = cls.sessions[0]
        ablation_thread = MALB(session=session)

        # 2. Gathering args for the analysis (via threads) ---------------------------

        compiled_contracts = DataPipe(
            ablation_thread.dirs['compiled_contracts'],
            verbose_policy=0
        ).fetch_all_files()

        analysis_logs = DataPipe(
            ablation_thread.dirs['analysis_logs'],
            verbose_policy=0
        ).fetch_all_files()

        # 3. Running the analysis (only required args) -------------------------------

        compiled_contracts_linting_stats(
            compiled_contracts=compiled_contracts,
            analysis_logs=analysis_logs
        )

    @classmethod
    def run_compiled_contracts_warning_plots_1(
        cls,
        labels
    ):
        """
        Analyzes linting reports of compiled smart contracts and generates statistics and visualizations.

        Workflow:
        1. Imports the `compiled_contracts_linting_plots` function.
        2. Creates an `MALB` instance for the first session.
        3. Fetches all compiled contract files and analysis logs using `DataPipe`.
        4. Calls the `compiled_contracts_linting_plots` function with the fetched session, contracts, and analysis logs.

        Inputs:

            - compiled_contracts (list): A list of compiled smart contracts.
            - analysis_logs (list): A list of file paths to the Solhint analysis logs.
            - labels (list): A list of labels for the plots.

        """

        # 1. Importing the analysis program & creating threads -----------------------

        from utils.sttmd.compiled_contracts_warning_plots_1 import compiled_contracts_warning_plots_1
        multi_plotting_threads = [MALB(session=session) for session in cls.sessions]

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contract_sets = [
            DataPipe(
                thread.dirs['compiled_contracts'],
                verbose_policy=0
            ).fetch_all_files() for thread in multi_plotting_threads
        ]

        analysis_logs_list_sets = [
            DataPipe(
                thread.dirs['analysis_logs'],
                verbose_policy=0
            ).fetch_all_files() for thread in multi_plotting_threads
        ]

        # 3. Running the analysis (only required args) -------------------------------
        
        compiled_contracts_warning_plots_1(
            contract_sets=contract_sets,
            analysis_logs_list_sets=analysis_logs_list_sets,
            labels=labels
        )

    @classmethod
    def run_compiled_contracts_warning_plots_2(
        cls,
        labels
    ):
        """
        Takes multiple sets of contracts, sorts them by length, divides them into 4 equally sized parts, calculates the mean number of errors for each part, and plots the results.

        Workflow:
        1. Initializes a thread to gather inputs.
        2. Fetches all compiled contract files using `DataPipe`.
        3. Splits contracts into 4 parts based on their lengths.
        4. Calculates the mean number of errors for each part.
        5. Plots these means linked by lines.

        Inputs:

            - contract_sets (list of lists of str): Each set is a list of contract strings.

        Outputs:
        
            Console Outputs:
            - Mean number of errors for each part.
            
            Image Outputs:
            - Plot showing the mean number of errors for each part across multiple sets.
              Dir: utils/sttmd/output_images/plotting_warnings_throughout_length_sets/
        """

        # 1. Importing the analysis program & creating threads -----------------------

        from utils.sttmd.compiled_contracts_warning_plots_2 import compiled_contracts_warning_plots_2
        multi_plotting_threads = [MALB(session=session) for session in cls.sessions]

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contract_sets = [
            DataPipe(
                thread.dirs['compiled_contracts'],
                verbose_policy=0
            ).fetch_all_files() for thread in multi_plotting_threads
        ]

        # 3. Running the analysis (only required args) -------------------------------
        
        compiled_contracts_warning_plots_2(
            contract_sets=contract_sets,
            labels=labels
        )

if __name__ == '__main__':

    ############################################################
    ############################################################
    #                                                          #
    #                          Ablation                        #
    #                                                          #
    ############################################################
    ############################################################

    # [!] Print useful statistical results in the terminal
    # [!] Generate plots


    ''' ~ Targeting sessions for analysis '''
    session = ['7501', '7502', '7503']  # <<< (used for labeling plots)

    sttmd = SttmdRunner()
    sttmd.set_sessions(session) # for creating threads to gather data
    

    ''' ~ Compiled contract lengths '''
    run_compiled_contract_lengths_stats = False  # <<<

    # [!] Supports +1 session plotting
    # # plots saved at 'utils/sttmd/output_images/.../'
    run_compiled_contract_lengths_distributions = False  # <<<
    norm_flags, lognorm_flags, hist_flags = [True], [True], [True]  # <<<

    
    ''' ~ Warnings and errors in the linting process '''
    run_compiled_contracts_linting_stats = False  # <<<

    # [!] Supports +1 session plotting
    # plots saved at 'utils/sttmd/output_images/.../'
    run_compiled_contracts_warning_plots_1 = True  # <<<

    
    ''' ~ Plotting warnings throughout length sets '''
    # [!] Supports +1 session plotting
    # plots saved at 'utils/sttmd/output_images/.../'
    run_compiled_contracts_warning_plots_2 = False  # <<<


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

    ''' ~ Compiled contract lengths '''    
    if run_compiled_contract_lengths_stats:
        sttmd.run_compiled_contract_lengths_stats()

    if run_compiled_contract_lengths_distributions:
        sttmd.run_compiled_contract_lengths_distributions(
            norm_flags=norm_flags,
            lognorm_flags=lognorm_flags,
            hist_flags=hist_flags,
            labels=session
        )

    ''' ~ Warnings and errors in the linting process '''
    if run_compiled_contracts_linting_stats:
        sttmd.run_compiled_contracts_linting_stats() 

    if run_compiled_contracts_warning_plots_1:
        sttmd.run_compiled_contracts_warning_plots_1(labels=session)
    
    ''' ~ Plotting warnings throughout length sets '''
    if run_compiled_contracts_warning_plots_2:
        sttmd.run_compiled_contracts_warning_plots_2(labels=session)