@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: ========== ANSI颜色转义 Win10+ ==========
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=!ESC![0;31m"
set "GREEN=!ESC![0;32m"
set "YELLOW=!ESC![1;33m"
set "BLUE=!ESC![0;34m"
set "MAGENTA=!ESC![0;35m"
set "CYAN=!ESC![0;36m"
set "BOLD=!ESC![1m"
set "NC=!ESC![0m"

:: ========== 默认设置 ==========
set "CC_PROVIDER=MEGREZ"
set "ENABLE_TEAMS=0"
set "EXTRA_ARGS="

:: ========== Provider配置 ==========
set "MEGREZ_BASE_URL=https://enhance.megrez.plus/api/code"
set "MEGREZ_LEAD_MODEL=code"
set "MEGREZ_PRIMARY_MODEL=code"
set "MEGREZ_SECONDARY_MODEL=code"
set "MEGREZ_LITE_MODEL=code"

set "OPENROUTER_BASE_URL=https://openrouter.ai/api"
set "OPENROUTER_LEAD_MODEL=openai/gpt-oss-120b:free"
set "OPENROUTER_PRIMARY_MODEL=openai/gpt-oss-120b:free"
set "OPENROUTER_SECONDARY_MODEL=z-ai/glm-4.5-air:free"
set "OPENROUTER_LITE_MODEL=minimax/minimax-m2.5:free"

set "NIM_BASE_URL=https://integrate.api.nvidia.com/v1"
set "NIM_LEAD_MODEL=z-ai/glm-5.2"
set "NIM_PRIMARY_MODEL=z-ai/glm-5.2"
set "NIM_SECONDARY_MODEL=z-ai/glm-5.2"
set "NIM_LITE_MODEL=z-ai/glm-5.2"

set "POLARIS_BASE_URL=http://localhost:11565"
set "POLARIS_LEAD_MODEL=code"
set "POLARIS_PRIMARY_MODEL=code"
set "POLARIS_SECONDARY_MODEL=code"
set "POLARIS_LITE_MODEL=code"

set "LITELLM_BASE_URL=http://localhost:4000"
set "LITELLM_LEAD_MODEL=code"
set "LITELLM_PRIMARY_MODEL=code"
set "LITELLM_SECONDARY_MODEL=code"
set "LITELLM_LITE_MODEL=code"

set "OLLAMA_BASE_URL=http://localhost:11434"
set "OLLAMA_LEAD_MODEL=qwen3.5:2b"
set "OLLAMA_PRIMARY_MODEL=qwen3.5:2b"
set "OLLAMA_SECONDARY_MODEL=qwen3.5:2b"
set "OLLAMA_LITE_MODEL=qwen3.5:2b"

set "GLM_BASE_URL=https://api.z.ai/api/anthropic"
set "GLM_LEAD_MODEL=GLM-5.3"
set "GLM_PRIMARY_MODEL=GLM-5.3"
set "GLM_SECONDARY_MODEL=GLM-5.3"
set "GLM_LITE_MODEL=GLM-5.2"

set "KIMI_BASE_URL=https://api.kimi.com/coding/"
set "KIMI_LEAD_MODEL=kimi-k3[1m]"
set "KIMI_PRIMARY_MODEL=kimi-k3[1m]"
set "KIMI_SECONDARY_MODEL=kimi-k3[1m]"
set "KIMI_LITE_MODEL=kimi-k2.7-code"

set "MINIMAX_BASE_URL=https://api.minimax.io/anthropic"
set "MINIMAX_LEAD_MODEL=MiniMax-M2.1"
set "MINIMAX_PRIMARY_MODEL=MiniMax-M2.1"
set "MINIMAX_SECONDARY_MODEL=MiniMax-M2.1"
set "MINIMAX_LITE_MODEL=MiniMax-M2-Stable"

set "DEEPSEEK_BASE_URL=https://api.deepseek.com/anthropic"
set "DEEPSEEK_LEAD_MODEL=deepseek-v4-flash"
set "DEEPSEEK_PRIMARY_MODEL=deepseek-v4-flash"
set "DEEPSEEK_SECONDARY_MODEL=deepseek-v4-flash"
set "DEEPSEEK_LITE_MODEL=deepseek-v4-pro"

set "QWENCODE_BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic"
set "QWENCODE_LEAD_MODEL=qwen3.5-plus"
set "QWENCODE_PRIMARY_MODEL=qwen3.5-plus"
set "QWENCODE_SECONDARY_MODEL=qwen3.5-plus"
set "QWENCODE_LITE_MODEL=qwen3.5-plus"

set "DOUBAOCODE_BASE_URL=https://ark.cn-beijing.volces.com/api/coding"
set "DOUBAOCODE_LEAD_MODEL=doubao-seed-code-preview-latest"
set "DOUBAOCODE_PRIMARY_MODEL=doubao-seed-code-preview-latest"
set "DOUBAOCODE_SECONDARY_MODEL=doubao-seed-code-preview-latest"
set "DOUBAOCODE_LITE_MODEL=doubao-seed-code-preview-latest"

:: ========== 跳过帮助信息，先解析参数 ==========
goto :parse_args

:: ========== 帮助信息 ==========
:usage
echo Usage: %~nx0 [-p PROVIDER] [--team] [extra claude args...]
echo Providers: MEGREZ, POLARIS, LITELLM, OPENROUTER, NIM, OLLAMA, GLM, KIMI, QWENCODE, DEEPSEEK, MINIMAX, DOUBAOCODE
endlocal
exit /b 1

:: ========== shift-based argument parser ==========
:: 注意: 不能把 shift 和 %~1 放在同一个括号块里 (百分号变量在整个块解析时就已展开)
:parse_args
if "%~1"=="" goto args_done
if /i "%~1"=="-p" goto arg_provider
if /i "%~1"=="--team" goto arg_team
if /i "%~1"=="-h" goto usage
if /i "%~1"=="--help" goto usage

:: 未识别的参数原样转发给 claude
set "EXTRA_ARGS=!EXTRA_ARGS! %~1"
shift
goto parse_args

:arg_provider
shift
if "%~1"=="" goto usage
set "CC_PROVIDER=%~1"
shift
goto parse_args

:arg_team
set "ENABLE_TEAMS=1"
shift
goto parse_args

:args_done

:: ========== Provider名称转大写 ==========
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "CC_PROVIDER=!CC_PROVIDER:%%A=%%A!"

:: ========== Provider白名单检查 ==========
set "VALID=0"
for %%P in (MEGREZ POLARIS LITELLM OPENROUTER NIM OLLAMA GLM KIMI QWENCODE DEEPSEEK MINIMAX DOUBAOCODE) do (
    if /i "!CC_PROVIDER!"=="%%P" set "VALID=1"
)
if "!VALID!"=="0" (
    echo !RED!Error: Unknown provider '!CC_PROVIDER!'!NC!
    goto :usage
)

:: ========== 读取对应Provider变量 ==========
set "ANTHROPIC_BASE_URL=!%CC_PROVIDER%_BASE_URL!"
set "ANTHROPIC_AUTH_TOKEN=!%CC_PROVIDER%_API_KEY!"
set "ANTHROPIC_DEFAULT_OPUS_MODEL=!%CC_PROVIDER%_PRIMARY_MODEL!"
set "ANTHROPIC_DEFAULT_SONNET_MODEL=!%CC_PROVIDER%_SECONDARY_MODEL!"
set "ANTHROPIC_DEFAULT_HAIKU_MODEL=!%CC_PROVIDER%_LITE_MODEL!"
set "ANTHROPIC_DEFAULT_FABLE_MODEL=!%CC_PROVIDER%_LEAD_MODEL!"

:: 设置环境变量
set "COLORTERM=truecolor"
set "ANTHROPIC_API_KEY="

:: Agent Teams开关
if "!ENABLE_TEAMS!"=="1" (
    set "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
    set "TEAM_STATUS=!GREEN!Enabled!NC!"
) else (
    set "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS="
    set "TEAM_STATUS=!YELLOW!Disabled!NC!"
)

:: ========== API Key检查 (跳过OLLAMA/POLARIS) ==========
if not "!CC_PROVIDER!"=="OLLAMA" if not "!CC_PROVIDER!"=="POLARIS" (
    if "!ANTHROPIC_AUTH_TOKEN!"=="" (
        echo.
        echo !RED!✗ ERROR: API Key Not Found for !CC_PROVIDER!!NC!
        echo !YELLOW!Please set environment variable: !CC_PROVIDER!_API_KEY=your_key!NC!
        echo.
        goto :exit_err
    )
)

:: ========== 状态打印 ==========
echo.
echo !BLUE!═══════════════════════════════════════════════════════!NC!
echo !CYAN!🚀 Claude CLI Wrapper ^| Agent Status!NC!
echo !BLUE!═══════════════════════════════════════════════════════!NC!
echo !GREEN!Provider:!NC!      !YELLOW!!CC_PROVIDER!!NC!
echo !GREEN!Agent Teams:!NC!   !TEAM_STATUS!
echo !GREEN!Base URL:!NC!      !MAGENTA!!ANTHROPIC_BASE_URL!!NC!

set "MODEL_SAME=0"
if "!ANTHROPIC_DEFAULT_FABLE_MODEL!"=="!ANTHROPIC_DEFAULT_OPUS_MODEL!" (
    if "!ANTHROPIC_DEFAULT_OPUS_MODEL!"=="!ANTHROPIC_DEFAULT_SONNET_MODEL!" (
        if "!ANTHROPIC_DEFAULT_SONNET_MODEL!"=="!ANTHROPIC_DEFAULT_HAIKU_MODEL!" (
            set "MODEL_SAME=1"
        )
    )
)

if "!MODEL_SAME!"=="1" (
    echo !GREEN!Model Mode:!NC!    !BOLD!Unified ^(!ANTHROPIC_DEFAULT_FABLE_MODEL!^)!NC!
) else (
    echo !GREEN!Fable Model:!NC!   !BOLD!!ANTHROPIC_DEFAULT_FABLE_MODEL!!NC!
    echo !GREEN!Opus Model:!NC!    !BOLD!!ANTHROPIC_DEFAULT_OPUS_MODEL!!NC!
    echo !GREEN!Sonnet Model:!NC!  !BOLD!!ANTHROPIC_DEFAULT_SONNET_MODEL!!NC!
    echo !GREEN!Haiku Model:!NC!   !BOLD!!ANTHROPIC_DEFAULT_HAIKU_MODEL!!NC!
)
echo !BLUE!═══════════════════════════════════════════════════════!NC!
echo.

:: ========== 执行 claude cli ==========
claude --fallback-model "!ANTHROPIC_DEFAULT_HAIKU_MODEL!" !EXTRA_ARGS!
endlocal
goto :eof

:exit_err
endlocal
exit /b 1