# Définir le chemin de l'exécutable Dell Command | Update
$dcuPath = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"

# Vérifier les mises à jour disponibles
Start-Process -FilePath $dcuPath -ArgumentList "/check" -Wait

# Installer les mises à jour disponibles
Start-Process -FilePath $dcuPath -ArgumentList "/applyUpdates" -Wait

# Redémarrer si nécessaire
Start-Process -FilePath $dcuPath -ArgumentList "/reboot" -Wait

