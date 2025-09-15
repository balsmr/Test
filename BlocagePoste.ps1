# Change le mot de passe des comptes locaux administrateurs – aucune sortie
# À exécuter en PowerShell élevé (Exécuter en tant qu’administrateur)

$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# Nouveau mot de passe (tel que demandé)
$SecurePwd = ConvertTo-SecureString '0344064008' -AsPlainText -Force

# Récupère les comptes *locaux* membres du groupe Administrateurs (nom localisé FR)
$localAdminUsers = Get-LocalGroupMember -Group 'Administrateurs' 2>$null |
  Where-Object { $_.ObjectClass -eq 'User' -and $_.PrincipalSource -eq 'Local' } |
  Select-Object -ExpandProperty Name

# Applique le mot de passe à chaque compte
foreach ($name in $localAdminUsers) {
  try {
    Set-LocalUser -Name $name -Password $SecurePwd *> $null
  } catch { }
}
