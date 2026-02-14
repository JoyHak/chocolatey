$ErrorActionPreference = 'SilentlyContinue'

Stop-Process -name QuickSwitch -Force
Remove-Item `
    -Path "$($env:ProgramFiles)\QuickSwitch" `
    -Force -Recurse
    
Remove-Item `
    -Path "$([Environment]::GetFolderPath('StartMenu'))\Programs\QuickSwitch.lnk" `
    -ErrorAction SilentlyContinue `
    -Force