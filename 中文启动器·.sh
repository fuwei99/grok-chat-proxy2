#!/bin/bash

# 配置文件路径
CONFIG_FILE="config.txt"

# 初始默认配置值
CFG_USE_COOKIES="n"
CFG_RUN_HEADLESS="n"
CFG_API_TOKEN=""
CFG_SESSION_NUMBER="1"
CFG_USE_PRIVATE_MODE="n"
CFG_LISTEN_PORT="9867"

# 清除屏幕的函数
clear_screen() {
    printf "\033c"
}

# 从配置文件加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "正在从 $CONFIG_FILE 加载配置..."
        while IFS='=' read -r key value; do
            if [[ -n "$key" && ! "$key" =~ ^# ]]; then
                case "$key" in
                    CFG_USE_COOKIES) CFG_USE_COOKIES="$value" ;;
                    CFG_RUN_HEADLESS) CFG_RUN_HEADLESS="$value" ;;
                    CFG_API_TOKEN) CFG_API_TOKEN="$value" ;;
                    CFG_SESSION_NUMBER) CFG_SESSION_NUMBER="$value" ;;
                    CFG_USE_PRIVATE_MODE) CFG_USE_PRIVATE_MODE="$value" ;;
                    CFG_LISTEN_PORT) CFG_LISTEN_PORT="$value" ;;
                esac
            fi
        done < "$CONFIG_FILE"
        echo "配置已加载。"
    else
        echo "$CONFIG_FILE 未找到。将使用默认配置并创建该文件。"
        save_config # 保存当前 (默认) 配置
    fi
}

# 保存配置到配置文件
save_config() {
    echo "正在保存配置到 $CONFIG_FILE..."
    cat > "$CONFIG_FILE" << EOF
CFG_USE_COOKIES=$CFG_USE_COOKIES
CFG_RUN_HEADLESS=$CFG_RUN_HEADLESS
CFG_API_TOKEN=$CFG_API_TOKEN
CFG_SESSION_NUMBER=$CFG_SESSION_NUMBER
CFG_USE_PRIVATE_MODE=$CFG_USE_PRIVATE_MODE
CFG_LISTEN_PORT=$CFG_LISTEN_PORT
EOF
    echo "配置已保存。"
}

# 初次加载配置
load_config

show_menu() {
    clear_screen
    echo "=========================="
    echo " Grok Chat Proxy 启动器 (配置: $CONFIG_FILE)"
    echo "=========================="
    echo ""
    echo "当前配置:"
    echo "  使用 Cookies (-c)      : $CFG_USE_COOKIES"
    echo "  无头模式运行 (-h)    : $CFG_RUN_HEADLESS"
    echo "  API Token (-i)         : $CFG_API_TOKEN"
    echo "  会话数量 (-n)        : $CFG_SESSION_NUMBER"
    echo "  使用隐私模式 (-p)    : $CFG_USE_PRIVATE_MODE"
    echo "  监听端口 (-port)     : $CFG_LISTEN_PORT"
    echo ""
    echo "选择一个选项:"
    echo "1. 配置参数"
    echo "2. 启动应用 (grok-chat-proxy2.exe)"
    echo "3. 退出"
    echo ""
    read -p "请输入你的选择 (1-3): " choice
}

configure_settings() {
    clear_screen
    echo "--- 配置参数 ---"
    echo "对于 是/否 选项, 请输入 'y' 或 'n'."
    echo "对于其他选项, 请输入期望的值."
    echo "直接按 Enter 键将保留当前值."
    echo ""

    local TEMP_INPUT

    read -p "是否使用cookie文件(y)/手动登录(n)，初次启动建议手动登录提取cookie，后续启动改为cookie登录? (y/n) [当前: $CFG_USE_COOKIES]: " TEMP_INPUT
    if [[ -n "$TEMP_INPUT" ]]; then
        if [[ "$TEMP_INPUT" == "y" || "$TEMP_INPUT" == "Y" ]]; then
            CFG_USE_COOKIES="y"
        elif [[ "$TEMP_INPUT" == "n" || "$TEMP_INPUT" == "N" ]]; then
            CFG_USE_COOKIES="n"
        else
            echo "无效输入，配置未更改。"
        fi
    fi

    read -p "以无头模式(不显示浏览器页面，但可能被block)? (y/n) [当前: $CFG_RUN_HEADLESS]: " TEMP_INPUT
    if [[ -n "$TEMP_INPUT" ]]; then
        if [[ "$TEMP_INPUT" == "y" || "$TEMP_INPUT" == "Y" ]]; then
            CFG_RUN_HEADLESS="y"
        elif [[ "$TEMP_INPUT" == "n" || "$TEMP_INPUT" == "N" ]]; then
            CFG_RUN_HEADLESS="n"
        else
            echo "无效输入，配置未更改。"
        fi
    fi
    
    local CURRENT_TOKEN_DISPLAY="$CFG_API_TOKEN"
    if [[ -z "$CURRENT_TOKEN_DISPLAY" ]]; then CURRENT_TOKEN_DISPLAY="[空]"; fi
    read -p "API密码 (-i) [当前: $CURRENT_TOKEN_DISPLAY]: " TEMP_INPUT
    if [[ -n "$TEMP_INPUT" ]]; then
        CFG_API_TOKEN="$TEMP_INPUT"
    else 
        if [[ -n "$CFG_API_TOKEN" ]]; then 
            read -p "API Token 当前已设置。按 Enter 保留，或输入 'clear' (然后按Enter) 来清空它: " CONFIRM_TOKEN_CLEAR
            if [[ "$CONFIRM_TOKEN_CLEAR" == "clear" ]]; then
                CFG_API_TOKEN=""
            fi
        fi
    fi

    read -p "手动登录账号数量 (-n) [当前: $CFG_SESSION_NUMBER]: " TEMP_INPUT
    if [[ -n "$TEMP_INPUT" ]]; then
        CFG_SESSION_NUMBER="$TEMP_INPUT"
    elif [[ -z "$TEMP_INPUT" && "$CFG_SESSION_NUMBER" != "0" ]]; then
        read -p "数量将设为0 (默认)。按 Enter 确认，或重新输入值: " CONFIRM_CLEAR
        if [[ -z "$CONFIRM_CLEAR" ]]; then CFG_SESSION_NUMBER="0"; fi
    fi

    read -p "使用隐私模式（不保存聊天记录） (-p)? (y/n) [当前: $CFG_USE_PRIVATE_MODE]: " TEMP_INPUT
    if [[ -n "$TEMP_INPUT" ]]; then
        if [[ "$TEMP_INPUT" == "y" || "$TEMP_INPUT" == "Y" ]]; then
            CFG_USE_PRIVATE_MODE="y"
        elif [[ "$TEMP_INPUT" == "n" || "$TEMP_INPUT" == "N" ]]; then
            CFG_USE_PRIVATE_MODE="n"
        else
            echo "无效输入，配置未更改。"
        fi
    fi

    read -p "监听端口 (-port) [当前: $CFG_LISTEN_PORT]: " TEMP_INPUT
    if [[ -n "$TEMP_INPUT" ]]; then
        CFG_LISTEN_PORT="$TEMP_INPUT"
    elif [[ -z "$TEMP_INPUT" && "$CFG_LISTEN_PORT" != "9867" ]]; then
        read -p "端口将设为9867 (默认)。按 Enter 确认，或重新输入值: " CONFIRM_CLEAR_PORT
        if [[ -z "$CONFIRM_CLEAR_PORT" ]]; then CFG_LISTEN_PORT="9867"; fi
    fi
    
    save_config
    echo ""
    echo "配置已更新并保存到 $CONFIG_FILE。按任意键返回主菜单。"
    read -n 1 -s
}

start_application() {
    clear_screen
    echo "--- 正在启动应用 ---"
    CMD_ARGS=""
    if [[ "$CFG_USE_COOKIES" == "y" ]]; then
        CMD_ARGS+=" -c"
    fi
    if [[ "$CFG_RUN_HEADLESS" == "y" ]]; then
        CMD_ARGS+=" -h"
    fi
    if [[ -n "$CFG_API_TOKEN" ]]; then
        CMD_ARGS+=" -i \"$CFG_API_TOKEN\"" 
    fi
    
    local session_num_val=0
    if [[ "$CFG_SESSION_NUMBER" =~ ^[0-9]+$ ]]; then
       session_num_val=$CFG_SESSION_NUMBER
    fi
    if [[ "$session_num_val" -ne 0 ]]; then
        CMD_ARGS+=" -n $session_num_val"
    fi

    if [[ "$CFG_USE_PRIVATE_MODE" == "y" ]]; then
        CMD_ARGS+=" -p"
    fi
    
    local effective_port="$CFG_LISTEN_PORT"
    if [[ -z "$effective_port" || ! "$effective_port" =~ ^[0-9]+$ ]]; then
        effective_port="9867"
    fi
    
    if [[ "$effective_port" != "9867" ]]; then
        CMD_ARGS+=" -port $effective_port"
    fi

    EXECUTABLE_NAME="./grok-chat-proxy2.exe"

    echo "正在运行: $EXECUTABLE_NAME $CMD_ARGS"

    if [ ! -f "$EXECUTABLE_NAME" ]; then
        echo "错误: $EXECUTABLE_NAME 未在当前目录中找到。"
        echo "请确保 grok-chat-proxy2.exe 文件存在于此脚本所在的目录中。"
        echo "通常, 你可以使用 build.bat 来编译它。"
        read -n 1 -s -p "按任意键返回主菜单。"
        return
    fi
    
    eval "$EXECUTABLE_NAME $CMD_ARGS &"
    
    echo ""
    echo "已尝试启动应用: $EXECUTABLE_NAME"
    echo "如果它是一个服务器应用, 它应该在后台运行 (可能在一个新的 Windows 窗口中，如果在 WSL 中启动)。"
    echo "请检查你的系统进程或应用日志以确认其状态。"
    echo "按任意键返回主菜单。"
    read -n 1 -s
}

# 主循环
while true; do
    show_menu
    case "$choice" in
        1)
            configure_settings
            ;;
        2)
            start_application
            ;;
        3)
            clear_screen
            echo "已退出。"
            exit 0
            ;;
        *)
            echo "无效选择。按任意键重试。"
            read -n 1 -s
            ;;
    esac
done