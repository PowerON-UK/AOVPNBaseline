<#
.SYNOPSIS
    Creates an Always On VPN user tunnel connection.

.PARAMETER xmlFilePath
    Path to the ProfileXML configuration file.

.PARAMETER ProfileName
    Name of the VPN profile to be created.

.EXAMPLE
    New-AovpnConnection.ps1 -xmlFilePath "C:\Users\rdeckard\desktop\ProfileXML.xml" -ProfileName "Always On VPN User Tunnel"

.DESCRIPTION
    This script will create an Always On VPN device tunnel on supported Windows 10 devices.

.LINK
    https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/deploy/vpn-deploy-client-vpn-connections#bkmk_fullscript

.NOTES
    Version:            1.01
    Creation Date:      May 28, 2019
    Last Updated:       May 29, 2019
    Special Note:       This script adapted from published guidance provided by Microsoft.
    Original Author:    Microsoft Corporation
    Original Script:    https://docs.microsoft.com/en-us/windows-server/remote/remote-access/vpn/always-on-vpn/deploy/vpn-deploy-client-vpn-connections#bkmk_fullscript
    Author:             Richard Hicks
    Organization:       Richard M. Hicks Consulting, Inc.
    Contact:            rich@richardhicks.com
    Web Site:           www.richardhicks.com
    Modified By:        Leo D'Arcy

    License:
    MIT License

    Copyright (c) 2018 Richard M. Hicks

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

[CmdletBinding()]

Param(

    [Parameter(Mandatory = $True, HelpMessage = 'Enter the path to the ProfileXML file.')]
    [string]$xmlFilePath,
    [Parameter(Mandatory = $True, HelpMessage = 'Enter a name for the VPN profile.')]
    [string]$ProfileName

)

$CurrentTunnel = Get-VpnConnection -Name $ProfileName -ErrorAction SilentlyContinue
if ($null -ne $CurrentTunnel)
{
    Remove-VpnConnection -Name $ProfileName -Force
}

# Import ProfileXML
$ProfileXML = Get-Content $xmlFilePath

# Escape spaces in profile name
$ProfileNameEscaped = $ProfileName -replace ' ', '%20'
$ProfileXML = $ProfileXML -replace '<', '&lt;'
$ProfileXML = $ProfileXML -replace '>', '&gt;'
$ProfileXML = $ProfileXML -replace '"', '&quot;'

# OMA URI information
$NodeCSPURI = './Vendor/MSFT/VPNv2'
$NamespaceName = 'root\cimv2\mdm\dmmap'
$ClassName = 'MDM_VPNv2_01'

<#-- Define WMI Session --#>
$session = New-CimSession

<#-- Detect and Delete Previous VPN Profile --#>
try
{
    $deleteInstances = $session.EnumerateInstances($namespaceName, $className, $options)
    foreach ($deleteInstance in $deleteInstances)
    {
        $InstanceId = $deleteInstance.InstanceID
        if ("$InstanceId" -eq "$ProfileNameEscaped")
        {
            $session.DeleteInstance($namespaceName, $deleteInstance, $options)
            $Message = "Removed $ProfileName profile $InstanceId"
            Write-Host "$Message"
        } else {
            $Message = "Ignoring existing VPN profile $InstanceId"
            Write-Host "$Message"
        }
    }
}
catch [Exception]
{
    $Message = "Unable to remove existing outdated instance(s) of $ProfileName profile: $_"
    Write-Host "$Message"
    exit
}

try
{
    $username = $env:USERDOMAIN + "\" + $env:USERNAME
    $User = New-Object System.Security.Principal.NTAccount($username)
    $Sid = $User.Translate([System.Security.Principal.SecurityIdentifier])
    $SidValue = $Sid.Value
    Write-Verbose "User SID is $SidValue."
}
catch [Exception]
{
    Write-Output "Unable to get user SID. User may be logged on over Remote Desktop: $_"
    return
}

try
{
    $NewInstance = New-Object Microsoft.Management.Infrastructure.CimInstance $className, $namespaceName
    $Property = [Microsoft.Management.Infrastructure.CimProperty]::Create('ParentID', "$nodeCSPURI", 'String', 'Key')
    $NewInstance.CimInstanceProperties.Add($Property)
    $Property = [Microsoft.Management.Infrastructure.CimProperty]::Create('InstanceID', "$ProfileNameEscaped", 'String', 'Key')
    $NewInstance.CimInstanceProperties.Add($Property)
    $Property = [Microsoft.Management.Infrastructure.CimProperty]::Create('ProfileXML', "$ProfileXML", 'String', 'Property')
    $NewInstance.CimInstanceProperties.Add($Property)

    $Session.CreateInstance($namespaceName, $NewInstance, $Options)
    Write-Output "Created $ProfileName profile."
    $session.EnumerateInstances($namespaceName, $className, $options)
}
catch [Exception]
{
    Write-Output "Unable to create $ProfileName profile: $_"
    return
}

Write-Output 'Script complete.'
