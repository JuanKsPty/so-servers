# Semestral App

Aplicación Node.js minimalista utilizada para el proyecto de servidores del curso de Sistemas Operativos 1. Sirve una página informativa y responsive que resume los principales sistemas operativos (Linux, Windows, macOS y distribuciones para servidores).

## Requisitos

- Node.js 14+ (se instala automáticamente con `scripts/install.sh`)

## Uso

```bash
cd app
npm install
npm start
```

La aplicación expone el puerto `3000`. En producción se recomienda colocar Nginx al frente (configuración incluida en `nginx/server.conf`).
