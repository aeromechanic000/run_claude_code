#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Default Settings
CC_PROVIDER="MEGREZ"
ENABLE_TEAMS=0
AUTO_MODE=0
EXTRA_ARGS=""

# --- Provider Configurations ---
MEGREZ_BASE_URL=https://enhance.megrez.plus/api/code
MEGREZ_PRIMARY_MODEL=code
MEGREZ_SECONDARY_MODEL=code
MEGREZ_LITE_MODEL=code
# MEGREZ_API_KEY=""

# New: OpenRouter Configuration (May 2026 Free Tier SOTA)
OPENROUTER_BASE_URL=https://openrouter.ai/api
OPENROUTER_PRIMARY_MODEL=qwen/qwen-3.6-plus:free        # Current king of coding tokens
OPENROUTER_SECONDARY_MODEL=nvidia/nemotron-3-super:free  # Best for complex refactoring
OPENROUTER_LITE_MODEL=stepfun/step-3.5-flash:free        # Ultra-fast for small edits

GLM_BASE_URL=https://api.z.ai/api/anthropic
GLM_PRIMARY_MODEL=GLM-5.1
GLM_SECONDARY_MODEL=GLM-5.1
GLM_LITE_MODEL=GLM-4.7

KIMI_BASE_URL=https://api.kimi.com/coding/
KIMI_PRIMARY_MODEL=kimi-for-coding
KIMI_SECONDARY_MODEL=kimi-for-coding
KIMI_LITE_MODEL=kimi-for-coding

MINIMAX_BASE_URL=https://api.minimax.io/anthropic
MINIMAX_PRIMARY_MODEL=MiniMax-M2.1
MINIMAX_SECONDARY_MODEL=MiniMax-M2.1
MINIMAX_LITE_MODEL=MiniMax-M2-Stable

DEEPSEEK_BASE_URL=https://api.deepseek.com/anthropic
DEEPSEEK_PRIMARY_MODEL=deepseek-chat
DEEPSEEK_SECONDARY_MODEL=deepseek-chat
DEEPSEEK_LITE_MODEL=deepseek-chat

QWENCODE_BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic
QWENCODE_PRIMARY_MODEL=qwen3.5-plus
QWENCODE_SECONDARY_MODEL=qwen3.5-plus
QWENCODE_LITE_MODEL=qwen3.5-plus

DOUBAO_BASE_URL=https://ark.cn-beijing.volces.com/api/coding
DOUBAO_PRIMARY_MODEL=doubao-seed-code-preview-latest
DOUBAO_SECONDARY_MODEL=doubao-seed-code-preview-latest
DOUBAO_LITE_MODEL=doubao-seed-code-preview-latest

# --- Argument Parsing ---
usage() {
    echo "Usage: $0 [-p PROVIDER] [--team] [--auto]"
    echo "Providers: MEGREZ, OPENROUTER, GLM, KIMI, QWENCODE, DEEPSEEK, MINIMAX, DOUBAO"
    exit 1
}

# Loop to handle arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p) CC_PROVIDER="$2"; shift ;;
        --team) ENABLE_TEAMS=1 ;;
        --auto) AUTO_MODE=1 ;;
        -h|--help) usage ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; usage ;;
    esac
    shift
done

CC_PROVIDER=$(echo "$CC_PROVIDER" | tr '[:lower:]' '[:upper:]')

# --- Validation & Env Setup ---
case "$CC_PROVIDER" in
    MEGREZ|OPENROUTER|GLM|KIMI|QWENCODE|DEEPSEEK|MINIMAX|DOUBAO) ;;
    *) echo -e "${RED}Error: Unknown provider '$CC_PROVIDER'${NC}"; usage ;;
esac

BASE_URL_VAR="${CC_PROVIDER}_BASE_URL"
API_KEY_VAR="${CC_PROVIDER}_API_KEY"
PRIMARY_MODEL_VAR="${CC_PROVIDER}_PRIMARY_MODEL"
SECONDARY_MODEL_VAR="${CC_PROVIDER}_SECONDARY_MODEL"
LITE_MODEL_VAR="${CC_PROVIDER}_LITE_MODEL"

export ANTHROPIC_BASE_URL=${!BASE_URL_VAR}
export ANTHROPIC_AUTH_TOKEN=${!API_KEY_VAR}
export ANTHROPIC_API_KEY=""
export ANTHROPIC_DEFAULT_OPUS_MODEL=${!PRIMARY_MODEL_VAR}
export ANTHROPIC_DEFAULT_SONNET_MODEL=${!SECONDARY_MODEL_VAR}
export ANTHROPIC_DEFAULT_HAIKU_MODEL=${!LITE_MODEL_VAR}

# Toggle Agent Teams
if [ "$ENABLE_TEAMS" -eq 1 ]; then
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
    TEAM_STATUS="${GREEN}Enabled${NC}"
else
    unset CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
    TEAM_STATUS="${RED}Disabled${NC}"
fi

# Prepare CLI Flags
if [ "$AUTO_MODE" -eq 1 ]; then
    EXTRA_ARGS="--enable-auto-mode"
    AUTO_STATUS="${GREEN}Enabled (Flag: --enable-auto-mode)${NC}"
else
    EXTRA_ARGS=""
    AUTO_STATUS="${YELLOW}Disabled${NC}"
fi

# --- API Key Check ---
if [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
    echo -e "\n${RED}✗ ERROR: API Key Not Found for $CC_PROVIDER${NC}"
    echo -e "${YELLOW}Please set: export ${API_KEY_VAR}=your_key${NC}\n"
    exit 1
fi

# --- Status Display ---
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}🚀 Claude CLI Wrapper | Agent Status${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Provider:${NC}      ${YELLOW}$CC_PROVIDER${NC}"
echo -e "${GREEN}Agent Teams:${NC}   $TEAM_STATUS"
echo -e "${GREEN}Auto Mode:${NC}     $AUTO_STATUS"
echo -e "${GREEN}Base URL:${NC}      ${MAGENTA}$ANTHROPIC_BASE_URL${NC}"

if [ "$ANTHROPIC_DEFAULT_OPUS_MODEL" == "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && \
   [ "$ANTHROPIC_DEFAULT_SONNET_MODEL" == "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ]; then
    echo -e "${GREEN}Model Mode:${NC}    ${BOLD}Unified (${ANTHROPIC_DEFAULT_SONNET_MODEL})${NC}"
else
    echo -e "${GREEN}Opus Model:${NC}    ${BOLD}$ANTHROPIC_DEFAULT_OPUS_MODEL${NC}"
    echo -e "${GREEN}Sonnet Model:${NC}  ${BOLD}$ANTHROPIC_DEFAULT_SONNET_MODEL${NC}"
    echo -e "${GREEN}Haiku Model:${NC}   ${BOLD}$ANTHROPIC_DEFAULT_HAIKU_MODEL${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Execute Claude CLI
claude $EXTRA_ARGS
