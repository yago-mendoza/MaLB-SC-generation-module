
from utils.datapipe import DataPipe
import numpy as np
from scipy.stats import norm, lognorm, kstest, anderson

def contracts_stats(main_thread):

    contracts = DataPipe(
        main_thread.dirs['compiled_contracts']
    ).fetch_all_files()

    print('-'*50)
    # Number of duplicate contracts and percentage of duplicates
    ############################################################

    unique_contracts = list(set(contracts))
    num_duplicates = len(contracts) - len(unique_contracts)
    percentage_duplicates = (num_duplicates / len(contracts)) * 100
    
    print(f"Number of duplicate contracts: {num_duplicates}")
    print(f"Percentage of duplicate contracts: {percentage_duplicates:.2f}%")

    lengths = [len(contract) for contract in contracts]


    print('-'*50)
    # Kolmogorov-Smirnov test for normal distribution
    #################################################

    mu, std = norm.fit(lengths)
    print(f"Mean contract length: {mu:.2f}")
    print(f"Standard deviation of contract length: {std:.2f}")
    
    _, ks_p_value_normal = kstest(lengths, 'norm', args=(mu, std))

    if ks_p_value_normal < 0.05:
        print(f"KS p-value for normal distribution: {ks_p_value_normal:.2f} (< 0.05)")
        print("> Data does not follow normal distribution")
    else:
        print(f"KS p-value for normal distribution: {ks_p_value_normal:.2f} (>= 0.05)")
        print("> Data does follow normal distribution")

        confidence = 0.05
        h = std * norm.ppf((1 + confidence) / 2) / np.sqrt(len(contracts))
        lower_bound = mu - h
        upper_bound = mu + h

        print(f"> Confidence interval ({100*confidence}%) for mean contract length: ({lower_bound:.2f}, {upper_bound:.2f})")

    print('-'*50)
    # Kolmogorov-Smirnov test for log-normal distribution
    #####################################################

    shape, loc, scale = lognorm.fit(lengths, floc=0)
    print(f"Shape parameter for log-normal distribution: {shape:.2f}")
    print(f"Location parameter for log-normal distribution: {loc:.2f}")
    print(f"Scale parameter for log-normal distribution: {scale:.2f}")
    
    _, ks_p_value_lognorm = kstest(lengths, 'lognorm', args=(shape, loc, scale))

    if ks_p_value_lognorm < 0.05:
        print(f"KS p-value for log-normal distribution: {ks_p_value_lognorm:.2f} (< 0.05)")
        print("> Data does not follow log-normal distribution")
    else:
        print(f"KS p-value for log-normal distribution: {ks_p_value_lognorm:.2f} (>= 0.05)")
        print("> Data does follow log-normal distribution")