#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NETWORK_NAME="mynetwork"
NODE_VERSION="16"
DB_PORT="27017"
APP_PORT="8080"

info "SIEĆ" "Tworzenie sieci: $NETWORK_NAME"
docker network create $NETWORK_NAME 2> /dev/null

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z MongoDB"
MONGO_ID=$(docker run -d --name my-mongo --network $NETWORK_NAME -p $DB_PORT:$DB_PORT -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=secret mongo:latest)
echo "Utworzono kontener MongoDB o ID: $MONGO_ID"

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Node.js $NODE_VERSION"
NODE_ID=$(docker run -d --name node-app --network $NETWORK_NAME -p $APP_PORT:$APP_PORT -it node:$NODE_VERSION-alpine tail -f /dev/null)
echo "Utworzono kontener Node.js o ID: $NODE_ID"

info "STRUKTURA" "Tworzenie katalogu /app w kontenerze Node.js"
docker exec $NODE_ID mkdir -p /app

info "KOPIOWANIE" "Kopiowanie plików aplikacji do kontenera za pomocą docker cp"
docker cp package.json $NODE_ID:/app/
docker cp app.js $NODE_ID:/app/

info "ZALEŻNOŚCI" "Instalacja zależności Node.js wewnątrz kontenera"
docker exec -w /app $NODE_ID npm install

info "URUCHOMIENIE" "Uruchamianie aplikacji Node.js w kontenerze"
docker exec -w /app $NODE_ID node app.js &

while [ -z "$(curl -s http://localhost:$APP_PORT)" ]; do
    echo "Oczekiwanie na uruchomienie serwera..."
    sleep 3
done

info "TESTOWANIE" "Sprawdzanie działania aplikacji"
BODY=$(curl -s http://localhost:$APP_PORT)
echo "Wysłano zapytanie GET na http://localhost:$APP_PORT"
echo -e "Zwrócona zawartość:\n$BODY"

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener Node.js, wykonaj:"
echo "docker stop $NODE_ID"
echo "docker rm $NODE_ID"

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener MongoDB, wykonaj:"
echo "docker stop $MONGO_ID"
echo "docker rm $MONGO_ID"
