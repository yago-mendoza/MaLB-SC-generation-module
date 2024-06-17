from static_linting.solhint_analyzer import SolhintReport
from pathlib import Path
from datetime import datetime
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import statsmodels.api as sm

savefig_path = Path('utils/sttmd/output_images/compiled_contracts_warning_plots/g1')

def compiled_contracts_warning_plots_1(contract_sets, analysis_logs_list_sets, labels):
    global savefig_path

    if len(labels) != len(contract_sets):
        raise ValueError("The number of labels must match the number of contract sets")

    total_reports = []
    total_compiled_contracts = []
    contract_set_lengths = []

    for compiled_contracts, dp_analysis_logs in zip(contract_sets, analysis_logs_list_sets):
        reports = [SolhintReport(fetched_file) for fetched_file in dp_analysis_logs]
        total_reports.extend(reports)
        total_compiled_contracts.extend(compiled_contracts)
        contract_set_lengths.append(len(compiled_contracts))

    df = pd.DataFrame({
        "nwarnings": [report.nwarnings for report in total_reports],
        "code_length": [len(contract) for contract in total_compiled_contracts],
        "contract_set_label": sum([[label] * length for label, length in zip(labels, contract_set_lengths)], [])
    })

    sns.set(style="whitegrid")
    plt.figure(figsize=(10, 6))

    colors = sns.color_palette("muted", len(labels))

    for label, color in zip(labels, colors):
        subset = df[df["contract_set_label"] == label]
        sns.scatterplot(
            x=subset["code_length"],
            y=subset["nwarnings"],
            label=label,
            s=50,
            alpha=0.85,
            color=color
        )

        X = subset["code_length"]
        y = subset["nwarnings"]
        X = sm.add_constant(X)
        
        model = sm.OLS(y, X).fit()
        predictions = model.predict(X)

        sns.lineplot(
            x=subset["code_length"],
            y=predictions,
            color=color,
            alpha=1.0
        )  # Coincidir color con los puntos

        print(f"\nModel Summary for {label}:")
        print(model.summary())

    plt.title("Scatter plot with trend line")
    plt.xlabel("Code Length")
    plt.ylabel("Number of Warnings")
    plt.legend()


    # (keep this format)
    # Save the figure to the path specified at the top
    ####################################################
    if not savefig_path.exists():
        savefig_path.mkdir(parents=True, exist_ok=True)
    filename = datetime.now().strftime("%m.%d_%H.%M.%S")
    plt.savefig(savefig_path / f"{filename}.png")
    ####################################################

    plt.show()