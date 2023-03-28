#lancement du telechargement en utilisant basic parsing et la methode GET pour forcer l'attente de la fin du téléchargement avant de continuer
Invoke-WebRequest -uri 'https://dl.groupeisagri.com/Troupo/FR-FR/IT/KES_installer.zip' -OutFile 'C:\KES_installer.zip' -UseBasicParsing -Method Get 


#on temporise 5 secondes avant de lancer l'instalaltion
Start-Sleep -Seconds 5


#on temporise 5 secondes avant de décompresser
Start-Sleep -Seconds 5
Expand-Archive C:\KES_installer.zip -DestinationPath C:\


#on lance l'installaiton avec les arguments
Start-Process -FilePath 'C:\KES_installer.exe' -ArgumentList '-s'
