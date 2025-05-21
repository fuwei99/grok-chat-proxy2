@echo off
setlocal EnableDelayedExpansion

REM 配置文件路径
set "CONFIG_FILE=config.txt"

REM 初始默认配置值
set "CFG_USE_COOKIES=n"
set "CFG_RUN_HEADLESS=n"
set "CFG_API_TOKEN="
set "CFG_SESSION_NUMBER=0"
set "CFG_USE_PRIVATE_MODE=n"
set "CFG_LISTEN_PORT=9867"

REM 从配置文件加载配置
call :load_config
goto :menu

:load_config
echo 正在从 %CONFIG_FILE% 加载配置...
if not exist "%CONFIG_FILE%" (
    echo %CONFIG_FILE% 未找到。将使用默认配置并创建该文件。
    call :save_config
    goto :eof
)

for /f "tokens=1,2 delims==" %%a in (%CONFIG_FILE%) do (
    set "%%a=%%b"
)
echo 配置已加载。
goto :eof

:save_config
echo 正在保存配置到 %CONFIG_FILE%...
(
    echo CFG_USE_COOKIES=!CFG_USE_COOKIES!
    echo CFG_RUN_HEADLESS=!CFG_RUN_HEADLESS!
    echo CFG_API_TOKEN=!CFG_API_TOKEN!
    echo CFG_SESSION_NUMBER=!CFG_SESSION_NUMBER!
    echo CFG_USE_PRIVATE_MODE=!CFG_USE_PRIVATE_MODE!
    echo CFG_LISTEN_PORT=!CFG_LISTEN_PORT!
) > %CONFIG_FILE%
echo 配置已保存。
goto :eof

:menu
cls
echo ==========================
echo  Grok Chat Proxy 启动器 (配置: %CONFIG_FILE%)
echo ==========================
echo.
echo 当前配置:
echo   使用 Cookies (-c)      : %CFG_USE_COOKIES%
echo   无头模式运行 (-h)      : %CFG_RUN_HEADLESS%
echo   API Token (-i)         : %CFG_API_TOKEN%
echo   会话数量 (-n)          : %CFG_SESSION_NUMBER%
echo   使用隐私模式 (-p)      : %CFG_USE_PRIVATE_MODE%
echo   监听端口 (-port)       : %CFG_LISTEN_PORT%
echo.
echo 选择一个选项:
echo 1. 配置参数
echo 2. 启动应用
echo 3. 退出
echo.
set /p choice="请输入你的选择 (1-3): "

if "%choice%"=="1" goto configure
if "%choice%"=="2" goto start_app
if "%choice%"=="3" goto end_script

echo 无效选择。按任意键重试。
pause >nul
goto menu

:configure
cls
echo --- 配置参数 ---
echo 对于 是/否 选项, 请输入 'y' 或 'n'.
echo 对于其他选项, 请输入期望的值.
echo 直接按 Enter 键将保留当前值.
echo.

set "TEMP_INPUT="
set /p TEMP_INPUT="是否使用cookie文件(y)/手动登录(n)，初次启动建议手动登录提取cookie，后续启动改为cookie登录? (y/n) [当前: %CFG_USE_COOKIES%]: "
if /i "%TEMP_INPUT%"=="y" (set CFG_USE_COOKIES=y) else if /i "%TEMP_INPUT%"=="n" (set CFG_USE_COOKIES=n) else if not "%TEMP_INPUT%"=="" (echo 无效输入。值未更改。)

set "TEMP_INPUT="
set /p TEMP_INPUT="以无头模式(不显示浏览器页面，但可能被block)? (y/n) [当前: %CFG_RUN_HEADLESS%]: "
if /i "%TEMP_INPUT%"=="y" (set CFG_RUN_HEADLESS=y) else if /i "%TEMP_INPUT%"=="n" (set CFG_RUN_HEADLESS=n) else if not "%TEMP_INPUT%"=="" (echo 无效输入。值未更改。)

set "CURRENT_TOKEN_DISPLAY=%CFG_API_TOKEN%"
if "%CURRENT_TOKEN_DISPLAY%"=="" set "CURRENT_TOKEN_DISPLAY=[空]"
set "TEMP_INPUT="
set /p TEMP_INPUT="API密码 (-i) [当前: %CURRENT_TOKEN_DISPLAY%]: "
if not "%TEMP_INPUT%"=="" (
    set "CFG_API_TOKEN=%TEMP_INPUT%"
) else (
    if not "%CFG_API_TOKEN%"=="" (
        set "CONFIRM_TOKEN_CLEAR="
        set /p CONFIRM_TOKEN_CLEAR="API Token 当前已设置。按 Enter 保留，或输入 'clear' (然后按Enter) 来清空它: "
        if /i "%CONFIRM_TOKEN_CLEAR%"=="clear" set "CFG_API_TOKEN="
    )
)

set "TEMP_INPUT="
set /p TEMP_INPUT="手动登录账号数量 (-n) [当前: %CFG_SESSION_NUMBER%]: "
if not "%TEMP_INPUT%"=="" (
    set "CFG_SESSION_NUMBER=%TEMP_INPUT%"
) else (
    if not "%CFG_SESSION_NUMBER%"=="0" (
        set "CONFIRM_CLEAR="
        set /p CONFIRM_CLEAR="数量将设为0 (默认)。按 Enter 确认，或重新输入值: "
        if "%CONFIRM_CLEAR%"=="" set "CFG_SESSION_NUMBER=0"
    )
)

set "TEMP_INPUT="
set /p TEMP_INPUT="使用隐私模式（不保存聊天记录） (-p)? (y/n) [当前: %CFG_USE_PRIVATE_MODE%]: "
if /i "%TEMP_INPUT%"=="y" (set CFG_USE_PRIVATE_MODE=y) else if /i "%TEMP_INPUT%"=="n" (set CFG_USE_PRIVATE_MODE=n) else if not "%TEMP_INPUT%"=="" (echo 无效输入。值未更改。)

set "TEMP_INPUT="
set /p TEMP_INPUT="监听端口 (-port) [当前: %CFG_LISTEN_PORT%]: "
if not "%TEMP_INPUT%"=="" (
    set "CFG_LISTEN_PORT=%TEMP_INPUT%"
) else (
    if not "%CFG_LISTEN_PORT%"=="9867" (
        set "CONFIRM_CLEAR_PORT="
        set /p CONFIRM_CLEAR_PORT="端口将设为9867 (默认)。按 Enter 确认，或重新输入值: "
        if "%CONFIRM_CLEAR_PORT%"=="" set "CFG_LISTEN_PORT=9867"
    )
)

call :save_config
echo.
echo 配置已更新并保存到 %CONFIG_FILE%。按任意键返回主菜单。
pause >nul
goto menu

:start_app
cls
echo --- 正在启动应用 ---
set CMD_ARGS=
if /i "%CFG_USE_COOKIES%"=="y" set CMD_ARGS=%CMD_ARGS% -c
if /i "%CFG_RUN_HEADLESS%"=="y" set CMD_ARGS=%CMD_ARGS% -h
if defined CFG_API_TOKEN if not "%CFG_API_TOKEN%"=="" set CMD_ARGS=%CMD_ARGS% -i "%CFG_API_TOKEN%"

set /a "session_num_val=0"
if defined CFG_SESSION_NUMBER (
    set /a "session_num_val=%CFG_SESSION_NUMBER%" 2>nul
)
if not "%session_num_val%"=="0" set CMD_ARGS=%CMD_ARGS% -n %session_num_val%

if /i "%CFG_USE_PRIVATE_MODE%"=="y" set CMD_ARGS=%CMD_ARGS% -p

set "effective_port=9867"
if defined CFG_LISTEN_PORT (
    set /a "effective_port=%CFG_LISTEN_PORT%" 2>nul
)
if not "%effective_port%"=="9867" set CMD_ARGS=%CMD_ARGS% -port %effective_port%

set "EXECUTABLE_NAME=grok-chat-proxy2.exe"
echo 正在运行: %EXECUTABLE_NAME% %CMD_ARGS%

if not exist "%EXECUTABLE_NAME%" (
    echo 错误: %EXECUTABLE_NAME% 未在当前目录中找到。
    echo 请确保 grok-chat-proxy2.exe 文件存在于此脚本所在的目录中。
    echo 通常, 你可以使用 build.bat 来编译它。
    pause
    goto menu
)

start "" "%EXECUTABLE_NAME%" %CMD_ARGS%
echo.
echo 应用已启动。
echo 如果它是一个服务器应用, 它应该在新窗口中运行。
echo 按任意键返回主菜单。
pause >nul
goto menu

:end_script
echo 已退出。
endlocal
exit /b