Import-Module BitsTransfer

#lancement du telechargement en utilisant basic parsing et la methode GET pour forcer l'attente de la fin du téléchargement avant de continuer
Start-BitsTransfer -Source 'https://kaspersky-smr.groupeisagri.com:8061/dlpkg?id=13717305' -Destination 'C:\Windows\temp\KES_installer.exe'

#on temporise 5 secondes avant de lancer l'instalaltion
Start-Sleep -Seconds 5

#on lance l'installaiton avec les arguments
Start-Process -FilePath 'C:\Windows\temp\KES_installer.exe' -ArgumentList '-s'
