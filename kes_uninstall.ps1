$KasperskyApp = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Kaspersky Endpoint%'"

if ($KasperskyApp) {
    $Password = "!H_<*i:6dJeU7HABbt(F"
    $KLAdminUser = "KLAdmin"
    $Argument = "/x $($KasperskyApp.IdentifyingNumber) KLLOGIN=$KLAdminUser KLPASSWD=$Password /qn"
    Start-Process -FilePath "msiexec.exe" -ArgumentList $Argument -Wait -NoNewWindow
}
