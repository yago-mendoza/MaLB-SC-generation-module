import numpy as np
from pathlib import Path
from datetime import datetime
import matplotlib.pyplot as plt


savefig_path = 'utils/'          \
               'sttmd/'          \
               'output_images/'  \
               'plotting_warnings_throughout_length_sets/'


def plotting_warnings_throughout_length_sets(contract_sets):

    global savefig_path
    savefig_path = Path(savefig_path)

    all_means = []
    
    for i, contracts in enumerate(contract_sets):
        # Calculate lengths of contracts
        lengths = [len(contract) for contract in contracts]
        
        # Sort contracts by length
        sorted_contracts = [contract for _, contract in sorted(zip(lengths, contracts))]
        
        # Dummy error generation for demonstration, replace this with actual error calculation if available
        errors = [len(contract) % 10 for contract in sorted_contracts]  # Example: errors based on contract length modulo 10
        
        # Split into four parts
        quartiles = np.array_split(errors, 4)
        
        # Calculate the mean number of errors for each part
        means = [np.mean(part) for part in quartiles]
        
        # Invert the order of means
        means.reverse()
        
        all_means.append(means)
        
        # Print the means
        print(f"Set {i + 1} - Mean Errors by Quartile: {means}")
        
        # Plotting the results
        x_labels = ['Q4', 'Q3', 'Q2', 'Q1']
        x = np.arange(len(x_labels))
        
        plt.plot(x, means, marker='o', linestyle='-', label=f'Set {i + 1}')

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
                plt.text(
                    x[j], mid_point,
                    f'({round(distance, 2)}, ±{round(np.abs(distance), 2)})',
                    horizontalalignment='center',
                    verticalalignment='center',
                    color='orange'
                )


    # Save the figure to the path specified at the top
    ####################################################
    if not savefig_path.exists():
        savefig_path.mkdir(parents=True, exist_ok=True)
    filename = datetime.now().strftime("%m.%d_%H.%M.%S")
    plt.savefig(savefig_path / f"{filename}.png")
    ####################################################

    plt.show()