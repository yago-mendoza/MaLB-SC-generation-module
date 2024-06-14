import solcx
import json
import os

class SolidityCompiler:
    def __init__(
        self,
        default_version='0.8.4'
    ):
        self.default_version = default_version
        self.selected_version = default_version
        self.source_code = None
        self.compiled_output = None
        self.output = None

    def set_version(
        self,
        version
    ):
        """
        Allows the user to specify the version of the Solidity compiler they wish to use. It takes a version parameter, installs the specified version using solcx.install_solc(version), and sets it as the current version with solcx.set_solc_version(version).

        """
        self.selected_version = version
        solcx.install_solc(version)
        solcx.set_solc_version(version)

    def compile(
        self,
        code,
    ):
        """
        Compiles the provided Solidity source code. It accepts code (the source code to compile) and an optional path parameter to save the output. The method attempts to compile the source code using solcx.compile_source with specified output values 'abi' and 'bin'. If successful, it stores the result in self.compiled_output and sets self.output to a success message with the compiled output. If an exception occurs, it categorizes the error using the _categorize_error method and stores the error information in self.output.
        
        """
        self.source_code = code
        try:
            self.compiled_output = solcx.compile_source(
                self.source_code,
                output_values=['abi', 'bin']
            )
            self.output = {
                'success': True,
                'errors': None,
                'output': self.compiled_output
            }
        except solcx.exceptions.SolcError as e:
            error_message = e.message
            error_type = self._categorize_error(error_message)
            self.output = {
                'success': False,
                'errors': {'type': error_type, 'message': error_message},
                'output': None
            }
        except Exception as e:
            error_message = str(e)
            self.output = {
                'success': False,
                'errors': {'type': 4, 'message': error_message},
                'output': None
            }

        return self.output

    def _categorize_error(
        self,
        error_message
    ):
        """
        Processes the error messages from the Solidity compiler. It accepts error_message as a parameter, matches it against predefined error categories (e.g., 'ParserError', 'TypeError'), and returns the corresponding error type.
        
        """
        error_categories = {
            'ParserError': 0,
            'TypeError': 1,
            'CompilerError': 2,
            'RuntimeError': 3,
            'Other': 4
        }
        for category in error_categories:
            if category in error_message:
                return error_categories[category]
        return error_categories['Other']





