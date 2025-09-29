# --- Paramètres ---
$TaskName = "PopupWindows10_Inline"
$ScriptUrl = "https://raw.githubusercontent.com/plop/Test/refs/heads/main/mapopup.ps1"

# --- Récupérer l'utilisateur actuellement connecté (domaine\user ou user) ---
$User = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
if (-not $User) {
    Write-Output "Aucun utilisateur interactif trouvé. Abandon."
    exit 1
}

# --- Construire l'argument pour powershell.exe ---
# Version UTF-8 en mémoire avec bullets sécurisés
$psCommand = "$wc=New-Object System.Net.WebClient;$raw=$wc.DownloadData('$ScriptUrl');$script=[System.Text.Encoding]::UTF8.GetString($raw);$script=$script -replace '•',([char]0x2022);iex $script"

# Argument final pour scheduled task : -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "<psCommand>"
$argumentForTask = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"$psCommand`""

# --- Créer l'action / trigger / principal ---
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $argumentForTask
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
$principal = New-ScheduledTaskPrincipal -UserId $User -LogonType Interactive -RunLevel Limited

# --- Enregistrer, démarrer, puis nettoyer ---
try {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Force
    #Start-ScheduledTask -TaskName $TaskName

    # Laisser le temps à la tâche de s'exécuter (ajuste si nécessaire)
    Start-Sleep -Seconds 90

} catch {
    Write-Output "Erreur lors de la création/exécution de la tâche : $_"
} finally {
    # Supprime la tâche planifiée
    try { Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue } catch {}
    Write-Output "Tâche $TaskName supprimée."
}
