from importlib import import_module

def generate_smart_contract(requirements, reasoning=None):
    if reasoning:
        ReasoningStrategy = getattr(
            import_module(f"Modules.generation_module.{reasoning}_generator"),
            reasoning
            )
    else:
        from Modules.generation_module.ZSGen_generator import ZSGen
        ReasoningStrategy = ZSGen

    path, code = ReasoningStrategy(requirements)
    return path, code