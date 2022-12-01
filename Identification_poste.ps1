##########
##
##Nom : identification-poste.ps1
##Description : ajoute les information client dans le registre (ESET) ou TAG (kaspersky) si elles sont dispo sur le poste (snr / histo/ juste sn ou rien)
##Emplacement : git-hub / exe ?
##Date modification : 30/11/2022
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

function Set-SNR {
    param (
        [String]$Cclient,
        [string]$NumSerie,
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
Function Set-NumSerieOuRien {
    #On recupere le SN dans barebone
    $SN2 = Get-WmiObject -Class Win32_BIOS | select -ExpandProperty serialnumber
    if ($SN2 -ne $null) {
        
        #Creation du fichier SNR avec juste le SN
        Set-SNR -Cclient "NONidentifie" -NumSerie $SN2

<#
        #On cree le fichier SNR
        New-Item $SNRfile -type file -force
        #On ajoute les informations pertinentes au fichier SNR
        Add-Content -path $SNRfile -value "[Infos_Client]"
        Add-Content -Path $SNRfile -Value "Code_Client=NONidentifie"
        Add-Content -Path $SNRfile -value "NumeroSerie=$($SN2)"
#>
        
        #on reprend les infos saisies dans le SNR pour les forcer pour ESET et Kaspersky
        $info = Get-InfoClientFromFiles -FilePath $SNRfile
        #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
        Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
        $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"'+$($info.CodeClient)+'\",\"'+$($info.SerialNumber)+'"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
        $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
        Start-Process $ksTag -ArgumentList $arguments
        break   
    }
    
    #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
    Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. Aucune_Identification"
    #Tag pour Kaspersky ?
    $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"Aucune_Identification"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
    $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
    Start-Process $ksTag -ArgumentList $arguments
    break

}



#Si le fichier SNR existe
if ((Test-Path $SNRfile)) {
    #on recupere le code client et sn du fichier snr avec le fonction
    $info = Get-InfoClientFromFiles -FilePath $SNRfile
    
    #si le code client et le num série récupéré ne sont pas vides
    if($info.CodeClient -and $info.SerialNumber -ne ""){

        #Modification de la cle registre avec CC et SN ESET
        Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
        #Tag pour Kaspersky 
        $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"'+$($info.CodeClient)+'\",\"'+$($info.SerialNumber)+'"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
        $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
        Start-Process $ksTag -ArgumentList $arguments
        #On sort du script car fini
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

<#
                ##Creation Fichier SNR
                #Si le fichier SNR exite on le supprime
                if(Test-Path $SNRfile){
                    Remove-Item $SNRfile
                }

                #On cree le fichier SNR
                New-Item $SNRfile -type file -force
                #On ajoute les informations pertinentes au fichier SNR
                Add-Content -path $SNRfile -value "[Infos_Client]"
                Add-Content -Path $SNRfile -Value "Code_Client=$($info.CodeClient)"
                Add-Content -Path $SNRfile -value "NumeroSerie=$($info.SerialNumber)"
#>

                #Modification de la cle registre avec CC et SN
                Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
                #Tag pour Kaspersky ?
                $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"'+$($info.CodeClient)+'\",\"'+$($info.SerialNumber)+'"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
                $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
                Start-Process $ksTag -ArgumentList $arguments
                #On sort du script car fini

                break
            }Else{#info dans histo erronees
                #On met le SN ou on prévien qu'aucune info d'authentification est remonté
                Set-NumSerieOuRien
                break
                
<#
                #On recupere le SN dans barebone
                $SN2 = Get-WmiObject -Class Win32_BIOS | select -ExpandProperty serialnumber
                if ($SN2 -ne $null) {

                    #On cree le fichier SNR
                    New-Item $SNRfile -type file -force
                    #On ajoute les informations pertinentes au fichier SNR
                    Add-Content -path $SNRfile -value "[Infos_Client]"
                    Add-Content -Path $SNRfile -Value "Code_Client=NONidentifie"
                    Add-Content -Path $SNRfile -value "NumeroSerie=$($SN2)"

                    #on reprend les infos saisies dans le SNR pour les forcer pour ESET et Kaspersky
                    $info = Get-InfoClientFromFiles -FilePath $SNRfile
                    #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
                    #Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
                    #Tag pour Kaspersky ?
                    #start-process ..?
                    break   
                }

                #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
                Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. AucuneIdentification"
                #Tag pour Kaspersky ?
                #start-process ..?
                break
#>
            }
        }else {#fichier histo n'existe pas
            #on met juste le num de série ou alors on remonte que le poste ne peux pas etre identifié
            Set-NumSerieOuRien
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

<#
            ##Creation Fichier SNR
            #Si le fichier SNR exite on le supprime
            if(Test-Path $SNRfile){
                Remove-Item $SNRfile
            }
            #On cree le fichier SNR
            New-Item $SNRfile -type file -force
            #On ajoute les informations pertinentes au fichier SNR
            Add-Content -path $SNRfile -value "[Infos_Client]"
            Add-Content -Path $SNRfile -Value "Code_Client=$($info.CodeClient)"
            Add-Content -Path $SNRfile -value "NumeroSerie=$($info.SerialNumber)"
#>

            #Modification de la cle registre avec CC et SN
            Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
            #De même pour kaspersky
            $arguments = '-ssvset -pv klnagent -s KLNAG_SECTION_TAGS_INFO -n KLCONN_HOST_TAGS -sv "[\"'+$($info.CodeClient)+'\",\"'+$($info.SerialNumber)+'"]" -svt ARRAY_T -ss "|ss_type = \"SS_PRODINFO\";" -t d -tl 4'
            $ksTag = "C:\Program Files (x86)\Kaspersky Lab\NetworkAgent\klscflag"
            Start-Process $ksTag -ArgumentList $arguments
            #On sort du script car fini
            break
        }Else{
            #on met juste le num de série ou alors on remonte que le poste ne peux pas etre identifié
            Set-NumSerieOuRien
            break
        }
    }else {#fichier histo n'existe pas
        #on met juste le num de série ou alors on remonte que le poste ne peux pas etre identifié
        Set-NumSerieOuRien
        break
    }
}





