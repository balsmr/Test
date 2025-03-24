$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$kasperskyApp = $null

foreach ($path in $registryPaths) {
    $apps = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "*Kaspersky Endpoint*"
    }

    if ($apps) {
        $kasperskyApp = $apps
        break
    }
}

if ($kasperskyApp) {
    $productCode = $kasperskyApp.PSChildName

    # Lancement silencieux de la désinstallation
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $productCode /qn /norestart" -WindowStyle Hidden -Wait
}
