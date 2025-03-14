##########
##
##Nom : SupprUninstaller.ps1
##Description : script pour supprimer une application par son uninstaller silencieux si renseigné dans la base de registre
##Emplacement : git / tache eset
##Date modification : 14/03/2025
##Auteur : bbo
##
##########

# Chemin vers les clés de désinstallation dans le registre
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
#Nom de l'application a chercher
$Application = "Digital Pulse"

# Recherche de l'application
$prog = Get-ChildItem -Path $path | ForEach-Object {
    $appName = (Get-ItemProperty -Path $_.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
    if ($appName -like "*$($Application)*") {
        Get-ItemProperty -Path $_.PSPath
    }
}

# Vérifie si l'application a été trouvée
if ($prog.QuietUninstallString) {
    # Lance la commande de désinstallation silencieuse
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($prog.QuietUninstallString)" -Wait -NoNewWindow
    Write-Output "Désinstallation lancée avec succès."
} else {
    Write-Output "Application non trouvée ou QuietUninstallString non disponible."
}
