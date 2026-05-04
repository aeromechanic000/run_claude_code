#Requires -Version 5.1

param(
    [Alias("p")]
    [string]$Provider = "MEGREZ",
    [switch]$Team,
    [switch]$Auto
)

# --- Provider Configurations ---
$Providers = @{
    MEGREZ = @{
        BaseUrl   = "https://enhance.megrez.plus/api/code"
        Primary   = "code"
        Secondary = "code"
        Lite      = "code"
        SubAgent  = "code"
    }
    OPENROUTER = @{
        BaseUrl   = "https://openrouter.ai/api"
        Primary   = "openai/gpt-oss-120b:free"
        Secondary = "z-ai/glm-4.5-air:free"
        Lite      = "minimax/minimax-m2.5:free"
        SubAgent  = "minimax/minimax-m2.5:free"
    }
    POLARIS = @{
        BaseUrl   = "http://localhost:11565"
        Primary   = "code"
        Secondary = "code"
        Lite      = "code"
        SubAgent  = "code"
    }
    OLLAMA = @{
        BaseUrl   = "http://localhost:11434"
        Primary   = "qwen3.5:2b"
        Secondary = "qwen3.5:2b"
        Lite      = "qwen3.5:2b"
        SubAgent  = "qwen3.5:2b"
    }
    GLM = @{
        BaseUrl   = "https://api.z.ai/api/anthropic"
        Primary   = "GLM-5.1"
        Secondary = "GLM-5.1"
        Lite      = "GLM-4.7"
        SubAgent  = "GLM-4.7"
    }
    KIMI = @{
        BaseUrl   = "https://api.kimi.com/coding/"
        Primary   = "kimi-for-coding"
        Secondary = "kimi-for-coding"
        Lite      = "kimi-for-coding"
        SubAgent  = "kimi-for-coding"
    }
    MINIMAX = @{
        BaseUrl   = "https://api.minimax.io/anthropic"
        Primary   = "MiniMax-M2.1"
        Secondary = "MiniMax-M2.1"
        Lite      = "MiniMax-M2-Stable"
        SubAgent  = "MiniMax-M2-Stable"
    }
    DEEPSEEK = @{
        BaseUrl   = "https://api.deepseek.com/anthropic"
        Primary   = "deepseek-chat"
        Secondary = "deepseek-chat"
        Lite      = "deepseek-chat"
        SubAgent  = "deepseek-chat"
    }
    QWENCODE = @{
        BaseUrl   = "https://dashscope.aliyuncs.com/apps/anthropic"
        Primary   = "qwen3.5-plus"
        Secondary = "qwen3.5-plus"
        Lite      = "qwen3.5-plus"
        SubAgent  = "qwen3.5-plus"
    }
    DOUBAO = @{
        BaseUrl   = "https://ark.cn-beijing.volces.com/api/coding"
        Primary   = "GLM-5.1"
        Secondary = "doubao-seed-code-preview-latest"
        Lite      = "doubao-seed-code-preview-latest"
        SubAgent  = "doubao-seed-code-preview-latest"
    }
}

# --- Validate Provider ---
$Provider = $Provider.ToUpper()
if (-not $Providers.ContainsKey($Provider)) {
    Write-Host "Error: Unknown provider '$Provider'" -ForegroundColor Red
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [-p PROVIDER] [-Team] [-Auto]"
    Write-Host "Providers: $($Providers.Keys -join ', ')"
    exit 1
}

$config = $Providers[$Provider]

# --- Set Environment Variables ---
$env:ANTHROPIC_BASE_URL = $config.BaseUrl
$env:ANTHROPIC_AUTH_TOKEN = [Environment]::GetEnvironmentVariable("${Provider}_API_KEY")
$env:ANTHROPIC_API_KEY = ""
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = $config.Primary
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = $config.Secondary
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $config.Lite
$env:CLAUDE_CODE_SUBAGENT_MODEL = $config.SubAgent

# --- Toggle Agent Teams ---
if ($Team) {
    $env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
    $teamStatus = "Enabled"
    $teamColor = "Green"
} else {
    Remove-Item Env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS -ErrorAction SilentlyContinue
    $teamStatus = "Disabled"
    $teamColor = "Yellow"
}

# --- Auto Mode ---
if ($Auto) {
    $claudeArgs = @("--enable-auto-mode")
    $autoStatus = "Enabled (Flag: --enable-auto-mode)"
    $autoColor = "Green"
} else {
    $claudeArgs = @()
    $autoStatus = "Disabled"
    $autoColor = "Yellow"
}

# --- API Key Check ---
if ($Provider -notin @("OLLAMA", "POLARIS") -and [string]::IsNullOrEmpty($env:ANTHROPIC_AUTH_TOKEN)) {
    Write-Host ""
    Write-Host "[X] ERROR: API Key Not Found for $Provider" -ForegroundColor Red
    Write-Host "Please set: `$env:${Provider}_API_KEY = `"your_key`"" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# --- Status Display ---
Write-Host ""
Write-Host "============================================================" -ForegroundColor Blue
Write-Host "  Claude CLI Wrapper | Agent Status" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Blue
Write-Host "Provider:      " -ForegroundColor Green -NoNewline; Write-Host $Provider -ForegroundColor Yellow
Write-Host "Agent Teams:   " -ForegroundColor Green -NoNewline; Write-Host $teamStatus -ForegroundColor $teamColor
Write-Host "Auto Mode:     " -ForegroundColor Green -NoNewline; Write-Host $autoStatus -ForegroundColor $autoColor
Write-Host "Base URL:      " -ForegroundColor Green -NoNewline; Write-Host $env:ANTHROPIC_BASE_URL -ForegroundColor Magenta

if ($config.Primary -eq $config.Secondary -and $config.Secondary -eq $config.Lite) {
    Write-Host "Model Mode:    " -ForegroundColor Green -NoNewline; Write-Host "Unified ($($config.Secondary))" -ForegroundColor White
} else {
    Write-Host "Opus Model:    " -ForegroundColor Green -NoNewline; Write-Host $config.Primary -ForegroundColor White
    Write-Host "Sonnet Model:  " -ForegroundColor Green -NoNewline; Write-Host $config.Secondary -ForegroundColor White
    Write-Host "Haiku Model:   " -ForegroundColor Green -NoNewline; Write-Host $config.Lite -ForegroundColor White
}
Write-Host "============================================================" -ForegroundColor Blue
Write-Host ""

# --- Execute Claude CLI ---
& claude @claudeArgs
