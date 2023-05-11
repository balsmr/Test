##########
##
##Nom : Install_cURL.ps1
##Description : pour installer la commande cURL sur les postes qui ne l'ont pas 
##Emplacement : git
##Date modification : 24/04/2023
##Auteur : bbo
##
##########
#on active les tls
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#on test si curl est déjà présent 
if((Test-Path "C:\Windows\System32\curl.exe") -eq $true){

    Write-Verbose "cURL déjà installé"
    break
}else{

    #on s'assure que le TLS est activé
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #On télécharge le zip de curl a la racine du c
    Invoke-WebRequest 'https://curl.se/windows/latest.cgi?p=win64-mingw.zip' -OutFile 'C:\Windows\temp\cURL.zip' -UseBasicParsing -Method Get 

    #on temporise
    Start-Sleep -Seconds 5

    #on dézip l'archive
    Expand-Archive "C:\Windows\temp\cURL.zip" -DestinationPath "C:\Windows\temp\" 

    #On renome le dossier créé
    Rename-Item "c:\Windows\temp\curl-8.0.1_7-win64-mingw" "c:\Windows\temp\cURL"

    #On copie l'executable ddns system32 pour le rendre natif
    Copy-Item -Path "c:\Windows\temp\cURL\bin\curl.exe" -Destination "C:\Windows\System32\curl.exe"

    #on installe le certificat pour pouvoir télécharger en https et ftps
    Import-Certificate -FilePath "C:\Windows\temp\cURL\bin\curl-ca-bundle.crt"-CertStoreLocation Root

    Remove-Item "c:\Windows\temp\cURL" -Recurse

}
