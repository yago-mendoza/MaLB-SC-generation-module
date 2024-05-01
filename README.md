
<!-- SOURCE -->
<!-- https://github.com/princeton-nlp/SWE-agent/blob/main/README.md -->

<p align="center">
  <a href="https://www.google.com/">
    <img src="assets/banner.PNG" />
  </a>
</p>

<!-- <p align="center">
  <a href="https://swe-agent.com"><strong>Website & Demo</strong></a>&nbsp; | &nbsp;
  <a href="https://discord.gg/AVEFbBn2rH"><strong>Discord</strong></a>&nbsp; | &nbsp;
  <strong>Paper [coming April 10th]</strong>
</p> -->

# Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
   - [Python & Poetry](#python-and-poetry)
   - [Cloning the Repository](#cloning-the-repository)
   - [Activate the Virtual Environment](#activate-the-virtual-environment)
3. [Development Commands](#development-commands)


# 👋 Overview <a name="overview"></a>
Proof-of-concept for a self-organizing multi-agent system that leverages transformer-based LLMs to autonomously script functional programs for the Ethereum Virtual Machine (EVM), designed within specified operational constraints and aiming to achieve targeted performance metrics and security standards.

<!-- <p align="center">
  <img src="assets/workflow.png" style="width: 90%; height: auto;">
</p> -->

# 🔧 Installation <a name="installation"></a>

In this section, we provide detailed instructions on how to install [Python](https://www.python.org/downloads/) and [Poetry](https://python-poetry.org/) using [Chocolatey](https://chocolatey.org/), a package manager for windows. We highly recommend this approach, although more traditional methods should also suffice. 

Run the following command to install [Chocolatey](https://chocolatey.org/) (if you haven't already):

  ```shell
  Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  ```

## 1. Python & Poetry <a name="python-and-poetry"></a>

### Python

Before you can use [Poetry](https://python-poetry.org/) or any other Python-based tool, you need to have Python installed on your system. Enter the following commands to install [Python](https://www.python.org/downloads/):

1. Open a command prompt with administrator privileges.

2. Once [Chocolatey](https://chocolatey.org/) is installed, run the following command to install [Python](https://www.python.org/downloads/):

    ```shell
    choco install python
    ```

    This command will install the latest version of [Python](https://www.python.org/downloads/). If you need a specific version of Python, you can specify it by adding `--version=X.X.X` to the command.

3. To verify that Python was installed correctly, open a new command prompt and run the following command:

   ```shell
   python --version
   ```

### Poetry

Once you will have [Poetry](https://python-poetry.org/) installed, you will be able to install dependencies specified in the `pyproject.toml` file in a secure and smooth manner. 

> While we recommend [Poetry](https://python-poetry.org/) due to its ease of use and robustness, other [Python](https://www.python.org/downloads/) dependency managers can also be used to accurately install the specified versions of dependencies.

To install [Poetry](https://python-poetry.org/) using [Chocolatey](https://chocolatey.org/), follow these steps:

1. Open a command prompt with administrator privileges.

2. Once [Chocolatey](https://chocolatey.org/) is installed, run the following command to install [Poetry](https://python-poetry.org/):

    ```shell
    choco install poetry
    ```

    This will install [Poetry](https://python-poetry.org/) and its dependencies.

3. Verify the installation by running:

    ```shell
    poetry --version
    ```

## 2. Cloning the Repository <a name="cloning-the-repository"></a>

  First, clone the repository to your local machine:

  ```shell
  git clone https://github.com/yago-mendoza/MaLB-SC-generation-module.git
  cd MaLB-SC-generation-module
  ```

## 3. Activate the Virtual Environment <a name="activate-the-virtual-environment"></a>

  Use [Poetry](https://python-poetry.org/) to install the project's dependencies. [Poetry](https://python-poetry.org/) will automatically create a virtual environment.

  ```shell
  poetry install
  ```

  This should install many critical dependencies, besides development tools like [Ruff](https://docs.astral.sh/ruff/), [Black](https://github.com/psf/black), and [Sphynx](https://www.sphinx-doc.org/en/master/), which alongside [GitHub Copilot] and and the [VSCode Debugger]() are unvaluable for developing.

  Is it advisable to select `CTRL+SHIFT+P` `Select Interpreter` `Python3.11.1 ('.venv': Poetry)`, or whatever version you are using.

  Once the dependencies are installed, activate the virtual environment:

  ```powershell
  .\.venv\Scripts\Activate
  ```

  This command activates the virtual environment, setting up your shell to use the project’s local dependencies instead of globally installed packages. Ensure that you're using a command-line interface that supports PowerShell commands if you're on Windows, or adapt the command for Unix-based systems as needed.

  ```powershell
  deactivate
  ```

  When you're done working, you can deactivate the virtual environment to return to your global Python environment:

# 🛠 Development Commands <a name="development-commands"></a>

| Tool    | Command                           | Explanation                                                  |
|---------|-----------------------------------|--------------------------------------------------------------|
| Ruff    | `ruff . --fix`                    | Automatically fixes `FIXABLE` `[*]` issues in the current directory.         |
| Ruff    | `ruff check .`                    | Checks for issues in the current directory without fixing.   |
| Black   | `black .`                         | Automatically formats Python code in the current directory (requires `:reload`)  |
| Poetry  | `poetry add`                      | Adds a new dependency to your Poetry project.                |
| Poetry  | `poetry remove`                   | Removes a dependency from your Poetry project.               |
| Sphinx  | `docs/make html`                  | Builds HTML documentation using Sphinx.                      |
| Browser | `start docs/build/html/index.html`| Opens the built HTML documentation in your default browser.  |

# 📄 License <a name="license"></a>
MIT. Check `LICENSE`.

