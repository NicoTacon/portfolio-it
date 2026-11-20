# 03 · Instalación y reparación de WSL 2

Registro de los problemas reales que aparecieron al instalar **WSL 2**, requisito de Docker Desktop, y cómo los resolví.

| Síntoma | Causa | Solución |
|---|---|---|
| `wsl --install` parece trabado y el título de la ventana dice **"Select"** | Al hacer clic dentro de la consola, Windows entra en modo selección y pausa el proceso | Apretar `Esc` o `Enter` |
| `WSL installation appears to be corrupted (Wsl/CallMsi/Install/REGDB_E_CLASSNOTREG)` | Instalación previa de WSL dañada | Dejar que Windows la repare y la actualice, y reiniciar |
| `WSL1 is not supported with your current machine configuration` | Aviso informativo: WSL 1 no está habilitado | Ninguna. Lo importante es `Default Version: 2` |

## Plan B si la reparación falla

```powershell
wsl --update --web-download

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# reiniciar
```

Último recurso: desinstalar "Subsistema de Windows para Linux" desde Configuración → Aplicaciones, reiniciar y correr `wsl --install` de nuevo.

## Verificación

```powershell
wsl --status    # Default Version: 2
```
