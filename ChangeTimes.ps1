# Requires -RunAsAdministrator
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Update Theme Switch Times" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nTime Format: HH:MM AM/PM (e.g., 7:00 AM, 11:30 PM)`n"

function Get-ValidTime ($Prompt) {
    while ($true) {
        $timeStr = Read-Host $Prompt
        try {
            $parsed = [datetime]::Parse($timeStr)
            return $parsed.ToString("h:mm tt")
        } catch {
            Write-Host "  -> Error: '$timeStr' is not a valid time format." -ForegroundColor Red
            Write-Host "  -> Please use the format HH:MM AM/PM (e.g., 7:00 AM).`n" -ForegroundColor Yellow
        }
    }
}

$newLight = Get-ValidTime "Enter the NEW time for LIGHT mode"
$newDark = Get-ValidTime "Enter the NEW time for DARK mode"

Write-Host "`nUpdating Task Scheduler..."
$triggerLight = New-ScheduledTaskTrigger -Daily -At $newLight
Set-ScheduledTask -TaskName "AutoTheme - Light Mode" -Trigger $triggerLight | Out-Null

$triggerDark = New-ScheduledTaskTrigger -Daily -At $newDark
Set-ScheduledTask -TaskName "AutoTheme - Dark Mode" -Trigger $triggerDark | Out-Null

Write-Host "`nSuccess! Your schedule has been updated." -ForegroundColor Green
Start-Sleep -Seconds 3
