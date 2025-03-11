$app = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Kaspersky%'"
if ($app) {
    $app.Uninstall()
}
