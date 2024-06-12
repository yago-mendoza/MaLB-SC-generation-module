from datapipe import DataPipe as dp

from Modules.generation_module.abstract_generator import generate_smart_contract
from Modules.generation_module.syntax_checker import check_syntax
from Modules.generation_module.syntax_refinement import assess_suitability

class SC_GENERATOR:

    reasoning_technique = None
    input_features = None
    input_description = None
    code = None

    @classmethod
    def config(cls, technique=None, features=None, description=None, code=None):
        if technique: cls.reasoning_technique = technique
        if features: cls.input_features = features
        if description: cls.input_description = description
        if code: cls.code = code

    @classmethod
    def syntax_generation(cls, run_syntax_check=True, max_iterations=3):

        if not cls.input_features:
            raise ValueError('No features have been provided.')
        
        n_iterations = 0
        execution_log = []
        
        execution_log.append(code := generate_smart_contract(cls.input_features, reasoning=cls.reasoning_technique))

        while run_syntax_check and n_iterations < max_iterations:

            n_iterations += 1

            if not check_syntax(code):
                print('Syntax check failed. Trying again...')
                execution_log.append(code := generate_smart_contract(cls.input_features, reasoning=cls.reasoning_technique))

        solidity_file_path = dp.save(code, extension='sol', dir=dp.contracts_dir)
        execution_log_path = dp.save(execution_log, extension='json', dir=dp.syntax_generation_logs_dir)

        cls.config(code=code)

        return code, execution_log

    @classmethod
    def syntax_refinement(cls, max_iterations=3):

        bool_hist = []

        n_iterations = 0
        execution_log = []

        execution_log.append(features_assessment := assess_suitability(description, code, features))
        bool_hist.append(bool_assessments := [result["is_adequate"] for result in features_assessment])

        features = dp.read(index=-1, dir=dp.attributes_dir)
        while not all(bool_assessments) and n_iterations < max_iterations:

            n_iterations += 1

            print(f'|Gen({n_iterations}/{max_iterations}){'-'*30}|')

            for i, _ in enumerate(features):
                feature_completeness = bool_assessments[i]
                if not feature_completeness:

                    features[i]['hint'] = features_assessment[i]["assessment"]
                    features[i]['to_do'] = features_assessment[i]["to_do"]

            code = generate_smart_contract(str(features), cls.reasoning_technique)
            features_assessment = assess_suitability(description, code, [str(f) for f in features])

            execution_log.append({'features_assessment': features_assessment, 'code': code})

            bool_hist.append(bool_assessments := [result["is_adequate"] for result in features_assessment])

        assessments_log_path = dp.save(execution_log, extension='json', dir=dp.syntax_refinement_logs_dir)

        return n_iterations, bool_hist, execution_log


features = dp.read(index=-1, json_joined=True, dir=dp.attributes_dir)
description = dp.read(index=-1, dir=dp.descriptions_dir)
SC_GENERATOR.config(technique='ZSGen', features=features, description=description)

code, execution_log = SC_GENERATOR.syntax_generation(run_syntax_check=True, max_iterations=3)
n_iterations, bool_hist, execution_log = SC_GENERATOR.syntax_refinement(max_iterations=5)
































