# --- Paramètres ---
$TaskName  = "PopupWindows10_Inline"
$ScriptUrl = "https://raw.githubusercontent.com/balsmr/Test/main/popup.ps1"  # <-- ton URL
$VbsPath   = Join-Path $env:ProgramData ($TaskName + ".vbs")

# --- 1) Récupérer l'utilisateur interactif ---
$User = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
if (-not $User) {
    Write-Output "Aucun utilisateur interactif trouvé. Abandon."
    exit 1
}

# --- 2) Préparer la commande PowerShell qui sera exécutée dans la session user ---
# Cette commande :
#  - force l'OutputEncoding en UTF8 (utile pour logs)
#  - télécharge en binaire et convertit en UTF-8 avant iex (résout les accents)
#  - attend un peu, puis supprime la tâche planifiée
$psCmdHere = @"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
\$wc = New-Object System.Net.WebClient
\$bytes = \$wc.DownloadData('$ScriptUrl')
\$script = [System.Text.Encoding]::UTF8.GetString(\$bytes)
iex \$script
Start-Sleep -Seconds 3
schtasks /Delete /TN "$TaskName" /F > \$null 2>&1
"@


# --- 3) Encoder la commande en Base64 Unicode (pour -EncodedCommand) ---
# PowerShell attend la base64 encodée en Unicode (UTF-16LE)
$bytesForB64 = [System.Text.Encoding]::Unicode.GetBytes($psCmdHere)
$b64 = [Convert]::ToBase64String($bytesForB64)

# --- 4) Créer un petit VBS qui lance PowerShell de façon totalement silencieuse ---
# WScript.Run "<commande>", 0, False  --> 0 = hidden window
$vbsContent = "Set WshShell = CreateObject(""WScript.Shell"")" + "`r`n"
$vbsContent += "WshShell.Run ""powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $b64"", 0, False" + "`r`n"

# écrire le VBS sur le disque (ProgramData)
try {
    Set-Content -Path $VbsPath -Value $vbsContent -Encoding ASCII -Force
} catch {
    Write-Output "Impossible d'écrire le VBS : $_"
    exit 1
}

# --- 5) Préparer la tâche planifiée pour exécuter wscript.exe avec le VBS ---
# Action : wscript.exe "C:\ProgramData\PopupWindows10_Inline.vbs"
$action = New-ScheduledTaskAction -Execute "wscript.exe" -Argument "`"$VbsPath`""

# Trigger dans ~20s pour laisser le temps à la création
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddSeconds(20)

# Exécuter dans la session interactive de l'utilisateur
$principal = New-ScheduledTaskPrincipal -UserId $User -LogonType Interactive -RunLevel Limited

# Si la tâche existe déjà, on la supprime d'abord (prévention doublons)
try { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue } catch {}

# --- 6) Enregistrer la tâche (ne pas la Start manuellement) ---
try {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Force
    Write-Output "Tâche $TaskName créée pour $User. Elle s'exécutera dans ~20s."
} catch {
    Write-Output "Erreur création tâche : $_"
    # cleanup
    try { Remove-Item -Path $VbsPath -ErrorAction SilentlyContinue } catch {}
    exit 1
}

# --- Optionnel : nettoyage du VBS côté SYSTEM après 90s (éviter résidu) ---
Start-Sleep -Seconds 90
try { Remove-Item -Path $VbsPath -ErrorAction SilentlyContinue } catch {}

