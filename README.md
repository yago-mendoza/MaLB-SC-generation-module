
# README

<p align="center">
  <a href="https://www.google.com/">
    <img src="assets/banner.PNG" />
  </a>
</p>

# Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
   - [Python & Poetry](#python-and-poetry)
   - [Cloning the Repository](#cloning-the-repository)
   - [Activate the Virtual Environment](#activate-the-virtual-environment)
3. [Running the Modules](#running-the-modules)
   - [Interaction Module](#interaction-module)
   - [Generation Module](#generation-module)
   - [Statistics and Testing Module (STTMD)](#statistics-and-testing-module-sttmd)
4. [Development Commands](#development-commands)
5. [License](#license)

# 👋 Overview <a name="overview"></a>
This project is a proof-of-concept for a multi-agent system that leverages transformer-based Large Language Models (LLMs) to autonomously script functional programs for the Ethereum Virtual Machine (EVM). The goal is to design these programs within specified operational constraints while achieving targeted performance metrics and security standards. 

The project is organized into several modules, each responsible for different aspects of the overall process. The primary modules include:
- Interaction Module: Refines a description of a smart contract and chunks it into structured features.
- Generation Module: Generates smart contracts based on the structured features.
- Statistics and Testing Module (STTMD): Analyzes data generated from the smart contracts, especially from compiled contracts.

⚠️ **Note:** This project is currently under active development. Some features are still being refined and are not yet ready for production use.

# 🔧 Installation <a name="installation"></a>

In this section, we provide detailed instructions on how to install [Python](https://www.python.org/downloads/) and [Poetry](https://python-poetry.org/) using various methods. The installation process varies slightly depending on your operating system.

## 1. Python & Poetry <a name="python-and-poetry"></a>

### For Windows

Run the following command to install [Chocolatey](https://chocolatey.org/) (if you haven't already):

```shell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

Once [Chocolatey](https://chocolatey.org/) is installed, run the following command to install [Python](https://www.python.org/downloads/):

```shell
choco install python
```

To verify that Python was installed correctly, open a new command prompt and run the following command:

```shell
python --version
```

Next, install [Poetry](https://python-poetry.org/) using [Chocolatey](https://chocolatey.org/):

```shell
choco install poetry
```

Verify the installation by running:

```shell
poetry --version
```

### For Linux and macOS

First, ensure that [Python](https://www.python.org/downloads/) is installed. Then, install [Poetry](https://python-poetry.org/) using the following command:

```shell
curl -sSL https://install.python-poetry.org | python3 -
```

Verify the installation by running:

```shell
poetry --version
```

## 2. Cloning the Repository <a name="cloning-the-repository"></a>

First, clone the repository to your local machine. This repository contains all the code and resources needed to run the project.

```shell
git clone https://github.com/yago-mendoza/MaLB-SC-generation-module.git
cd MaLB-SC-generation-module
```

## 3. Activate the Virtual Environment <a name="activate-the-virtual-environment"></a>

Use [Poetry](https://python-poetry.org/) to install the project's dependencies. Poetry will automatically create a virtual environment for the project. This ensures that all dependencies are installed in an isolated environment, avoiding conflicts with other projects.

```shell
poetry install
```

Activate the virtual environment created by Poetry:

```powershell
.\.venv\Scripts\Activate
```

For Unix-based systems, use the following command:

```bash
source .venv/bin/activate
```

When you're done working, you can deactivate the virtual environment to return to your global Python environment:

```powershell
deactivate
```

# 🚀 Running the Modules <a name="running-the-modules"></a>

The project consists of multiple modules, each responsible for a specific part of the process. Below are detailed instructions on how to run each module.

## Interaction Module <a name="interaction-module"></a>

The interaction module is designed to refine a description of a smart contract and chunk it into structured features. This process is facilitated through a Streamlit web application.

To run the interaction module, navigate to the appropriate directory and execute the Streamlit application:

```bash
cd src/InteractionApp
streamlit run streamlit_app.py
```

This command launches a Streamlit web application on your local server. The app provides an interface for you to input and refine a description of a smart contract, breaking it down into structured features. The refined descriptions and features are then stored in the `src/InteractionApp/output` directory.

**Preloaded Outputs:**
- **Descriptions:** Stored in `src/InteractionApp/output/descriptions`. This JSON file contains a multi-line string describing what the smart contract should do.
- **Features:** Stored in `src/InteractionApp/output/features`. This JSON file contains a list of dictionaries, each representing a feature of the smart contract. Each feature dictionary includes:
  - `Name` (str): The name of the feature.
  - `Scope` (str): The scope of the feature.
  - `Input` (list of strings): Inputs required for the feature.
  - `Constraints` (list of strings): Constraints associated with the feature.
  - `Output` (list of strings): Outputs generated by the feature.
  - `PrimaryScenario` (string): The primary scenario for the feature.
  - `AlternativeScenario` (string): Alternative scenarios for the feature.

## Generation Module <a name="generation-module"></a>

The generation module is responsible for generating smart contracts based on the structured features produced by the interaction module. This module uses the refined descriptions and features to generate functional smart contracts.

To run the generation module, execute the following command:

```bash
poetry run python src/ModGen/run_MaLB.py
```

Alternatively, you can run it using:

```bash
python src/ModGen/run_MaLB.py
```

### Main Parameters

Before running, ensure you adjust the parameters in the `__name__ == '__main__'` section of `run_MaLB.py`. These parameters control various aspects of the generation process:

```python
session = "session_name"  # The name of the folder in "output" being used
generate_contracts = True
compile_contracts = False
analyze_contracts = False
align_contracts = False

language_model = "gpt-3.5-turbo"
n_description = 1
n_contracts = 5
reasoning_layer = "ZSGen"
analysis_coverage = 0.8
feature_nquestions = 10
view_points = 3
gpt_openai_model = "gpt-3.5-turbo"
```

### Task Options

1. **Generate Contracts**
   - `n_contracts`: Number of contracts to generate.
   - `reasoning_layer`: Type of reasoning technique to use (default: `ZSGen` from `ModGen/generation_module/reasoning_layers`).

2. **Compile Contracts**
   - `analysis_coverage`: Proportion of contracts to compile.

3. **Analyze Contracts** (Solhint)
   - No parameters required.

4. **Align Contracts**
   - `feature_nquestions`: Number of questions generated per feature.
   - `view_points`: Points of view for the questions.
   - `gpt_openai_model`: Large language model used for this phase.

### Outputs

The outputs of this process are stored in a folder named `output` with the name of the execution session. The outputs for each task are as follows:

- **Generation:** Contracts
- **Compilation:** `compilation_logs`, `compiled_contracts`, `execution_log`
- **Solhint:** `analysis_logs` (list of errors and warnings)
- **Alignment:** `alignment_questions`, answers to those questions, and improvement suggestions

## Statistics and Testing Module (STTMD) <a name="statistics-and-testing-module-sttmd"></a>

The STTMD is used for analyzing the generated data, especially from compiled contracts. It generates statistics and plots to provide insights into the performance and characteristics of the generated smart contracts.

To run the statistics and testing module, use:

```bash
poetry run python src/ModGen/run_sttmd.py
```

The module outputs its results in `src/ModGen/utils/sttmd/output_images`.

**Analysis Scripts:**
- `compiled_contract_lengths_distributions.py`: Analyzes normal and lognormal length distributions.
- `compiled_contract_lengths_stats.py`: Provides general statistics on length distributions.
- `compiled_contracts_linting_stats.py`: Generates statistics on Solhint warning logs.
- `compiled_contracts_warnings_plots_1.py`: Plots length vs. warnings with linear regression and statistical inference of linear regression parameters.
- `compiled_contracts_warnings_plots_2.py`: Advanced chunking plots relating length and number of warnings.

# 🛠 Development Commands <a name="development-commands"></a>

The following commands are useful for development and maintaining code quality:

| Tool    | Command                           | Explanation                                                  |
|---------|-----------------------------------|--------------------------------------------------------------|
| Ruff    | `ruff check . --fix`              | Automatically fixes `FIXABLE` `[*]` issues in the current directory. |
| Ruff    | `ruff check .`                    | Checks for issues in the current directory without fixing.   |
| Black   | `black .`                         | Automatically formats Python code in the current directory.  |
| Poetry  | `poetry add <package>`            | Adds a new dependency to your Poetry project.                |
| Poetry  | `poetry remove <package>`         | Removes a dependency from your Poetry project.               |
| Sphinx  | `docs/make html`                  | Builds HTML documentation using Sphinx.                      |
| Browser | `start docs/build/html/index.html`| Opens the built HTML documentation in your default browser.  |

# 📄 License <a name="license"></a>
This project is licensed under the MIT License. See the `LICENSE` file for more details.

---

# Brief Overview

![image_1](https://github.com/yago-mendoza/MaLB-SC-generation-module/blob/main/assets/img_1.PNG)

The architecture depicts a modular system centered around a Large Language Model (LLM) for generating and validating smart contracts. The system is divided into three main phases: M1, M2, and M3.
In M1, the Coordinator module handles initial input processing. It performs validation of premises, updates descriptions, and conducts reflection on the input. This module interacts directly with user-provided premises and feedback, ensuring the input is properly formatted and understood before further processing. M2 encompasses parsing and generation. The Parser extracts relevant information from the validated input and performs inference to structure the data. The Generator then utilizes this structured information to produce Solidity smart contracts. This generation process is iterative, with multiple attempts represented by the vertical bars in the Generator block. M3 focuses on quality assurance and alignment. The Linting module performs compilation checks and uses Solhint for static code analysis, ensuring correctness of the generated contract. The Alignment module implements the SuAV (Survey Augmented Generation for Validation) process, utilizing an Inquisitor to generate questions and Scrutineers to assess completeness.

## SuAV (Survey Augmented Generation for Validation)

![image_1](https://github.com/yago-mendoza/MaLB-SC-generation-module/blob/main/assets/img3.PNG)

The Survey Augmented Generation for Validation (SuAV) process is a key component of the smart contract generation system. It employs an Inquisitor agent to formulate targeted questions based on contract features and the compiled program. These questions are then evaluated by multiple Scrutineers, whose assessments are consolidated to produce a comprehensive evaluation of the smart contract's alignment with user requirements. This multi-step process ensures a thorough and unbiased validation of the generated contracts.









