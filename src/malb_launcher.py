from datapipe import DataPipe as dp

from Modules.generation_module.abstract_generator import generate_smart_contract
from Modules.assessment_module.syntax_checker import check_syntax
from Modules.assessment_module.syntax_refinement import assess_suitability

class MALB :

    reasoning_technique = None
    input_features = None
    input_description = None
    code = None

    # Class method to configure the generator
    @classmethod
    def config(cls, technique=None, features=None, description=None, code=None):
        # Assign values to class attributes if provided
        if technique: cls.reasoning_technique = technique
        if features: cls.input_features = features
        if description: cls.input_description = description
        if code: cls.code = code

    # Class method for generating and checking syntax of smart contracts
    @classmethod
    def syntax_generation(cls, run_syntax_check=True, max_iterations=3):

        # Raise an error if no features are provided
        if not cls.input_features:
            raise ValueError('No features have been provided.')
        
        n_iterations = 0
        execution_log = []

        features = str(cls.input_features)
        
        # Initial generation of the smart contract code
        execution_log.append(code := generate_smart_contract(features, reasoning=cls.reasoning_technique))

        # Loop to check syntax and regenerate code if necessary
        while run_syntax_check and n_iterations < max_iterations:

            n_iterations += 1

            # If syntax check fails, regenerate the code
            if not check_syntax(code):
                print('Syntax check failed. Trying again...')
                execution_log.append(code := generate_smart_contract(features, reasoning=cls.reasoning_technique))
            else:
                print('> Syntax check succesfully passed!')
                break

        # Save the final smart contract code and execution log
        execution_log_path = dp.save(execution_log, extension='json', dir=dp.syntax_generation_logs_dir)

        # Update the class configuration with the final code
        cls.config(code=code)

        return code, execution_log
    
    # Class method for refining the syntax based on feature suitability
    @classmethod
    def syntax_refinement(cls, max_iterations=3):

        description = cls.input_description
        features = cls.input_features
        code = cls.code

        bool_hist = []

        n_iterations = 1
        execution_log = []

        # Initial assessment of features suitability
        execution_log.append(features_assessment := assess_suitability(description, code, features))
        bool_hist.append(bool_assessments := [result["is_adequate"] for result in features_assessment])
        
        # Loop to refine the code based on assessment
        while not all(bool_assessments) and n_iterations < max_iterations:

            n_iterations += 1

            print(f'|Gen({n_iterations}/{max_iterations}){"-"*30}|')

            # Update features based on the assessment
            for i, _ in enumerate(features):
                feature_completeness = bool_assessments[i]
                if not feature_completeness:

                    features[i]['hint'] = features_assessment[i]["assessment"]
                    features[i]['to_do'] = features_assessment[i]["to_do"]

            # Generate new code based on updated features
            code = generate_smart_contract(str(features), cls.reasoning_technique)

            # Check for syntax correctness (not gathered data)
            while not check_syntax(code):
                print('Syntax check failed. Trying again...')
                code = generate_smart_contract(str(features), cls.reasoning_technique)

            features_assessment = assess_suitability(description, code, [str(f) for f in features])

            execution_log.append({'features_assessment': features_assessment, 'code': code})

            bool_hist.append(bool_assessments := [result["is_adequate"] for result in features_assessment])

        # Save the execution log
        assessments_log_path = dp.save(execution_log, extension='json', dir=dp.syntax_refinement_logs_dir)

        return n_iterations, bool_hist, execution_log


features = dp.read(dir=dp.interaction_attributes_dir)
description = dp.read(dir=dp.interaction_descriptions_dir)

MALB.config(technique='ZSGen', features=features, description=description)

code, execution_log = MALB.syntax_generation(run_syntax_check=True, max_iterations=3)
n_iterations, bool_hist, execution_log = MALB.syntax_refinement(max_iterations=5)
































