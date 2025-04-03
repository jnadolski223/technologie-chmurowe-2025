FROM alpine:latest
ARG PYTHON_VERSION=3.12
ARG SERVER_PORT=3000
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV SERVER_PORT=${SERVER_PORT}
RUN apk update && apk add --no-cache python3=${PYTHON_VERSION} py3-pip || apk add --no-cache python3 py3-pip
VOLUME /flask-app-data
WORKDIR /flask-app-data
RUN python3 -m venv venv
COPY ./myapp .
RUN . /flask-app-data/venv/bin/activate && pip install --no-cache-dir -r requirements.txt
ENV PATH="/flask-app-data/venv/bin:$PATH"
EXPOSE ${SERVER_PORT}
CMD ["python3", "app.py"]
