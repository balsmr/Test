#lancement du telechargement en utilisant basic parsing et la methode GET pour forcer l'attente de la fin du téléchargement avant de continuer
Invoke-WebRequest 'https://kaspersky-smr.groupeisagri.com:8061/dlpkg?id=13751576' -OutFile 'C:\Windows\temp\KES_TEST.exe' -UseBasicParsing -Method Get 

#on temporise 5 secondes avant de lancer l'instalaltion
Start-Sleep -Seconds 5
#on lance l'installaiton avec les arguments
Start-Process -FilePath 'C:\Windows\temp\KES_TEST.exe' -ArgumentList '/S /pEULA=1 /pPRIVACYPOLICY=1 /pKSN=1'
