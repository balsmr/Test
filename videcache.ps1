# Ouvre une console PowerShell en tant qu'administrateur avant d'exécuter ce script

# 1. Arrêt des services liés à Windows Update
Stop-Service -Name wuauserv -Force
Stop-Service -Name bits -Force
Stop-Service -Name cryptsvc -Force
Stop-Service -Name msiserver -Force

# 2. Suppression du cache de mises à jour
Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force
Remove-Item -Path "C:\Windows\System32\catroot2\*" -Recurse -Force

# 3. Redémarrage des services
Start-Service -Name wuauserv
Start-Service -Name bits
Start-Service -Name cryptsvc
Start-Service -Name msiserver

