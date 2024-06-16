import numpy as np
from pathlib import Path
import random
import matplotlib.pyplot as plt
from scipy.stats import norm, lognorm

def contracts_plot(contracts_sets, norm_flags, lognorm_flags, hist_flags, main_thread):
    def prepare_elements():
        lines = [[len(contract) for contract in contracts] for contracts in contracts_sets]
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
    
    session = main_thread.session
    dir_path = Path(f'utils/sttmd/{session}/contracts_lengths')
    if not dir_path.exists():
        dir_path.mkdir(parents=True, exist_ok=True)
    file_name = "".join(str(random.randint(0, 9)) for _ in range(8)) + '.png'
    file_path = dir_path / file_name
    plt.savefig(file_path)

    plt.show()