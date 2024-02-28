#importer csv local :
#$LeCSV = Import-Csv C:\test2.csv -Delimiter ","

#Pour voir le temps qu'a mis le script a s'éxecuter, on récupère le temp au départ
#$debut = Get-Date -Format "HH:mm:ss.fff"

###Récupération du code d'activation a partir d'un csv en ligne :
$FilePath = "C:\SNR.txt"
$SN = Get-Content -Path $FilePath | where { $_ -ne "$null" } | Select-Object -Index 2
$SN = $SN.Substring($SN.Length - ($SN.Length -12))
#on retire l'espace a la fin s'il existe
$SN = $SN.TrimEnd()
#SN du poste 
#$SN = "R5556515"

#on ajoute le TLS a utiliser pour la securite
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#url du csv contenant les informations
$url = "https://raw.githubusercontent.com/balsmr/Test/main/List.csv"
#telechargement du csv
$reponse = Invoke-WebRequest -UseBasicParsing -Uri $url
#isolation du contenu du fichier
$content = $reponse.Content
#on met en variable les informations du CSV en utilisant ; comme délimiteur

$LautreCSV = $content | ConvertFrom-Csv -Delimiter ";"

#on filtre dans le CSV récupéré la ligne qui correspond au SN
$FilterData = $LautreCSV | where { $_.SerialNumber -eq $SN }

# Le .count dans cette utilisation est incompatible avec serveur 2016 : If ($FilterData.count -ne $null){
If ($FilterData -ne $null){#si le filtre retourne qqch
    #on récupère le code d'activation dans une variable
    $ActivationCode = $FilterData.ActivationCode

    
    $arguments = "license /add $ActivationCode"

     Start-Process -FilePath "C:\Program Files (x86)\Kaspersky Lab\KES.11.11.0\avp.com" -ArgumentList $arguments

     
<#
    Write-Host -ForegroundColor Green "Le Code d'activation kaspersky pour le poste avec le SN " -NoNewline
    Write-Host $SN -NoNewline
    Write-Host -ForegroundColor Green " est " -NoNewline
    Write-Host $ActivationCode
#>

}else { #si on ne récupère pas de ligne
    <#
    Write-Host -ForegroundColor Red "Le numéro de série " -NoNewline
    Write-Host $SN -NoNewline
    Write-Host -ForegroundColor Red " n'est pas dans la liste"
    #>
}




<#
#on récupère le temps a la fin du script
$fin = Get-Date -Format "HH:mm:ss.fff"
#on calcule la durée et on l'affiche
$duree = ((Get-Date $fin) - (Get-Date $debut))
Write-Host "Le script a mis " $duree.TotalSeconds "secondes à s'éxecuter."
#>
