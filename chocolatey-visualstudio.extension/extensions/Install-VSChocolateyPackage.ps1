﻿# based on Install-ChocolateyPackage (a9519b5), with changes:
# - added recognition of exit codes signifying reboot requirement
# - VS installers are exe
# - local file name is extracted from the url (to avoid passing -getOriginalFileName to Get-ChocolateyWebFile for compatibility with old Chocolatey)
# - removed Get-ChocolateyWebFile options support (for compatibility with old Chocolatey)
# - removed exit code parameters in order to centralize exit code logic
function Install-VSChocolateyPackage
{
    [CmdletBinding()]
    param(
        [string] $packageName,
        [string] $silentArgs = '',
        [string] $url,
        [alias("url64")][string] $url64bit = '',
        [string] $checksum = '',
        [string] $checksumType = '',
        [string] $checksum64 = '',
        [string] $checksumType64 = '',
        [string] $logFilePath,
        [switch] $assumeNewVS15Installer
    )

    Write-Debug "Running 'Install-VSChocolateyPackage' for $packageName with url:'$url', args:'$silentArgs', url64bit:'$url64bit', checksum:'$checksum', checksumType:'$checksumType', checksum64:'$checksum64', checksumType64:'$checksumType64', logFilePath:'$logFilePath'";

    $chocTempDir = $env:TEMP
    $tempDir = Join-Path $chocTempDir "$packageName"
    if ($env:packageVersion -ne $null) { $tempDir = Join-Path $tempDir "$env:packageVersion" }

    if (![System.IO.Directory]::Exists($tempDir)) { [System.IO.Directory]::CreateDirectory($tempDir) | Out-Null }
    $urlForFileNameDetermination = $url
    if ($urlForFileNameDetermination -eq '') { $urlForFileNameDetermination = $url64bit }
    if ($urlForFileNameDetermination -like '*.exe') { $localFileName = $urlForFileNameDetermination.Substring($urlForFileNameDetermination.LastIndexOfAny(@('/', '\')) + 1) }
    else { $localFileName = 'vs_setup.exe' }
    $localFilePath = Join-Path $tempDir $localFileName

    $arguments = @{
        packageName = $packageName
        fileFullPath = $localFilePath
        url = $url
        url64bit = $url64bit
        checksum = $checksum
        checksumType = $checksumType
        checksum64 = $checksum64
        checksumType64 = $checksumType64
    }
    Get-ChocolateyWebFile @arguments | Out-Null

    $arguments = @{
        packageName = $packageName
        silentArgs = $silentArgs
        file = $localFilePath
        logFilePath = $logFilePath
        assumeNewVS15Installer = $assumeNewVS15Installer
    }
    Install-VSChocolateyInstallPackage @arguments
}