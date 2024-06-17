import numpy as np
from pathlib import Path
from datetime import datetime
import matplotlib.pyplot as plt

savefig_path = 'utils/'          \
               'sttmd/'          \
               'output_images/'  \
               'compiled_contracts_warning_plots/g2'

def compiled_contracts_warning_plots_2(
    contract_sets,
    labels
):

    global savefig_path
    savefig_path = Path(savefig_path)
    
    q = 15  # Variable interna para ajustar el número de partes
    all_means = []

    for i, contracts in enumerate(contract_sets):
        # Calculate lengths of contracts
        lengths = [len(contract) for contract in contracts]

        # Sort contracts by length
        sorted_contracts = [contract for _, contract in sorted(zip(lengths, contracts))]

        # Dummy error generation for demonstration, replace this with actual error calculation if available
        errors = [len(contract) % 10 for contract in sorted_contracts]  # Example: errors based on contract length modulo 10

        # Split into parts based on q
        parts = np.array_split(errors, q)

        # Calculate the mean number of errors for each part
        means = [np.mean(part) for part in parts]
        
        all_means.append(means)

        # Print the means
        print(f"Label: {labels[i]}")
        for j, part in enumerate(parts):
            part_label = f"Q{q - j}"
            n_contracts = len(part)
            mean_errors = np.mean(part)
            print(f"{part_label} [n = {n_contracts}, mean = {mean_errors:.2f} warnings]")

        # Plotting the results
        x_labels = [f'Q{k+1}' for k in range(q)]  # Adjust the order if necessary
        x = np.arange(len(x_labels))

        plt.plot(x, means, marker='o', linestyle='-', label=labels[i])

    plt.xticks(x, x_labels)
    plt.xlabel('Quartiles')
    plt.ylabel('Mean Number of Errors')
    plt.title('Mean Number of Errors by Quartile Across Contract Sets')
    plt.legend()
    plt.grid(True)

    # Add arrows and labels between sets
    if len(all_means) > 1:
        for i in range(len(all_means) - 1):
            for j in range(len(all_means[i])):
                plt.annotate(
                    '',
                    xy=(x[j], all_means[i + 1][j]),
                    xytext=(x[j], all_means[i][j]),
                    arrowprops=dict(arrowstyle='<|-|>', color='orange')
                )
                mid_point = (all_means[i][j] + all_means[i + 1][j]) / 2
                distance = all_means[i + 1][j] - all_means[i][j]
                if i == 0:
                    plt.text(
                        x[j], mid_point,
                        f'({round(distance, 2)}, ±{round(np.abs(distance), 2)})',
                        horizontalalignment='center',
                        verticalalignment='center',
                        color='black',
                        fontsize=8
                    )

    # (keep this format)
    # Save the figure to the path specified at the top
    ####################################################
    if not savefig_path.exists():
        savefig_path.mkdir(parents=True, exist_ok=True)
    filename = datetime.now().strftime("%m.%d_%H.%M.%S")
    plt.savefig(savefig_path / f"{filename}.png")
    ####################################################

    plt.show()