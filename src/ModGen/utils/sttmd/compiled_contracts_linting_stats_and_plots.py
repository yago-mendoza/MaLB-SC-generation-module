from utils.datapipe import DataPipe
from static_linting.solhint_analyzer import SolhintReport

from pathlib import Path
import random
import datetime
import os

import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import statsmodels.api as sm

savefig_path = f'utils/'                                      \
               'sttmd/'                                       \
               'output_images/'                               \
               'compiled_contracts_linting_stats_and_plots/'  \
               '{session}'

def compiled_contracts_linting_stats_and_plots(session, compiled_contracts, dp_analysis_logs):

    global savefig_path
    savefig_path = Path(savefig_path.format(session=session))

    # We import the reports using the SolhintReport class
    reports = [SolhintReport(fetched_file) for fetched_file in dp_analysis_logs]

    # Number of contracts
    num_contracts = len(reports)

    # Number of warnings and errors
    total_warnings = sum(report.nwarnings for report in reports)
    total_errors = sum(report.nerrors for report in reports)

    # Mean (mu) of warnings and errors
    mean_warnings = total_warnings / num_contracts
    mean_errors = total_errors / num_contracts

    # Standard deviation (std) of warnings and errors
    std_warnings = (sum((report.nwarnings - mean_warnings)**2 for report in reports) / num_contracts)**0.5
    std_errors = (sum((report.nerrors - mean_errors)**2 for report in reports) / num_contracts)**0.5

    print("\nNumber of contracts analyzed:", num_contracts)
    print("Total number of warnings:", total_warnings)
    print("Mean (mu) of warnings:", mean_warnings)
    print("Standard deviation (std) of warnings:", std_warnings)
    print("Total number of errors:", total_errors)
    print("Mean (mu) of errors:", mean_errors)
    print("Standard deviation (std) of errors:", std_errors)
    print('')

    df = pd.DataFrame({
        "nwarnings": [report.nwarnings for report in reports],
        "code_length": [len(contract) for contract in compiled_contracts]
    })

    # Statistical Summary
    summary = df.describe()
    print("Statistical Summary:")
    print(summary)

    # Correlation Analysis
    correlation = df.corr()
    print("\nCorrelation:")
    print(correlation)

    # Visualization Enhancements
    sns.set(style="whitegrid")
    plt.figure(figsize=(10, 6))

    sns.scatterplot(x="code_length", y="nwarnings", data=df, s=100)
    sns.regplot(x="code_length", y="nwarnings", data=df, scatter=False, color='blue')

    plt.title("Scatter plot with trend line")
    plt.xlabel("Code Length")
    plt.ylabel("Number of Warnings")

    # Modeling
    X = df["code_length"]
    y = df["nwarnings"]
    X = sm.add_constant(X)  # Adds a constant term to the predictor

    model = sm.OLS(y, X).fit()
    predictions = model.predict(X) 

    print("\nModel Summary:")
    print(model.summary())


    # Save the figure to the path specified at the top
    ####################################################
    if not savefig_path.exists():
        savefig_path.mkdir(parents=True, exist_ok=True)
    filename = datetime.now().strftime("%m.%d_%H.%M.%S")
    plt.savefig(savefig_path / f"{filename}.png")
    ####################################################

    plt.show()

