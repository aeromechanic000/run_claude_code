@echo off
setlocal enabledelayedexpansion

REM --- Color Definitions (ANSI escape codes, requires Windows 10+) ---
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "RED=!ESC![0;31m"
set "GREEN=!ESC![0;32m"
set "YELLOW=!ESC![1;33m"
set "BLUE=!ESC![0;34m"
set "MAGENTA=!ESC![0;35m"
set "CYAN=!ESC![0;36m"
set "BOLD=!ESC![1m"
set "NC=!ESC![0m"

REM --- Default Settings ---
set "CC_PROVIDER=MEGREZ"
set "ENABLE_TEAMS=0"
set "AUTO_MODE=0"
set "EXTRA_ARGS="

REM --- Provider Configurations ---
set "MEGREZ_BASE_URL=https://enhance.megrez.plus/api/code"
set "MEGREZ_PRIMARY_MODEL=code"
set "MEGREZ_SECONDARY_MODEL=code"
set "MEGREZ_LITE_MODEL=code"
set "MEGREZ_CODE_SUBAGENT_MODEL=code"

set "OPENROUTER_BASE_URL=https://openrouter.ai/api"
set "OPENROUTER_PRIMARY_MODEL=openai/gpt-oss-120b:free"
set "OPENROUTER_SECONDARY_MODEL=z-ai/glm-4.5-air:free"
set "OPENROUTER_LITE_MODEL=minimax/minimax-m2.5:free"
set "OPENROUTER_CODE_SUBAGENT_MODEL=minimax/minimax-m2.5:free"

set "POLARIS_BASE_URL=http://localhost:11565"
set "POLARIS_PRIMARY_MODEL=code"
set "POLARIS_SECONDARY_MODEL=code"
set "POLARIS_LITE_MODEL=code"
set "POLARIS_CODE_SUBAGENT_MODEL=code"

set "OLLAMA_BASE_URL=http://localhost:11434"
set "OLLAMA_PRIMARY_MODEL=qwen3.5:2b"
set "OLLAMA_SECONDARY_MODEL=qwen3.5:2b"
set "OLLAMA_LITE_MODEL=qwen3.5:2b"
set "OLLAMA_CODE_SUBAGENT_MODEL=qwen3.5:2b"

set "GLM_BASE_URL=https://api.z.ai/api/anthropic"
set "GLM_PRIMARY_MODEL=GLM-5.1"
set "GLM_SECONDARY_MODEL=GLM-5.1"
set "GLM_LITE_MODEL=GLM-4.7"
set "GLM_CODE_SUBAGENT_MODEL=GLM-4.7"

set "KIMI_BASE_URL=https://api.kimi.com/coding/"
set "KIMI_PRIMARY_MODEL=kimi-for-coding"
set "KIMI_SECONDARY_MODEL=kimi-for-coding"
set "KIMI_LITE_MODEL=kimi-for-coding"
set "KIMI_CODE_SUBAGENT_MODEL=kimi-for-coding"

set "MINIMAX_BASE_URL=https://api.minimax.io/anthropic"
set "MINIMAX_PRIMARY_MODEL=MiniMax-M2.1"
set "MINIMAX_SECONDARY_MODEL=MiniMax-M2.1"
set "MINIMAX_LITE_MODEL=MiniMax-M2-Stable"
set "MINIMAX_CODE_SUBAGENT_MODEL=MiniMax-M2-Stable"

set "DEEPSEEK_BASE_URL=https://api.deepseek.com/anthropic"
set "DEEPSEEK_PRIMARY_MODEL=deepseek-chat"
set "DEEPSEEK_SECONDARY_MODEL=deepseek-chat"
set "DEEPSEEK_LITE_MODEL=deepseek-chat"
set "DEEPSEEK_CODE_SUBAGENT_MODEL=deepseek-chat"

set "QWENCODE_BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic"
set "QWENCODE_PRIMARY_MODEL=qwen3.5-plus"
set "QWENCODE_SECONDARY_MODEL=qwen3.5-plus"
set "QWENCODE_LITE_MODEL=qwen3.5-plus"
set "QWENCODE_CODE_SUBAGENT_MODEL=qwen3.5-plus"

set "DOUBAO_BASE_URL=https://ark.cn-beijing.volces.com/api/coding"
set "DOUBAO_PRIMARY_MODEL=GLM-5.1"
set "DOUBAO_SECONDARY_MODEL=doubao-seed-code-preview-latest"
set "DOUBAO_LITE_MODEL=doubao-seed-code-preview-latest"
set "DOUBAO_CODE_SUBAGENT_MODEL=doubao-seed-code-preview-latest"

REM --- Argument Parsing ---
:parse_args
if "%~1"=="" goto end_parse

if /i "%~1"=="-p" (
    set "CC_PROVIDER=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--team" (
    set "ENABLE_TEAMS=1"
    shift
    goto parse_args
)
if /i "%~1"=="--auto" (
    set "AUTO_MODE=1"
    shift
    goto parse_args
)
if /i "%~1"=="-h" goto usage
if /i "%~1"=="--help" goto usage

echo !RED!Unknown parameter: %~1!NC!
goto usage

:end_parse

REM --- Uppercase Conversion & Validation ---
set "CC_PROVIDER_VALID=0"
for %%p in (MEGREZ POLARIS OPENROUTER OLLAMA GLM KIMI QWENCODE DEEPSEEK MINIMAX DOUBAO) do (
    if /i "!CC_PROVIDER!"=="%%p" (
        set "CC_PROVIDER=%%p"
        set "CC_PROVIDER_VALID=1"
    )
)

if "!CC_PROVIDER_VALID!"=="0" (
    echo !RED!Error: Unknown provider '!CC_PROVIDER!'!NC!
    goto usage
)

REM --- Environment Variable Setup (indirect access via call set) ---
set "BASE_URL_VAR=!CC_PROVIDER!_BASE_URL"
set "API_KEY_VAR=!CC_PROVIDER!_API_KEY"
set "PRIMARY_MODEL_VAR=!CC_PROVIDER!_PRIMARY_MODEL"
set "SECONDARY_MODEL_VAR=!CC_PROVIDER!_SECONDARY_MODEL"
set "LITE_MODEL_VAR=!CC_PROVIDER!_LITE_MODEL"
set "SUBAGENT_MODEL_VAR=!CC_PROVIDER!_CODE_SUBAGENT_MODEL"

call set "ANTHROPIC_BASE_URL=%%!BASE_URL_VAR!%%"
call set "ANTHROPIC_AUTH_TOKEN=%%!API_KEY_VAR!%%"
set "ANTHROPIC_API_KEY="
call set "ANTHROPIC_DEFAULT_OPUS_MODEL=%%!PRIMARY_MODEL_VAR!%%"
call set "ANTHROPIC_DEFAULT_SONNET_MODEL=%%!SECONDARY_MODEL_VAR!%%"
call set "ANTHROPIC_DEFAULT_HAIKU_MODEL=%%!LITE_MODEL_VAR!%%"
call set "CLAUDE_CODE_SUBAGENT_MODEL=%%!SUBAGENT_MODEL_VAR!%%"

REM --- Toggle Agent Teams ---
if "!ENABLE_TEAMS!"=="1" (
    set "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1"
    set "TEAM_STATUS=!GREEN!Enabled!NC!"
) else (
    set "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS="
    set "TEAM_STATUS=!YELLOW!Disabled!NC!"
)

REM --- Auto Mode ---
if "!AUTO_MODE!"=="1" (
    set "EXTRA_ARGS=--enable-auto-mode"
    set "AUTO_STATUS=!GREEN!Enabled (Flag: --enable-auto-mode)!NC!"
) else (
    set "EXTRA_ARGS="
    set "AUTO_STATUS=!YELLOW!Disabled!NC!"
)

REM --- API Key Check ---
if not "!CC_PROVIDER!"=="OLLAMA" if not "!CC_PROVIDER!"=="POLARIS" if "!ANTHROPIC_AUTH_TOKEN!"=="" (
    echo.
    echo !RED![X] ERROR: API Key Not Found for !CC_PROVIDER!!NC!
    echo !YELLOW!Please set: set !API_KEY_VAR!=your_key!NC!
    echo.
    exit /b 1
)

REM --- Status Display ---
echo.
echo !BLUE!============================================================!NC!
echo !CYAN!  Claude CLI Wrapper ^| Agent Status!NC!
echo !BLUE!============================================================!NC!
echo !GREEN!Provider:!NC!      !YELLOW!!CC_PROVIDER!!NC!
echo !GREEN!Agent Teams:!NC!   !TEAM_STATUS!
echo !GREEN!Auto Mode:!NC!     !AUTO_STATUS!
echo !GREEN!Base URL:!NC!      !MAGENTA!!ANTHROPIC_BASE_URL!!NC!

set "MODELS_EQUAL=0"
if "!ANTHROPIC_DEFAULT_OPUS_MODEL!"=="!ANTHROPIC_DEFAULT_SONNET_MODEL!" (
    if "!ANTHROPIC_DEFAULT_SONNET_MODEL!"=="!ANTHROPIC_DEFAULT_HAIKU_MODEL!" (
        set "MODELS_EQUAL=1"
    )
)

if "!MODELS_EQUAL!"=="1" (
    echo !GREEN!Model Mode:!NC!    !BOLD!Unified ^(!ANTHROPIC_DEFAULT_SONNET_MODEL!^)!NC!
) else (
    echo !GREEN!Opus Model:!NC!    !BOLD!!ANTHROPIC_DEFAULT_OPUS_MODEL!!NC!
    echo !GREEN!Sonnet Model:!NC!  !BOLD!!ANTHROPIC_DEFAULT_SONNET_MODEL!!NC!
    echo !GREEN!Haiku Model:!NC!   !BOLD!!ANTHROPIC_DEFAULT_HAIKU_MODEL!!NC!
)
echo !BLUE!============================================================!NC!
echo.

REM --- Execute Claude CLI ---
claude %EXTRA_ARGS%

endlocal
exit /b

:usage
echo Usage: %~nx0 [-p PROVIDER] [--team] [--auto]
echo Providers: MEGREZ, POLARIS, OPENROUTER, OLLAMA, GLM, KIMI, QWENCODE, DEEPSEEK, MINIMAX, DOUBAO
exit /b 1
