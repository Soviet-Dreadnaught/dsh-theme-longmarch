#Requires -Version 5.1
<#
.SYNOPSIS
    dsh-theme-longmarch 一键安装（DSH 桌面版 profile）
.DESCRIPTION
    把本仓库登记进 DSH profile：写 dependencies + dsh.profile.bundles，再跑一次 install。
    幂等：重复运行不会重复写入。写盘前先备份，并用 JSON 解析校验结果，校验不过就放弃写入。
.PARAMETER Profile
    profile 名字，默认 desktop。
.PARAMETER DshHome
    DSH_HOME，默认取环境变量，没设就退回用户目录下的 .dsh
.PARAMETER DryRun
    只打印将要做的改动，不写任何文件。
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1
.EXAMPLE
    .\install.ps1 -DryRun
#>
param(
    [string]$Profile = 'desktop',
    [string]$DshHome = $env:DSH_HOME,
    [switch]$DryRun,
    [switch]$SkipInstall
)

$ErrorActionPreference = 'Stop'
$NL = [Environment]::NewLine

function Say($msg, $color = 'Gray') { Write-Host $msg -ForegroundColor $color }
function Fail($msg) { Say ('  [x] ' + $msg) 'Red'; exit 1 }

Say ''
Say '  dsh-theme-longmarch installer' 'White'
Say '  ------------------------------' 'DarkGray'

# ---------- 1. 定位包与 profile ----------
$pkgPath = Join-Path $PSScriptRoot 'package.json'
if (-not (Test-Path $pkgPath)) { Fail '找不到 package.json，请把脚本放在插件仓库根目录运行' }
$pkg  = Get-Content $pkgPath -Raw -Encoding UTF8 | ConvertFrom-Json
$name = $pkg.name
Say ('  package      : ' + $name + ' v' + $pkg.version)

if (-not $DshHome) { $DshHome = Join-Path $env:USERPROFILE '.dsh' }
$profileDir = Join-Path (Join-Path $DshHome 'profiles') $Profile
if (-not (Test-Path $profileDir)) {
    $profilesRoot = Join-Path $DshHome 'profiles'
    $existing = ''
    if (Test-Path $profilesRoot) {
        $existing = (Get-ChildItem $profilesRoot -Directory | Select-Object -ExpandProperty Name) -join ', '
    }
    Fail ('找不到 profile 目录: ' + $profileDir + '  现有 profile: ' + $existing + '  （用 -Profile 指定，或先打开一次 DSH）')
}
Say ('  profile      : ' + $profileDir)

# ---------- 2. 读清单 ----------
$manifestPath = Join-Path $profileDir 'package.json'
if (-not (Test-Path $manifestPath)) { Fail ('profile 里没有 package.json: ' + $manifestPath) }
$text     = Get-Content $manifestPath -Raw -Encoding UTF8
$manifest = $text | ConvertFrom-Json

$linkSpec = 'link:' + ($PSScriptRoot -replace '\\', '/')
$alreadyDep    = ($manifest.dependencies -ne $null) -and ($manifest.dependencies.PSObject.Properties.Name -contains $name)
$alreadyBundle = ($manifest.dsh -ne $null) -and ($manifest.dsh.profile -ne $null) -and ($manifest.dsh.profile.bundles -contains $name)

Say ('  dependency   : ' + $(if ($alreadyDep) { '已存在' } else { '待写入' }))
Say ('  bundle       : ' + $(if ($alreadyBundle) { '已存在' } else { '待写入' }))

if ($alreadyDep -and $alreadyBundle) {
    Say ''
    Say '  [ok] 已经装过了，什么都没改。' 'Green'
    Say '       改过代码后按 Ctrl+F5 刷新 DSH 即可。' 'DarkGray'
    Say ''
    exit 0
}

# ---------- 3. 插入（保留原格式）----------
$new = $text
if (-not $alreadyDep) {
    $i = $new.IndexOf('"dependencies"')
    if ($i -lt 0) { Fail ('profile 的 package.json 里没有 dependencies 段，请手动加一行: "' + $name + '": "' + $linkSpec + '"') }
    $b = $new.IndexOf('{', $i)
    $new = $new.Insert($b + 1, $NL + '    "' + $name + '": "' + $linkSpec + '",')
}
if (-not $alreadyBundle) {
    $i = $new.IndexOf('"bundles"')
    if ($i -lt 0) { Fail ('profile 的 package.json 里没有 dsh.profile.bundles 段，请手动加一项: "' + $name + '"') }
    $b = $new.IndexOf('[', $i)
    $new = $new.Insert($b + 1, $NL + '        "' + $name + '",')
}

try { $null = $new | ConvertFrom-Json } catch {
    Fail '改完的 JSON 解析失败，已放弃写入（原文件未改动）。请手动编辑 profile 的 package.json'
}

if ($DryRun) {
    Say ''
    Say '  [dry-run] 将要写入的行：' 'Yellow'
    ($new -split '\r?\n' | Where-Object { $_ -like ('*' + $name + '*') }) | ForEach-Object { '      ' + $_.Trim() }
    Say '  [dry-run] 没有写任何文件。' 'Yellow'
    exit 0
}

# ---------- 4. 备份 + 写入（UTF-8 无 BOM）----------
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item $manifestPath ($manifestPath + '.bak-' + $stamp) -Force
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($manifestPath, $new, $utf8)
Say ('  [ok] 已更新 profile 清单（备份: package.json.bak-' + $stamp + '）') 'Green'

# ---------- 5. 让包管理器把依赖落到位 ----------
if (-not $SkipInstall) {
    Say ''
    Say '  正在安装依赖（可能需要几十秒）…' 'DarkGray'
    $dshCmd  = Get-Command dsh  -ErrorAction SilentlyContinue
    $pnpmCmd = Get-Command pnpm -ErrorAction SilentlyContinue
    try {
        if ($dshCmd) {
            & dsh plugin --profile $Profile install 2>&1 | ForEach-Object { '      ' + $_ }
        } elseif ($pnpmCmd) {
            & pnpm -C $profileDir install 2>&1 | ForEach-Object { '      ' + $_ }
        } else {
            Say '      [warn] 没找到 dsh 也没找到 pnpm，请在那个 profile 目录里手动跑一次 install' 'Yellow'
        }
    } catch {
        Say ('      [warn] 安装命令报错: ' + $_.Exception.Message) 'Yellow'
    }

    $installed = Join-Path (Join-Path $profileDir 'node_modules') $name
    if (Test-Path $installed) { Say ('  [ok] node_modules 里已有 ' + $name) 'Green' }
    else { Say ('  [warn] node_modules 里还没看到 ' + $name + '，可在 profile 目录手动跑一次 install') 'Yellow' }

    Say ''
    Say '  完成。接下来：' 'White'
    Say '    1. 完全退出 DSH 桌面版（托盘图标也要退）' 'Gray'
    Say '    2. 重新打开 —— 设置页左侧会出现「长征终端」' 'Gray'
    Say '    3. 插件列表里也能看到它，随时可以关掉' 'Gray'
    Say ''
}
