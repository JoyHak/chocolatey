$ErrorActionPreference = 'Stop'
        
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$targetPath = $toolsDir

$packageArgs = @{
  packageName    = 'QuickSwitch'
  destination    = $targetPath
  fileFullPath   = "$toolsDir\QuickSwitch-1.8-x32.zip"
  fileFullPath64 = "$toolsDir\QuickSwitch-1.8-x64.zip"
}

Get-ChocolateyUnzip @packageArgs

$shortcutArgs = @{
    shortcutFilePath = "$([Environment]::GetFolderPath('StartMenu'))\Programs\QuickSwitch.lnk"
    targetPath       = "$targetPath\QuickSwitch.exe"
    description      = 'https://github.com/JoyHak/QuickSwitch'
}

Install-ChocolateyShortcut @shortcutArgs