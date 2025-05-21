$uninstallPath = "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Endpoint Security for Windows\avp.com"
$password = "!H_<*i:6dJeU7HABbt(F"  # Adapté si le mot de passe est requis

if (Test-Path $uninstallPath) {
    Start-Process -FilePath $uninstallPath -ArgumentList "REMOVE /password=$password /silent" -Wait -NoNewWindow
} else {
    Write-Output "L'outil avp.com n'est pas trouvé sur ce poste."
}
