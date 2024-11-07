# Usar una imagen de Python base
FROM python:3.8-slim

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos
COPY . /app

# Instalar dependencias
RUN pip install -r requirements.txt

# Definir variable de entorno de Flask para la app
ENV FLASK_APP=app.py

# Exponer el puerto 80
EXPOSE 80

# Iniciar la aplicación
CMD ["python", "app.py"]
