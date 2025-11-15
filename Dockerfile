# Etapa 1: Construcción
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY prisma ./prisma/

# Instalar dependencias
RUN npm ci

# Copiar el código fuente
COPY . .

# Generar el cliente de Prisma
RUN npx prisma generate

# Compilar la aplicación
RUN npm run build

# Etapa 2: Producción
FROM node:20-alpine AS production

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./
COPY prisma ./prisma/

# Instalar solo dependencias de producción
RUN npm ci --only=production && npm cache clean --force

# Copiar el cliente de Prisma generado desde la etapa de construcción
COPY --from=builder /app/generated ./generated

# Copiar los archivos compilados
COPY --from=builder /app/dist ./dist

# Exponer el puerto de la aplicación
EXPOSE 3004

# Comando para ejecutar las migraciones y luego iniciar la aplicación
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
