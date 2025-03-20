#!/bin/bash

NETWORK_NAME="mynetwork"
NODE_VERSION="18"
NODE_PORT="3000"
NGINX_PORT="80"
HTTPS_PORT="443"
APP_FILE="app.js"
PACKAGE_NODE_FILE="package.json"
CONFIG_FILE="default.conf"
SSL_CERT_FILE="/etc/nginx/ssl/nginx.crt"
SSL_KEY_FILE="/etc/nginx/ssl/nginx.key"

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "SIEĆ" "Tworzenie sieci: $NETWORK_NAME"
docker network create $NETWORK_NAME 2> /dev/null

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Node.js $NODE_VERSION"
NODE_ID=$(docker run -d --name node-app --network $NETWORK_NAME -p $NODE_PORT:$NODE_PORT -it node:$NODE_VERSION-alpine tail -f /dev/null)
echo "Utworzono kontener Node.js o ID: $NODE_ID"

info "STRUKTURA" "Tworzenie katalogu /app w kontenerze Node.js"
docker exec $NODE_ID mkdir -p /app

info "KOPIOWANIE" "Kopiowanie plików aplikacji do kontenera Node.js"
docker cp $PACKAGE_NODE_FILE $NODE_ID:/app/
docker cp $APP_FILE $NODE_ID:/app/

info "ZALEŻNOŚCI" "Instalacja zależności Node.js wewnątrz kontenera"
docker exec -w /app $NODE_ID npm install

info "URUCHOMIENIE" "Uruchamianie aplikacji Node.js w kontenerze"
docker exec -w /app $NODE_ID node app.js &
sleep 3

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx"
NGINX_ID=$(docker run -d -p $NGINX_PORT:$NGINX_PORT -p $HTTPS_PORT:$HTTPS_PORT --name my-nginx --network $NETWORK_NAME nginx)
echo "Utworzono kontener Nginx o ID: $NGINX_ID"
sleep 3

info "KOPIOWANIE" "Kopiowanie pliku konfiguracji kontenera Docker z Nginx"
docker cp $CONFIG_FILE $NGINX_ID:/etc/nginx/conf.d/default.conf

info "STRUKTURA" "Tworzenie katalogu /etc/nginx/ssl w kontenerze Docker z Nginx"
docker exec $NGINX_ID mkdir -p /etc/nginx/ssl

info "INSTALACJA" "Instalowanie openssl w kontenerze Nginx"
docker exec $NGINX_ID apt update &> /dev/null
docker exec $NGINX_ID apt install openssl &> /dev/null

info "SSL" "Generowanie certyfikatu SSL"
docker exec $NGINX_ID openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $SSL_KEY_FILE -out $SSL_CERT_FILE -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=localhost" &> /dev/null

info "AKTUALIZACJA" "Przeładowywanie konfiguracji Nginx"
docker exec $NGINX_ID nginx -s reload 2> /dev/null

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

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener Nginx, wykonaj:"
echo "docker stop $NGINX_ID"
echo "docker rm $NGINX_ID"

info "SPRZĄTANIE" "Aby usunąć sieć $NETWORK_NAME, wykonaj:"
echo "docker network rm $NETWORK_NAME"
