// serverfrp.mjs
// Servidor FRP para exponer RTSP (MediaMTX) en un VPS
// Ejecuta este archivo en tu VPS (servidor público)

import { exec } from 'child_process';
import fs from 'fs';

// Configuración básica de FRP server (frps)
const FRPS_CONFIG = `
[common]
bind_port = 7000
# Puedes agregar más opciones de seguridad aquí
`;

// Guardar archivo de configuración frps.ini
fs.writeFileSync('./frps.ini', FRPS_CONFIG);

console.log('▶ Archivo frps.ini generado.');

// Comando para iniciar frps
const frpsCmd = './frps -c ./frps.ini';

console.log('▶ Iniciando FRP Server (frps)...');

const frpsProcess = exec(frpsCmd, (error, stdout, stderr) => {
  if (error) {
    console.error(`❌ Error al iniciar frps: ${error.message}`);
    return;
  }
  if (stdout) console.log(stdout);
  if (stderr) console.error(stderr);
});

frpsProcess.stdout?.on('data', data => process.stdout.write(data));
frpsProcess.stderr?.on('data', data => process.stderr.write(data));

console.log('✅ FRP Server corriendo en el puerto 7000.');
console.log('Mantén este proceso activo para exponer el puerto RTSP de tus cámaras.');
