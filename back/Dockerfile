# Dockerfile para el backend Node.js
FROM node:20

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --production || yarn install --production

COPY . .

EXPOSE 3000

CMD ["node", "server.mjs"]
