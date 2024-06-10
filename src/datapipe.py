import json
from typing import List, Union
from pathlib import Path
from datetime import datetime
import random


def json_to_python(file_path: str, multistring: bool = False, joined: bool = False) -> Union[List[dict], List[str], str]:

    # multistring=True : returns a list of strings
    # joined=True : returns a single string with all requirements joined

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

class DataPipe:
    attributes_dir = Path('storage/attributes')
    descriptions_dir = Path('storage/descriptions')
    contracts_dir = Path('storage/contracts')
    _default_dir = contracts_dir

    @classmethod
    def set_dir(cls, dir_name: str) -> None:
        dir_name += "_dir"  # Add the suffix to the directory name
        if hasattr(cls, dir_name):
            cls._default_dir = getattr(cls, dir_name)
            print(f"Directory set to: {getattr(cls, dir_name)}")
        else:
            raise ValueError(f"Directory name {dir_name} does not exist.")
        
    @staticmethod
    def _filename_gen(content: str, extension: str) -> str:
        return datetime.now().strftime("%m.%d_%H.%M.%S") + '.' + extension

    @classmethod
    def save(cls, content: str, dir: Path = None, extension: str = 'txt') -> Path:
        if dir is None:
            dir = cls._default_dir
        dir.mkdir(parents=True, exist_ok=True)
        file_path = dir / cls._filename_gen(str(content), extension)
        if extension == 'json':
            with open(file_path, 'w') as file:
                json.dump(content, file, indent=4, default=lambda o: o.__dict__)
        else:
            with open(file_path, 'w') as file:
                file.write(content)
        print(f"File saved to: {file_path}")
        return file_path

    @classmethod
    def read(cls, dir: Path = None, filename: str = None, index: int = None, random_select: bool = False,
             json_multistring: bool = False, json_joined: bool = False) :
        if dir is None:
            dir = cls._default_dir
        
        files = list(dir.glob('*'))
        if not files:
            raise FileNotFoundError(f"No files found in the directory {dir}.")
        
        if random_select:
            file_path = random.choice(files)
        elif index is not None:
            if index >= len(files) or index < -len(files):
                raise IndexError(f"Index {index} is out of range for the directory {dir}.")
            file_path = files[index]
        elif filename:
            file_path = dir / filename
            if not file_path.exists():
                raise FileNotFoundError(f"The file {filename} does not exist in the directory {dir}.")
        else:
            raise ValueError("Either filename, index, or random_select must be provided.")
        
        if file_path.suffix == '.json':
            content = json_to_python(file_path, multistring=json_multistring, joined=json_joined)
            print(f"JSON file content read from: {file_path}")
            return content
        else:
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
