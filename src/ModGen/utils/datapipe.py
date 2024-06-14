from datetime import datetime
from pathlib import Path
import json
import os


class DataPipe:

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
        load_all_files: Reads content from all files in the set directory.
    
    """

    def __init__(self):
        self.directory = None
        self.file = None
    
    def _get_directory(self):
        if not self.directory:
            self.set_root()
        return self.directory

    def set_root(self):
        self.directory = Path(os.getcwd())
    
    def set(
        self,
        *args
    ):
        """
        Configures the directory and file paths for the FileManager. It accepts either one or two arguments. If a single argument is provided, it can be an integer to set the file by index from the directory, a string to set the file by name, or a path string to set both the directory and file. If the path string represents a directory, it sets only the directory. If the path string represents a file, it splits it into the directory and file. If two arguments are provided, the first is the directory, and the second is the file name. The method automatically creates the directory if it does not exist.

        >>> file_manager = FileManager()
        
        # Setting the directory, file and path        
        >>> file_manager.set('InteractionApp/output/descriptions')
        >>> file_manager.set('InteractionApp/output/descriptions', 'filename.json')
        >>> file_manager.set('InteractionApp/output/descriptions/filename.json')

        # Setting the file
        >>> file_manager.set(-1)  # by index : first file in the directory
        >>> file_manager.set('anotherfile.json')
        
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
            elif isinstance(arg, str):
                path = Path(arg)
                if path.is_dir():
                    self.directory = path
                    self.file = None
                elif path.is_file():
                    self.directory = path.parent
                    self.file = path.name
                else:
                    if '.' in arg:
                        self.file = arg
                    else:
                        self.directory = self._get_directory() / arg
            else:
                raise ValueError("Invalid argument type. Expected int or str.")
        elif len(args) == 2:
            self.directory = Path(args[0])
            self.file = args[1]
        else:
            raise ValueError("Invalid number of arguments. Expected 1 or 2 arguments.")

        if self._get_directory() and not self._get_directory().exists():
            self._create_directory_if_not_exists(self._get_directory())

    def load(
        self,
        index=None
    ):
        """
        The load method reads content from the specified file. If no argument is provided, it loads from the default file set by the set method. If a string is provided, it treats it as a file name and loads from that file within the set directory. If an integer is provided, it loads the file by index from the directory, with negative indices counting from the end of the list. The method handles both JSON and non-JSON files, returning the content as a dictionary/list for JSON files and as a string for non-JSON files. It raises errors for non-existent files and invalid indices.

        >>> file_manager = FileManager()

        # Loading content
        >>> content = file_manager.load()
        >>> content = file_manager.load('anotherfile.json')
        >>> content = file_manager.load(-1)
        >>> indexed_content_negative = file_manager.load(-1)

        """
        if index is None:
            if not self.file:
                raise ValueError("File not set. Use FileManager.set() to set the file.")
            file_path = self._get_directory() / self.file
        elif isinstance(index, str):
            file_path = self._get_directory() / index
        elif isinstance(index, int):
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
                return json.load(f)
        else:
            with file_path.open('r', encoding='utf-8') as f:
                return f.read()

    def dump(
        self,
        content,
        file=None,
        force=False
    ):
        """
        The dump method writes content to the specified file. If only the content is provided, it writes to the default file set by the set method. If an integer is provided as the second argument, it writes to the file by index within the set directory, handling negative indices appropriately. If a string is provided as the second argument, it writes to the specified file name within the set directory. When an extension is provided as the second argument, the file name is automatically set to the current date and time. The method supports both JSON and non-JSON files, automatically creating the file if it does not exist. If there is no default file or directory set, it defaults to the root directory. If the file is not empty, you need 'force=True' to overwrite it.

        >>> file_manager.dump("content")
        >>> file_manager.dump({"key": "value"})
        >>> file_manager.dump("content", "newfile.txt")
        >>> file_manager.dump("content", "newfile.sol")
        >>> file_manager.dump("content", "newfile.py")
        >>> file_manager.dump("content", "newfile.json")
        >>> file_manager.dump("content", -1)
        >>> file_manager.dump({"key": "value"}, "data.json")
        >>> file_manager.dump({"key": "value"}, -1)

        >>> file_manager.dump({"key": "value"}, 'sol')  # creates "06.13_23.03.38.sol" file

        """
        
        if file:
            if '.' not in file: # then it is an extension
                file = f"{datetime.now().strftime('%m.%d_%H.%M.%S')}.{file}"

        if isinstance(file, int):
            file_list = sorted(self._get_directory().glob('*'))
            index = file if file >= 0 else len(file_list) + file
            if index < 0 or index >= len(file_list):
                raise IndexError("Index out of range.")
            file_path = file_list[index]
        elif isinstance(file, str):
            file_path = self._get_directory() / file
        else:
            if not self.file:
                raise ValueError("File not set. Use FileManager.set() to set the file.")
            file_path = self._get_directory() / self.file
        
        # Check if file is empty
        if file_path.exists():
            if file_path.stat().st_size > 0 and not force:
                raise ValueError(f"File {file_path} is not empty and force is not True.")

        if self._is_json(file_path):
            with file_path.open('w', encoding='utf-8') as f:
                json.dump(content, f, indent=4)
        else:
            if isinstance(content, (int, str)):
                with file_path.open('w', encoding='utf-8') as f:
                    f.write(content)
            else:
                raise ValueError("Invalid content type for non-JSON file.")
    
    def load_all_files(
        self
    ):
        """
        The load_all_files method reads content from all files in the set directory. It returns a list of content, with each element representing the content of a single file. The method raises an error if the directory is not set.

        >>> lst = file_manager.load_all_files()
        
        """
        if not self._get_directory():
            raise ValueError("Directory not set. Use FileManager.set() to set the directory first.")

        file_list = sorted(self._get_directory().glob('*'))
        return [self.load(index) for index in range(len(file_list))]

    @staticmethod
    def _is_json(file_path):
        return file_path.suffix == '.json'

    @staticmethod
    def _create_directory_if_not_exists(directory):
        directory.mkdir(parents=True, exist_ok=True)