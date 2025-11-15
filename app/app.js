const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const publicDir = path.join(__dirname, 'public');
const defaultLogPath = '/var/log/testapp/app.log';
const fallbackLogPath = path.join(__dirname, '..', 'logs', 'app.log');

const ensureLogPath = (desiredPath) => {
  try {
    fs.mkdirSync(path.dirname(desiredPath), { recursive: true });
    return desiredPath;
  } catch (error) {
    console.warn(
      `No se pudo utilizar ${desiredPath} para los logs (${error.message}). Usando ${fallbackLogPath}.`
    );
    fs.mkdirSync(path.dirname(fallbackLogPath), { recursive: true });
    return fallbackLogPath;
  }
};

const logPath = ensureLogPath(process.env.APP_LOG || defaultLogPath);

const logRequest = (req, statusCode) => {
  const entry = `[${new Date().toISOString()}] ${req.socket.remoteAddress || 'desconocido'} ${req.method} ${req.url} -> ${statusCode}\n`;
  fs.appendFile(logPath, entry, (err) => {
    if (err) {
      console.error(`No se pudo escribir en el log ${logPath}:`, err.message);
    }
  });
};

const mimeTypes = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
};

const server = http.createServer((req, res) => {
  const safePath = path.normalize(req.url).replace(/^\.\/+/, '');
  const requestedPath = safePath === '/' ? 'index.html' : safePath;
  const filePath = path.join(publicDir, requestedPath);

  if (!filePath.startsWith(publicDir)) {
    res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Acceso denegado');
    logRequest(req, 403);
    return;
  }

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Recurso no encontrado');
      logRequest(req, 404);
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = mimeTypes[ext] || 'application/octet-stream';
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
    logRequest(req, 200);
  });
});

server.listen(PORT, () => {
  console.log(`App corriendo en puerto ${PORT}`);
});
