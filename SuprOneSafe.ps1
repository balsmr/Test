##########
##
##Nom : SupprUninstaller.ps1
##Description : script pour supprimer une application par son uninstaller silencieux si renseigné dans la base de registre
##Emplacement : git / tache eset
##Date modification : 18/03/2025
##Auteur : bbo
##
##########

#-------------------- Variables a modifier ---------------------#
#Nom de l'application a chercher
$Application = "OneSafe PC Cleaner"

#--------------------- Script --------------------------------#
# Chemin vers les clés de désinstallation dans le registre
$path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$path64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"


# Recherche de l'application
$prog = Get-ChildItem -Path $path | ForEach-Object {
    $appName = (Get-ItemProperty -Path $_.PSPath -Name DisplayName -ErrorAction SilentlyContinue).DisplayName
    if ($appName -like "*$($Application)*") {
        Get-ItemProperty -Path $_.PSPath
    }
}

$prog64 = Get-ChildItem -Path $path64 | ForEach-Object {
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
} elseif ($prog64.QuietUninstallString) {
    # Lance la commande de désinstallation silencieuse
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($prog64.QuietUninstallString)" -Wait -NoNewWindow
    Write-Output "Désinstallation lancée avec succès."
} else {
    #Création de la requete qui vas servir pour la commande get-wmiobject
    $requete = "SELECT * FROM Win32_Product WHERE Name LIKE '%" + $Application +"%'"
    #On selectionne la ou les application(s) qui contienne le nom entre %
    $AppGui = Get-WmiObject -Query $requete
    
    #Si la selection contient une ou des application(s)
    if ($AppGui) {z
         #Pour chaque application
        foreach($app in $AppGui){
            #On prépare les arguments (possibilite d'ajouter un id et mdp pour kapsersky par exemple)
            $Argument = "/x $($app.IdentifyingNumber) /qn"
            #on lance la commande MSIEXEC pour lancer la désinstallation 
            Start-Process -FilePath "msiexec.exe" -ArgumentList $Argument -Wait -NoNewWindow
    
        }

    }
}
