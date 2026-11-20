# 05 · Reporte de uso de disco con PowerShell

Script **de solo lectura** que releva qué ocupa espacio en una PC con Windows, para decidir qué limpiar.

## Uso

Recomendado: PowerShell como administrador.

```powershell
powershell -ExecutionPolicy Bypass -File reporte_espacio.ps1
```

## Qué releva

| Archivo | Contenido |
|---|---|
| `discos.csv` | Espacio total, usado y libre |
| `programas.csv` | Programas instalados y su tamaño (registro de Windows) |
| `steam.csv` | Juegos de Steam, su tamaño y la **última vez jugado** |
| `epic.csv` | Juegos de Epic Games |
| `ultimo_uso.csv` | Última ejecución de cada programa (Prefetch) |
| `carpetas.csv` | Carpetas más pesadas (usuario, AppData, Program Files) |
| `archivos_grandes.csv` | Archivos de más de 300 MB |
| `papelera.csv` | Tamaño de la papelera |

## Cómo lo usé

Con el reporte clasifiqué todo en tres grupos: **seguro de borrar** (instaladores, temporales, ISO), **sin uso** (juegos y launchers sin abrir hace meses) y **no tocar** (drivers, runtimes, herramientas en uso). La limpieza se hizo mandando todo a la Papelera primero, para poder revertirla.
