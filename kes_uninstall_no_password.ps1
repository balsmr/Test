$KasperskyApp = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Kaspersky Endpoint%'"

if ($KasperskyApp) {
 
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($KasperskyApp.IdentifyingNumber) /qn " -Wait -NoNewWindow
}
