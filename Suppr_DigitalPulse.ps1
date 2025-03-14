##########
##
##Nom : Suppr_*.ps1
##Description : script de désinstallation d'application par la commande msiexec
##Emplacement : github pour lancement par tache
##Date modification :  14/03/2025
##Auteur : BBO
##
##########

#On selectionne la ou les application(s) qui contienne le nom entre %
$Application = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE '%Digital Pulse%'"

#Si la selection contient une ou des application(s)
if ($Application) {
     #Pour chaque application
    foreach($app in $Application){
        #On prépare les arguments (possibilite d'ajouter un id et mdp pour kapsersky par exemple)
        $Argument = "/x $($Application.IdentifyingNumber) /qn"
        #on lance la commande MSIEXEC pour lancer la désinstallation 
        Start-Process -FilePath "msiexec.exe" -ArgumentList $Argument -Wait -NoNewWindow

    }

}
