# todo.ps1 - Daily Todo Git Automation
# Usage: todo <command>
# Commands:
#   push   - Stage all, commit with date, push to remote
#   today  - Open today's todo file (create if not exists)

param(
    [Parameter(Position = 0)]
    [ValidateSet("push", "today", "help")]
    [string]$Command = "help"
)

$TodoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TodayFile = Join-Path $TodoDir "$(Get-Date -Format 'yyyy-MM-dd').md"
$DayOfWeek = (Get-Date).ToString("ddd")

function Invoke-TodoPush {
    Write-Host "📦 Staging all changes..." -ForegroundColor Cyan
    Set-Location $TodoDir
    git add -A

    # Check if there are staged changes
    $status = git status --porcelain
    if (-not $status) {
        Write-Host "⚠️  Nothing to commit. Working tree is clean." -ForegroundColor Yellow
        return
    }

    $dateMsg = Get-Date -Format "yyyy-MM-dd"
    Write-Host "📝 Committing with message: $dateMsg" -ForegroundColor Cyan
    git commit -m $dateMsg

    Write-Host "🚀 Pushing to remote..." -ForegroundColor Cyan
    git push

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Done! Today's todos pushed successfully." -ForegroundColor Green
    }
    else {
        Write-Host "❌ Push failed. Check your SSH key or network." -ForegroundColor Red
    }
}

function Invoke-TodoToday {
    Set-Location $TodoDir

    if (-not (Test-Path $TodayFile)) {
        Write-Host "📄 Creating todo file for today: $TodayFile" -ForegroundColor Cyan
@"
# $(Get-Date -Format 'yyyy-MM-dd') ($DayOfWeek)

## 📋 Today

- [ ]
- [ ]
- [ ]

## 📝 Notes


## 🔄 Follow-up


"@ | Out-File -FilePath $TodayFile -Encoding UTF8
    }

    Write-Host "📝 Opening today's todo: $(Split-Path -Leaf $TodayFile)" -ForegroundColor Cyan
    Start-Process $TodayFile
}

function Invoke-TodoHelp {
    Write-Host @"

  📋 Todo Automation

  Commands:
    todo push    Stage all, commit with date, push to remote
    todo today   Open today's markdown file (auto-create if needed)

  Files are stored in: $TodoDir

"@ -ForegroundColor Green
}

switch ($Command) {
    "push"  { Invoke-TodoPush }
    "today" { Invoke-TodoToday }
    "help"  { Invoke-TodoHelp }
    default { Invoke-TodoHelp }
}
