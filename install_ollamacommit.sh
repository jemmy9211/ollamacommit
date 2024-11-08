#!/bin/bash

# Define the installation path and virtual environment path
INSTALL_PATH="/usr/local/bin/ollamacommit"
VENV_PATH="$HOME/ollama_venv"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# 1. Check if Ollama is installed
if ! command_exists ollama; then
    echo "Ollama is not installed. Installing Ollama..."
    echo "Please install Ollama manually by visiting https://ollama.com and follow the Linux installation instructions."
    exit 1
else
    echo "Ollama is already installed."
fi

# 2. Check if the llama3.2 model is installed in Ollama
if ! ollama list | grep -q "llama3.2"; then
    echo "Downloading the llama3.2 model for Ollama..."
    if ! ollama pull llama3.2; then
        echo "Failed to download llama3.2 model. Please try again."
        exit 1
    fi
else
    echo "llama3.2 model is already installed in Ollama."
fi

# 3. Create a virtual environment if it doesn't exist
if [ ! -d "$VENV_PATH" ]; then
    echo "Creating a virtual environment at $VENV_PATH..."
    python3 -m venv "$VENV_PATH"
    if [ $? -ne 0 ]; then
        echo "Failed to create virtual environment. Please ensure Python 3 and venv are installed."
        exit 1
    fi
fi

# Activate the virtual environment
source "$VENV_PATH/bin/activate"

# 4. Check and install required Python packages in the virtual environment
REQUIRED_PACKAGES=("requests" "langchain" "langchain_ollama")
echo "Checking for required Python packages in the virtual environment..."

for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
    if ! pip show "$PACKAGE" &> /dev/null; then
        echo "Installing $PACKAGE in the virtual environment..."
        if ! pip install "$PACKAGE"; then
            echo "Failed to install $PACKAGE. Please check your virtual environment setup."
            deactivate
            exit 1
        fi
    else
        echo "$PACKAGE is already installed in the virtual environment."
    fi
done

# 5. Copy the commit message generation script to the installation path
echo "Copying the ollamacommit script to $INSTALL_PATH..."
if ! sudo cp ollamacommit.sh "$INSTALL_PATH"; then
    echo "Failed to copy the script to $INSTALL_PATH. Please check your permissions."
    deactivate
    exit 1
fi

# 6. Make the script executable
if ! sudo chmod +x "$INSTALL_PATH"; then
    echo "Failed to make the script executable. Please check your permissions."
    deactivate
    exit 1
fi

# Deactivate the virtual environment
deactivate

# Print success message
echo "Installation complete! You can now use 'ollamacommit' as a command."
echo "Ensure that your local Ollama API server is running at http://localhost:11434."

