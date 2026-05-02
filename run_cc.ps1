# --- 颜色与样式定义 ---
$Colors = @{
    Info    = "Cyan"
    Success = "Green"
    Warn    = "Yellow"
    Error   = "Red"
    Accent  = "Magenta"
}

# --- API 提供商配置库 ---
$Providers = @{
    "MEGREZ" = @{
        BaseUrl = "https://enhance.megrez.plus/api/code"
        Primary = "code"; Secondary = "code"; Lite = "code"
    }
    "OPENROUTER" = @{
        BaseUrl = "https://openrouter.ai/api"
        Primary = "z-ai/glm-4.5-air:free"
        Secondary = "z-ai/glm-4.5-air:free"
        Lite    = "z-ai/glm-4.5-air:free"
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
        Lite    = "doubao-seed-code-preview-latest"
    }
}

# --- 参数解析 ---
param (
    [Parameter(Mandatory=$false, HelpMessage="指定 API 提供商")]
    [Alias("provider")]
    [string]$p = "MEGREZ",

    [Parameter(Mandatory=$false)]
    [switch]$team,

    [Parameter(Mandatory=$false)]
    [switch]$auto
)

$CC_PROVIDER = $p.ToUpper()

# --- 验证提供商 ---
if (-not $Providers.ContainsKey($CC_PROVIDER)) {
    Write-Host "❌ 错误: 未知的提供商 '$CC_PROVIDER'" -ForegroundColor $Colors.Error
    Write-Host "可用列表: $($Providers.Keys -join ', ')" -ForegroundColor $Colors.Warn
    exit 1
}

# --- 获取环境变量 ---
$Config = $Providers[$CC_PROVIDER]
$ApiKeyVar = "${CC_PROVIDER}_API_KEY"
$ApiKey = [System.Environment]::GetEnvironmentVariable($ApiKeyVar, "User") 
if (-not $ApiKey) { $ApiKey = $env:$ApiKeyVar } # 兼容当前会话变量

if (-not $ApiKey) {
    Write-Host "`n[!] 缺少 API Key" -ForegroundColor $Colors.Error
    Write-Host "请先设置环境变量: `$env:$ApiKeyVar = '你的秘钥'" -ForegroundColor $Colors.Warn
    exit 1
}

# --- 设置 Claude CLI 所需的环境变量 ---
$env:ANTHROPIC_BASE_URL = $Config.BaseUrl
$env:ANTHROPIC_AUTH_TOKEN = $ApiKey
$env:ANTHROPIC_API_KEY = "" # 置空以绕过官方端点验证
$env:ANTHROPIC_DEFAULT_OPUS_MODEL = $Config.Primary
$env:ANTHROPIC_DEFAULT_SONNET_MODEL = $Config.Secondary
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL = $Config.Lite

# 团队模式处理
if ($team) {
    $env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1"
    $TeamStatus = "已启用"
} else {
    Remove-Item env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS -ErrorAction SilentlyContinue
    $TeamStatus = "未启用"
}

# 自动模式处理
$ExtraArgs = @()
if ($auto) {
    $ExtraArgs += "--enable-auto-mode"
    $AutoStatus = "已开启 (--enable-auto-mode)"
} else {
    $AutoStatus = "关闭"
}

# --- 状态展示界面 ---
Write-Host "`n" + ("=" * 60) -ForegroundColor Blue
Write-Host " 🚀 Claude CLI Wrapper (PowerShell Edition)" -ForegroundColor $Colors.Info
Write-Host ("=" * 60) -ForegroundColor Blue

Write-Host " 📍 提供商:    " -NoNewline; Write-Host $CC_PROVIDER -ForegroundColor $Colors.Success
Write-Host " 👥 团队模式:  " -NoNewline; Write-Host $TeamStatus -ForegroundColor ($team ? $Colors.Success : $Colors.Error)
Write-Host " 🤖 自动模式:  " -NoNewline; Write-Host $AutoStatus -ForegroundColor ($auto ? $Colors.Success : $Colors.Warn)
Write-Host " 🌐 接口地址:  " -NoNewline; Write-Host $env:ANTHROPIC_BASE_URL -ForegroundColor $Colors.Accent

if ($Config.Primary -eq $Config.Secondary) {
    Write-Host " 📦 统一模型:  " -NoNewline; Write-Host $Config.Primary -ForegroundColor White
} else {
    Write-Host " 💎 Opus 层级: " -NoNewline; Write-Host $Config.Primary -ForegroundColor White
    Write-Host " ⚡ Sonnet 层级:" -NoNewline; Write-Host $Config.Secondary -ForegroundColor White
}
Write-Host ("=" * 60) + "`n" -ForegroundColor Blue

# --- 启动 Claude ---
& claude $ExtraArgs
