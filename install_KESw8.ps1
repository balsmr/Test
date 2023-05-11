$Url = "https://kaspersky-smr.groupeisagri.com:8061/dlpkg?id=13717305"  # Remplacez URL_DU_FICHIER par l'URL réelle du fichier que vous souhaitez télécharger
$OutputPath = "C:\Windows\temp\KES_installer.exe"  # Remplacez CHEMIN_DE_DESTINATION par le chemin d'accès complet où vous souhaitez enregistrer le fichier téléchargé

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($Url, $OutputPath)
