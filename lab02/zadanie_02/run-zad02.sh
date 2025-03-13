#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

NODE_VERSION="14"
PORT="8080"

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Node.js $NODE_VERSION"
CONTAINER_ID=$(docker run -d -p $PORT:$PORT --name node-app -it node:$NODE_VERSION-alpine tail -f /dev/null)
echo "Utworzono kontener o ID: $CONTAINER_ID"

info "STRUKTURA" "Tworzenie katalogu /app w kontenerze"
docker exec $CONTAINER_ID mkdir -p /app

info "KOPIOWANIE" "Kopiowanie plików aplikacji do kontenera za pomocą docker cp"
docker cp package.json $CONTAINER_ID:/app/
docker cp app.js $CONTAINER_ID:/app/

info "ZALEŻNOŚCI" "Instalacja zależności Node.js wewnątrz kontenera"
docker exec -w /app $CONTAINER_ID npm install

info "URUCHOMIENIE" "Uruchamianie aplikacji Node.js w kontenerze"
docker exec -w /app $CONTAINER_ID node app.js &

while [ -z "$(curl -s http://localhost:$PORT)" ]; do
    echo "Oczekiwanie na uruchomienie serwera..."
    sleep 3
done

info "TESTOWANIE" "Sprawdzanie działania aplikacji"
BODY=$(curl -s http://localhost:$PORT)
echo "Wysłano zapytanie GET na http://localhost:$PORT"
echo -e "Zwrócona zawartość:\n$BODY"

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"
