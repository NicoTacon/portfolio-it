# 04 · Análisis de tráfico de red con Wireshark y TShark

Script de PowerShell que **captura tráfico con TShark** (la versión de línea de comandos de Wireshark) y genera **resúmenes listos para analizar**.

## Uso

Requisitos: Wireshark con TShark y Npcap.

```powershell
# Captura de 30 segundos (pregunta la interfaz)
powershell -ExecutionPolicy Bypass -File captura.ps1

# Opciones
powershell -ExecutionPolicy Bypass -File captura.ps1 -Segundos 60 -Interfaz 4
powershell -ExecutionPolicy Bypass -File captura.ps1 -Filtro "port 8080"
powershell -ExecutionPolicy Bypass -File captura.ps1 -Archivo C:\ruta\captura.pcapng
```

## Qué genera

| Archivo | Contenido |
|---|---|
| `captura.pcapng` | La captura completa (se abre con Wireshark) |
| `protocolos.txt` | Jerarquía de protocolos |
| `conversaciones_ip.txt` / `conversaciones_tcp.txt` | Quién habló con quién y cuántos datos |
| `equipos_ip.txt` | Direcciones IP que aparecen |
| `dns.csv` | Nombres de dominio consultados |
| `sitios_tls.csv` | Sitios HTTPS (SNI del handshake TLS) |
| `http.csv` | Pedidos y respuestas HTTP |
| `conversacion_tcp_0.txt` | La primera conversación TCP reconstruida |
| `paquetes.csv` | Lista de paquetes |

## Análisis realizados

**1. Tráfico general (30 s, unos 7.400 paquetes)**
- La mayor parte del tráfico viajó por **IPv6**, sobre todo **QUIC** (HTTP/3) de YouTube.
- Identifiqué servicios por DNS y SNI: streaming, juegos, launchers, antivirus.
- Los juegos en tiempo real usan **UDP**: paquetes chicos y constantes.
- Los "Malformed Packet" eran segmentos gigantes por **offload** de la placa de red, no un error real.

**2. HTTP sin cifrar vs. HTTPS** (página del proyecto 01, por la interfaz loopback)
- **Handshake TCP**: SYN → SYN/ACK → ACK, en 0,2 ms.
- Se leen en texto plano el `GET /`, el `User-Agent`, la respuesta `200 OK`, la versión de nginx y **el HTML completo**.
- Detecté un `404` en `/favicon.ico` y lo corregí en el proyecto 01.
- Conclusión: en HTTPS solo se ve **a qué sitio** te conectás, no el contenido. En HTTP se ve todo.

> Las capturas no se suben al repositorio (ver `.gitignore`) porque contienen datos de mi red.
