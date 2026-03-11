<#
.SYNOPSIS
    Disables/removes the ICMPv4 (ping) firewall rule on Windows Server.
.DESCRIPTION
    This script removes the inbound firewall rule that allows ICMPv4 echo requests (ping).
    Use this when you want to restore default Windows Firewall behavior.
.NOTES
    File Name  : disable-icmp-ping.ps1
    Author     : martinsaf
    Requires   : Administrator privileges
    Version    : 1.0
.EXAMPLE
    .\disable-icmp-ping.ps1
    Removes firewall rule "Allow ICMPv4-In" if it exists.
#>

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    exit 1
}

# Define rule name
$ruleName = "Allow ICMPv4-In"

# Check if rule exists
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($existingRule) {
    # Remove the firewall rule
    try {
        Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction Stop
        Write-Host "Firewall rule '$ruleName' removed successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to remove firewall rule: $_"
        exit 1
    }
} else {
    Write-Host "Firewall rule '$ruleName' does not exist. Nothing to remove." -ForegroundColor Yellow
}
