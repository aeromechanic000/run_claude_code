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
EXTRA_ARGS=""

# --- Provider Configurations ---
MEGREZ_BASE_URL=https://enhance.megrez.plus/api/code
MEGREZ_LEAD_MODEL=code
MEGREZ_PRIMARY_MODEL=code
MEGREZ_SECONDARY_MODEL=code
MEGREZ_LITE_MODEL=code

OPENROUTER_BASE_URL=https://openrouter.ai/api
OPENROUTER_LEAD_MODEL=openai/gpt-oss-120b:free
OPENROUTER_PRIMARY_MODEL=openai/gpt-oss-120b:free
OPENROUTER_SECONDARY_MODEL=z-ai/glm-4.5-air:free
OPENROUTER_LITE_MODEL=minimax/minimax-m2.5:free

NIM_BASE_URL=https://integrate.api.nvidia.com/v1
NIM_LEAD_MODEL=z-ai/glm-5.2
NIM_PRIMARY_MODEL=z-ai/glm-5.2
NIM_SECONDARY_MODEL=z-ai/glm-5.2
NIM_LITE_MODEL=z-ai/glm-5.2

POLARIS_BASE_URL=http://localhost:11565
POLARIS_LEAD_MODEL=code
POLARIS_PRIMARY_MODEL=code
POLARIS_SECONDARY_MODEL=code
POLARIS_LITE_MODEL=code

LITELLM_BASE_URL=http://localhost:4000
LITELLM_LEAD_MODEL=code
LITELLM_PRIMARY_MODEL=code
LITELLM_SECONDARY_MODEL=code
LITELLM_LITE_MODEL=code

OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_LEAD_MODEL=qwen3.5:2b
OLLAMA_PRIMARY_MODEL=qwen3.5:2b
OLLAMA_SECONDARY_MODEL=qwen3.5:2b
OLLAMA_LITE_MODEL=qwen3.5:2b

GLM_BASE_URL=https://api.z.ai/api/anthropic
GLM_LEAD_MODEL=GLM-5.3
GLM_PRIMARY_MODEL=GLM-5.3
GLM_SECONDARY_MODEL=GLM-5.3
GLM_LITE_MODEL=GLM-5.2

KIMI_BASE_URL=https://api.kimi.com/coding/
KIMI_LEAD_MODEL="kimi-k3[1m]"
KIMI_PRIMARY_MODEL="kimi-k3[1m]"
KIMI_SECONDARY_MODEL="kimi-k3[1m]"
KIMI_LITE_MODEL="kimi-k2.7-code"

MINIMAX_BASE_URL=https://api.minimax.io/anthropic
MINIMAX_LEAD_MODEL=MiniMax-M2.1
MINIMAX_PRIMARY_MODEL=MiniMax-M2.1
MINIMAX_SECONDARY_MODEL=MiniMax-M2.1
MINIMAX_LITE_MODEL=MiniMax-M2-Stable

DEEPSEEK_BASE_URL=https://api.deepseek.com/anthropic
DEEPSEEK_LEAD_MODEL=deepseek-v4-flash
DEEPSEEK_PRIMARY_MODEL=deepseek-v4-flash
DEEPSEEK_SECONDARY_MODEL=deepseek-v4-flash
DEEPSEEK_LITE_MODEL=deepseek-v4-pro

QWENCODE_BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic
QWENCODE_LEAD_MODEL=qwen3.5-plus
QWENCODE_PRIMARY_MODEL=qwen3.5-plus
QWENCODE_SECONDARY_MODEL=qwen3.5-plus
QWENCODE_LITE_MODEL=qwen3.5-plus

DOUBAOCODE_BASE_URL=https://ark.cn-beijing.volces.com/api/coding
DOUBAOCODE_LEAD_MODEL=doubao-seed-code-preview-latest
DOUBAOCODE_PRIMARY_MODEL=doubao-seed-code-preview-latest
DOUBAOCODE_SECONDARY_MODEL=doubao-seed-code-preview-latest
DOUBAOCODE_LITE_MODEL=doubao-seed-code-preview-latest

# --- Argument Parsing ---
usage() {
    echo "Usage: $0 [-p PROVIDER] [--team] [--auto]"
    echo "Providers: MEGREZ, POLARIS, LITELLM,OPENROUTER, NIM, OLLAMA, GLM, KIMI, QWENCODE, DEEPSEEK, MINIMAX, DOUBAOCODE"
    exit 1
}

# Loop to handle arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p) CC_PROVIDER="$2"; shift ;;
        --team) ENABLE_TEAMS=1 ;;
        -h|--help) usage ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; usage ;;
    esac
    shift
done

CC_PROVIDER=$(echo "$CC_PROVIDER" | tr '[:lower:]' '[:upper:]')

# --- Validation & Env Setup ---
case "$CC_PROVIDER" in
    MEGREZ|POLARIS|LITELLM|OPENROUTER|NIM|OLLAMA|GLM|KIMI|QWENCODE|DEEPSEEK|MINIMAX|DOUBAOCODE) ;;
    *) echo -e "${RED}Error: Unknown provider '$CC_PROVIDER'${NC}"; usage ;;
esac

BASE_URL_VAR="${CC_PROVIDER}_BASE_URL"
API_KEY_VAR="${CC_PROVIDER}_API_KEY"
PRIMARY_MODEL_VAR="${CC_PROVIDER}_PRIMARY_MODEL"
SECONDARY_MODEL_VAR="${CC_PROVIDER}_SECONDARY_MODEL"
LITE_MODEL_VAR="${CC_PROVIDER}_LITE_MODEL"
LEAD_MODEL_VAR="${CC_PROVIDER}_LEAD_MODEL"

export COLORTERM=truecolor
export ANTHROPIC_BASE_URL=${!BASE_URL_VAR}
export ANTHROPIC_AUTH_TOKEN=${!API_KEY_VAR}
export ANTHROPIC_API_KEY=""
export ANTHROPIC_DEFAULT_OPUS_MODEL=${!PRIMARY_MODEL_VAR}
export ANTHROPIC_DEFAULT_SONNET_MODEL=${!SECONDARY_MODEL_VAR}
export ANTHROPIC_DEFAULT_HAIKU_MODEL=${!LITE_MODEL_VAR}
export ANTHROPIC_DEFAULT_FABLE_MODEL=${!LEAD_MODEL_VAR}

# Toggle Agent Teams
if [ "$ENABLE_TEAMS" -eq 1 ]; then
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
    TEAM_STATUS="${GREEN}Enabled${NC}"
else
    unset CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS
    TEAM_STATUS="${YELLOW}Disabled${NC}"
fi

# Prepare CLI Flags
EXTRA_ARGS=""

# --- API Key Check ---
if [ "$CC_PROVIDER" != "OLLAMA" ] && [ "$CC_PROVIDER" != "POLARIS" ] && [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
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
echo -e "${GREEN}Base URL:${NC}      ${MAGENTA}$ANTHROPIC_BASE_URL${NC}"

if [ "$ANTHROPIC_DEFAULT_FABLE_MODEL" == "$ANTHROPIC_DEFAULT_OPUS_MODEL" ] && \
   [ "$ANTHROPIC_DEFAULT_OPUS_MODEL" == "$ANTHROPIC_DEFAULT_SONNET_MODEL" ] && \
   [ "$ANTHROPIC_DEFAULT_SONNET_MODEL" == "$ANTHROPIC_DEFAULT_HAIKU_MODEL" ]; then
    echo -e "${GREEN}Model Mode:${NC}    ${BOLD}Unified (${ANTHROPIC_DEFAULT_FABLE_MODEL})${NC}"
else
    echo -e "${GREEN}Fable Model:${NC}   ${BOLD}$ANTHROPIC_DEFAULT_FABLE_MODEL${NC}"
    echo -e "${GREEN}Opus Model:${NC}    ${BOLD}$ANTHROPIC_DEFAULT_OPUS_MODEL${NC}"
    echo -e "${GREEN}Sonnet Model:${NC}  ${BOLD}$ANTHROPIC_DEFAULT_SONNET_MODEL${NC}"
    echo -e "${GREEN}Haiku Model:${NC}   ${BOLD}$ANTHROPIC_DEFAULT_HAIKU_MODEL${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Execute Claude CLI
claude $EXTRA_ARGS
