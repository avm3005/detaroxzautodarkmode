# Requires -RunAsAdministrator

Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows 11 Auto-Theme Master Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please enter the times in a standard format (e.g., 7:00 AM, 18:30, 8:00 PM)"
$lightTime = Read-Host "Enter the time to trigger LIGHT mode"
$darkTime = Read-Host "Enter the time to trigger DARK mode"

# Updated Directory Path
$targetDir = "C:\Scripts\detaroxzautodarkmode"
$coreScriptPath = "$targetDir\Set-Theme.ps1"
$settingsScriptPath = "$targetDir\ChangeTimes.ps1"
$uninstallScriptPath = "$targetDir\Uninstall-AutoTheme.ps1"

# --- 1. CREATE DIRECTORY ---
Write-Host "`n[1/5] Setting up directory at $targetDir..."
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# --- 2. CREATE THE CORE THEME SCRIPT ---
Write-Host "[2/5] Generating core theme script..."
$coreScriptContent = @'
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Light", "Dark")]
    [string]$Theme
)
$val = if ($Theme -eq "Light") { 1 } else { 0 }
$reg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $reg -Name AppsUseLightTheme -Value $val -Force
Set-ItemProperty -Path $reg -Name SystemUsesLightTheme -Value $val -Force

$code = '[DllImport("user32.dll",CharSet=CharSet.Auto)]public static extern IntPtr SendMessageTimeout(IntPtr h,uint m,IntPtr w,string l,uint f,uint t,out IntPtr r);'
if (-not ("Win32.ThemeRefresher" -as [type])) { Add-Type -MemberDefinition $code -Name "ThemeRefresher" -Namespace "Win32" }

$res = [IntPtr]::Zero
[Win32.ThemeRefresher]::SendMessageTimeout([IntPtr]0xFFFF, 0x001A, [IntPtr]0, "ImmersiveColorSet", 2, 2000, [ref]$res) | Out-Null
exit 0
'@
Set-Content -Path $coreScriptPath -Value $coreScriptContent -Force

# --- 3. CREATE THE SETTINGS SCRIPT ---
Write-Host "[3/5] Generating the 'Change Times' settings script..."
$settingsScriptContent = @'
# Requires -RunAsAdministrator
Clear-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Update Theme Switch Times" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
$newLight = Read-Host "Enter the NEW time for LIGHT mode (e.g., 7:00 AM)"
$newDark = Read-Host "Enter the NEW time for DARK mode (e.g., 7:00 PM)"

Write-Host "`nUpdating Task Scheduler..."
$triggerLight = New-ScheduledTaskTrigger -Daily -At $newLight
Set-ScheduledTask -TaskName "AutoTheme - Light Mode" -Trigger $triggerLight | Out-Null

$triggerDark = New-ScheduledTaskTrigger -Daily -At $newDark
Set-ScheduledTask -TaskName "AutoTheme - Dark Mode" -Trigger $triggerDark | Out-Null

Write-Host "`nSuccess! Your schedule has been updated." -ForegroundColor Green
Start-Sleep -Seconds 3
'@
Set-Content -Path $settingsScriptPath -Value $settingsScriptContent -Force

# --- 4. CREATE THE UNINSTALLER SCRIPT ---
Write-Host "[4/5] Generating the Uninstaller script..."
$uninstallScriptContent = @'
# Requires -RunAsAdministrator
Clear-Host
Write-Host "========================================" -ForegroundColor Red
Write-Host "  Removing Windows 11 Auto-Theme..." -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "1. Unregistering Scheduled Tasks..."
$tasks = @("AutoTheme - Light Mode", "AutoTheme - Dark Mode")
foreach ($task in $tasks) {
    if (Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $task -Confirm:$false
        Write-Host "   -> Removed task: $task" -ForegroundColor Green
    }
}

Write-Host "`n2. Queuing directory deletion (C:\Scripts\detaroxzautodarkmode)..."
Write-Host "`nEverything has been successfully removed!" -ForegroundColor Green
Write-Host "This window will close and the folder will be deleted in 3 seconds."
Start-Sleep -Seconds 3

$cmdArgs = "/c timeout /t 2 >nul & rmdir /s /q `"C:\Scripts\detaroxzautodarkmode`""
Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -WindowStyle Hidden
exit
'@
Set-Content -Path $uninstallScriptPath -Value $uninstallScriptContent -Force

# --- 5. REGISTER SCHEDULED TASKS ---
Write-Host "[5/5] Configuring Windows Task Scheduler..."
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

$actionLight = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"`& '$coreScriptPath' -Theme Light; exit`""
$triggerLight = New-ScheduledTaskTrigger -Daily -At $lightTime
$taskLight = New-ScheduledTask -Action $actionLight -Principal $principal -Trigger $triggerLight -Settings $settings
Register-ScheduledTask -TaskName "AutoTheme - Light Mode" -InputObject $taskLight -Force | Out-Null

$actionDark = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"`& '$coreScriptPath' -Theme Dark; exit`""
$triggerDark = New-ScheduledTaskTrigger -Daily -At $darkTime
$taskDark = New-ScheduledTask -Action $actionDark -Principal $principal -Trigger $triggerDark -Settings $settings
Register-ScheduledTask -TaskName "AutoTheme - Dark Mode" -InputObject $taskDark -Force | Out-Null

# --- FINISH & GITHUB PROMPT ---
Write-Host "`n========================================" -ForegroundColor Green
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Light mode set for: $lightTime"
Write-Host "Dark mode set for:  $darkTime"
Write-Host "`nYou can now delete this installation file."
Write-Host "Inside '$targetDir' you will find scripts to change the schedule or uninstall entirely."

Write-Host "`n----------------------------------------"
$visit = Read-Host "Would you like to visit the developer's GitHub page (@avm3005)? (Y/N)"
if ($visit -match '^[Yy]') {
    Write-Host "Opening GitHub..." -ForegroundColor Cyan
    Start-Process "https://github.com/avm3005"
}

Start-Sleep -Seconds 3
