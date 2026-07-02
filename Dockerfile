# --- Etapa 1: Construcción (Se mantiene igual) ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- Etapa 2: Servidor de Producción Seguro ---
FROM nginx:1.25-alpine

# Copiamos los archivos compilados
COPY --from=builder /app/dist /usr/share/nginx/html

# Modificamos los permisos para que el usuario 'nginx' tenga acceso
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Crear el archivo PID en una ruta donde el usuario 'nginx' pueda escribir
RUN touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

COPY default.conf /etc/nginx/conf.d/default.conf    

# 🛑 CAMBIO CLAVE: Cambiamos al usuario sin privilegios
USER nginx

# Exponemos el puerto 8080 (los usuarios no-root no pueden usar puertos < 1024)
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]