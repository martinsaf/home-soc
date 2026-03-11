<#
.SYNOPSIS
    Enables ICMPv4 (ping) on Windows Server by creating a firewall rule.

.DESCRIPTION
    This script creates an inbound firewall rule to allow ICMPv4 echo requests (ping).
    Useful for lab environments where connectivity testing is needed.

.NOTES
    File Name  : allow-icmp-ping.ps1
    Author     : martinsaf
    Requires   : Administrator privileges
    Version    : 1.0

.EXAMPLE
    .\allow-icmp-ping.ps1
    Creates firewall rule "Allow ICMPv4-In" if it doesn't exist.
#>

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    exit 1
}

# Define rule name
$ruleName = "Allow ICMPv4-In"

# Check if rule already exists
$existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "Firewall rule '$ruleName' already exists." -ForegroundColor Yellow
} else {
    # Create the firewall rule
    try {
        New-NetFirewallRule -DisplayName $ruleName `
                           -Protocol ICMPv4 `
                           -IcmpType 8 `
                           -Direction Inbound `
                           -Action Allow `
                           -Description "Allow ICMPv4 echo requests (ping) for lab connectivity" `
                           -ErrorAction Stop
        
        Write-Host "Firewall rule '$ruleName' created successfully." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create firewall rule: $_"
        exit 1
    }
}

# Display rule details
Write-Host "`nRule details:" -ForegroundColor Cyan
Get-NetFirewallRule -DisplayName $ruleName | Format-List Name, DisplayName, Enabled, Direction, Action