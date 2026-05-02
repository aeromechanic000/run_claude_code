# Run Claude Code 🚀

**Contact with me on X**: [@aeromechan71402](https://x.com/aeromechan71402)

A cross-platform wrapper (Bash/PowerShell) to run [Claude Code](https://github.com/anthropics/anthropic-quickstarts/tree/main/claude-code) with multiple API providers including OpenRouter, GLM, Kimi, MiniMax, DeepSeek, Qwen, and Doubao.

## Features

- 🚀 **Multi-Provider Support**: Seamlessly switch between 8+ AI backends.
- 🛠️ **OpenRouter Integration**: Access SOTA models like Qwen 3.6 Plus and Nemotron for free.
- 🪟 **Cross-Platform**: Native support for macOS/Linux (`.sh`) and Windows (`.ps1`).
- 🤖 **Agent Teams & Auto Mode**: Toggle experimental Claude features via flags.
- ⚙️ **Smart Mapping**: Automatic tier mapping for Opus, Sonnet, and Haiku.

## Supported Providers

| Provider | Primary Model (Opus Tier) | Base URL |
|----------|---------------------------|----------|
| **OpenRouter** | `qwen-3.6-plus:free` | [https://openrouter.ai/api](https://openrouter.ai/api) |
| **GLM** | `GLM-5` | [https://api.z.ai/api/anthropic](https://api.z.ai/api/anthropic) |
| **Kimi** | `kimi-for-coding` | [https://api.kimi.com/coding/](https://api.kimi.com/coding/) |
| **DeepSeek** | `deepseek-chat` | [https://api.deepseek.com/anthropic](https://api.deepseek.com/anthropic) |
| **Qwen** | `qwen3.5-plus` | [https://dashscope.aliyuncs.com/apps/anthropic](https://dashscope.aliyuncs.com/apps/anthropic) |
| **MiniMax** | `MiniMax-M2.1` | [https://api.minimax.io/anthropic](https://api.minimax.io/anthropic) |
| **Doubao** | `doubao-seed-code` | [https://ark.cn-beijing.volces.com/api/coding](https://ark.cn-beijing.volces.com/api/coding) |

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
3. (Optional) Move to bin: `sudo mv run_cc.sh /usr/local/bin/claude-nav`.

### For Windows (PowerShell)
1. Download `run_cc.ps1`.
2. If blocked by execution policy, run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`.

---

## Usage

The script now uses flags for better control.

### Basic Usage
```bash
# macOS/Linux
./run_cc.sh -p OPENROUTER

# Windows
.\run_cc.ps1 -p OPENROUTER
```

### Advanced Flags
- `-p`: Specify provider (Default: MEGREZ)
- `--team`: Enable experimental **Agent Teams**
- `--auto`: Enable **Auto Mode** (dangerous/powerful)

**Example: Run with OpenRouter, Teams, and Auto-mode enabled:**
```bash
./run_cc.sh -p OPENROUTER --team --auto
```

---

## Model Mapping (Deep Dive)

When you use the `--model` flag inside Claude Code, the wrapper maps them as follows:

| Provider | Opus (Primary) | Sonnet (Secondary) | Haiku (Lite) |
| :--- | :--- | :--- | :--- |
| **OpenRouter** | Qwen 3.6 Plus | Nemotron 3 Super | Step 3.5 Flash |
| **GLM** | GLM-5 | GLM-5 | GLM-4.7 |
| **DeepSeek** | deepseek-chat | deepseek-chat | deepseek-chat |
| **MiniMax** | MiniMax-M2.1 | MiniMax-M2.1 | M2-Stable |

---

## Troubleshooting

### Windows Execution Policy
If Windows prevents the script from running, open PowerShell as Admin and run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### API Key Errors
Ensure you are using the correct variable name:
- `OPENROUTER_API_KEY`
- `DEEPSEEK_API_KEY`
- `GLM_API_KEY`
- (etc.)

### macOS DNS Fix
If `claude.com` is unreachable in your region, add these to your `/etc/hosts`:
```text
34.162.46.92    claude.com
160.79.104.10   docs.claude.com
```
Then flush DNS: `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`.

---

**License**: Provided "as-is". Please comply with the Terms of Service of each API provider.
