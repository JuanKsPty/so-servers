# so1-semestral-servers

Repositorio base para el proyecto semestral de Sistemas Operativos 1. Incluye una aplicación Node.js, configuración de Nginx, reglas de logrotate y scripts para instalar todo automáticamente en Ubuntu, Debian o Rocky Linux.

## Estructura

```
so1-semestral-servers/
├── app/              # Código de la app Node.js + assets web
├── nginx/            # Configuración para Nginx (reverse proxy)
├── logrotate/        # Reglas para rotar logs del proyecto
└── scripts/          # Scripts de instalación y utilidades
```

## Requisitos

- Git
- Node.js 14+ (se instala automáticamente con el script)
- Nginx (también instalado desde el script)

## Uso rápido

```bash
git clone https://github.com/tu_usuario/so1-semestral-servers.git
cd so1-semestral-servers
bash scripts/install.sh
```

El script instalará Node.js, npm, Nginx, copiará las configuraciones, creará la carpeta `/var/log/testapp` y dejará todo listo para ejecutar la app en el puerto 3000 detrás de Nginx.

Para iniciar la app manualmente:

```bash
cd app
npm start
```

## Simular logs

```bash
bash scripts/simulate_logs.sh
```

Esto genera entradas en `/var/log/testapp/test.log`, ideal para verificar la configuración de logrotate durante las pruebas.

## GitHub remoto

1. Crea el repositorio en GitHub (`https://github.com/new`).
2. Usa este contenido localmente y agrega el remote:
   ```bash
   git init
   git remote add origin https://github.com/tu_usuario/so1-semestral-servers.git
   git add .
   git commit -m "Proyecto semestral configurado"
   git push -u origin main
   ```

Luego podrás clonar el repositorio en tus tres VMs (Ubuntu, Debian y Rocky) y ejecutar `bash scripts/install.sh` para replicar todo sin tareas manuales.
