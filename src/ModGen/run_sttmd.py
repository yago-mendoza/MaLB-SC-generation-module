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
    def run_compiled_contracts_general_stats (
        cls
    ):
        """
        Analyzes general statistics of compiled smart contracts, including duplicates and distribution fitting.

        Workflow:
        1. Imports the `compiled_contracts_general_stats` function.
        2. Creates an `MALB` instance for the first session.
        3. Fetches all compiled contract files using `DataPipe`.
        4. Calls the `compiled_contracts_general_stats` function with the fetched contracts.

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

        from utils.sttmd.compiled_contracts_general_stats import compiled_contracts_general_stats
        session = cls.sessions[0]
        ablation_thread = MALB(session=session)

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contracts = DataPipe(
            ablation_thread.dirs['compiled_contracts']
        ).fetch_all_files()

        # 3. Running the analysis (only required args) -------------------------------

        compiled_contracts_general_stats(contracts)
    
    ##################################################################################

    @classmethod
    def run_multi_plotting_contract_lenghts(
        cls,
        norm_flags,
        lognorm_flags,
        hist_flags
    ):
        """
        Generates plots for contract lengths, fitting normal and log-normal distributions, and plotting histograms.

        Workflow:
        1. Imports the `multi_plotting_contract_lenghts` function.
        2. Creates an `MALB` instance for each session.
        3. Fetches all compiled contract files for each session using `DataPipe`.
        4. Calls the `multi_plotting_contract_lenghts` function with the fetched contract data and specified flags.

        Inputs:

            - contract_data_batches (list of lists): Batches of contract lengths.
            - norm_flags (list of bools): Flags indicating whether to fit a normal distribution for each batch.
            - lognorm_flags (list of bools): Flags indicating whether to fit a log-normal distribution for each batch.
            - hist_flags (list of bools): Flags indicating whether to plot a histogram for each batch.

        Outputs:

            Image Outputs:
            - Plot showing fitted normal and log-normal distributions, along with histograms of contract lengths.
              Dir: utils/sttmd/output_images/multi_plotting_contract_lenghts/

        """

        # 1. Importing the analysis program & creating threads -----------------------

        from utils.sttmd.multi_plotting_contract_lenghts import multi_plotting_contract_lenghts
        multi_plotting_threads = [MALB(session=session) for session in cls.sessions]

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contract_data_batches = [
            DataPipe(
                thread.dirs['compiled_contracts']
            ).fetch_all_files() for thread in multi_plotting_threads
        ]

        # 3. Running the analysis (only required args) -------------------------------

        multi_plotting_contract_lenghts(
            contract_length_data_batches=contract_data_batches,
            norm_flags=norm_flags,
            lognorm_flags=lognorm_flags,
            hist_flags=hist_flags,
        )

    @classmethod
    def run_compiled_contracts_linting_stats_and_plots(
        cls,
    ):
        """
        Analyzes linting reports of compiled smart contracts and generates statistics and visualizations.

        Workflow:
        1. Imports the `compiled_contracts_linting_stats_and_plots` function.
        2. Creates an `MALB` instance for the first session.
        3. Fetches all compiled contract files and analysis logs using `DataPipe`.
        4. Calls the `compiled_contracts_linting_stats_and_plots` function with the fetched session, contracts, and analysis logs.

        Inputs:

            - session (str): A session identifier used to organize and save the specific analysis results.
            - compiled_contracts (list): A list of compiled smart contracts.
            - dp_analysis_logs (list): A list of file paths to the Solhint analysis logs.

        Outputs:
        
            Console Outputs:
            1. Number of contracts analyzed.
            2. Total number of warnings.
            3. Mean (average) number of warnings per contract.
            4. Standard deviation of warnings.
            5. Total number of errors.
            6. Mean (average) number of errors per contract.
            7. Standard deviation of errors.
            8. Statistical summary of warnings and code length.
            9. Correlation matrix between code length and number of warnings.
            10. Summary of the linear regression model (OLS), including coefficients and fit measures.

            Image Outputs:
            - Scatter plot with a trend line showing the relationship between code length and number of warnings.
            Dir: utils/sttmd/output_images/compiled_contracts_linting_stats_and_plots/{session}

        """

        # 1. Importing the analysis program & creating threads -----------------------

        from ModGen.utils.sttmd.compiled_contracts_linting_stats_and_plots import compiled_contracts_linting_stats_and_plots
        session = cls.sessions[0]
        ablation_thread = MALB(session=session)

        """
        Displays some general statistics in the terminal, about the linting results for the given contracts.

        """

        # 2. Gathering args for the analysis (via threads) ---------------------------

        compiled_contracts =  DataPipe(
            ablation_thread.dirs['compiled_contracts']
        ).fetch_all_files()

        dp_analysis_logs = DataPipe(
            ablation_thread.dirs['analysis_logs'],
            verbose_policy=0
        ).fetch_all_files()

        # 3. Running the analysis (only required args) -------------------------------
        
        compiled_contracts_linting_stats_and_plots(session, compiled_contracts, dp_analysis_logs)

    @classmethod
    def run_plotting_warnings_throughout_length_sets(
        cls
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

        from utils.sttmd.plotting_warnings_throughout_length_sets import plotting_warnings_throughout_length_sets
        multi_plotting_threads = [MALB(session=session) for session in cls.sessions]

        # 2. Gathering args for the analysis (via threads) ---------------------------

        contract_sets = [
            DataPipe(
                thread.dirs['compiled_contracts']
            ).fetch_all_files() for thread in multi_plotting_threads
        ]

        # 3. Running the analysis (only required args) -------------------------------
        
        plotting_warnings_throughout_length_sets(contract_sets)

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
    session = ['0225', '0075']  # <<<

    sttmd = SttmdRunner()
    sttmd.set_sessions(session)


    ''' ~ Compiled contract lengths '''
    run_compiled_contracts_general_stats = False  # <<<

    # plots saved at 'utils/sttmd/output_images/.../'
    run_multi_plotting_contract_lenghts = False  # <<<
    norm_flags, lognorm_flags, hist_flags = [True], [True], [True]  # <<<

    
    ''' ~ Warnings and errors in the linting process '''
    # plots saved at 'utils/sttmd/output_images/.../session/'
    run_compiled_contracts_linting_stats_and_plots = False  # <<<

    
    ''' ~ Plotting warnings throughout length sets '''
    # plots saved at 'utils/sttmd/output_images/.../'
    run_plotting_warnings_throughout_length_sets = True  # <<<


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
    if run_compiled_contracts_general_stats:
        sttmd.run_compiled_contracts_general_stats()

    if run_multi_plotting_contract_lenghts:
        sttmd.run_multi_plotting_contract_lenghts(
            norm_flags,
            lognorm_flags,
            hist_flags
        )

    ''' ~ Warnings and errors in the linting process '''
    if run_compiled_contracts_linting_stats_and_plots:
        sttmd.run_compiled_contracts_linting_stats_and_plots()
    
    ''' ~ Plotting warnings throughout length sets '''
    if run_plotting_warnings_throughout_length_sets:
        sttmd.run_plotting_warnings_throughout_length_sets()