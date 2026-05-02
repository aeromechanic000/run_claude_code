# --- Configuration ---
$DefaultProvider = "MEGREZ"
$EnableTeams = $false
$AutoMode = $false

# --- Provider Configurations ---
$Providers = @{
    "MEGREZ" = @{
        BaseUrl = "https://enhance.megrez.plus/api/code"
        Primary = "code"; Secondary = "code"; Lite = "code"
    }
    "OPENROUTER" = @{
        BaseUrl = "https://openrouter.ai/api"
        Primary = "qwen/qwen-3.6-plus:free"
        Secondary = "nvidia/nemotron-3-super:free"
        Lite = "stepfun/step-3.5-flash:free"
    }
    "GLM" = @{
        BaseUrl = "https://api.z.ai/api/anthropic"
        Primary = "GLM-5"; Secondary = "GLM-5"; Lite = "GLM-4.7"
    }
    "KIMI" = @{
        BaseUrl = "https://api.kimi.com/coding/"
        Primary = "kimi-for-coding"; Secondary = "kimi-for-coding"; Lite = "kimi-for-coding"
    }
    "MINIMAX" = @{
        BaseUrl = "https://api.minimax.io/anthropic"
        Primary = "MiniMax-M2.1"; Secondary = "MiniMax-M2.1"; Lite = "MiniMax-M2-Stable"
    }
    "DEEPSEEK" = @{
        BaseUrl = "https://api.deepseek.com/anthropic"
        Primary = "deepseek-chat"; Secondary = "deepseek-chat"; Lite = "deepseek-chat"
    }
    "QWENCODE" = @{
        BaseUrl = "https://dashscope.aliyuncs.com/apps/anthropic"
        Primary = "qwen3.5-plus"; Secondary = "qwen3.5-plus"; Lite = "qwen3.5-plus"
    }
    "DOUBAO" = @{
        BaseUrl = "https://ark.cn-beijing.volces.com/api/coding"
        Primary = "doubao-seed-code-preview-latest"
        Secondary = "doubao-seed-code-preview-latest"
        Lite = "doubao-seed-code-preview-latest"
    }
}

# --- Argument Parsing ---
param (
    [Parameter(Mandatory=$false)][string]$p,
    [switch]$team,
    [switch]$auto
)

$CC_PROVIDER = if ($p) { $p.ToUpper() } else { $DefaultProvider }

# --- Validation ---
if (-not $Providers.ContainsKey($CC_PROVIDER)) {
    Write-Host "Error: Unknown provider '$CC_PROVIDER'" -ForegroundColor Red
    Write-Host "Available: $($Providers.Keys -join ', ')" -ForegroundColor Yellow
    exit 1
}

# --- Env Setup ---
$Config = $Providers[$CC_PROVIDER]
$ApiKeyVar = "${CC_PROVIDER}_API_KEY"
$ApiKey = [System.Environment]::GetEnvironmentVariable($ApiKeyVar)

if (-not $ApiKey) {
    Write-Host "`n✗ ERROR: API Key Not Found for $CC_PROVIDER" -ForegroundColor Red
    Write-Host "Please set it using: `$env:$ApiKeyVar = 'your_key'" -ForegroundColor Yellow
    exit 1
}

# Set Environment Variables for the current process
$env:ANTHROPIC_BASE_URL = $Config.BaseUrl
$env:ANTHROPIC_AUTH_TOKEN = $ApiKey
$env:ANTHROPIC_API_KEY = ""
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = $Config.Primary
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = $Config.Secondary
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $Config.Lite

if ($team) {
    $env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
    $TeamStatus = "Enabled"
    $TeamColor = "Green"
} else {
    Remove-Item env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS -ErrorAction SilentlyContinue
    $TeamStatus = "Disabled"
    $TeamColor = "Red"
}

$ExtraArgs = @()
if ($auto) {
    $ExtraArgs += "--enable-auto-mode"
    $AutoStatus = "Enabled (Flag: --enable-auto-mode)"
    $AutoColor = "Green"
} else {
    $AutoStatus = "Disabled"
    $AutoColor = "Yellow"
}

# --- Status Display ---
Write-Host "`n" + ("=" * 55) -ForegroundColor Blue
Write-Host "🚀 Claude CLI Wrapper | Agent Status" -ForegroundColor Cyan
Write-Host ("=" * 55) -ForegroundColor Blue

Write-Host "Provider:      " -NoNewline -ForegroundColor Green; Write-Host $CC_PROVIDER -ForegroundColor Yellow
Write-Host "Agent Teams:   " -NoNewline -ForegroundColor Green; Write-Host $TeamStatus -ForegroundColor $TeamColor
Write-Host "Auto Mode:     " -NoNewline -ForegroundColor Green; Write-Host $AutoStatus -ForegroundColor $AutoColor
Write-Host "Base URL:      " -NoNewline -ForegroundColor Green; Write-Host $env:ANTHROPIC_BASE_URL -ForegroundColor Magenta

if ($Config.Primary -eq $Config.Secondary -and $Config.Secondary -eq $Config.Lite) {
    Write-Host "Model Mode:    " -NoNewline -ForegroundColor Green; Write-Host "Unified ($($Config.Primary))" -ForegroundColor White -BackGroundColor DarkGray
} else {
    Write-Host "Opus Model:    " -NoNewline -ForegroundColor Green; Write-Host $Config.Primary -ForegroundColor White
    Write-Host "Sonnet Model:  " -NoNewline -ForegroundColor Green; Write-Host $Config.Secondary -ForegroundColor White
    Write-Host "Haiku Model:   " -NoNewline -ForegroundColor Green; Write-Host $Config.Lite -ForegroundColor White
}
Write-Host ("=" * 55) + "`n" -ForegroundColor Blue

# --- Execute Claude CLI ---
# Using & to call the command with the array of arguments
& claude $ExtraArgs
