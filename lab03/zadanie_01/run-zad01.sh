#!/bin/bash

SERVER_PORT="80"
HOST_PORT="80"
PAGE_FILE="index.html"

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "WERYFIKACJA" "Sprawdzanie czy plik index.html istnieje w bieżącym katalogu"
if [ ! -f $PAGE_FILE ]; then
    echo "Błąd: Plik $PAGE_FILE nie istnieje w bieżącym katalogu"
    exit 1
fi

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx"
CONTAINER_ID=$(docker run -d -p $HOST_PORT:$SERVER_PORT --name my-nginx nginx)
echo "Utworzono kontener o ID: $CONTAINER_ID"
sleep 3
echo "Serwer Nginx działa pod adresem http://localhost:$HOST_PORT"

info "KOPIOWANIE" "Kopiowanie pliku $PAGE_FILE do kontenera Nginx"
docker cp $PAGE_FILE $CONTAINER_ID:/usr/share/nginx/html/index.html

info "TESTOWANIE" "Sprawdzanie działania aplikacji"
BODY=$(curl -s http://localhost:$HOST_PORT)
echo "Wysłano zapytanie GET na http://localhost:$HOST_PORT"

if [ -z "$BODY" ]; then
    echo "Test zakończony porażką: Nie udało się pobrać zawartości strony"
elif [ "$BODY" != "$(cat index.html)" ]; then
    echo "Test zakończony porażką: Zawartość strony niezgodna z plikiem index.html"
    echo -e "Zwrócona zawartość:\n$BODY"
else
    echo "Test zakończony sukcesem: Zawartość strony zgodna z plikiem index.html"
    echo -e "Zwrócona zawartość:\n$BODY"
fi

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"
