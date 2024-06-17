from static_linting.solhint_analyzer import SolhintReport
import pandas as pd

def compiled_contracts_linting_stats(
    compiled_contracts,
    analysis_logs
):
    reports = [SolhintReport(fetched_file) for fetched_file in analysis_logs]
    num_contracts = len(reports)

    total_warnings = sum(report.nwarnings for report in reports)
    total_errors = sum(report.nerrors for report in reports)

    mean_warnings = total_warnings / num_contracts
    mean_errors = total_errors / num_contracts

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

    summary = df.describe()
    print("Statistical Summary:")
    print(summary)

    correlation = df.corr()
    print("\nCorrelation:")
    print(correlation)

    return df
