# 01 · Página web en un contenedor Docker

Una página estática (HTML + CSS) servida por **nginx** dentro de un contenedor **Docker**.

## Qué hice

- Instalé **Docker Desktop** en Windows sobre **WSL 2**.
- Escribí la página (`index.html`) y un **Dockerfile** basado en `nginx:alpine`.
- Construí la imagen, la corrí como contenedor y la publiqué en el puerto 8080.
- Analicé con Wireshark el tráfico entre el navegador y el contenedor (ver proyecto 04). Así descubrí que el navegador pedía `/favicon.ico` y recibía un **404**, y lo resolví agregando `favicon.svg`.

## Cómo correrlo

```powershell
docker build -t mi-web .
docker run -d -p 8080:80 --name mi-web mi-web
```

Abrir <http://localhost:8080>.

Para actualizar después de un cambio:

```powershell
docker rm -f mi-web
docker build -t mi-web .
docker run -d -p 8080:80 --name mi-web mi-web
```

## Qué aprendí

- La diferencia entre **imagen** (el molde) y **contenedor** (la imagen corriendo).
- Cómo un **Dockerfile** describe la imagen capa por capa.
- Cómo se **publican puertos** (`-p puerto_pc:puerto_contenedor`).
- Que una página así es **frontend puro**: nginx solo entrega archivos, no hay backend.
