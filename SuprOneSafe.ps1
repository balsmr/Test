##########
##
##Nom : SupprUninstaller.ps1
##Description : script pour supprimer une application par son uninstaller silencieux si renseigné dans la base de registre
##Emplacement : git / tache eset
##Date modification : 18/03/2025
##Auteur : bbo
##
##########

# Chemin vers les clés de désinstallation dans le registre
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
#Nom de l'application a chercher
$Application = "OneSafe PC Cleaner"

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
    #On selectionne la ou les application(s) qui contienne le nom entre %
    $AppGui = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%OneSafe PC Cleaner%'"
    
    #Si la selection contient une ou des application(s)
    if ($AppGui) {
         #Pour chaque application
        foreach($app in $AppGui){
            #On prépare les arguments (possibilite d'ajouter un id et mdp pour kapsersky par exemple)
            $Argument = "/x $($app.IdentifyingNumber) /qn"
            #on lance la commande MSIEXEC pour lancer la désinstallation 
            Start-Process -FilePath "msiexec.exe" -ArgumentList $Argument -Wait -NoNewWindow
    
        }

}
}
