@echo off
REM Script to start the Grok Chat Proxy application
REM To configure, edit the DEFAULT_ variables below.

REM --- Configuration (Edit these values) ---
set "DEFAULT_PORT=9867"
set "DEFAULT_MAX_PROMPT_LENGTH=40000"
set "DEFAULT_MAX_SESSIONS=3"
set "DEFAULT_API_TOKEN="
REM Set YOUR_API_TOKEN_HERE if you want to hardcode it, e.g.:
REM set "DEFAULT_API_TOKEN=YOUR_API_TOKEN_HERE"

set "EXECUTABLE_NAME=grok-chat-proxy2-windows-amd64.exe"
REM Assuming the executable is in the same directory as the script
set "EXECUTABLE_PATH=.\%EXECUTABLE_NAME%"

echo Starting Grok Chat Proxy...
echo.

REM Assign variables directly from defaults
set "APP_PORT=%DEFAULT_PORT%"
set "APP_MAX_PROMPT_LENGTH=%DEFAULT_MAX_PROMPT_LENGTH%"
set "APP_MAX_SESSIONS=%DEFAULT_MAX_SESSIONS%"
set "APP_API_TOKEN=%DEFAULT_API_TOKEN%"

echo --- Configuration Used ---
echo Executable: %EXECUTABLE_PATH%
echo Port: %APP_PORT%
echo Max Prompt Length: %APP_MAX_PROMPT_LENGTH%
echo Max Sessions: %APP_MAX_SESSIONS%
if not "%APP_API_TOKEN%"=="" (
    echo API Token: [set]
) else (
    echo API Token: [not set]
)
echo.

REM Construct command arguments
set "CMD_ARGS=--port %APP_PORT% --max-prompt-length %APP_MAX_PROMPT_LENGTH% --max-sessions %APP_MAX_SESSIONS%"
if not "%APP_API_TOKEN%"=="" (
    set "CMD_ARGS=%CMD_ARGS% -i "%APP_API_TOKEN%""
)

REM Check if executable exists
if not exist "%EXECUTABLE_PATH%" (
    echo Error: Executable not found at %EXECUTABLE_PATH%
    echo Please build the project first using build.bat
    pause
    goto :eof
)

REM Run the application
echo Starting application...
%EXECUTABLE_PATH% %CMD_ARGS%

echo.
echo Application has terminated.
pause

:eof 