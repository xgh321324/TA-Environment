# Test Automation Environment - Developer Setup

## First Time Setup

1. xxx
2. xxx
3. xxx
## Test Automation Environment Setup with Intranet access

1. xx
2. xx
## Test Automation Environment Setup without Intranet access

1. xxx.

## Updating an existing environment

If you already have an existing environment, you need to update this environment. You can either completely delete your local environment and start from scratch by cloning a new copy of the repository or upgrade in place. First of all, you need to delete the ./.venv folder in the repository root. After that, running a `git pull` should update your repository to the current state. Consider your current branch, you might need to check out the develop branch and rebase your active feature branches to the current develop head.

After your existing virtual environment was deleted, start with step 2 or step 3 depending on the ability to access the Siemens Intranet on the target PC.

## Relevant software
### Visual Studio Code
For editing source code files, install the latest version of Visual Studio Code. Install the both the Python extension and Robot Framwork IntelliSense extension. A baseline configuration for VSCode is provided within the repository. Using VSCode will allow you to use standard features during development like linting and autocompletion.

### Browser
Both Firefox and Chrome have to be installed in their latest versions. If a Siemens provided installation of Firefox ESR is already installed, please uninstall this version of Firefox and installed the latest version directly from the internet.

