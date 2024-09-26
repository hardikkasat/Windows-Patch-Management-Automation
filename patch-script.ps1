# Windows Patch Management Automation Script

# Load server names from a text file
$servers = Get-Content -Path "C:\path\to\servers.txt"

# Function to install Windows updates on a remote server
function Install-WindowsUpdates {
    param (
        [string]$server
    )
    
    Write-Host "Connecting to $server..."

    Invoke-Command -ComputerName $server -ScriptBlock {
        Install-WindowsUpdate -AcceptAll -AutoReboot
    } -ErrorAction Stop

    Write-Host "Updates installed on $server."
}

# Function to check update status and generate a report
function Check-UpdateStatus {
    param (
        [string]$server
    )

    Invoke-Command -ComputerName $server -ScriptBlock {
        Get-WindowsUpdateLog
    } | Out-File "C:\path\to\reports\$server-update-status.txt"
}

# Function to rollback updates
function Rollback-Updates {
    param (
        [string]$server
    )

    Invoke-Command -ComputerName $server -ScriptBlock {
        wusa.exe /uninstall /kb:UpdateKBID /quiet /norestart
    }

    Write-Host "Rolled back updates on $server."
}

# Iterate through servers and install updates
foreach ($server in $servers) {
    try {
        Install-WindowsUpdates -server $server
        Check-UpdateStatus -server $server
    }
    catch {
        Write-Host "Failed to install updates on $server." -ForegroundColor Red
    }
}

# Schedule script execution (if desired)
$trigger = New-ScheduledTaskTrigger -At 3am -Daily
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "C:\path\to\patch-script.ps1"
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PatchManagementTask" -Description "Automated Windows Patch Management"
