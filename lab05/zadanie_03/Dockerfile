ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}
WORKDIR /my-flask-app
COPY ./myapp .
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 3000
CMD ["python", "app.py"]
