from importlib import import_module
from datapipe import DataPipe as dp

def generate_smart_contract(requirements, reasoning=None):
    if reasoning:
        ReasoningStrategy = getattr(
            import_module(f"Modules.generation_module.{reasoning}_generator"),
            reasoning
            )
    else:
        from Modules.generation_module.ZSGen_generator import ZSGen
        ReasoningStrategy = ZSGen
    
        
    path = dp.save(code:=ReasoningStrategy(requirements),
                   extension='sol', dir=dp.contracts_dir)

    return code