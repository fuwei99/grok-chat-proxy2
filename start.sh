#!/bin/bash
# Script to start the Grok Chat Proxy application
# To configure, edit the DEFAULT_ variables below.

# --- Configuration (Edit these values) ---
DEFAULT_PORT="9867"
DEFAULT_MAX_PROMPT_LENGTH="40000"
DEFAULT_MAX_SESSIONS="3"
DEFAULT_API_TOKEN=""
# Set YOUR_API_TOKEN_HERE if you want to hardcode it, e.g.:
# DEFAULT_API_TOKEN="YOUR_API_TOKEN_HERE"

EXECUTABLE_NAME="grok-chat-proxy2-linux-amd64"
EXECUTABLE_PATH="./bin/$EXECUTABLE_NAME"

echo "Starting Grok Chat Proxy Configuration..."
echo

# Port
APP_PORT=$DEFAULT_PORT
read -p "Enter Port (default: $DEFAULT_PORT): " INPUT_PORT
if [[ -n "$INPUT_PORT" ]]; then
    APP_PORT=$INPUT_PORT
fi

# Max Prompt Length
APP_MAX_PROMPT_LENGTH=$DEFAULT_MAX_PROMPT_LENGTH
read -p "Enter Max Prompt Length (default: $DEFAULT_MAX_PROMPT_LENGTH): " INPUT_MAX_PROMPT_LENGTH
if [[ -n "$INPUT_MAX_PROMPT_LENGTH" ]]; then
    APP_MAX_PROMPT_LENGTH=$INPUT_MAX_PROMPT_LENGTH
fi

# Max Sessions
APP_MAX_SESSIONS=$DEFAULT_MAX_SESSIONS
read -p "Enter Max Sessions (default: $DEFAULT_MAX_SESSIONS): " INPUT_MAX_SESSIONS
if [[ -n "$INPUT_MAX_SESSIONS" ]]; then
    APP_MAX_SESSIONS=$INPUT_MAX_SESSIONS
fi

# API Token
APP_API_TOKEN=$DEFAULT_API_TOKEN
read -p "Enter API Token (optional, press Enter to skip): " INPUT_API_TOKEN
if [[ -n "$INPUT_API_TOKEN" ]]; then
    APP_API_TOKEN=$INPUT_API_TOKEN
fi

echo
echo "--- Configuration Used ---"
echo "Executable: $EXECUTABLE_PATH"
echo "Port: $APP_PORT"
echo "Max Prompt Length: $APP_MAX_PROMPT_LENGTH"
echo "Max Sessions: $APP_MAX_SESSIONS"
if [[ -n "$APP_API_TOKEN" ]]; then
    echo "API Token: [set]"
else
    echo "API Token: [not set]"
fi
echo

# Construct command arguments
CMD_ARGS=("--port" "$APP_PORT" "--max-prompt-length" "$APP_MAX_PROMPT_LENGTH" "--max-sessions" "$APP_MAX_SESSIONS")
if [[ -n "$APP_API_TOKEN" ]]; then
    CMD_ARGS+=("-i" "$APP_API_TOKEN")
fi

# Check if executable exists
if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo "Error: Executable not found at $EXECUTABLE_PATH"
    echo "Please build the project first (e.g., using build.bat or go build)."
    exit 1
fi

# Make executable if it's not (common on Linux/Mac after git clone or unzipping)
if [ ! -x "$EXECUTABLE_PATH" ]; then
    echo "Attempting to make executable: $EXECUTABLE_PATH"
    chmod +x "$EXECUTABLE_PATH"
    if [ ! -x "$EXECUTABLE_PATH" ]; then
        echo "Error: Could not make the file executable. Please check permissions."
        exit 1
    fi
fi


# Run the application
echo "Starting application..."
"$EXECUTABLE_PATH" "${CMD_ARGS[@]}"

echo
echo "Application has terminated." 