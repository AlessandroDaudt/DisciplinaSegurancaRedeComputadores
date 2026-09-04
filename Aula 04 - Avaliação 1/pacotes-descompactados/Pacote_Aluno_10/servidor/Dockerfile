FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
COPY dados ./dados
WORKDIR /app/app
EXPOSE 8080
CMD ["python", "app.pyc"]
