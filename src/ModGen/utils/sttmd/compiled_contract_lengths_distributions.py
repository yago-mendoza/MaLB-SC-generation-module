import numpy as np
from pathlib import Path
import random
import matplotlib.pyplot as plt
from datetime import datetime
from scipy.stats import norm, lognorm
import matplotlib.colors as mcolors
import matplotlib.cm as cm

savefig_path = Path('utils/sttmd/output_images/compiled_contract_lengths_distributions/')

def compiled_contract_lengths_distributions(
    contract_sets,
    norm_flags,
    lognorm_flags,
    hist_flags,
    labels
):
    global savefig_path

    # Si todos los argumentos NO tienen la MISMA longitud, rellenamos las flags con valores "True" hasta que la tengna
    max_len = max(len(contract_sets), len(norm_flags), len(lognorm_flags), len(hist_flags), len(labels))
    contract_sets = (contract_sets * max_len)[:max_len]
    norm_flags = (norm_flags * max_len)[:max_len]
    lognorm_flags = (lognorm_flags * max_len)[:max_len]
    hist_flags = (hist_flags * max_len)[:max_len]
    labels = (labels * max_len)[:max_len]

    def prepare_elements():
        lines = [[len(contract) for contract in contracts] for contracts in contract_sets]
        elements = []
        
        for i, data in enumerate(lines):
            if norm_flags[i]:
                mu, std = norm.fit(data)
                elements.append({
                    "type": "norm",
                    "params": (mu, std),
                    "label": f"{labels[i]}_norm"
                })
            
            if lognorm_flags[i]:
                shape, loc, scale = lognorm.fit(data, floc=0)
                elements.append({
                    "type": "lognorm",
                    "params": (shape, loc, scale),
                    "label": f"{labels[i]}_lognorm"
                })
            
            if hist_flags[i]:
                elements.append({
                    "type": "hist",
                    "data": data,
                    "label": f"{labels[i]}_hist"
                })
        
        return elements
    
    elements = prepare_elements()
    
    # Define colors
    unique_labels = list(set(labels))
    num_labels = len(unique_labels)
    color_map = cm.get_cmap('tab20', num_labels)
    label_colors = {label: color_map(i) for i, label in enumerate(unique_labels)}

    plt.figure(figsize=(10, 6))
    
    for element in elements:
        label_base = element["label"].rsplit('_', 1)[0]
        color = label_colors[label_base]

        if element["type"] == "hist":
            plt.hist(element["data"], bins=20, density=True, alpha=0.6, edgecolor='black', label=element["label"], color=color)
        
        elif element["type"] == "norm":
            mu, std = element["params"]
            x = np.linspace(mu - 3*std, mu + 3*std, 100)
            p_norm = norm.pdf(x, mu, std)
            plt.plot(x, p_norm, linewidth=2, label=element["label"], color=color)
        
        elif element["type"] == "lognorm":
            shape, loc, scale = element["params"]
            x = np.linspace(lognorm.ppf(0.01, shape, loc, scale), lognorm.ppf(0.99, shape, loc, scale), 100)
            p_lognorm = lognorm.pdf(x, shape, loc, scale)
            plt.plot(x, p_lognorm, linewidth=2, label=element["label"], color=color)
    
    plt.title('Fit of Normal and Log-Normal Distributions')
    plt.xlabel('Length')
    plt.ylabel('Density')
    plt.legend()

    # Guardar la figura en la ruta especificada arriba
    ####################################################
    if not savefig_path.exists():
        savefig_path.mkdir(parents=True, exist_ok=True)
    filename = datetime.now().strftime("%m.%d_%H.%M.%S")
    plt.savefig(savefig_path / f"{filename}.png")
    ####################################################

    plt.show()
