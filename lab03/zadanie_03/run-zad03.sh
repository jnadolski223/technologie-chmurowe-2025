#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

CACHE_DIR="./nginx-cache"
SSL_DIR="./ssl"
NETWORK_NAME="mynetwork"
NODE_VERSION="18"
CONFIG_FILE="default.conf"

info "CACHE" "Tworzenie katalogu na cache i udzielanie uprawnień użytkownikowi nginx"
mkdir -p $CACHE_DIR
chown -R 101:101 $CACHE_DIR

info "SSL" "Tworzenie katalogu i generowanie certyfikatu SSL"
mkdir -p $SSL_DIR
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SSL_DIR/nginx.key -out $SSL_DIR/nginx.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost"

info "SIEĆ" "Tworzenie sieci: $NETWORK_NAME"
docker network create $NETWORK_NAME 2> /dev/null

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Node.js $NODE_VERSION"
NODE_ID=$(docker run -d --name node-app --network $NETWORK_NAME -p 3000:3000 -it node:$NODE_VERSION-alpine tail -f /dev/null)
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

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx"
NGINX_ID=$(docker run -d -p 80:80 -p 443:443 --name moj_nginx --network $NETWORK_NAME -v $(pwd)/$CONFIG_FILE:/etc/nginx/conf.d/default.conf:ro -v $CACHE_DIR:/var/cache/nginx -v $SSL_DIR:/etc/nginx/ssl nginx)
echo "Utworzono kontener o ID: $NGINX_ID"
docker exec moj_nginx nginx -s reload
sleep 3
echo "Serwer Nginx działa pod adresem http://localhost:80"
echo "Serwer Nginx działa pod adresem https://localhost:443"

info "TESTOWANIE" "Sprawdzanie działania aplikacji"
RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:3000)
echo "Wysłano zapytanie GET na http://localhost:3000"

if [ "$RESPONSE_CODE" -eq 200 ]; then
    echo "Test zakończony sukcesem: Serwer działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
else
    echo "Test zakończony porażką: Serwer nie działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
fi

RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:80)
echo "Wysłano zapytanie GET na http://localhost:80"

if [ "$RESPONSE_CODE" -eq 200 ]; then
    echo "Test zakończony sukcesem: Serwer działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
else
    echo "Test zakończony porażką: Serwer nie działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
fi

RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}" -k https://localhost:443)
echo "Wysłano zapytanie GET na https://localhost:443"

if [ "$RESPONSE_CODE" -eq 200 ]; then
    echo "Test zakończony sukcesem: Serwer działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
else
    echo "Test zakończony porażką: Serwer nie działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
fi

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener Node.js, wykonaj:"
echo "docker stop $NODE_ID"
echo "docker rm $NODE_ID"

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $NGINX_ID"
echo "docker rm $NGINX_ID"
