import os
import subprocess
import json
import tempfile

class MythrilAnalyzer:
    def __init__(self):
        self.ensure_mythril_installed()
        self.mythril_path = self.get_mythril_path()

    def ensure_mythril_installed(self):
        try:
            subprocess.run(['pip', 'install', 'mythril'], check=True)
            print("Mythril installed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to install Mythril: {e}")
            raise EnvironmentError("Mythril installation failed.")

    def get_mythril_path(self):
        # Verify Mythril installation path using the 'where' command
        try:
            mythril_path = subprocess.check_output("where myth", shell=True).decode().strip()
            print("Mythril is installed at:", mythril_path)
        except subprocess.CalledProcessError:
            print("Mythril is not found in the PATH.")
            raise EnvironmentError("Mythril installation not found. Ensure it's installed and in PATH.")

        # Update PATH environment variable if necessary
        mythril_dir = os.path.dirname(mythril_path)
        os.environ['PATH'] = mythril_dir + os.pathsep + os.environ['PATH']
        print("Updated PATH:", os.environ['PATH'])

        return mythril_path

    def set_execution_policy(self):
        try:
            result = subprocess.run(['powershell', 'Get-ExecutionPolicy'], capture_output=True, text=True)
            if 'RemoteSigned' not in result.stdout:
                print("Setting PowerShell execution policy to RemoteSigned...")
                subprocess.run(['powershell', 'Set-ExecutionPolicy', 'RemoteSigned', '-Scope', 'CurrentUser', '-Force'], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Failed to set execution policy: {e}")

    def analyze(self, source_code):
        if os.name == 'nt':
            self.set_execution_policy()

        with tempfile.NamedTemporaryFile(delete=False, suffix=".sol") as temp_file:
            temp_file.write(source_code.encode('utf-8'))
            temp_filename = temp_file.name

        try:
            # Ensure the temp_filename is properly formatted for Windows
            temp_filename = temp_filename.replace('\\', '\\\\')

            cmd = [self.mythril_path, 'analyze', temp_filename, '--json']

            # Print the command to be executed for debugging
            print(f"Executing command: {cmd}")

            # Use shell=True to ensure proper execution of the command
            result = subprocess.run(cmd, capture_output=True, text=True, shell=True)

            # Print stdout and stderr for debugging
            print("stdout:", result.stdout)
            print("stderr:", result.stderr)

            mythril_report = json.loads(result.stdout)
        except json.JSONDecodeError as e:
            print(f"Error decoding JSON: {e}")
            print("stdout:", result.stdout)
            print("stderr:", result.stderr)
            mythril_report = None
        finally:
            os.remove(temp_filename)

        return mythril_report

# Example usage
source_code = """
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract SimpleStorage {
    uint256 private storedData;
    address public owner;

    event DataStored(uint256 data);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function set(uint256 data) public onlyOwner {
        storedData = data;
        emit DataStored(data);
    }

    function get() public view returns (uint256) {
        return storedData;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
"""

mythril_analyzer = MythrilAnalyzer()
mythril_report = mythril_analyzer.analyze(source_code)

import json

# Assuming mythril_report is the variable containing the analysis result
if mythril_report is not None:
    output_file_path = "mythril_report.json"
    with open(output_file_path, 'w') as json_file:
        json.dump(mythril_report, json_file, indent=4)
    print(f"Mythril report saved to {output_file_path}")
else:
    print("Mythril report is None, nothing to save.")
