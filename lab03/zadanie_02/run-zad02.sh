#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

HOST_PORT="8080"
SERVER_PORT="80"
CONFIG_FILE="default.conf"

info "STRUKTURA" "Sprawdzenie czy plik $CONFIG_FILE istnieje w bieżącym katalogu"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Błąd: Plik $CONFIG_FILE nie istnieje w bieżącym katalogu"
    exit 1
fi

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx"
CONTAINER_ID=$(docker run -d -p $HOST_PORT:$SERVER_PORT --name moj_nginx -v $(pwd)/$CONFIG_FILE:/etc/nginx/conf.d/default.conf:ro nginx)
echo "Utworzono kontener o ID: $CONTAINER_ID"
sleep 3
echo "Serwer Nginx działa pod adresem http://localhost:$HOST_PORT"

info "TESTOWANIE" "Sprawdzanie działania aplikacji"
RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:$HOST_PORT)
echo "Wysłano zapytanie GET na http://localhost:$HOST_PORT"

if [ "$RESPONSE_CODE" -eq 200 ]; then
    echo "Test zakończony sukcesem: Serwer działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
else
    echo "Test zakończony porażką: Serwer nie działa poprawnie"
    echo "Kod odpowiedzi: $RESPONSE_CODE"
fi

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"
