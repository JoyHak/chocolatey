Verification is intended to assist the Chocolatey moderators and community in verifying that this package's contents are trustworthy.

The embedded software can be verified automatically by running the `verifysignature.ps1` script from "tools" folder. This script requires `chocolateyInstaller.psm1` module!

The embedded software can be verified manually by doing the following:

1. Download official assets:
    -   32-bit software: <https://github.com/JoyHak/QuickSwitch/releases/download/1.8/QuickSwitch-1.8-x32.zip>
    -   64-bit software: <https://github.com/JoyHak/QuickSwitch/releases/download/1.8/QuickSwitch-1.8-x64.zip>
2. Get the checksum using one of the following methods:
    - Using PowerShell function `Get-FileHash`:
    ```powershell
    (Get-FileHash QuickSwitch-1.8-x64.zip sha256).hash
    ```
    - Use Chocolatey utility `checksum.exe` :
    ```powershell
    &"C:\ProgramData\chocolatey\tools\checksum.exe" -f="QuickSwitch-1.8-x64.zip" -t=sha256
    ```
    - Using PowerShell function `Get-RemoteChecksum` included in Chocolatey AU module
3. The sha256 checksum of the downloaded asset and embedded archive must match the following:
    -   32-bit software: 3032808530936E48CD6D07C0998550C5C75BEAF9A854B47391500088AC1D6D9C
    -   64-bit software: 5CA14D7BEC9DAF8AA3A0C4C835970B0CAB5607CA16094311C2CB5E33D92A8341
4. Get the zip signature of the embedded archive using one of the following methods:
    -   Using utility `7z.exe`:
    ```powershell
    (&"C:\ProgramData\chocolatey\tools\7z.exe" l QuickSwitch-1.8-x64.zip | Select-String "Comment = (.+)").Matches.Groups[1].Value
    ```
    -  Using utility `WinRar.exe`:
    ```powershell
    &"C:\Program Files\WinRAR\WinRar.exe" cw -y -scu QuickSwitch-1.8-x64.zip QuickSwitch-1.8.sig
    Get-Content QuickSwitch-1.8.sig
    ```
    -   Using `System.IO.Compression` namespace::
    ```powershell
    ([IO.Compression.ZipFile]::OpenRead('QuickSwitch-1.8-x64.zip')).comment
    ```
5. The signature of the downloaded asset and embedded archive (both 32-bit and 64-bit) must match the following:
<details> <summary>ZipSign</summary>
ZipSign=data:application/cms;base64,MIIC3QYJKoZIhvcNAQcCoIICzjCCAsoCAQExDTALBglghkgBZQMEAgEwCwYJKoZIhvcNAQcBMYICpzCCAqMCAQEwgZYwfjELMAkGA1UEBhMCRU4xEDAOBgNVBAgMB0FsYWJhbWExEzARBgNVBAcMCk1vbnRnb21lcnkxFDASBgNVBAoMC1RvWXUgc3R1ZGlvMREwDwYDVQQDDAhSYWZhZWxsbzEfMB0GCSqGSIb3DQEJARYQRGlzY29yZDogQHRveXUucwIUZOe+7P9MtefNGFMEknqEn9WVnw0wCwYJYIZIAWUDBAIBoIHkMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI1MDgxNDA3MTUyNlowLwYJKoZIhvcNAQkEMSIEIAEB2L61DlIisiBqydLbY7UxvxpIwbLTMUbFuHTheMJPMHkGCSqGSIb3DQEJDzFsMGowCwYJYIZIAWUDBAEqMAsGCWCGSAFlAwQBFjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwDgYIKoZIhvcNAwICAgCAMA0GCCqGSIb3DQMCAgFAMAcGBSsOAwIHMA0GCCqGSIb3DQMCAgEoMA0GCSqGSIb3DQEBAQUABIIBAJa6BCtb3CYmeNjnGWy7W7sbFg8IAcHIBopVwiDWvAA0U1sdzqGrpbMktJ0OHlR1AVmyklfC5ttwOs3XFrIfMuIX9L4J9ExUQtnZJRb7WApCHi/fLcTdvTAeexLE3jXIcrfpahgvbZT3zu4ntQSUpSgEDFesImMlKAqDQACmxbairfJUn6Rqm72JhHg66hImyaGI7LqkcxFly9QzcuWUdU4AesVtcrZ11aE1J+kRGPDoEukvEgfF+S9IUCa+MMlQwIad9Axup3M0OtGd7ZG3cGFgLHzkdIjSRi8CyaUQ6nsCDETJmq4CnVLUrRewd05kxE/cqcmDvG5X0uF8bDm2wcU=
</details>
6.   Verify zip signature using utility `ZipSign.exe`:
     1.   Download and install: <https://github.com/falk-werner/zipsign>
     2.   Verify embedded `certificate.pem`:
     ```powershell
     zipsign verify --verbose --file QuickSwitch-1.8-x64.zip --certificate certificate.pem
     ```
     3.   Get certificate info:
     ```powershell
     zipsign info --file QuickSwitch-1.8-x64.zip
     ```
     4.   For both 32-bit and 64-bit software certificate info must contain the following:

          -   issuer: C=EN, ST=Alabama, L=Montgomery, O=ToYu studio, CN=Rafaello/emailAddress=Discord: @toyu.s

          -   serialNumber: 0x64E7BEECFF4CB5E7CD185304927A849FD5959F0D

7.   Extract required archive or install the package.

8.   Use methods from above and verify that the sha256 checksum of the installed `QuickSwitch.exe` matches the following:
     -   32-bit: 1E4D93170CF130903DC427AFF5C5524C3357A440FA97982887041FF98B6695A5
     -   64-bit: DD678DDA00D58E4DAEE85F1806B51E0EECBF117549911C642875A28FA1CFF3E9

9.   Get sha1 checksum of the digital signature using one of the following methods:
     - Using PowerShell function `Get-AuthenticodeSignature` :
     ```powershell
     (Get-AuthenticodeSignature .\QuickSwitch-1.8-x64\QuickSwitch.exe).SignerCertificate.Thumbprint
     ```

10.   For both 32-bit and 64-bit executable the sha1 checksum of the digital signature must match the following: 637F47F58F6B06D1ADB2E14B3144E6F8CD5EFD10	


The file `LICENSE.txt` has been obtained from <https://github.com/JoyHak/QuickSwitch/blob/main/LICENSE>	
