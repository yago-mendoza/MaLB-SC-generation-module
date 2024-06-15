import solcx
import json
import subprocess

from utils.verbose_logger import VerboseLogger

from typing import (
    Dict,
    Any
)

class CompilationReport(dict):

    """
    Attributes:

        success (bool): Indicates if the compilation was successful.
        errors (Dict[str, Any]): A dictionary containing error information if the compilation failed.
        abi (Any): The ABI part of the compiled output if successful.
        bytecode (Any): The bytecode part of the compiled output if successful.

    Methods:
    
        None

    Usage:

    >>> report.success
    >>> report.errors
    >>> report.abi
    >>> report.bytecode

    >>> print(json.dumps(report, indent=4)  # for pretty display
    
    """

    def __init__(
        self,
        output: Dict[str, Any] = None
    ) -> None:
        super().__init__(output if output is not None else {})

    @property
    def success(self) -> bool:
        return self.get('success', False)

    @property
    def errors(self) -> Dict[str, Any]:
        return self.get('errors', {})

    @property
    def abi(self) -> Any:
        return self.get('abi', None)

    @property
    def bytecode(self) -> Any:
        return self.get('bytecode', None)

class SolidityCompiler(VerboseLogger):

    """
    SolidityCompiler

    Attributes:
    
        default_version (str): The default version of the Solidity compiler.
        selected_version (str): The currently selected version of the Solidity compiler.
        source_code (str): The Solidity source code to be compiled.
        compiled_output (Dict[str, Any]): The output from the Solidity compiler, containing ABI and bytecode.
        output (Dict[str, Any]): The detailed result of the compilation process.

    Methods:

        set_version: Allows the user to specify and set the version of the Solidity compiler.
        compile: Compiles the provided Solidity source code.
        _categorize_error: Processes and categorizes error messages from the Solidity compiler.

    Usage:

    # Initializing SolidityCompiler, setting version, and compiling source code
    >>> compiler = SolidityCompiler(verbose_policy=1)
    >>> compiler.set_version('0.8.4')  # [optional]
    >>> source_code = DataPipe('generation_module/output/contracts').load(-1)
    >>> report = compiler.compile(source_code)  # saved at compiler.report anyways
    >>> report.success
    >>> report.errors
    >>> report.abi
    >>> report.bytecode

    """

    def __init__(
        self,
        default_version='0.8.4',
        verbose_policy=1
    ):
        VerboseLogger.__init__(self)
        self.verbose_policy = verbose_policy

        self.log("Initializing compiler...", 1)

        self.default_version = default_version
        self.selected_version = default_version
        self.source_code = None
        self.compiled_output = None
        self.report = None

        self.log("Compiler initialized", 1)

    def set_version(
        self,
        version: str
    ) -> None:
        """
        Allows the user to specify the version of the Solidity compiler they wish to use. It takes a version parameter, installs the specified version using solcx.install_solc(version), and sets it as the current version with solcx.set_solc_version(version).

        """
        self.log(f"Setting Solidity compiler version to {version}", 1)
        self.selected_version = version
        solcx.install_solc(version)
        solcx.set_solc_version(version)
        self.log(f"Solidity compiler version set to {version}", 1)

    def compile(
        self,
        code: str
    ) -> CompilationReport:
        """
        Compiles the provided Solidity source code. It accepts code (the source code to compile) and an optional path parameter to save the output. The method attempts to compile the source code using the solc command line tool. If successful, it stores the result in self.compiled_output and sets self.report to a success message with the compiled output. If an exception occurs, it categorizes the error using the _categorize_error method and stores the error information in self.report as a CompilationReport object.

        """
        self.log("Starting Solidity compilation process", 1)
        self.source_code = code
        try:
            # Temporary file
            with open("temp_contract.sol", "w") as f:
                f.write(self.source_code)
                self.log("Source code written to temporary file temp_contract.sol", 2)

            # Using the solc command line tool
            result = subprocess.run(
                [
                    'solc',
                    '--combined-json',
                    'abi,bin',
                    'temp_contract.sol'
                ],
                capture_output=True,
                text=True,
                check=True
            )
            self.log("Solidity compilation completed successfully", 1)
            compiled_sol = json.loads(result.stdout)
            contract_key = next(iter(compiled_sol['contracts']))
            contract_data = compiled_sol['contracts'][contract_key]

            abi = contract_data['abi']
            bytecode = contract_data['bin']
            
            self.compiled_output = {
                'abi': abi,
                'bytecode': bytecode
            }
            self.report = CompilationReport({
                'success': True,
                'errors': None,
                'abi': self.compiled_output.get('abi', None),
                'output': self.compiled_output.get('abi', None)
            })
            self.log("Compilation output stored", 2)
        except subprocess.CalledProcessError as e:
            error_message = e.stderr
            error_type = self._categorize_error(error_message)
            self.report = CompilationReport({
                'success': False,
                'errors': {'type': error_type, 'message': error_message},
                'abi': None,
                'bytecode': None
            })
            self.log(f"Compilation failed with error: {error_message}", 2)

        except json.JSONDecodeError as e:
            error_message = f"JSON decode error: {str(e)}"
            self.report = CompilationReport({
                'success': False,
                'errors': {'type': 4, 'message': error_message},
                'abi': None,
                'bytecode': None
            })
            self.log(f"JSON decode error: {error_message}", 1)
        except Exception as e:
            error_message = str(e)
            self.report = CompilationReport({
                'success': False,
                'errors': {'type': 4, 'message': error_message},
                'abi': None,
                'bytecode': None
            })
            self.log(f"Unexpected error: {error_message}", 1)

        return self.report

    def _categorize_error(
        self,
        error_message: str
    ) -> int:
        self.log(f"Categorizing error message: {error_message}", 2)
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
                error_type = error_categories[category]
                self.log(f"Error categorized as: {category} with type code {error_type}", 2)
                return error_type
        self.log("Error categorized as: Other", 2)
        return error_categories['Other']





