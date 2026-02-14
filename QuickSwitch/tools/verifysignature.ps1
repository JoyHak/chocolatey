<#
.SYNOPSIS
    Validates the digital signatures of embedded archive and installed executable.

.DESCRIPTION
    Validates that the metadata of embedded archive and installed executable matches the metadata on the GitHub server:
    - archive hash
    - hidden digital signature of the archive
    - hash of the executable file
    - digital signature of the executable file
    - compilation date
    - VersionInfo (special file properties assigned during compilation)

    A warning about at least one mismatch indicates the unreliability of the downloaded package or an error on the GitHub side.

.PARAMETER silent
    Answer "yes" to all prompts.
#>
[CmdletBinding()]
param(
    [alias('y')]
    [switch]$silent
)
$debug   = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('debug')
$verbose = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('verbose')

function Get-Prompt {
    param(
        [string]$question
    )
    if ($silent) {
        return 1
    }    
    
    $title   = ""
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&No", "&Yes")
    $default = 1
    
    return $Host.UI.PromptForChoice($title, $question, $choices, 1)
}

Import-Module $env:ChocolateyInstall\helpers\chocolateyInstaller.psm1 -verbose:$false -debug:$false 

$packageName = 'QuickSwitch'
$exeName     = "$packageName.exe"
$packageVer  = '1.8'
             
$release     =  Invoke-RestMethod "https://api.github.com/repos/JoyHak/$packageName/releases/tags/$packageVer" -debug:$debug -verbose:$verbose
$assetName   = "{0}-{1}-x{2}.zip" -f $packageName, $packageVer, (Get-OSBitness)
$asset       = $release.assets | where { $_.name -eq $assetName }

Write-Debug    "Found metadata for `"$asset`" asset"
Write-Verbose  "Checksum $($asset.digest)"

if ((Get-FileHash $assetName sha256).hash -eq ($asset.digest -replace "sha256:").ToUpper()) {
    Write-Host "$assetName sha256 hash is valid" -f Green
} else {
    Write-Warning "$assetName sha256 hash does not match the hash of the published asset"
}

if (!(Test-Path $exeName)) {
    Write-Debug "Path not found: $exeName"
    $exeName = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\$exeName"
    Write-Debug "Updated path: $exeName"
}
if (!(Test-Path $exeName)) {
    Write-Error "Unable to find installed executable: `"$exeName`"" -a "ERROR"
    exit 1
}

try {
    # Compare date of the digital signature with server.
    # Date must be less or equal to the public asset modification date.
    # Asset may be updated and uploaded again after "created_at" date so we're checking "updated_at" date
    Write-Debug     "Get digital signature for installed `"$exeName`""
    $signature     = Get-AuthenticodeSignature $exeName -debug:$debug -verbose:$verbose  
    $signatureDate = [DateTime]$signature.SignerCertificate.NotBefore.ToUniversalTime()
    $assetDate     = [DateTime]$asset.updated_at.ToUniversalTime()
   
    if (([DateTime]::Compare($assetDate, $signatureDate)) -ge 0) {
        Write-Host "$exeName was compiled before publication: $signatureDate" -f Green
    } else {
        Write-Warning "$exeName compilation date ($signatureDate) does not match the public compilation date ($assetDate)"
    }
} catch {
    Write-Error "Unable to verify compilation date. $_" -a "ERROR"
}


if (!(Get-Prompt "Do you want to download asset from server and compare `"$assetName`" and `"$exeName`" with it?")) {
    Write-Verbose "Validation terminated manually"
    exit 1
}

try {    
    # Compare embedded archive signature with server.
    # Each published .zip archive contains hidden signature in "comment" field.
    # We need to download the published asset, read the comment from it and compare it with the archive comment.
    $zipPath   = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\$assetName"
    $assetPath = "$env:temp\$assetName"
    
    Get-WebFile $asset.browser_download_url $assetPath -debug:$debug -verbose:$verbose
    Get-ChocolateyUnzip $assetPath ($assetPath -replace ".zip") -debug:$debug -DisableLogging
    
    $exePath = "$($env:ChocolateyPackageInstallLocation)\$exeName"
    Write-Debug "Extracted published executable `"$exePath`""
    
    $zipSignature   = ([IO.Compression.ZipFile]::OpenRead($zipPath)).Comment
    $assetSignature = ([IO.Compression.ZipFile]::OpenRead($assetPath)).Comment
    Write-Verbose "$assetSignature"
        
    if (!$zipSignature) {
        throw $assetSignature `
            ? "Signature is empty" `
            : "Downloaded asset and embedded archive contains ampty signature"
    }
        
    if ($assetSignature -eq $zipSignature) {
        Write-Host "$assetName hidden ZIP signature is valid" -f Green
    } else {
        Write-Warning "$assetName hidden ZIP signature does not match the ZIP signature of the published asset"
    }
} catch {
    Write-Error "Unable to verify hidden ZIP signature. $_" -a "ERROR"
}

if (!(Test-Path $exePath)) {
    Write-Error "Unable to find extracted executable: `"$exePath`"" -a "ERROR"
    exit 1
}

try {
    if ((Get-FileHash $exeName sha256).hash -eq (Get-FileHash $exePath sha256).hash) {
        Write-Host "$exeName sha256 hash is valid" -f Green
    } else {
        Write-Warning "$exeName sha256 hash does not match the hash of the published executable"
    }
} catch {
    Write-Error "Unable to verify executable hash. $_"  -a "ERROR"
}

try {
    Write-Debug "Get digital signature for published `"$exePath`""
    $signature_ = Get-AuthenticodeSignature $exePath -debug:$debug -verbose:$verbose   
    
    if (!$signature -or !$signature_) {
        throw "Signature is empty"
    }
    
    if ($signature.SignerCertificate.Thumbprint -eq $signature_.SignerCertificate.Thumbprint) {
        Write-Host "$exeName digital signature is valid: " -f Green -n
        Write-Host $signature_.SignerCertificate.subject -f DarkGray
    } else {
        Write-Warning "$exeName digital signature does not match the public signature"
    }
} catch {
    Write-Error "Unable to verify digital signature. $_" -a "ERROR"
}

try {
    # Validate special fields assigned during compilation
    Write-Debug "Get VersionInfo for `"$exeName`" and `"$exePath`""
    $versionInfo  = (Get-ChildItem $exeName).VersionInfo
    $versionInfo_ = (Get-ChildItem $exePath).VersionInfo
    
    if (!$versionInfo -or !$versionInfo_) {
        throw "VersionInfo is empty"
    }
    
    Write-Verbose "Version: $($versionInfo.FileVersion)" 
    if ($versionInfo.FileVersion     -eq $versionInfo_.FileVersion    -and
        $versionInfo.CompanyName     -eq $versionInfo_.CompanyName    -and
        $versionInfo.ProductVersion  -eq $versionInfo_.ProductVersion -and
        $versionInfo.FileDescription -eq $versionInfo_.FileDescription) {
        
        Write-Host "$exeName VersionInfo is valid, compiled by maintainer: " -f Green -n
        Write-Host $versionInfo.FileDescription -f DarkGray
    } else {
        Write-Warning "$exeName VersionInfo mismatch, сompilation source is unknown."
    }        
} catch {
    Write-Error "Unable to verify VersionInfo, сompilation source is unknown. $_" -a "ERROR"
}