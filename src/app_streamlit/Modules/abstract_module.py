import dspy
from typing import List
from pathlib import Path
import tempfile

# ---------- Drop-in MaLB Implementation Class for Modules ---------- #

class LLM_Agent:

    def __init__(self,
                 module=None,
                 load_path=None,  ### unique
                 model=None,
                 out=None
                 ):

        self.module = module() ### unique

        self.load_path = load_path
        if load_path: self.load_task()

        self.model = model
        self.load_model()

        self.out = out

    def load_model(self) -> None:

        model = dspy.OpenAI(model=self.model, max_tokens=300, temperature=1)
        dspy.settings.configure(lm=model, max_tokens=1024)

    def load_task(self) -> None:

        with tempfile.NamedTemporaryFile(delete=False) as temp_file:
            json_content = Path(self.load_path).read_text()
            temp_file.write(json_content.encode())
            temp_file.flush()

        self.module.load(Path(temp_file.name))
        Path(temp_file.name).unlink()
    
    def forward(self, *args):
        return getattr(self.module.forward(*args), self.out)
            
