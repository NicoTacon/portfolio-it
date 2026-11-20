# 02 · Máquina virtual Ubuntu administrada por SSH

Laboratorio con una VM **Ubuntu** en **VirtualBox**, administrada desde Windows por **SSH**.

## Qué hice

1. Creé la VM en VirtualBox: 4 GB de RAM, 2 vCPU, disco de 25 GB e instalación desatendida con Guest Additions.
2. Dejé Ubuntu listo: actualizaciones (`apt update` / `apt upgrade`), teclado en español y servidor **OpenSSH**.
3. Configuré **reenvío de puertos** en la red NAT de VirtualBox, para llegar a la VM desde mi PC.
4. Me conecté por SSH desde PowerShell y administré la VM sin usar su ventana.

## Configuración de red (reenvío de puertos)

| Regla | Protocolo | IP anfitrión | Puerto anfitrión | Puerto invitado | Para qué |
|---|---|---|---|---|---|
| ssh | TCP | 127.0.0.1 | 2222 | 22 | Acceso SSH |
| web | TCP | 127.0.0.1 | 8081 | 8080 | Servicios web en la VM |

```text
Mi PC (cliente SSH) --puerto 2222--> VirtualBox NAT --puerto 22--> VM Ubuntu (OpenSSH)
```

## Comandos clave

```bash
# En la VM
sudo apt update && sudo apt upgrade -y
sudo apt install -y openssh-server
systemctl is-active ssh        # -> active
```

```powershell
# Desde Windows
ssh -p 2222 usuario@127.0.0.1
```

## Problema resuelto

**"usuario is not in the sudoers file"**: con la instalación desatendida, el usuario puede quedar sin permisos de administrador. Se soluciona así:

```bash
su -
usermod -aG sudo usuario
exit
# cerrar sesión y volver a entrar
```

## Qué aprendí

- La diferencia entre hipervisor **tipo 1** (Proxmox, ESXi) y **tipo 2** (VirtualBox).
- Cómo funciona la red **NAT** y por qué hace falta el reenvío de puertos.
- **SSH**: cliente y servidor, puerto 22, huella del servidor y conexión cifrada.
