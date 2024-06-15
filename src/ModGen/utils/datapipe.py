from datetime import datetime
from pathlib import Path
import json
import os

from utils.verbose_logger import VerboseLogger 

from typing import (
    Any,
    Dict,
    List
)

class FetchedFileData(dict):

    """
    Class to encapsulate file content information.

    Attributes:

        filename (str): The name of the file.
        content (str): The content of the file.

    Methods:

        None

    Usage:
    >>> file_data_dict = FetchedFileData(filename="example.txt", content="This is an example.")
    
    >>> file_data_dict.filename
    >>> file_data_dict.content

    >>> file_data_dict
    >>> {
    >>>     "filename": file_data_dict.filename,
    >>>     "content": file_data_dict.content
    >>> }

    """

    def __init__(
        self,
        data_dict: Dict[str, Any]
    ) -> None:
        super().__init__(data_dict if data_dict is not None else {})
        
        self._filename = data_dict['filename']
        self._content = data_dict['content']

    @property
    def filename(self) -> str:
        return self._filename

    @property
    def content(self) -> str:
        return self._content

class DataPipe(VerboseLogger):

    """
    DataPipe

    Attributes:

        directory (Path): The directory path.
        file (str): The file name.
    
    Methods:

        set_root: Sets the root directory.
        set: Configures the directory and file paths.
        load: Reads content from the specified file.
        dump: Writes content to the specified file.
        fetch_all_files: Reads content from all files in the set directory.
    
    Usage:

    # Initializing DataPipe, setting root, and dumping text with a datetime-based filename extension
    >>> dp = DataPipe(verbose_policy=1)
    >>> dp.set_root()
    >>> dp.dump("This is a sample text content.", extension='txt')

    # Setting parameters during initialization
    >>> dp = DataPipe('InteractionApp/output/descriptions', 'data.json')
    >>> dp = DataPipe('InteractionApp/output/descriptions/data.json')
    >>> dp = DataPipe('InteractionApp/output/descriptions', verbose_policy=2)

    # Setting directory, file by name, and dumping JSON content to a specified file
    >>> dp.set('InteractionApp/output/descriptions', 'data.json')
    >>> dp.dump({"key": "value"})

    # Setting the file by positive index and loading it
    >>> dp.set('InteractionApp/output/descriptions')
    >>> content = dp.load(0)

    # Setting the file by negative index and loading it
    >>> dp.set(-1)  # Set the last file in the directory
    >>> content = dp.load()

    # Dumping content to a file by negative index
    >>> dp.dump("Content to indexed file", -1)  # Dump to the last file in the directory

    # Setting the file by name in the current directory and loading it
    >>> dp.set('anotherfile.json')

    # Directly loading a file from the current directory
    >>> content = dp.load('anotherfile.json)

    # Loading content using the default file set
    >>> dp.set('InteractionApp/output/descriptions', 'defaultfile.txt')
    >>> content = dp.load()

    # Loading all files in a directory
    >>> files = dp.fetch_all_files()
    >>> for file in files:  # they are dicts
    >>>     print(file.filename, file.content)

    # Dumping content with overwrite protection
    >>> dp.set('InteractionApp/output/descriptions', 'data.json')
    >>> try:
    >>>     dp.dump({"key": "new_value"})
    >>> except ValueError as e:
    >>>     print(e)
    # Force dumping to overwrite existing file
    >>> dp.dump({"key": "new_value"}, force=True)

    # Setting and creating a new directory if it does not exist
    >>> dp.set('new_non_existent_directory')
    >>> dp.dump("Creating new directory content", extension='log')

    """

    def __init__(
        self,
        *args,
        verbose_policy: int =1
    ) -> None:
        self.directory = None
        self.file = None

        VerboseLogger.__init__(self)
        self.verbose_policy = verbose_policy

        if args:
            self.set(*args)
        
    def _get_directory(
        self
    ) -> Path:
        if not self.directory:
            self.log("Directory not set. Using root directory.", 2)
            self.set_root()
        return self.directory

    def set_root(
        self
    ):
        self.directory = Path(os.getcwd())
    
    def set(
        self,
        *args
    ) -> None:
        """
        Configures the directory and file paths for the FileManager. It accepts either one or two arguments. If a single argument is provided, it can be an integer to set the file by index from the directory, a string to set the file by name, or a path string to set both the directory and file. If the path string represents a directory, it sets only the directory. If the path string represents a file, it splits it into the directory and file. If two arguments are provided, the first is the directory, and the second is the file name. The method automatically creates the directory if it does not exist.
        
        """
        if len(args) == 1:
            arg = args[0]
            if isinstance(arg, int):
                if self._get_directory() is None:
                    raise ValueError("Directory not set. Use FileManager.set(directory) to set the directory first.")
                file_list = sorted(self._get_directory().glob('*'))
                index = arg if arg >= 0 else len(file_list) + arg
                if index < 0 or index >= len(file_list):
                    raise IndexError("Index out of range.")
                self.file = file_list[index].name
                self.log(f"File set: {self.file} (by index {index})", 1)
            elif isinstance(arg, str):
                path = Path(arg)
                if path.is_dir():
                    self.directory = path
                    self.log(f"Directory set: {self.directory}", 1)
                    self.file = None
                elif path.is_file():
                    self.directory = path.parent
                    self.log(f"Directory set: {self.directory}", 1) 
                    self.file = path.name
                    self.log(f"File set: {self.file}", 1)
                else:
                    self.log(f"Unrecognized path: {path}.", 1)
                    if len(path.parts) > 1:
                        if path.suffix:
                            self.file = path.name
                            self.directory = path.parent
                            self.log(f"File set: {self.file}", 1)
                            self.log(f"Directory set: {self.directory}", 1)
                        else:
                            self.directory = path
                            self.log(f"Directory set: {self.directory}", 1)
                    elif path.suffix:
                        self.file = path
                        self.log(f"File set: {self.file}", 1)

            else:
                raise ValueError("Invalid argument type. Expected int or str.")
        elif len(args) == 2:
            self.directory = Path(args[0])
            self.file = args[1]
            self.log(f"Directory set: {self.directory}", 1)
            self.log(f"File set: {self.file}", 1)
        else:
            raise ValueError("Invalid number of arguments. Expected 1 or 2 arguments.")

        if self._get_directory() and not self._get_directory().exists():
            self._create_directory_if_not_exists(self._get_directory())
            self.log(f"Directory created: {self._get_directory()}", 1)

    def load(
        self,
        index: int = None,
        filename: str = None,
    ) -> Any:
        """
        The load method reads content from the specified file. If no argument is provided, it loads from the default file set by the set method. If a string is provided, it treats it as a file name and loads from that file within the set directory. If an integer is provided, it loads the file by index from the directory, with negative indices counting from the end of the list. The method handles both JSON and non-JSON files, returning the content as a dictionary/list for JSON files and as a string for non-JSON files. It raises errors for non-existent files and invalid indices.

        """
        if index is None and filename is None:
            if not self.file:
                raise ValueError("File not set. Use FileManager.set() to set the file.")
            file_path = self._get_directory() / self.file
        elif filename:
            file_path = self._get_directory() / filename
        elif index:
            file_list = sorted(self._get_directory().glob('*'))
            index = index if index >= 0 else len(file_list) + index
            if index < 0 or index >= len(file_list):
                raise IndexError("Index out of range.")
            file_path = file_list[index]
        else:
            raise ValueError("Invalid argument type for index.")

        if not file_path.exists():
            raise FileNotFoundError(f"The file {file_path} does not exist.")

        if self._is_json(file_path):
            with file_path.open('r', encoding='utf-8') as f:
                self.log(f"Loading JSON content from file: {file_path}", 1)
                return json.load(f)
        else:
            with file_path.open('r', encoding='utf-8') as f:
                self.log(f"Loading content from file: {file_path}", 1)
                return f.read()

    def dump(
        self,
        content: str,
        filename=None,
        index=None,
        extension=None,
        force=False
    ) -> None:
        """
        The dump method writes content to the specified file. If only the content is provided, it writes to the default file set by the set method. If an integer is provided as the second argument, it writes to the file by index within the set directory, handling negative indices appropriately. If a string is provided as the second argument, it writes to the specified file name within the set directory. When an extension is provided as the second argument, the file name is automatically set to the current date and time. The method supports both JSON and non-JSON files, automatically creating the file if it does not exist. If there is no default file or directory set, it defaults to the root directory. If the file is not empty, you need 'force=True' to overwrite it.

        """
        
        if extension:
            filename = f"{datetime.now().strftime('%m.%d_%H.%M.%S')}.{extension}"
            file_path = self._get_directory() / filename
            self.log(f"Using path with created datetime file: {file_path}.", 1)

        if filename:

            if isinstance(filename, str):
                if '.' in filename:
                    file_path = self._get_directory() / filename
                    self.log(f"Using specified path: {file_path}", 1)

                else:
                    raise ValueError("Invalid file name. Include the file extension.")
            else:
                if self.file:
                    file_path = self._get_directory() / self.file
                    self.log(f"Using default file: {file_path} at {self._get_directory()}", 1)

                else:
                    raise ValueError("File not set. Use FileManager.set() to set the file.")
            
        if index:
            if isinstance(index, int):
                file_list = sorted(self._get_directory().glob('*'))
                index = index if index >= 0 else len(file_list) + index
                if index < 0 or index >= len(file_list):
                    raise IndexError("Index out of range.")
                
                file_path = file_list[index]
                self.log(f"Using file by index: {file_path}", 1)
                
            else:
                raise ValueError("Invalid index type. Expected int.")

        # Check if file is empty
        if file_path.exists():
            if file_path.stat().st_size > 0 and not force:
                raise ValueError(f"File {file_path} is not empty and force is not True.")
            
        if self._is_json(file_path):
            with file_path.open('w', encoding='utf-8') as f:
                json.dump(content, f, indent=4)
                self.log(f"Dumped JSON content to file: {file_path}", 1)
        else:
            if isinstance(content, (int, str)):
                with file_path.open('w', encoding='utf-8') as f:
                    f.write(content)
                    self.log(f"Dumped content to file: {file_path}", 1)
            else:
                raise ValueError("Invalid content type for non-JSON file.")
    
    def fetch_all_files(
        self
    ) -> List[FetchedFileData]:
        """
        The fetch_all_files method reads content from all files in the set directory. It returns a list of structures, with each element representing the filename and content of a single file. The method raises an error if the directory is not set.

        >>> lst = file_manager.fetch_all_files()
        
        """
        if not self._get_directory():
            raise ValueError("Directory not set. Use FileManager.set() to set the directory first.")
    
        file_list = sorted(self._get_directory().glob('*'))
        files_with_contents = []

        self.verbose_policy, policy_backup = 0, self.verbose_policy # Suppress recurrent verbose output	
        
        for file_path in file_list:
            content = self.load(filename=file_path.name)
            files_with_contents.append(
                FetchedFileData({
                    "filename": file_path.name,
                    "content": content
                    })
                 )
            
        self.verbose_policy = policy_backup
        
        self.log(f"Loaded content from all files in directory: {self._get_directory()}", 1)
        
        return files_with_contents

    @staticmethod
    def _is_json(file_path):
        return file_path.suffix == '.json'

    @staticmethod
    def _create_directory_if_not_exists(directory):
        directory.mkdir(parents=True, exist_ok=True)