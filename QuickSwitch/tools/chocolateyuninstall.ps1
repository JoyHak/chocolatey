$ErrorActionPreference = 'SilentlyContinue'

Stop-Process -name QuickSwitch -Force

Remove-Item `
    -Path "$([Environment]::GetFolderPath('StartMenu'))\Programs\QuickSwitch.lnk" `
    -ErrorAction SilentlyContinue `
    -Force