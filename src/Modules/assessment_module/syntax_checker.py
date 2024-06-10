import solcx
from datapipe import DataPipe as dp

def check_syntax(source_code):
    solcx.install_solc('0.8.4')
    solcx.set_solc_version('0.8.4')

    try:
        compiled_sol = solcx.compile_source(source_code, output_values=['abi', 'bin'])
        return True
    except solcx.exceptions.SolcError as e:
        return False

# deprecated

def check_syntax_from_file(file_path: str) -> bool:
    dp.set_dir('contracts')
    try:
        source_code = dp.read(filename=file_path)
        return check_syntax(source_code)
    except Exception as e:
        print(f"An error occurred: {e}")
        return False