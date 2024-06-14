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

# import subprocess
# import os
# import json

# class SolidityAnalyzer:
#     def __init__(self, solc_version='0.8.6'):  # Updated to 0.8.6
#         self.solc_version = solc_version

#     def install_and_use_solc(self):
#         # Install solc-select if not installed
#         subprocess.run(['pip', 'install', 'solc-select'], capture_output=True, text=True)
        
#         # Install the specific Solidity compiler version
#         solc_install_cmd = ['solc-select', 'install', self.solc_version]
#         subprocess.run(solc_install_cmd, capture_output=True, text=True)
        
#         # Use the specified Solidity compiler version
#         solc_use_cmd = ['solc-select', 'use', self.solc_version]
#         result = subprocess.run(solc_use_cmd, capture_output=True, text=True)
        
#         if result.returncode != 0:
#             print(f"Failed to set solc version to {self.solc_version}:")
#             print(result.stdout)
#             print(result.stderr)
#             return False
#         return True

#     def get_slither_analysis(self, source_code):
#         # Ensure the specified Solidity compiler version is used
#         if not self.install_and_use_solc():
#             return None
        
#         # Write the source code to a temporary file with SPDX identifier
#         source_code_with_spdx = f"// SPDX-License-Identifier: UNLICENSED\n{source_code}"
#         with open("temp.sol", "w") as file:
#             file.write(source_code_with_spdx)
        
#         # Ensure output.json does not exist before running analysis
#         if os.path.exists('output.json'):
#             os.remove('output.json')
        
#         # Run slither analysis
#         result = subprocess.run(['slither', 'temp.sol', '--json', 'output.json'], capture_output=True, text=True)
        
#         if result.returncode != 0 or not os.path.exists('output.json'):
#             print("Slither analysis failed:")
#             print(result.stdout)
#             print(result.stderr)
#             os.remove("temp.sol")
#             return None
        
#         # Check for and handle warnings
#         if result.stderr:
#             print("Slither analysis warnings/errors:")
#             print(result.stderr)
        
#         # Read and return the slither output
#         with open('output.json', 'r') as file:
#             slither_output = json.load(file)
        
#         os.remove("temp.sol")
#         os.remove("output.json")
#         return slither_output

# # Example usage:
# source_code = """
# pragma solidity ^0.8.6;

# contract SimpleStorage {
#     uint256 storedData;

#     function set(uint256 x) public {
#         storedData = x;
#     }

#     function get() public view returns (uint256) {
#         return storedData;
#     }
# }
# """

# analyzer = SolidityAnalyzer()
# slither_analysis = analyzer.get_slither_analysis(source_code)
# if slither_analysis:
#     print(f"Slither Analysis: {slither_analysis}")
# else:
#     print("Slither analysis did not produce a valid output.")
