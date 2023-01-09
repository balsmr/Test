##########
##
##Nom : identification-poste.ps1
##Description : ajoute les information client dans le registre (ESET) ou TAG (kaspersky) si elles sont dispo sur le poste (snr / histo/ juste sn ou rien)
##Emplacement : git-hub / exe ?
##Date modification : 09/01/2023
##Auteur : Baptiste Boileau
##
##########

#si erreur on continu
$ErrorActionPreference = 'SilentlyContinue'

#Variables
#recuperation chemin de la cle registre ESET
$regpath =  Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*\" | ? {$_.DisplayName -eq "ESET Management Agent"} | Select-Object -ExpandProperty PSPath

$SNRfile = "C:\SNR.txt"
$HISTOfile = "c:\windows\historique\Infos_Client.txt"

#Fonction pour reduire le code
function Get-InfoClientFromFiles {
    <#
    .SYNOPSIS


    .DESCRIPTION
    
    .PARAMETER FilePath

    .EXAMPLE 

    .INPUTS
    [String] chemin du fichier contenant les informations client

    .OUTPUTS
    PsObject :
        - Code client
            [string]$CodeClient
        - Numéro série
            [string]$SerialNumber

    .NOTES
        Auteur:  Baptiste Boileau
        Derniere modification : 21/11/2022
    #>
   
    param (
        [String] $FilePath
    )

    if((Test-Path -Path $FilePath)){
        #recuperationcode client a partir $FilePath
        $codeclient = Get-Content -Path $FilePath | where { $_ -ne "$null" } | Select-Object -Index 1
        $codeclient = $codeclient.Substring($codeclient.Length - ($codeclient.Length -12))
        #recuperation numero serie
        $SN = Get-Content -Path $FilePath | where { $_ -ne "$null" } | Select-Object -Index 2
        $SN = $SN.Substring($SN.Length - ($SN.Length -12))

        #Creation d'un objet contenant le code client et le num de serie
        $IDPoste = [PSCustomObject]@{
            CodeClient = $codeclient
            SerialNumber = $SN
        }
        
        #On retourne l'objet cree        
        Return $IDPoste
    }
    
}

function Get-ClientParLogISA {
    #idem mais si pas de valeur dans le premier on passse au suivant (fonctionne pas problème sortie boucle quand result est rempli)
    $result = ""
    $ListConfigISA = Get-ChildItem -Path "c:\IS*" -Recurse | where name -Like "Application.Common.4.0.0.0.config"
    $conteur = 0
    $Maxconteur = $ListConfigISA.Count
    if($ListConfigISA){
        while ($conteur -lt $Maxconteur ){
            [xml]$CONFIGISAtmp = Get-Content $($ListConfigISA[$conteur])
        
            $ISAsettingstmp = $CONFIGISAtmp.configuration.AuthenticationParameters.'Default.Trace'.setting
            $result = ($ISAsettingstmp | where name -Like LastLicenceClientId | select Value).Value
            if(!($result -eq "")){
                break
            }
            $conteur++
            
        }
    }else {
        
        $result = $null
    }

    return $result
    
}

function set-AVInfo {
    param (
        [String]$AVclient = "AucunCodeClient",
        [String]$AVserie = "AucunNumSerie"
    )

        $KPMexist =  Test-KPM

        if ($KPMexist -eq $true) {

            #Modification de la cle registre avec CC et SN ESET
            Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($AVclient)-$($AVserie)-KPM"
            #Tag pour Kaspersky 
            $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"'+$($AVclient)+'\",\"'+$($AVserie)+'\",\"KPM\"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
            $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
            Start-Process $ksTag -ArgumentList $arguments

        }else {
            #Modification de la cle registre avec CC et SN ESET
            Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($AVclient)-$($AVserie)"
            #Tag pour Kaspersky 
            $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"'+$($AVclient)+'\",\"'+$($AVserie)+'\"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
            $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
            Start-Process $ksTag -ArgumentList $arguments
        }

}

function Set-SNR {
    param (
        [String]$Cclient = "AucunCodeClient",
        [string]$NumSerie = "AucunNumSerie",
        [String]$SNRfile = "C:\SNR.txt"
    )
    if(Test-Path $SNRfile){
        Remove-Item $SNRfile
    }

    New-Item $SNRfile -type file -force | Out-Null
   
    #Ajout des informations dans le fichier
    Write-Verbose "Ajout des informations dans le fichier SNR.txt ($Cclient et $NumSerie) "
    Add-Content -path $SNRfile -value "[Infos_Client]"
    Add-Content -Path $SNRfile -Value "Code_Client=$Cclient"
    Add-Content -Path $SNRfile -value "NumeroSerie=$NumSerie"
    break
}

Function Set-LastInfoOuRien {
    #On recupere le SN dans barebone
    $SN2 = Get-WmiObject -Class Win32_BIOS | select -ExpandProperty serialnumber
    $CClient2 = Get-ClientParLogISA

    if($CClient2 -ne "" -and $SN2 -ne $null){
        
        #On fait le fichier SNR
        Set-SNR -Cclient $CClient2 -NumSerie $SN2
        #On récpère les infos du ficheir SNR
        $info = Get-InfoClientFromFiles -FilePath $SNRfile
        #On remontes les infos du snr dans les antivirus
        Set-AVInfo -AVclient $($info.CodeClient) -AVserie $($info.SerialNumber)
        break

    }elseif ($SN2 -ne $null) {
        
        #Creation du fichier SNR avec juste le SN
        Set-SNR -NumSerie $SN2
        #On récpère les infos du ficheir SNR
        $info = Get-InfoClientFromFiles -FilePath $SNRfile
        #On remontes les infos du snr dans les antivirus
        Set-AVInfo -AVclient $($info.CodeClient) -AVserie $($info.SerialNumber)
        break  

    }elseif($CClient2 -ne ""){

        #Creation du fichier SNR avec juste le SN
        Set-SNR -Cclient $CClient2
        #On récpère les infos du ficheir SNR
        $info = Get-InfoClientFromFiles -FilePath $SNRfile
        #On remontes les infos du snr dans les antivirus
        Set-AVInfo -AVclient $($info.CodeClient) -AVserie $($info.SerialNumber)
        break

    }
    
    Set-AVInfo
    break

}

function Test-KPM {
    #De base on considère qu'il n'y a pas de coffre fort a mot de passe :
    $Kvault = $false

    ####################

    $ListLocalUsers =  Get-LocalUser | where enabled -EQ $true

    foreach ($User in $ListLocalUsers){
        $Kvault = Test-Path -Path "C:\Users\$($User.Name)\AppData\Local\Kaspersky Lab\Kaspersky Password Manager\kpm_vault.edb"
        if ($Kvault -eq $true) {
            Return $Kvault
        }
    }

    return $Kvault
    
}

###################
##Début du script##
###################

#Si le fichier SNR existe
if ((Test-Path $SNRfile)) {
    #on recupere le code client et sn du fichier snr avec le fonction
    $info = Get-InfoClientFromFiles -FilePath $SNRfile
    
    #si le code client et le num série récupéré ne sont pas vides
    if($info.CodeClient -and $info.SerialNumber -ne ""){

        #On remontes les infos du snr dans les antivirus
        Set-AVInfo -AVclient $($info.CodeClient) -AVserie $($info.SerialNumber)
        break

    }else {#info sont pas bonnes 
        #si ficheir histo existe
        if ((Test-Path $HISTOfile )) {
            #on recupere le code client et sn du ficheri snr avec le fonction
            $info = Get-InfoClientFromFiles -FilePath $HISTOfile 
            
            #si le code client et le num série récupéré ne sont pas vides
            if($info.CodeClient -and $info.SerialNumber -ne ""){
                

                #Creation du fichier SNR avec juste les infos pertinantes
                Set-SNR -Cclient $($info.CodeClient) -NumSerie $($info.SerialNumber)

                #On remontes les infos du snr dans les antivirus
                Set-AVInfo -AVclient $($info.CodeClient) -AVserie $($info.SerialNumber)

                break

            }Else{#info dans histo erronees

                #On met le SN ou on prévien qu'aucune info d'authentification est remonté
                Set-LastInfoOuRien
                break
               
            }
        }else {#fichier histo n'existe pas

            #on met juste le num de série ou alors on remonte que le poste ne peux pas etre identifié
            Set-LastInfoOuRien
            break

        }

    }

}else { #Si fichier SNR n'existe pas
    if ((Test-Path $HISTOfile )) {

        #on recupere le code client et sn du ficheri snr avec le fonction
        $info = Get-InfoClientFromFiles -FilePath $HISTOfile 
        
        #si le code client et le num série récupéré ne sont pas vides
        if($info.CodeClient -and $info.SerialNumber -ne ""){

            #Creation du fichier SNR avec juste les infos pertinantes
            Set-SNR -Cclient $($info.CodeClient) -NumSerie $($info.SerialNumber)
            
            #On remontes les infos du snr dans les antivirus
            Set-AVInfo -AVclient $($info.CodeClient) -AVserie $($info.SerialNumber)
            break

        }Else{

            #on met juste le num de série ou alors on remonte que le poste ne peux pas etre identifié
            Set-LastInfoOuRien
            break

        }

    }else {#fichier histo n'existe pas

        #on met juste le num de série ou alors on remonte que le poste ne peux pas etre identifié
        Set-LastInfoOuRien
        break

    }

}
