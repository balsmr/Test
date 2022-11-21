##########
##
##Nom : ESET_modif_registre_SN-HlST.ps1
##Description : ajoute les information client dans le registre si elles sont dispo sur le poste (snr / histo)
##Emplacement : git-hub
##Date modification : 21/11/2022
##Auteur : Baptiste Boileau
##
##########

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


#recuperation chemin de la cle registre ESET
$regpath =  Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*\" | ? {$_.DisplayName -eq "ESET Management Agent"} | Select-Object -ExpandProperty PSPath

$SNRfile = "C:\SNR.txt"
$HISTOfile = "c:\windows\historique\Infos_Client.txt"

#Si le fichier SNR existe
if ((Test-Path $SNRfile)) {
    #on recupere le code client et sn du fichier snr avec le fonction
    $info = Get-InfoClientFromFiles -FilePath $SNRfile
    
    #si le code client et le num série récupéré ne sont pas vides
    if($info.CodeClient -and $info.SerialNumber -ne ""){

        #Modification de la cle registre avec CC et SN
        Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
        #On sort du script car fini
        break

    }else {#info sont pas bonnes 
        #si ficheir histo existe
        if ((Test-Path $HISTOfile )) {
            #on recupere le code client et sn du ficheri snr avec le fonction
            $info = Get-InfoClientFromFiles -FilePath $HISTOfile 
            
            #si le code client et le num série récupéré ne sont pas vides
            if($info.CodeClient -and $info.SerialNumber -ne ""){
                
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

                #Modification de la cle registre avec CC et SN
                Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
                #On sort du script car fini
                break
            }Else{#info dans histo erronees
                #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
                Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. SNRaFaire"
                break

            }
        }else {#fichier histo n'existe pas
            #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
            Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. SNRaFaire"
            break
        }
    }
}else { #Si fichier SNR n'existe pas
    if ((Test-Path $HISTOfile )) {
        #on recupere le code client et sn du ficheri snr avec le fonction
        $info = Get-InfoClientFromFiles -FilePath $HISTOfile 
        
        #si le code client et le num série récupéré ne sont pas vides
        if($info.CodeClient -and $info.SerialNumber -ne ""){
            
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

            #Modification de la cle registre avec CC et SN
            Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. $($info.CodeClient)-$($info.SerialNumber)"
            #On sort du script car fini
            break
        }Else{
            #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
            Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. SNRaFaire"
            break
        }
    }else {#fichier histo n'existe pas
        #Aucune des sources d'information retourne les bonnes information, il faut faire le fichier a la main
        Set-ItemProperty -Path $regpath -Name Publisher -Value "ESET, spol. s r.o. SNRaFaire"
        break
    }
}






