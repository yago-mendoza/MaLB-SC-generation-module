import os
import subprocess
import json
import tempfile
import pathlib
from pathlib import Path

from utils.verbose_logger import VerboseLogger

from typing import (
    List,
    Dict,
    Any
)

class SolhintReport(list):

    """
    Attributes:

        warnings (List[Dict[str, Any]]): A list of warning entries in the report.
        nwarnings (int): The number of warning entries in the report.
        errors (List[Dict[str, Any]]): A list of error entries in the report.
        nerrors (int): The number of error entries in the report.

    Methods:
    
        None

    Usage:

    >>> report = SolhintReport(report_data) 
    # report data is stored at every "analysis_log"
    >>> report.warnings
    >>> report.errors
    >>> report.nwarnings
    >>> report.nerrors
    
    >>> print(json.dumps(report, indent=4)  # for pretty display
    
    """

    def __init__(
        self,
        report_data: List[Dict[str, Any]] = None
    ) -> None:
        super().__init__(report_data if report_data is not None else [])

    @property
    def warnings(self) -> List[Dict[str, Any]]: 
        return [entry for entry in self if entry.get('severity') == 'Warning']

    @property
    def errors(self) -> List[Dict[str, Any]]:
        return [entry for entry in self if entry.get('severity') == 'Error']

    @property
    def nwarnings(self) -> int:
        return len(self.warnings)

    @property
    def nerrors(self) -> int:
        return len(self.errors)

class SolhintAnalyzer(VerboseLogger):

    """
    Attributes:

        solhint_path (str): Path to the Solhint executable.
        config_path (str): Path to the Solhint configuration file.
    
    Methods:

        analyze: Returns a SolhintReport object containing the results.
        
        log: Used  internally for debugging purposes.
        _initialize: Ensures Solhint is installed and sets up a default configuration.
        _ensure_solhint_installed: Checks if Solhint is installed on the system.
        _create_default_config: Creates a default configuration file for Solhint.
        _set_execution_policy: Sets the PowerShell execution policy to RemoteSigned on Windows systems.

    Usage:

    >>> report = SolhintAnalyzer().analyze(source_code)
    >>> report.warnings
    >>> report.errors
    >>> report.nwarnings
    >>> report.nerrors

    """

    def __init__(
        self,
        solhint_path: str = None,
        config_path: str = None,
        verbose_policy: int = 1
    ):

        VerboseLogger.__init__(self)
        self.verbose_policy = verbose_policy

        self.solhint_path = solhint_path
        self.config_path = config_path
        self._initialize()

        self.report = None

    def analyze(
        self,
        source_code: str
    ) -> SolhintReport:
        """
        Analyzes a given Solidity source code file using Solhint. It first calls initialize to ensure Solhint is installed and configured. If the operating system is Windows, it calls set_execution_policy to set the PowerShell execution policy. The method then creates a temporary file to store the provided source_code and constructs a command to run Solhint using the solhint_path and config_path class variables. It executes this command and captures the output, which it logs for debugging. The output is parsed into a JSON report, and the method handles any JSON decoding errors, ensuring the temporary file is deleted afterward.

        """

        if os.name == 'nt':
            self._set_execution_policy()

        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".sol") as temp_file:

            temp_file.write(source_code.encode('utf-8'))
            temp_filename = temp_file.name

        try:
            temp_filename = temp_filename.replace('\\', '\\\\')

            cmd = [
                self.solhint_path,
                '--formatter',
                'json',
                temp_filename,
                '-c', 
                self.config_path
                ]
            self.log(f"Executing command: {json.dumps(cmd, indent=4)}", 2)
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                shell=True
            )

            stdout_json = json.loads(result.stdout) if result.stdout else {}
            stderr_json = json.loads(result.stderr) if result.stderr else {}

            self.log(f"stdout: {json.dumps(stdout_json, indent=4)}", 2)
            self.log(f"stderr: {json.dumps(stderr_json, indent=4)}", 2)
            
            self.log("Solhint analysis completed", 1)

            solhint_report_data = stdout_json

        except json.JSONDecodeError as e:
            self.log(f"Error decoding JSON: {e}", 1)
            self.log(f"stdout: {result.stdout}", 2)
            self.log(f"stderr: {result.stderr}", 2)
            solhint_report_data = None
        finally:
            os.remove(temp_filename)
        
        self.report = SolhintReport(solhint_report_data)

        return self.report

    def _initialize(
        self
    ) -> None:
        """
        Ensures Solhint is installed and sets up a default configuration. It first checks if the solhint_path class variable is None. If it is, it calls ensure_solhint_installed to verify Solhint's installation and set the solhint_path variable. Similarly, it checks if the config_path class variable is None and, if so, calls create_default_config to create a default configuration file, setting the config_path variable. This method ensures that Solhint is ready for use with a standard configuration.

        """
        self.log("Initializing Solhint...", 1)
        if self.solhint_path is None:
            self.solhint_path = self._ensure_solhint_installed()
        if self.config_path is None:
            self.config_path = self._create_default_config()
        self.log("Solhint initialized", 1)

    def _ensure_solhint_installed(
        self
    ) -> str:
        """
        Checks if Solhint is installed on the system by attempting to locate its executable using the where solhint.cmd command. If the command succeeds, it updates the system PATH environment variable to include Solhint's directory and sets the solhint_path class variable to the path of the Solhint executable. If the command fails, it logs a message and sets solhint_path to None. This method is called by initialize to ensure Solhint is available for use.

        """
        import random
    
        _path_list_ = os.environ['PATH'].split(os.pathsep)
        self.log("Current PATH:", 2)
        for path in _path_list_:
            self.log(path, 2)

        try:
            solhint_path = subprocess.check_output(
                "where solhint.cmd",
                shell=True
                ).decode().strip()
            
            self.log(f"Solhint is installed at: {solhint_path}", 1)
        except subprocess.CalledProcessError:
            self.log("Solhint is not installed or not found in the PATH.", 1)
            solhint_path = None

        if solhint_path:
            solhint_dir = os.path.dirname(solhint_path)
            os.environ['PATH'] = solhint_dir + os.pathsep + os.environ['PATH']
            
            _updated_path_list_ = os.environ['PATH'].split(os.pathsep)
            self.log("Updated PATH:", 2)
            for path in _updated_path_list_:
                self.log(path, 2)

        else:
            self.log("Solhint path could not be determined. Please check your installation.", 1)

        return solhint_path

    def _create_default_config(
        self
    ) -> str:
        """
        Creates a default configuration file for Solhint. It sets the config_path variable to the path of a .solhint.json file in the current working directory. If this file does not already exist, the method creates it with a default configuration, including rules for maximum line length, inline assembly, and compiler version. The method logs whether the configuration file was created or already existed. It returns the path to the configuration file. This method is called by initialize to set up Solhint with a standard configuration.

        """
        # config_path = Path('static_linting/.solhint.json')
        config_path = os.path.join(os.getcwd(), '.solhint.json')

        if not os.path.exists(config_path):
            default_config = {
                "extends": "solhint:recommended",
                "rules": {
                    "max-line-length": ["error", 120],
                    "no-inline-assembly": "off",
                    "compiler-version": ["error", "^0.8.0"]
                }
            }
            with open(config_path, 'w') as config_file:
                json.dump(default_config, config_file, indent=4)
            self.log(f"Default config created at: {config_path}", 1)
        else:
            self.log(f"Config already exists at: {config_path}", 1)

        return config_path

    def _set_execution_policy(
        self
    ) -> None:
        """
        Sets the PowerShell execution policy to RemoteSigned on Windows systems to allow scripts to run. It first checks the current execution policy using the Get-ExecutionPolicy command. If the policy is not RemoteSigned, it runs the Set-ExecutionPolicy command to update it. The method logs actions and any errors encountered. This method is called by analyze when the operating system is Windows to ensure scripts can be executed properly.

        """
        try:
            result = subprocess.run(['powershell', 'Get-ExecutionPolicy'], capture_output=True, text=True)
            if 'RemoteSigned' not in result.stdout:
                self.log("Setting PowerShell execution policy to RemoteSigned...", 1)
                cmd = [
                    'powershell',
                    'Set-ExecutionPolicy',
                    'RemoteSigned',
                    '-Scope',
                    'CurrentUser',
                    '-Force'
                    ]
                subprocess.run(cmd, check=True)

        except subprocess.CalledProcessError as e:
            self.log(f"Failed to set execution policy: {e}", 1)

    

