# Etapa 1: Usamos una imagen más completa para construir las dependencias
FROM python:3.11-alpine AS builder

# Instalar dependencias del sistema necesarias para compilar psycopg2
RUN apk update && apk add --no-cache \
    gcc \
    musl-dev \
    postgresql-dev \
    libpq

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos el archivo de requisitos
COPY requirements.txt .

# Instalamos las dependencias
RUN pip install --user --no-cache-dir -r requirements.txt

# Etapa 2: Usamos una imagen ligera de Alpine para la producción
FROM python:3.11-alpine AS production

# Instalar solo las dependencias de runtime necesarias
RUN apk add --no-cache libpq

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos los archivos del proyecto
COPY . .

# Copiamos las dependencias instaladas en la etapa de compilación
COPY --from=builder /root/.local /root/.local

# Exponemos el puerto 8000 para Gunicorn
EXPOSE 8000

# Ajustamos las variables de entorno
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Ejecutamos las migraciones y lanzamos Gunicorn
CMD ["sh", "-c", "python manage.py migrate && gunicorn --bind 0.0.0.0:8000 pollme.wsgi:application"]