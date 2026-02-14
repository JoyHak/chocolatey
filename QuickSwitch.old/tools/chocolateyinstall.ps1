$ErrorActionPreference = 'Stop'
          
$url        = 'https://github.com/JoyHak/QuickSwitch/releases/download/1.8/QuickSwitch-1.8-x32.zip'
$url64      = 'https://github.com/JoyHak/QuickSwitch/releases/download/1.8/QuickSwitch-1.8-x64.zip'
$targetPath = "$($env:ProgramFiles)\QuickSwitch"

$packageArgs = @{
  packageName    = 'QuickSwitch'
  unzipLocation  = $targetPath
  url            = $url
  url64bit       = $url64
  checksum       = '3032808530936E48CD6D07C0998550C5C75BEAF9A854B47391500088AC1D6D9C'
  checksumType   = 'sha256'
  checksum64     = '5CA14D7BEC9DAF8AA3A0C4C835970B0CAB5607CA16094311C2CB5E33D92A8341'
  checksumType64 = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

$shortcutArgs = @{
    shortcutFilePath = "$([Environment]::GetFolderPath('StartMenu'))\Programs\QuickSwitch.lnk"
    targetPath       = "$targetPath\QuickSwitch.exe"
    description      = 'https://github.com/JoyHak/QuickSwitch'
}

Install-ChocolateyShortcut @shortcutArgs