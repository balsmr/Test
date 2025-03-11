$KasperskyApp = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Kaspersky Security Center%'"

if ($KasperskyApp) {
    
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($KasperskyApp.IdentifyingNumber) /qn REMOVE=ALL " -Wait -NoNewWindow
}
