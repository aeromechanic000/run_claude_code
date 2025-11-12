# Run Claude Code 

**Contact with me on X**: [@aeromechan71402](https://x.com/aeromechan71402)


A bash script to run [Claude Code](https://github.com/anthropics/anthropic-quickstarts/tree/main/claude-code) with multiple API providers including GLM, Kimi, MiniMax, DeepSeek, Qwen and Doubao.

## Features

- 🚀 Support for multiple AI API providers
- 🎨 Colorful terminal output
- 🔑 API key validation before execution
- 🔄 Easy provider switching with command-line arguments
- ⚙️ Model tier mapping (Opus/Sonnet/Haiku)

## Supported Providers

| Provider | Models | Base URL |
|----------|--------|----------|
| GLM | GLM-4.6, GLM-4.5-Air | https://api.z.ai/api/anthropic |
| Kimi | kimi-k2-0905-preview, kimi-latest-32k | https://api.moonshot.cn/anthropic/ |
| MiniMax | MiniMax-M2, MiniMax-M2-Stable | https://api.minimax.io/anthropic |
| DeepSeek | deepseek-chat | https://api.deepseek.com/anthropic |
| Qwen | qwen3-max, qwen3-plus | https://dashscope.aliyuncs.com/apps/anthropic |
| DOUBAO | doubao-seed-code-preview-latest | https://ark.cn-beijing.volces.com/api/coding |

## Prerequisites

### 1. Install Claude Code

Install the Claude CLI tool via npm:

```bash
npm install -g @anthropic-ai/claude-code
```

For detailed installation instructions and troubleshooting, please refer to the [official Claude Code documentation](https://github.com/anthropics/anthropic-quickstarts/tree/main/claude-code).

### 2. Fix Connection Issues (macOS Users)

If you experience connection issues to `claude.com` or `docs.claude.com`, follow these steps:

**Step 1:** Add the following lines to `/private/etc/hosts`:

```bash
sudo nano /private/etc/hosts
```

Add these lines:

```
34.162.46.92    claude.com  
34.162.102.82   claude.com  
34.162.136.91   claude.com  
34.162.142.92   claude.com  
34.162.183.95   claude.com  
160.79.104.10   docs.claude.com
```

**Step 2:** Flush the DNS cache:

```bash
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

## Installation

1. Download the `run_cc.sh` script:

```bash
curl -O https://your-repo-url/run_cc.sh
```

2. Make it executable:

```bash
chmod +x run_cc.sh
```

3. (Optional) Move it to your PATH for global access:

```bash
sudo mv run_cc.sh /usr/local/bin/run_cc
```

## Configuration

### Setting API Keys

You need to set the API key for each provider you want to use. Choose one of the following methods:

#### Method 1: Temporary (Current Session Only)

```bash
export GLM_API_KEY=your_glm_api_key_here
export KIMI_API_KEY=your_kimi_api_key_here
export MINIMAX_API_KEY=your_minimax_api_key_here
export DEEPSEEK_API_KEY=your_deepseek_api_key_here
export QWEN_API_KEY=your_qwen_api_key_here
export DOUBAO_API_KEY=your_doubao_api_key_here
```

#### Method 2: Permanent (Recommended)

Add the export commands to your shell configuration file:

**For Bash users (~/.bashrc):**

```bash
echo 'export GLM_API_KEY=your_glm_api_key_here' >> ~/.bashrc
echo 'export KIMI_API_KEY=your_kimi_api_key_here' >> ~/.bashrc
echo 'export MINIMAX_API_KEY=your_minimax_api_key_here' >> ~/.bashrc
echo 'export DEEPSEEK_API_KEY=your_deepseek_api_key_here' >> ~/.bashrc
echo 'export QWEN_API_KEY=your_qwen_api_key_here' >> ~/.bashrc
echo 'export DOUBAO_API_KEY=your_doubao_api_key_here' >> ~/.bashrc
source ~/.bashrc
```

**For Zsh users (~/.zshrc):**

```bash
echo 'export GLM_API_KEY=your_glm_api_key_here' >> ~/.zshrc
echo 'export KIMI_API_KEY=your_kimi_api_key_here' >> ~/.zshrc
echo 'export MINIMAX_API_KEY=your_minimax_api_key_here' >> ~/.zshrc
echo 'export DEEPSEEK_API_KEY=your_deepseek_api_key_here' >> ~/.zshrc
echo 'export QWEN_API_KEY=your_qwen_api_key_here' >> ~/.zshrc
echo 'export DOUBAO_API_KEY=your_doubao_api_key_here' >> ~/.zshrc
source ~/.zshrc
```

#### Method 3: Using .env File

Create a `.env` file in your project directory:

```bash
cat > .env << EOF
GLM_API_KEY=your_glm_api_key_here
KIMI_API_KEY=your_kimi_api_key_here
MINIMAX_API_KEY=your_minimax_api_key_here
DEEPSEEK_API_KEY=your_deepseek_api_key_here
QWEN_API_KEY=your_qwen_api_key_here
DOUBAO_API_KEY=your_doubao_api_key_here
EOF
```

Then load it before running the script:

```bash
source .env
./run_cc.sh
```

### Getting API Keys

- **GLM (智谱AI)**: https://open.bigmodel.cn/
- **Kimi (月之暗面)**: https://platform.moonshot.cn/
- **MiniMax**: https://www.minimax.chat/
- **DeepSeek**: https://platform.deepseek.com/
- **Qwen (阿里云)**: https://dashscope.aliyun.com/

## Usage

### Basic Usage

Run with the default provider (GLM):

```bash
./run_cc.sh
```

### Specify a Provider

Run with a specific provider:

```bash
./run_cc.sh KIMI
./run_cc.sh MINIMAX
./run_cc.sh DEEPSEEK
./run_cc.sh QWEN
./run_cc.sh GLM
```

The provider name is case-insensitive:

```bash
./run_cc.sh kimi
./run_cc.sh minimax
```

### Using Different Model Tiers

Once Claude Code is running, you can specify which model tier to use:

```bash
# Use the primary model (Opus tier)
claude --model opus

# Use the secondary model (Sonnet tier)
claude --model sonnet

# Use the lite model (Haiku tier)
claude --model haiku
```

## Model Mapping

The script maps Claude's model tiers to provider-specific models:

| Claude Tier | GLM | Kimi | MiniMax | DeepSeek | Qwen |
|-------------|-----|------|---------|----------|------|
| Opus | GLM-4.6 | kimi-k2-0905-preview | MiniMax-M2 | deepseek-chat | qwen3-max |
| Sonnet | GLM-4.6 | kimi-k2-0905-preview | MiniMax-M2 | deepseek-chat | qwen3-max |
| Haiku | GLM-4.5-Air | kimi-latest-32k | MiniMax-M2-Stable | deepseek-chat | qwen3-plus |

## Troubleshooting

### API Key Not Found Error

If you see this error:

```
✗ ERROR: API Key Not Found
The XXX_API_KEY environment variable is not set.
```

Make sure you've set the API key for the provider you're trying to use. See the [Configuration](#configuration) section above.

### Provider Not Found Error

If you see:

```
Error: Unknown provider 'XXX'
```

Make sure you're using one of the supported providers: GLM, KIMI, MINIMAX, DEEPSEEK, or QWEN.

### Connection Issues

If Claude Code cannot connect to the API:

1. Verify your API key is correct
2. Check your internet connection
3. Ensure the provider's API service is available
4. For macOS users, try the DNS fix mentioned in the [Prerequisites](#2-fix-connection-issues-macos-users) section

## Examples

### Example 1: Using GLM (Default)

```bash
export GLM_API_KEY=your_glm_api_key
./run_cc.sh
```

### Example 2: Using Kimi with Sonnet Model

```bash
export KIMI_API_KEY=your_kimi_api_key
./run_cc.sh kimi

# Then in Claude Code
claude --model sonnet
```

### Example 3: Switching Between Providers

```bash
# Set all API keys once
export GLM_API_KEY=your_glm_api_key
export KIMI_API_KEY=your_kimi_api_key
export DEEPSEEK_API_KEY=your_deepseek_api_key

# Switch providers easily
./run_cc.sh glm
./run_cc.sh kimi
./run_cc.sh deepseek
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This script is provided as-is for convenience. Please refer to each API provider's terms of service for usage restrictions.

## Related Links

- [Claude Code Official Documentation](https://github.com/anthropics/anthropic-quickstarts/tree/main/claude-code)
- [Anthropic API Documentation](https://docs.anthropic.com/)

---

**Note**: This script requires valid API keys from the respective providers. Make sure you comply with each provider's terms of service and usage policies.
```

This README includes:
- Clear installation instructions
- Multiple methods for setting API keys
- Usage examples
- Troubleshooting section
- Model mapping table
- Links to get API keys from each provider
- macOS DNS fix instructions
- Examples for different use cases
