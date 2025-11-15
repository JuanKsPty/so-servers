#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_USER="${SUDO_USER:-$(whoami)}"

info() { printf '\n➡ %s\n' "$1"; }

if command -v apt >/dev/null 2>&1; then
  PKG_UPDATE="sudo apt update -y"
  PKG_INSTALL="sudo apt install -y"
  PKG_MANAGER="apt"
elif command -v dnf >/dev/null 2>&1; then
  PKG_UPDATE="sudo dnf -y update"
  PKG_INSTALL="sudo dnf install -y"
  PKG_MANAGER="dnf"
else
  echo "No se encontró un gestor de paquetes compatible (apt o dnf)." >&2
  exit 1
fi

info "Actualizando paquetes con ${PKG_MANAGER}"
eval "$PKG_UPDATE"

info "Instalando Node.js, npm, Nginx y utilidades del sistema"
eval "$PKG_INSTALL nginx nodejs npm sysstat"

NODE_BIN="$(command -v node || echo /usr/bin/node)"

NGINX_AVAILABLE=/etc/nginx/sites-available
NGINX_ENABLED=/etc/nginx/sites-enabled
NGINX_CONF_TARGET=/etc/nginx/conf.d/testapp.conf

info "Copiando configuración de Nginx"
if [ -d "$NGINX_AVAILABLE" ]; then
  sudo cp "${REPO_ROOT}/nginx/server.conf" "${NGINX_AVAILABLE}/testapp"
  sudo ln -sf "${NGINX_AVAILABLE}/testapp" "${NGINX_ENABLED}/testapp"
else
  sudo cp "${REPO_ROOT}/nginx/server.conf" "$NGINX_CONF_TARGET"
fi

info "Habilitando y reiniciando Nginx"
sudo systemctl enable nginx
sudo systemctl restart nginx

info "Creando carpeta de logs"
sudo mkdir -p /var/log/testapp
sudo touch /var/log/testapp/app.log
sudo chown -R "$APP_USER":"$APP_USER" /var/log/testapp

info "Instalando script de monitoreo"
sudo install -m 0755 "${REPO_ROOT}/scripts/monitor_usage.sh" /usr/local/bin/testapp-monitor.sh

info "Configurando servicio para capturar CPU y visitas cada 30 minutos"
sudo tee /etc/systemd/system/testapp-monitor.service >/dev/null <<'EOF'
[Unit]
Description=Monitor de CPU y visitas de testapp
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/testapp-monitor.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

info "Configurando servicio systemd para la app Node.js"
sudo tee /etc/systemd/system/testapp.service >/dev/null <<EOF
[Unit]
Description=Servidor Node.js testapp
After=network.target

[Service]
Type=simple
WorkingDirectory=${REPO_ROOT}/app
Environment=APP_LOG=/var/log/testapp/app.log
ExecStart=${NODE_BIN} app.js
Restart=always
User=${APP_USER}

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now testapp-monitor.service
sudo systemctl enable --now testapp.service

info "Instalando regla de logrotate"
sudo cp "${REPO_ROOT}/logrotate/testapp" /etc/logrotate.d/testapp

info "Instalando dependencias de la app"
cd "${REPO_ROOT}/app"
npm install --omit=dev

info "Listo. El servicio testapp.service mantiene la app corriendo automáticamente."
info "El servicio testapp-monitor.service ya está guardando CPU y visitas en /var/log/testapp/."
