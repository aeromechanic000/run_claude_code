# Run Claude Code

**Contact with me on X**: [@aeromechan71402](https://x.com/aeromechan71402)

A cross-platform wrapper to run [Claude Code](https://github.com/anthropics/anthropic-quickstarts/tree/main/claude-code) with multiple third-party API providers. Available as Bash (macOS/Linux), CMD batch, and PowerShell (Windows) scripts.

## Features

- **Multi-Provider Support**: Seamlessly switch between 10+ AI backends.
- **OpenRouter Integration**: Access SOTA models for free.
- **Cross-Platform**: Native support for macOS/Linux (`.sh`), Windows CMD (`.cmd`), and PowerShell (`.ps1`).
- **Agent Teams & Auto Mode**: Toggle experimental Claude features via flags.
- **Smart Mapping**: Automatic tier mapping for Opus, Sonnet, and Haiku.

## Supported Providers

| Provider | Primary Model (Opus Tier) | Base URL | Requires API Key |
|----------|---------------------------|----------|:---:|
| **MEGREZ** | `code` | `https://enhance.megrez.plus/api/code` | Yes |
| **Polaris** | `code` | `http://localhost:11565` | No |
| **OpenRouter** | `openai/gpt-oss-120b:free` | `https://openrouter.ai/api` | Yes |
| **Ollama** | `qwen3.5:2b` | `http://localhost:11434` | No |
| **GLM** | `GLM-5.1` | `https://api.z.ai/api/anthropic` | Yes |
| **Kimi** | `kimi-for-coding` | `https://api.kimi.com/coding/` | Yes |
| **MiniMax** | `MiniMax-M2.1` | `https://api.minimax.io/anthropic` | Yes |
| **DeepSeek** | `deepseek-chat` | `https://api.deepseek.com/anthropic` | Yes |
| **Qwen** | `qwen3.5-plus` | `https://dashscope.aliyuncs.com/apps/anthropic` | Yes |
| **Doubao** | `GLM-5.1` | `https://ark.cn-beijing.volces.com/api/coding` | Yes |

### Polaris (Local API Router)

[Polaris](https://github.com/aeromechanic000/polaris-router) is a lightweight LLM API router that exposes an Anthropic-compatible API and forwards requests to upstream providers. It's designed for use with Claude Code and requires no API key — you configure the upstream endpoints in its `config.json`.

Key features:
- **Load balancing**: Round-robin, random, or failover strategies across multiple upstream endpoints
- **Model aliasing**: Define model names in `config.json` that map to real upstream models
- **Environment variable keys**: Use `env:VAR_NAME` in config to read API keys from the environment
- **Zero auth**: No API key needed to connect from Claude Code

```bash
# Quick start
git clone https://github.com/aeromechanic000/polaris-router
cd polaris-router
uv sync
export OPENROUTER_API_KEY=your-key-here
uv run python main.py
```

Polaris listens on `localhost:11565`. Once running, use `-p POLARIS` to route all Claude Code requests through it.

---

## Prerequisites

### 1. Install Claude Code
```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Set Your API Keys
You must set the environment variable for your chosen provider.

**macOS/Linux (Bash/Zsh):**
```bash
export OPENROUTER_API_KEY=your_key_here
export DEEPSEEK_API_KEY=your_key_here
```

**Windows (CMD):**
```cmd
set OPENROUTER_API_KEY=your_key_here
set DEEPSEEK_API_KEY=your_key_here
```

**Windows (PowerShell):**
```powershell
$env:OPENROUTER_API_KEY = "your_key_here"
$env:DEEPSEEK_API_KEY = "your_key_here"
```

---

## Installation & Setup

### For macOS/Linux (Bash)
1. Download `run_cc.sh`.
2. Make it executable: `chmod +x run_cc.sh`.
3. (Optional) Move to PATH: `sudo mv run_cc.sh /usr/local/bin/run_cc`.

### For Windows (CMD)
1. Download `run_cc.cmd`.
2. Place it in your project directory or anywhere in your `%PATH%`.

### For Windows (PowerShell)
1. Download `run_cc.ps1`.
2. If blocked by execution policy, run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`.

---

## Usage

### Basic Usage

```bash
# macOS/Linux
./run_cc.sh -p OPENROUTER

# Windows CMD
run_cc.cmd -p OPENROUTER

# Windows PowerShell
.\run_cc.ps1 -p OPENROUTER
```

### Advanced Flags

| Flag | Effect | Supported In |
|------|--------|:---:|
| `-p PROVIDER` | Select provider (default: `MEGREZ`) | All |
| `--team` | Enable experimental **Agent Teams** | Bash, CMD |
| `-Team` | Enable experimental **Agent Teams** | PowerShell |
| `--auto` | Enable **Auto Mode** | Bash, CMD |
| `-Auto` | Enable **Auto Mode** | PowerShell |

**Example: Run with OpenRouter, Teams, and Auto-mode enabled:**
```bash
# Bash / CMD
./run_cc.sh -p OPENROUTER --team --auto

# PowerShell
.\run_cc.ps1 -p OPENROUTER -Team -Auto
```

---

## Model Mapping

The scripts map Claude Code's internal model tiers (Opus, Sonnet, Haiku) to provider-specific models:

| Provider | Opus (Primary) | Sonnet (Secondary) | Haiku (Lite) | SubAgent |
| :--- | :--- | :--- | :--- | :--- |
| **MEGREZ** | `code` | `code` | `code` | `code` |
| **Polaris** | `code` | `code` | `code` | `code` |
| **OpenRouter** | `openai/gpt-oss-120b:free` | `z-ai/glm-4.5-air:free` | `minimax/minimax-m2.5:free` | `minimax/minimax-m2.5:free` |
| **Ollama** | `qwen3.5:2b` | `qwen3.5:2b` | `qwen3.5:2b` | `qwen3.5:2b` |
| **GLM** | `GLM-5.1` | `GLM-5.1` | `GLM-4.7` | `GLM-4.7` |
| **Kimi** | `kimi-for-coding` | `kimi-for-coding` | `kimi-for-coding` | `kimi-for-coding` |
| **MiniMax** | `MiniMax-M2.1` | `MiniMax-M2.1` | `MiniMax-M2-Stable` | `MiniMax-M2-Stable` |
| **DeepSeek** | `deepseek-chat` | `deepseek-chat` | `deepseek-chat` | `deepseek-chat` |
| **Qwen** | `qwen3.5-plus` | `qwen3.5-plus` | `qwen3.5-plus` | `qwen3.5-plus` |
| **Doubao** | `GLM-5.1` | `doubao-seed-code-preview-latest` | `doubao-seed-code-preview-latest` | `doubao-seed-code-preview-latest` |

When all three tiers use the same model, the status display shows **Unified** mode.

---

## Troubleshooting

### Windows Execution Policy
If Windows prevents the PowerShell script from running:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or for a single session:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### API Key Errors
Ensure you are using the correct variable name for your provider:
- `MEGREZ_API_KEY`
- `OPENROUTER_API_KEY`
- `GLM_API_KEY`
- `KIMI_API_KEY`
- `MINIMAX_API_KEY`
- `DEEPSEEK_API_KEY`
- `QWENCODE_API_KEY`
- `DOUBAO_API_KEY`

Polaris and Ollama do not require an API key.

### macOS DNS Fix
If `claude.com` is unreachable in your region, add these to your `/etc/hosts`:
```text
34.162.46.92    claude.com
160.79.104.10   docs.claude.com
```
Then flush DNS: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`.

---

**License**: Provided "as-is". Please comply with the Terms of Service of each API provider.
