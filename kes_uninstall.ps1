$KasperskyApp = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Kaspersky%'"

if ($KasperskyApp) {
    $Password = "!H_<*i:6dJeU7HABbt(F"
    $KLAdminUser = "KLAdmin"

    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($KasperskyApp.IdentifyingNumber) /qn REMOVE=ALL /pKLPASSWD=$Password /pKLLOGIN=$KLAdminUser" -Wait -NoNewWindow
}
