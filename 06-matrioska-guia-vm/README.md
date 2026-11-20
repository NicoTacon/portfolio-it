# 06 · Matrioska: guía interactiva para armar una VM

Sitio web de una sola página que enseña qué es una **máquina virtual** y simula paso a paso cómo crear una. No se instala nada: todo pasa en el navegador.

## Qué tiene

- **Capas interactivas** (hardware → sistema anfitrión → hipervisor → VMs), para comparar un hipervisor **tipo 2**, uno **tipo 1** y un **contenedor**.
- **Casos de uso** de las VMs: probar sistemas, abrir archivos sospechosos, snapshots, servidores, entornos de equipo, software viejo.
- **Por dentro:** cómo el hipervisor reparte CPU, RAM, disco y red.
- **Asistente de 6 pasos** para "armar" una VM: hipervisor, recursos, ISO, red e instalación.
- Consejos y **glosario**.
- **Modo claro y oscuro**, diseño adaptable a celular, navegación accesible con teclado.

## Tecnologías

HTML, CSS (variables, `color-mix`, modo oscuro), JavaScript sin frameworks, gráficos SVG y `localStorage` para recordar preferencias. Todo en un único archivo.

## Cómo verlo

- Abrir `index.html` en el navegador, o
- Correrlo en Docker:

```powershell
docker build -t matrioska .
docker run -d -p 8082:80 --name matrioska matrioska
```

Y abrir <http://localhost:8082>.

## Cómo lo hice

Lo diseñé y desarrollé con asistencia de IA (Claude), a partir de lo que aprendí armando mis propias VMs (ver proyecto 02).
