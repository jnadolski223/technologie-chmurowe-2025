FROM python:3.12-alpine
WORKDIR /app
RUN apk add --no-cache curl
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD curl --fail http://localhost:5000/health || exit 1
