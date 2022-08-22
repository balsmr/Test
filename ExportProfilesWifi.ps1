#Dossier où sont exportés les profiles wifi
$ProfileFolder = "c:\ProfilesWifi"

#préparation liste pour les SSID
$ssidList=@()
#Liste des profiles brutes
$RawList=netsh wlan show profiles
ForEach($row1 in $RawList)
{
    #Récupération des ssids par expression régulière
    If($row1 -match 'Profil Tous les utilisateurs[^:]+:.(.+)$')
    {
        $ssidList+=$Matches[1]

    }
}
##Export des profiles wifi en xml
#Test si le dossier existe sinon le créer 
if((Test-Path $ProfileFolder) -eq $false){
    New-Item -Path "c:\" -Name "ProfilesWifi" -ItemType directory | Out-Null
}
ForEach($ssid in $ssidList){
    netsh wlan export profile $ssid key=clear folder=$ProfileFolder | Out-Null
    Write-Host -ForegroundColor Green "Profile réseau Wifi $ssid exporté"
    }