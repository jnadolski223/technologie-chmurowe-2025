FROM python:3.12-alpine
WORKDIR /flask-app
COPY ./app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ./app .
EXPOSE 8080
CMD ["python", "app.py"]
