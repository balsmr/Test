$KasperskyApp = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Kaspersky Small%'"

if ($KasperskyApp) {
    $Password = "IT_K@5per5kY"
    $KLAdminUser = "KLAdmin"
    $Argument = "/x $($KasperskyApp.IdentifyingNumber) KLLOGIN=$KLAdminUser KLPASSWD=$Password /qn"
    Start-Process -FilePath "msiexec.exe" -ArgumentList $Argument -Wait -NoNewWindow
}
