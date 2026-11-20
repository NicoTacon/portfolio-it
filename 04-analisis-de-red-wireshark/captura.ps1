# captura.ps1 - Captura trafico con TShark y genera resumenes para analizar.
# Uso:
#   Capturar:  powershell -ExecutionPolicy Bypass -File captura.ps1 [-Segundos 30] [-Interfaz N] [-Filtro "host 1.2.3.4"]
#   Analizar un archivo existente:  powershell -ExecutionPolicy Bypass -File captura.ps1 -Archivo C:\ruta\archivo.pcapng
param(
  [int]$Segundos = 30,
  [string]$Interfaz = "",
  [string]$Filtro = "",
  [string]$Archivo = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ts = "C:\Program Files\Wireshark\tshark.exe"
if (-not (Test-Path $ts)) { Write-Host "No encuentro tshark.exe en $ts" -ForegroundColor Red; exit 1 }

$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$out = Join-Path $base $stamp
New-Item -ItemType Directory -Path $out | Out-Null

if ($Archivo -ne "") {
  $pcap = Join-Path $out "captura.pcapng"
  Copy-Item $Archivo $pcap
  Write-Host "Analizando archivo: $Archivo"
} else {
  if ($Interfaz -eq "") {
    Write-Host "Interfaces disponibles:" -ForegroundColor Cyan
    & $ts -D
    $Interfaz = Read-Host "Escribi el NUMERO de la interfaz a capturar (la de Wi-Fi o Ethernet)"
  }
  $pcap = Join-Path $out "captura.pcapng"
  Write-Host "Capturando $Segundos segundos en la interfaz $Interfaz ... (usa la compu normalmente)" -ForegroundColor Cyan
  if ($Filtro -ne "") {
    & $ts -i $Interfaz -a "duration:$Segundos" -f $Filtro -w $pcap -q
  } else {
    & $ts -i $Interfaz -a "duration:$Segundos" -w $pcap -q
  }
}

Write-Host "Generando resumenes..." -ForegroundColor Cyan
& $ts -r $pcap -q -z io,phs   | Out-File -Encoding utf8 (Join-Path $out "protocolos.txt")
& $ts -r $pcap -q -z conv,ip  | Out-File -Encoding utf8 (Join-Path $out "conversaciones_ip.txt")
& $ts -r $pcap -q -z conv,tcp | Out-File -Encoding utf8 (Join-Path $out "conversaciones_tcp.txt")
& $ts -r $pcap -q -z endpoints,ip | Out-File -Encoding utf8 (Join-Path $out "equipos_ip.txt")
& $ts -r $pcap -Y "dns.flags.response == 0" -T fields -E header=y -E separator=";" -e frame.time_relative -e ip.src -e dns.qry.name -e dns.qry.type | Out-File -Encoding utf8 (Join-Path $out "dns.csv")
& $ts -r $pcap -Y "tls.handshake.extensions_server_name" -T fields -E header=y -E separator=";" -e frame.time_relative -e ip.src -e ip.dst -e tls.handshake.extensions_server_name | Out-File -Encoding utf8 (Join-Path $out "sitios_tls.csv")
& $ts -r $pcap -T fields -E header=y -E separator=";" -E quote=d -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e ipv6.src -e ipv6.dst -e _ws.col.Protocol -e frame.len -e _ws.col.Info | Out-File -Encoding utf8 (Join-Path $out "paquetes.csv")

& $ts -r $pcap -Y "http" -T fields -E header=y -E separator=";" -E quote=d -e frame.number -e frame.time_relative -e tcp.srcport -e tcp.dstport -e http.request.method -e http.request.uri -e http.host -e http.user_agent -e http.response.code -e http.content_type -e http.content_length | Out-File -Encoding utf8 (Join-Path $out "http.csv")
& $ts -r $pcap -q -z follow,tcp,ascii,0 | Out-File -Encoding utf8 (Join-Path $out "conversacion_tcp_0.txt")
& $ts -r $pcap -q -z follow,tcp,ascii,1 | Out-File -Encoding utf8 (Join-Path $out "conversacion_tcp_1.txt")

Write-Host ""
Write-Host "Listo. Resultados en: $out" -ForegroundColor Green
Write-Host "Avisale a Claude: 'ya capture, analiza $stamp'" -ForegroundColor Green
