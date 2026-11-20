# reporte_espacio.ps1 - SOLO LECTURA. No borra nada. Genera un informe de uso de disco.
# Uso (ideal: PowerShell como administrador):
#   powershell -ExecutionPolicy Bypass -File reporte_espacio.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "SilentlyContinue"
$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$out = Join-Path $base ("Reporte_Espacio_" + (Get-Date -Format "yyyy-MM-dd_HH-mm"))
New-Item -ItemType Directory -Path $out | Out-Null
function GB($b) { if ($b) { [math]::Round($b / 1GB, 2) } else { 0 } }
function FolderSize($p) {
  if (Test-Path -LiteralPath $p) {
    (Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
  } else { 0 }
}
function Step($t) { Write-Host ">> $t" -ForegroundColor Cyan }

Step "Discos"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, VolumeName,
  @{n="Total_GB";e={GB $_.Size}}, @{n="Libre_GB";e={GB $_.FreeSpace}}, @{n="Usado_GB";e={GB ($_.Size - $_.FreeSpace)}} |
  Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "discos.csv")

Step "Programas instalados"
$keys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
Get-ItemProperty $keys | Where-Object { $_.DisplayName -and -not $_.SystemComponent } |
  Select-Object DisplayName, Publisher, DisplayVersion, InstallDate,
    @{n="Tamano_GB";e={GB ($_.EstimatedSize * 1KB)}}, InstallLocation |
  Sort-Object Tamano_GB -Descending |
  Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "programas.csv")

Step "Juegos de Steam"
$steam = (Get-ItemProperty "HKCU:\Software\Valve\Steam").SteamPath
$steamRows = @()
if ($steam) {
  $libs = @($steam.Replace("/", "\"))
  $vdf = Join-Path $steam "steamapps\libraryfolders.vdf"
  if (Test-Path $vdf) {
    foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) { $libs += $m.Groups[1].Value.Replace("\\", "\") }
  }
  foreach ($lib in ($libs | Select-Object -Unique)) {
    foreach ($f in Get-ChildItem (Join-Path $lib "steamapps\appmanifest_*.acf")) {
      $t = Get-Content $f.FullName -Raw
      $name = [regex]::Match($t, '"name"\s+"([^"]+)"').Groups[1].Value
      $size = [regex]::Match($t, '"SizeOnDisk"\s+"(\d+)"').Groups[1].Value
      $lp = [regex]::Match($t, '"LastPlayed"\s+"(\d+)"').Groups[1].Value
      $last = ""
      if ($lp -and $lp -ne "0") { $last = [DateTimeOffset]::FromUnixTimeSeconds([int64]$lp).LocalDateTime.ToString("yyyy-MM-dd") }
      $steamRows += [pscustomobject]@{ Juego = $name; Tamano_GB = (GB ([double]$size)); Ultima_vez_jugado = $last; Biblioteca = $lib }
    }
  }
}
$steamRows | Sort-Object Tamano_GB -Descending | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "steam.csv")

Step "Juegos de Epic Games"
$epicRows = @()
foreach ($f in Get-ChildItem "C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests\*.item") {
  $j = Get-Content $f.FullName -Raw | ConvertFrom-Json
  $lw = ""
  if (Test-Path -LiteralPath $j.InstallLocation) { $lw = (Get-Item -LiteralPath $j.InstallLocation).LastWriteTime.ToString("yyyy-MM-dd") }
  $epicRows += [pscustomobject]@{ Juego = $j.DisplayName; Tamano_GB = (GB ([double]$j.InstallSize)); Carpeta = $j.InstallLocation; Ultima_modificacion = $lw }
}
$epicRows | Sort-Object Tamano_GB -Descending | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "epic.csv")

Step "Ultima ejecucion de programas (Prefetch, requiere administrador)"
Get-ChildItem "C:\Windows\Prefetch\*.pf" | ForEach-Object {
  [pscustomobject]@{ Programa = ($_.BaseName -replace '-[0-9A-F]{8}$', ''); Ultima_ejecucion = $_.LastWriteTime.ToString("yyyy-MM-dd") }
} | Sort-Object Ultima_ejecucion -Descending | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "ultimo_uso.csv")

Step "Tamano de carpetas (puede tardar unos minutos)"
$rows = @()
$targets = @()
$targets += Get-ChildItem -LiteralPath $HOME -Directory -Force | Where-Object { $_.Name -ne "AppData" } | ForEach-Object { $_.FullName }
$targets += Get-ChildItem -LiteralPath "$HOME\AppData\Local" -Directory -Force | ForEach-Object { $_.FullName }
$targets += Get-ChildItem -LiteralPath "$HOME\AppData\Roaming" -Directory -Force | ForEach-Object { $_.FullName }
$targets += "C:\Windows\Temp", "C:\Windows\SoftwareDistribution\Download", "C:\XboxGames", "C:\Program Files", "C:\Program Files (x86)", "C:\ProgramData"
$targets += Get-ChildItem "C:\Program Files", "C:\Program Files (x86)" -Directory -Force | ForEach-Object { $_.FullName }
$targets += Get-ChildItem "C:\" -Directory -Force | Where-Object { $_.Name -notin @("Windows","Users","Program Files","Program Files (x86)","ProgramData","System Volume Information","`$Recycle.Bin") } | ForEach-Object { $_.FullName }
$i = 0
foreach ($t in ($targets | Select-Object -Unique)) {
  $i++
  Write-Progress -Activity "Midiendo carpetas" -Status $t -PercentComplete ([math]::Min(100, $i * 100 / $targets.Count))
  $rows += [pscustomobject]@{ Carpeta = $t; Tamano_GB = (GB (FolderSize $t)) }
}
$rows | Where-Object { $_.Tamano_GB -ge 0.1 } | Sort-Object Tamano_GB -Descending |
  Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "carpetas.csv")

Step "Papelera de reciclaje"
[pscustomobject]@{ Papelera_GB = (GB (FolderSize "C:\`$Recycle.Bin")) } | Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "papelera.csv")

Step "Archivos grandes (mas de 300 MB) en tu usuario"
Get-ChildItem -LiteralPath $HOME -Recurse -File -Force | Where-Object { $_.Length -gt 300MB } |
  Select-Object FullName, @{n="Tamano_GB";e={GB $_.Length}}, @{n="Modificado";e={$_.LastWriteTime.ToString("yyyy-MM-dd")}},
    @{n="Ultimo_acceso";e={$_.LastAccessTime.ToString("yyyy-MM-dd")}} |
  Sort-Object Tamano_GB -Descending | Select-Object -First 80 |
  Export-Csv -NoTypeInformation -Encoding UTF8 (Join-Path $out "archivos_grandes.csv")

Write-Progress -Activity "Midiendo carpetas" -Completed
Write-Host ""
Write-Host "Listo. No se borro nada. Informe en: $out" -ForegroundColor Green
Write-Host "Avisale a Claude que ya esta el reporte." -ForegroundColor Green
