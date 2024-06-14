from importlib import import_module

def generate_syntax(initial_conditions, reasoning=None):

    if reasoning:
        ReasoningLayer = getattr(
            import_module(f"generation_module.reasoning_layers.{reasoning}_layer"),
            reasoning
            )
    else:
        from ModGen.generation_module.reasoning_layers.ZSGen_layer import ZSGen
        ReasoningLayer = ZSGen

    code = ReasoningLayer(initial_conditions)

    return code