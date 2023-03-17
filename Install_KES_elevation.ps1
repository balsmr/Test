Set-ExecutionPolicy Unrestricted

#on lance l'installation avec les arguments
#Start-Process -FilePath 'C:\Windows\temp\KES_TEST.exe' -ArgumentList '-s'
Start-Process -FilePath "C:\Windows\temp\KES_TEST.exe" -ArgumentList "/S /pEULA=1 /pPRIVACYPOLICY=1 /pKSN=1" -Wait



Set-ExecutionPolicy restricted
