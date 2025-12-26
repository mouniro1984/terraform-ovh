# Chemin vers ton openrc.sh (il est dans le même dossier, donc chemin relatif)
$openrcPath = ".\openrc.sh"

if (-Not (Test-Path $openrcPath)) {
    Write-Error "Fichier openrc.sh non trouvé à $openrcPath"
    return
}

# Lecture et parsing des lignes export ...
Get-Content $openrcPath | ForEach-Object {
    # Ignore les lignes vides ou commentaires
    if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }

    # Capture les lignes du type : export MA_VARIABLE="valeur"
    if ($_ -match '^export\s+([A-Za-z0-9_]+)\s*=\s*(["'']?)(.*)\2$') {
        $var   = $matches[1]
        $value = $matches[3]
        [Environment]::SetEnvironmentVariable($var, $value, "Process")
        Write-Host "Variable chargée : $var = $value"
    }
}

# Demande du mot de passe OpenStack
Write-Host ""
Write-Host "Variables chargées depuis openrc.sh (sauf OS_PASSWORD)."
$securePassword = Read-Host "Entre ton mot de passe OpenStack" -AsSecureString
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
[Environment]::SetEnvironmentVariable("OS_PASSWORD", $plainPassword, "Process")
Write-Host "OS_PASSWORD chargé en mémoire. Prêt pour Terraform !"
Write-Host ""