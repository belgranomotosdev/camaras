# Dockerfile

# Usar una imagen base de Node.js
FROM node:18

# Crear directorio de trabajo en el raíz del proyecto
WORKDIR /usr/src/app

# Copiar archivos de configuración y dependencias
COPY package.json ./
COPY package-lock.json ./

# Instalar dependencias
RUN npm ci

# Copiar el resto de los archivos del proyecto
COPY . .

# Exponer el puerto del servidor
EXPOSE 3000

# Comando para iniciar el servidor
CMD ["npm", "start"]