import os
import subprocess
import json
import tempfile
import pathlib

class SolhintAnalyzer:

    debug_mode = False
    solhint_path = None
    config_path = None

    @classmethod
    def initialize(
        cls
    ):
        """
        Ensures Solhint is installed and sets up a default configuration. It first checks if the solhint_path class variable is None. If it is, it calls ensure_solhint_installed to verify Solhint's installation and set the solhint_path variable. Similarly, it checks if the config_path class variable is None and, if so, calls create_default_config to create a default configuration file, setting the config_path variable. This method ensures that Solhint is ready for use with a standard configuration.

        """
        if cls.solhint_path is None:
            cls.solhint_path = cls.ensure_solhint_installed()
        if cls.config_path is None:
            cls.config_path = cls.create_default_config()

    @classmethod
    def log(
        cls,
        message
    ):
        """
        Used for debugging purposes. It takes a message as input and prints it to the console if the debug_mode class variable is True. This function helps track and troubleshoot the program's execution by providing debug information at various points in other methods.

        """
        if cls.debug_mode:
            print(message)

    @classmethod
    def ensure_solhint_installed(
        cls
    ):
        """
        Checks if Solhint is installed on the system by attempting to locate its executable using the where solhint.cmd command. If the command succeeds, it updates the system PATH environment variable to include Solhint's directory and sets the solhint_path class variable to the path of the Solhint executable. If the command fails, it logs a message and sets solhint_path to None. This method is called by initialize to ensure Solhint is available for use.

        """
        cls.log(f"Current PATH: {os.environ['PATH']}")

        try:
            solhint_path = subprocess.check_output(
                "where solhint.cmd",
                shell=True
                ).decode().strip()
            
            cls.log(f"Solhint is installed at: {solhint_path}")
        except subprocess.CalledProcessError:
            cls.log("Solhint is not installed or not found in the PATH.")
            solhint_path = None

        if solhint_path:
            solhint_dir = os.path.dirname(solhint_path)
            os.environ['PATH'] = solhint_dir + os.pathsep + os.environ['PATH']

            cls.log(f"Updated PATH: {os.environ['PATH']}")
        else:
            cls.log("Solhint path could not be determined. Please check your installation.")

        return solhint_path

    @classmethod
    def create_default_config(
        cls
    ):
        """
        Creates a default configuration file for Solhint. It sets the config_path variable to the path of a .solhint.json file in the current working directory. If this file does not already exist, the method creates it with a default configuration, including rules for maximum line length, inline assembly, and compiler version. The method logs whether the configuration file was created or already existed. It returns the path to the configuration file. This method is called by initialize to set up Solhint with a standard configuration.

        """
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
            cls.log(f"Default config created at: {config_path}")
        else:
            cls.log(f"Config already exists at: {config_path}")

        return config_path

    @classmethod
    def set_execution_policy(
        cls
    ):
        """
        Sets the PowerShell execution policy to RemoteSigned on Windows systems to allow scripts to run. It first checks the current execution policy using the Get-ExecutionPolicy command. If the policy is not RemoteSigned, it runs the Set-ExecutionPolicy command to update it. The method logs actions and any errors encountered. This method is called by analyze when the operating system is Windows to ensure scripts can be executed properly.

        """
        try:
            result = subprocess.run(['powershell', 'Get-ExecutionPolicy'], capture_output=True, text=True)
            if 'RemoteSigned' not in result.stdout:
                cls.log("Setting PowerShell execution policy to RemoteSigned...")
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
            cls.log(f"Failed to set execution policy: {e}")

    @classmethod
    def analyze(
        cls,
        source_code,
        output_file_path="solhint_report.json"
    ):
        """
        Analyzes a given Solidity source code file using Solhint. It first calls initialize to ensure Solhint is installed and configured. If the operating system is Windows, it calls set_execution_policy to set the PowerShell execution policy. The method then creates a temporary file to store the provided source_code and constructs a command to run Solhint using the solhint_path and config_path class variables. It executes this command and captures the output, which it logs for debugging. The output is parsed into a JSON report, and the method handles any JSON decoding errors, ensuring the temporary file is deleted afterward. The resulting JSON report is written to the specified output_file_path and returned, or None if an error occurs.

        """
        cls.initialize()

        if os.name == 'nt':
            cls.set_execution_policy()

        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".sol") as temp_file:

            temp_file.write(source_code.encode('utf-8'))
            temp_filename = temp_file.name

        try:
            temp_filename = temp_filename.replace('\\', '\\\\')

            cmd = [
                cls.solhint_path,
                '--formatter',
                'json',
                temp_filename,
                '-c', 
                cls.config_path
                ]
            cls.log(f"Executing command: {cmd}")
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                shell=True
            )

            cls.log(f"stdout: {result.stdout}")
            cls.log(f"stderr: {result.stderr}")

            solhint_report = json.loads(result.stdout)

            os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
            with open(output_file_path, 'w') as json_file:
                json.dump(solhint_report, json_file, indent=4)
            cls.log(f"Solhint report saved to {output_file_path}")

        except json.JSONDecodeError as e:
            cls.log(f"Error decoding JSON: {e}")
            cls.log(f"stdout: {result.stdout}")
            cls.log(f"stderr: {result.stderr}")
            solhint_report = None
        finally:
            os.remove(temp_filename)

        return solhint_report

