
#lancement du telechargement en utilisant basic parsing et la methode GET pour forcer l'attente de la fin du téléchargement avant de continuer
Start-Job -Name Kdownload -ScriptBlock {
    Invoke-WebRequest 'https://kaspersky-smr.groupeisagri.com:8061/dlpkg?id=13751576' -OutFile 'C:\Windows\temp\KES_TEST.exe' -UseBasicParsing -Method Get 
}

while ((Get-Job -Name Kdownload).State -ne "Completed") {

    Start-Sleep -Seconds 5
    
}

Start-Process -FilePath 'C:\Windows\temp\KES_TEST.exe' -ArgumentList '/S /pEULA=1 /pPRIVACYPOLICY=1 /pKSN=1'


Get-Job -Name Kdownload | where State -EQ "Completed" | Remove-Job
