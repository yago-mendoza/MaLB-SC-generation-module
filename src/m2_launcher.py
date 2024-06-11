from datapipe import DataPipe as dp

turn_generation_on = False
turn_syntax_check_on = False
turn_assessment_on = True

######################
# GENERATION
######################
if turn_generation_on:

    features = dp.read(index=-1, json_joined=True, dir=dp.attributes_dir)

    from Modules.generation_module.abstract_generator import generate_smart_contract
    path, code = generate_smart_contract(features, reasoning="SOTA")

######################
# SYNTAX CHECK
######################
if turn_syntax_check_on:

    contract_to_be_syntax_checked = dp.read(index=-1, dir=dp.contracts_dir)

    from Modules.assessment_module.syntax_checker import check_syntax
    is_syntax_correct = check_syntax(contract_to_be_syntax_checked)

######################
# ASSESSMENT
######################

# completeness_hist = []
# lim = 5
# n = 1

# if turn_assessment_on:

#     features = dp.read(index=-1, json_multistring=True, dir=dp.attributes_dir)
#     description = dp.read(index=-1, dir=dp.descriptions_dir)
#     source_code = dp.read(index=-1, dir=dp.contracts_dir)

#     from Modules.assessment_module.suitability_assessment import assess_suitability
#     path = assess_suitability(description, source_code, features)

#     suitability_results = dp.read(path=path)
#     are_adequate = [result["is_adequate"] for result in suitability_results]
#     completeness_hist.append(are_adequate)

#     features = dp.read(index=-1, dir=dp.attributes_dir)
#     while not all(are_adequate) and len(completeness_hist) < lim:

#         n+=1
#         print(f'|Gen({n}/{lim}){'-'*30}|')

#         for i, _ in enumerate(features):
#             feature_completeness = are_adequate[i]
#             if not feature_completeness:
#                 features[i]['hint'] = suitability_results[i]["assessment"]
#                 features[i]['to_do'] = suitability_results[i]["to_do"]
        
#         from Modules.generation_module.abstract_generator import generate_smart_contract
#         path, code = generate_smart_contract(str(features), reasoning="SOTA")

#         path = assess_suitability(description, code, [str(f) for f in features])
#         suitability_results = dp.read(path=path)
#         are_adequate = [result["is_adequate"] for result in suitability_results]
#         completeness_hist.append(are_adequate)

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Your data
data = [[True, True, True, True, True, False, False, True, True, False], [False, True, True, True, True, True, False, True, True, False], [False, True, True, True, True, False, True, True, False, False], [False, True, True, False, True, False, True, False, False, False], [False, True, False, False, True, False, True, True, True, False]]

# Calculate the percentage of True values for each iteration
percentages = [0]  # Start with 0% at iteration 0
for row in data:
    percentages.append(sum(row) / len(row) * 100)

# Create a DataFrame for easy plotting
df = pd.DataFrame({
    'Iteration': list(range(len(percentages))),
    'Percentage of True': percentages
})

# Plotting
plt.figure(figsize=(10, 6))
sns.lineplot(x='Iteration', y='Percentage of True', data=df, marker='o')
plt.title('Percentage of True Values Over Iterations')
plt.xlabel('Iteration')
plt.ylabel('Percentage of True Values')
plt.ylim(0, 100)  # Ensuring y-axis goes from 0 to 100
plt.show()



#### Viridis Squared Matrix

# import matplotlib.pyplot as plt

# fig, ax = plt.subplots()
# ax.imshow(data, cmap='viridis', aspect='auto')
# plt.show()
















##########################
# RE-GENERATION
##########################

# suitability_results = dp.read(index=-1, dir=dp.suitability_assessments_dir)

# dp.set_dir('attributes')
# requirements = dp.read(index=0)

# for i, _ in enumerate(requirements):
#     suitability_result = suitability_results[i]
#     if not suitability_result["is_adequate"]:
#         requirements[i]['hint'] = suitability_result["assessment"]
#         print(requirements[i])

# from Modules.generation_module.SOTA_generator import SOTA
# path, code = SOTA(requirements) # .parent, .name, .suffix




























