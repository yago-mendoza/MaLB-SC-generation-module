import numpy as np
from pathlib import Path
import random
import matplotlib.pyplot as plt
from datetime import datetime
from scipy.stats import norm, lognorm

savefig_path = 'utils/'          \
               'sttmd/'          \
               'output_images/'  \
               'multi_plotting_contract_lenghts/'

def multi_plotting_contract_lenghts(contract_data_batches, norm_flags, lognorm_flags, hist_flags):

    global savefig_path
    savefig_path = Path(savefig_path)

    def prepare_elements():
        lines = [[len(contract) for contract in contracts] for contracts in contract_data_batches]
        elements = []
        
        for i, data in enumerate(lines):
            if norm_flags[i]:
                mu, std = norm.fit(data)
                elements.append({
                    "type": "norm",
                    "params": (mu, std),
                    "label": f"Normal {i+1}"
                })
            
            if lognorm_flags[i]:
                shape, loc, scale = lognorm.fit(data, floc=0)
                elements.append({
                    "type": "lognorm",
                    "params": (shape, loc, scale),
                    "label": f"Log-Normal {i+1}"
                })
            
            if hist_flags[i]:
                elements.append({
                    "type": "hist",
                    "data": data,
                    "label": f"Histogram {i+1}"
                })
        
        return elements
    
    elements = prepare_elements()
    
    plt.figure(figsize=(10, 6))
    
    for element in elements:
        if element["type"] == "hist":
            plt.hist(element["data"], bins=20, density=True, alpha=0.6, edgecolor='black', label=element["label"])
        
        elif element["type"] == "norm":
            mu, std = element["params"]
            x = np.linspace(mu - 3*std, mu + 3*std, 100)
            p_norm = norm.pdf(x, mu, std)
            plt.plot(x, p_norm, linewidth=2, label=element["label"])
        
        elif element["type"] == "lognorm":
            shape, loc, scale = element["params"]
            x = np.linspace(lognorm.ppf(0.01, shape, loc, scale), lognorm.ppf(0.99, shape, loc, scale), 100)
            p_lognorm = lognorm.pdf(x, shape, loc, scale)
            plt.plot(x, p_lognorm, linewidth=2, label=element["label"])
    
    plt.title('Fit of Normal and Log-Normal Distributions')
    plt.xlabel('Length')
    plt.ylabel('Density')
    plt.legend()
    
    
    # Save the figure to the path specified at the top
    ####################################################
    if not savefig_path.exists():
        savefig_path.mkdir(parents=True, exist_ok=True)
    filename = datetime.now().strftime("%m.%d_%H.%M.%S")
    plt.savefig(savefig_path / f"{filename}.png")
    ####################################################

    plt.show()