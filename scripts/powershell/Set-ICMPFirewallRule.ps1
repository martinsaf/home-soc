<#
.SYNOPSIS
    Enables or disables ICMPv4 (ping) firewall rule on Windows Server.
.DESCRIPTION
    This script crates or removes an inbound firewall rule for ICMPv4 echo requests.
    Use -Enable to allow ping, -Disable to remove the rule.
.PARAMETER Enable
    Switch to enable/enforce the ICMP rule.
.PARAMETER Disable
    Switch to disable/remove the ICMP rule.
.NOTES
    File Name  : Set-ICMPFirewallRule.ps1
    Author     : martinsaf
    Requires   : Administrator privileges
    Version    : 1.0
.EXAMPLE
    .\Set-ICMPFirewallRule.ps1 -Enable
    Creates/enables the "Allow ICMPv4-In rule.
.EXAMPLE    
    .\Set-ICMPFirewallRule.ps1 -Disable
    Removes THE "Allow ICMPv4-In" rule.
#>

param(
    [Parameter(Mandatory = $true, ParameterSetName = "Enable")]
    [switch]$Enable,

    [Parameter(Mandatory = $true, ParameterSetName = "Disable")]
    [switch]$Disable
)

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    exit 1
}

# Deifne rule name
$ruleName = "Allow ICMPv4-In"

if ($Enable) {
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
}

if ($Disable) {
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
}

# Display current rule status
Write-Host "`nCurrent rule status:" -ForegroundColor Cyan
$currentRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
if ($currentRule){
    $currentRule | Format-List Name, DisplayName, Enabled, Direction, Action
}else{
    Write-Host "Rule '$ruleName' is not present." -ForegroundColor Gray
}