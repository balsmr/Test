##########
##
##Nom : Verif_tache_planifier.ps1
##Description : Script permetant la vérification et si besoin la création d'une tache planifier de reboot du serveur
##Emplacement :
##Date modification : 25/01/2024
##Auteur : BBO
##
##########

########Variables de configuration##########

## Declancheur de la tache ##
#Utilisateur auteur de la tache
$User= "NT AUTHORITY\SYSTEM"
#jour d'execution de la tâche
$Jour = "Sunday"
#heure de l'execution de la tâche
$Heure = "3am"

## Actiona lancer ##
#Commande a executer
$Commande = "c:\windows\system32\shutdown.exe"
#Arguments pour a commande 
$Arguments = "-r -f -t 00"

## Creation de la tache planifiee ##
#Nom de la tache 
$TaskName = "Redemarrage"


#############################################Ne pas modifier ci-dessous#############################################

## Verification de la presence de la tache 
if((Get-ScheduledTask -TaskPath \ | where {$_.taskname -like "Reboot*" -or $_.TaskName -like "Redemarrage*"}) -ne $null){
    Write-Verbose  "La tache de reboot existe existe" 
    break
}Else{

    ## Declancheur de la tache ##
    $Trigger= New-ScheduledTaskTrigger -DaysOfWeek $Jour -At $Heure -Weekly

    ## Action a lancer ##
    $Action= New-ScheduledTaskAction -Execute $Commande -Argument $Arguments

    #Utilisteur de la tache
    $principal = New-ScheduledTaskPrincipal -UserID $User -LogonType ServiceAccount -RunLevel Highest

    ## Creation de la tache planifiee ##
    Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Principal $principal -Force

}
