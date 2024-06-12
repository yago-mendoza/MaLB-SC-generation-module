import json
from typing import List, Union
from pathlib import Path
from datetime import datetime
import random

# Convert JSON to Python
def json_to_python(file_path: str, multistring: bool = False, joined: bool = False) -> Union[List[dict], List[str], str]:
    # multistring=True : returns a list of strings with each JSON object as a pretty-printed string
    # joined=True : returns a single string with all requirements joined, useful for direct display

    with open(file_path, 'r') as file:
        data = json.load(file)
    
    if joined:
        # Return a single joined string of all requirements in multistring format
        return '\n'.join([json.dumps(item, indent=4) for item in data])
    elif multistring:
        # Return a list of requirements in multistring format
        return [json.dumps(item, indent=4) for item in data]
    else:
        # Return a list of dictionary objects
        return data

# Define DataPipe class for managing file operations
class DataPipe:

    # Interaction / Objects
    interaction_attributes_dir = Path('storage/interaction_storage/attributes')
    interaction_descriptions_dir = Path('storage/interaction_storage/descriptions')

    # Interaction / Logs
    interaction_logs_dir = Path('storage/interaction_storage/execution_logs')

    # Generation / Objects
    contracts_dir = Path('storage/generation_storage/contracts') # residual

    # Generation / Logs
    code_generation_logs_dir = Path('storage/execution_logs/syntax_generation')
    code_refinement_logs_dir = Path('storage/execution_logs/syntax_refinement')

    

    _default_dir = Path('storage')  # Set initial default directory to 'storage' itself

    # Set directory for operations
    @classmethod
    def set_dir(cls, dir_name: str) -> None:
        # Set the directory to the specified dir_name (attributes, descriptions, contracts)
        dir_name = f"{dir_name}_dir"  # Add the suffix to the directory name
        if hasattr(cls, dir_name):
            cls._default_dir = getattr(cls, dir_name)
            print(f"Directory set to: {cls._default_dir}")
        else:
            raise ValueError(f"Directory name {dir_name} does not exist.")
        
    # Generate filename based on current datetime
    @staticmethod
    def _filename_gen(content: str, extension: str) -> str:
        return f"{datetime.now().strftime('%m.%d_%H.%M.%S')}.{extension}"
    
    # Save content to a file
    @classmethod
    def save(cls, content: str, dir: Path = None, extension: str = 'txt') -> Path:
        # Save content to a specified directory with a given extension
        dir = dir or cls._default_dir # Use default directory if none is specified
        dir.mkdir(parents=True, exist_ok=True)

        file_path = dir / cls._filename_gen(str(content), extension)

        with open(file_path, 'w') as file:
            if extension == 'json':
                # Save content as JSON with indentation
                json.dump(content, file, indent=4, default=lambda o: o.__dict__)
            else:
                # Save content as plain text
                file.write(content)

        print(f"File saved to: {file_path}")
        return file_path  # Return file path for reference (parent, name, suffix, ...)

    # Read content from a file
    @classmethod
    def read(cls, path: Path = None, dir: Path = None, filename: str = None, index: int = None, random_select: bool = False,
             json_multistring: bool = False, json_joined: bool = False) :
        # Read content based on various selection criteria
        
        if path:
            file_path = path  # Directly use the provided path (most probably from "save" output)

        else:         
            dir = dir or cls._default_dir  # Use default directory if none is specified
            files = list(dir.glob('*'))  # Get all files in the directory

            if not files:
                raise FileNotFoundError(f"No files found in the directory {dir}.")
            
            if random_select:
                file_path = random.choice(files) # Select a random file (testing purposes)
            elif index is not None:
                if index >= len(files) or index < -len(files):
                    raise IndexError(f"Index {index} is out of range for the directory {dir}.")
                file_path = files[index] # Select file by index
            elif filename:
                file_path = dir / filename # Select file by filename
                if not file_path.exists():
                    raise FileNotFoundError(f"The file {filename} does not exist in the directory {dir}.")
            else:
                raise ValueError("Either filename, index, or random_select must be provided.")
        
        if file_path.suffix == '.json':
            # Read and convert JSON content based on provided flags
            content = json_to_python(file_path, multistring=json_multistring, joined=json_joined)
            print(f"JSON file content read from: {file_path}")
            return content
        else:
            # Read plain text content
            with open(file_path, 'r') as file:
                content = file.read()
            print(f"File content read from: {file_path}")
            return content

# Example usage of the DataPipe class ##############################

# Configurar el directorio predeterminado

# DataPipe.set_dir('contracts')

# content = "Hello, World!"

# file_path = DataPipe.save(content, extension="txt") # returns file_path 
# filename = file_path.name # gets the name of the file from the path
# content = DataPipe.read(filename=filename) # reads the content of the file
# content = DataPipe.read(index=0) # reads the content of the first file in the directory
# content = DataPipe.read(index=-1) # reads the content of the last file in the directory
# content = DataPipe.read(random_select=True) # reads the content of a randomly selected file in the directory

# json_content = DataPipe.read(filename='example.json', json_multistring=True)
# json_content = DataPipe.read(filename='example.json', json_joined=True)
