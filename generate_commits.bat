@echo off
REM Generates random backdated commits for the last 2 years (starting today).
REM - Randomly skips some days entirely
REM - On active days, makes between 1 and 25 commits at random times
REM
REM Usage: double-click, or run "generate_commits.bat" from inside a git repo.
REM Then review the log and run: git push

setlocal

git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo Error: not inside a git repository.
    exit /b 1
)

set "PS1=%TEMP%\generate_commits_%RANDOM%.ps1"

> "%PS1%" echo $ErrorActionPreference = 'Stop'
>> "%PS1%" echo $startDate = (Get-Date).AddYears(-2)
>> "%PS1%" echo $endDate = Get-Date
>> "%PS1%" echo $skipProbability = 25
>> "%PS1%" echo $minCommits = 1
>> "%PS1%" echo $maxCommits = 25
>> "%PS1%" echo $file = "activity.log"
>> "%PS1%" echo if (-not (Test-Path $file)) { New-Item -ItemType File -Path $file ^| Out-Null }
>> "%PS1%" echo $rand = New-Object System.Random
>> "%PS1%" echo $current = $startDate.Date
>> "%PS1%" echo $totalCommits = 0
>> "%PS1%" echo $totalDays = 0
>> "%PS1%" echo while ($current -le $endDate.Date) {
>> "%PS1%" echo     if ($rand.Next(0,100) -lt $skipProbability) { $current = $current.AddDays(1); continue }
>> "%PS1%" echo     $commitCount = $rand.Next($minCommits, $maxCommits + 1)
>> "%PS1%" echo     for ($i = 0; $i -lt $commitCount; $i++) {
>> "%PS1%" echo         $hour = $rand.Next(0,24)
>> "%PS1%" echo         $minute = $rand.Next(0,60)
>> "%PS1%" echo         $second = $rand.Next(0,60)
>> "%PS1%" echo         $dt = $current.AddHours($hour).AddMinutes($minute).AddSeconds($second)
>> "%PS1%" echo         $dtStr = $dt.ToString("yyyy-MM-ddTHH:mm:ss")
>> "%PS1%" echo         Add-Content -Path $file -Value "commit at $dtStr"
>> "%PS1%" echo         git add $file ^| Out-Null
>> "%PS1%" echo         $env:GIT_AUTHOR_DATE = $dtStr
>> "%PS1%" echo         $env:GIT_COMMITTER_DATE = $dtStr
>> "%PS1%" echo         git commit -m "chore: update log ($dtStr)" --quiet
>> "%PS1%" echo     }
>> "%PS1%" echo     $totalCommits += $commitCount
>> "%PS1%" echo     $totalDays += 1
>> "%PS1%" echo     Write-Host "Day $($current.ToString('yyyy-MM-dd')): $commitCount commits"
>> "%PS1%" echo     $current = $current.AddDays(1)
>> "%PS1%" echo }
>> "%PS1%" echo Write-Host ""
>> "%PS1%" echo Write-Host "Done. $totalCommits commits created across $totalDays active days."
>> "%PS1%" echo Write-Host "Review with 'git log --oneline' then push with: git push"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
del "%PS1%" >nul 2>&1

endlocal
