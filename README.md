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
git clone https://github.com/JuanKsPty/so-servers.git
cd so-servers
bash scripts/install.sh
```

El script instalará Node.js, npm, Nginx, copiará las configuraciones, creará la carpeta `/var/log/testapp` y dejará todo listo para ejecutar la app en el puerto 3000 detrás de Nginx.

### ¿Ya tenías una versión desplegada?

1. Entra a la carpeta existente del repo (`cd so-servers`).
2. Trae los últimos cambios: `git pull origin main` (o el branch que uses en Azure).
3. Ejecuta de nuevo `bash scripts/install.sh` para reinstalar dependencias y actualizar servicios.

Esto recrea las configuraciones necesarias y reinicia los servicios automáticamente.

La app queda gestionada por systemd mediante el servicio `testapp.service`, por lo que arranca sola tras cada reinicio (`systemctl status testapp` para verificarlo). Cada petición se registra en `/var/log/testapp/app.log` (o en la ruta definida por la variable `APP_LOG`).

## Simular logs

```bash
bash scripts/simulate_logs.sh
```

Esto genera entradas en `/var/log/testapp/test.log`, ideal para verificar la configuración de logrotate durante las pruebas.

## Monitoreo automático de CPU y visitas

El instalador también deja corriendo el servicio `testapp-monitor.service`, que ejecuta cada 30 minutos el script `scripts/monitor_usage.sh`. Este servicio:

- Guarda snapshots de uso de CPU y procesos en `/var/log/testapp/cpu_usage.log`.
- Copia las nuevas visitas del access log de Nginx en `/var/log/testapp/visits.log`.
- Se inicia automáticamente cada vez que arranca la VM (`systemctl status testapp-monitor` para verificarlo).
- Permite ajustar el intervalo exportando la variable `INTERVAL_SECONDS` en el servicio si fuese necesario.

Los archivos de monitoreo se incluyen en la regla de `logrotate/testapp`, por lo que se rotarán igual que el resto de logs del proyecto.

## Logs de la aplicación

- El servidor Node.js escribe cada request en `/var/log/testapp/app.log`.
- Si no tienes permisos para esa ruta, establece `APP_LOG=/ruta/local/app.log npm start`.
- La regla de `logrotate/testapp` cubre todos los archivos `*.log` dentro de `/var/log/testapp`, incluyendo `app.log`.

## GitHub remoto

El repositorio oficial vive en `https://github.com/JuanKsPty/so-servers/`. Clónalo directamente en cada VM:

```bash
git clone https://github.com/JuanKsPty/so-servers.git
cd so-servers
bash scripts/install.sh
```

Si prefieres subir tu propio fork, crea el repo en GitHub y reemplaza la URL anterior por la tuya al ejecutar `git remote set-url origin ...`.
