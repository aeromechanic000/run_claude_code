#! /bin/bash

# Install the Claude CLI tool:
# npm install -g @anthropic-ai/claude-code

# Fix the connection issue to claude.com and docs.claude.com: 
# 1. Add following lines to `/private/etc/hosts` (without the # at the beginning) :
# 34.162.46.92    claude.com  
# 34.162.102.82   claude.com  
# 34.162.136.91   claude.com  
# 34.162.142.92   claude.com  
# 34.162.183.95   claude.com  
# 160.79.104.10   docs.claude.com  

# 2. Then flush the DNS cache:
# sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# GLM: You need to set you API key in your environment variable, e.g. GLM_API_KEY=xxx-xxx-xxx-xxx

GLM_BASE_URL=https://api.z.ai/api/anthropic
GLM_PRIMARY_MODEL=GLM-4.6
GLM_SECONDARY_MODEL=GLM-4.6
GLM_LITE_MODEL=GLM-4.5-Air

# KIMI: You need to set you API key in your environment variable, e.g. KIMI_API_KEY=xxx-xxx-xxx-xxx

KIMI_BASE_URL==https://api.moonshot.cn/anthropic/
KIMI_PRIMARY_MODEL=kimi-k2-0905-preview
KIMI_SECONDARY_MODEL=kimi-k2-0905-preview
KIMI_LITE_MODEL=kimi-latest-32k

# MiniMax: You need to set you API key in your environment variable, e.g. MINIMAX_API_KEY=xxx-xxx-xxx-xxx

MINIMAX_BASE_URL==https://api.minimax.io/anthropic
MINIMAX_PRIMARY_MODEL=MiniMax-M2
MINIMAX_SECONDARY_MODEL=MiniMax-M2
MINIMAX_LITE_MODEL=MiniMax-M2-Stable

# DeepSeek: You need to set you API key in your environment variable, e.g. DEEPSEEK_API_KEY=xxx-xxx-xxx-xxx

DEEPSEEK_BASE_URL=https://api.deepseek.com/anthropic
DEEPSEEK_PRIMARY_MODEL=deepseek-chat
DEEPSEEK_SECONDARY_MODEL=deepseek-chat
DEEPSEEK_LITE_MODEL=deepseek-chat

# Qwen: You need to set you API key in your environment variable, e.g. QWEN_API_KEY=xxx-xxx-xxx-xxx

QWEN_BASE_URL=https://dashscope.aliyuncs.com/apps/anthropic
QWEN_PRIMARY_MODEL=qwen3-max
QWEN_SECONDARY_MODEL=qwen3-max
QWEN_LITE_MODEL=qwen3-plus

# Set provider from argument or default to GLM
CC_PROVIDER=${1:-GLM}

# Convert to uppercase for consistency
CC_PROVIDER=$(echo "$CC_PROVIDER" | tr '[:lower:]' '[:upper:]')

# Validate provider
case "$CC_PROVIDER" in
    GLM|KIMI|QWEN|DEEPSEEK|MINIMAX)
        echo "Starting with $CC_PROVIDER provider..."
        ;;
    *)
        echo "Error: Unknown provider '$CC_PROVIDER'"
        echo "Usage: $0 [PROVIDER]"
        echo "Supported providers: GLM, KIMI, QWEN, DEEPSEEK, MINIMAX"
        exit 1
        ;;
esac

# Use variable indirection to set environment variables
BASE_URL_VAR="${CC_PROVIDER}_BASE_URL"
API_KEY_VAR="${CC_PROVIDER}_API_KEY"
PRIMARY_MODEL_VAR="${CC_PROVIDER}_PRIMARY_MODEL"
SECONDARY_MODEL_VAR="${CC_PROVIDER}_SECONDARY_MODEL"
LITE_MODEL_VAR="${CC_PROVIDER}_LITE_MODEL"

export ANTHROPIC_BASE_URL=${!BASE_URL_VAR}
export ANTHROPIC_AUTH_TOKEN=${!API_KEY_VAR}
export ANTHROPIC_DEFAULT_OPUS_MODEL=${!PRIMARY_MODEL_VAR}
export ANTHROPIC_DEFAULT_SONNET_MODEL=${!SECONDARY_MODEL_VAR}
export ANTHROPIC_DEFAULT_HAIKU_MODEL=${!LITE_MODEL_VAR}

# Check if API key is set BEFORE displaying configuration
if [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
    echo -e "\n${RED}═══════════════════════════════════════════════════════${NC}"
    echo -e "${RED}✗ ERROR: API Key Not Found${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}The ${BOLD}${API_KEY_VAR}${NC}${YELLOW} environment variable is not set.${NC}\n"
    echo -e "${CYAN}Please set your API key using one of these methods:${NC}\n"
    echo -e "${GREEN}1. Temporary (current session only):${NC}"
    echo -e "   ${BOLD}export ${API_KEY_VAR}=your_api_key_here${NC}\n"
    echo -e "${GREEN}2. Permanent (add to ~/.bashrc or ~/.zshrc):${NC}"
    echo -e "   ${BOLD}echo 'export ${API_KEY_VAR}=your_api_key_here' >> ~/.bashrc${NC}"
    echo -e "   ${BOLD}source ~/.bashrc${NC}\n"
    echo -e "${GREEN}3. Using .env file:${NC}"
    echo -e "   ${BOLD}echo '${API_KEY_VAR}=your_api_key_here' >> .env${NC}"
    echo -e "   ${BOLD}source .env${NC}\n"
    echo -e "${RED}═══════════════════════════════════════════════════════${NC}\n"
    exit 1
fi

# Display configuration with colors
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}🚀 Configuration${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Provider:${NC}      ${YELLOW}$CC_PROVIDER${NC}"
echo -e "${GREEN}API Key:${NC}       ${GREEN}✓ Set${NC}"
echo -e "${GREEN}Base URL:${NC}      ${MAGENTA}$ANTHROPIC_BASE_URL${NC}"
echo -e "${GREEN}Opus Model:${NC}    ${BOLD}$ANTHROPIC_DEFAULT_OPUS_MODEL${NC}"
echo -e "${GREEN}Sonnet Model:${NC}  ${BOLD}$ANTHROPIC_DEFAULT_SONNET_MODEL${NC}"
echo -e "${GREEN}Haiku Model:${NC}   ${BOLD}$ANTHROPIC_DEFAULT_HAIKU_MODEL${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Run claude CLI
# You can use:
# claude --model opus 
# claude --model sonnet 
# claude --model haiku
claude