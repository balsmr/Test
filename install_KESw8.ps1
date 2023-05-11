$Url = "https://kaspersky-smr.groupeisagri.com:8061/dlpkg?id=13717305"  
$OutputPath = "C:\Windows\temp\KES_installer.exe"

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($Url, $OutputPath)
