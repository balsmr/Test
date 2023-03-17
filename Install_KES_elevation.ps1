#Set-ExecutionPolicy Unrestricted
Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope CurrentUser -Force


#on lance l'installation avec les arguments
Start-Process -FilePath 'C:\Windows\temp\KES_TEST.exe' -ArgumentList '/s'




#Set-ExecutionPolicy restricted
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

