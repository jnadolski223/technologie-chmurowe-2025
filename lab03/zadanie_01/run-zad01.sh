#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

PORT="8080"

info "STRUKTURA" "Sprawdzanie czy plik index.html istnieje w bieżącym katalogu"
if [ ! -f index.html ]; then
    echo "Błąd: Plik index.html nie istnieje w bieżącym katalogu"
    exit 1
fi

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx"
CONTAINER_ID=$(docker run -d -p $PORT:80 --name moj_nginx -v $(pwd)/index.html:/usr/share/nginx/html/index.html:ro nginx)
echo "Utworzono kontener o ID: $CONTAINER_ID"
sleep 3
echo "Serwer Nginx działa pod adresem http://localhost:$PORT"

info "TESTOWANIE" "Sprawdzanie działania aplikacji"
BODY=$(curl -s http://localhost:$PORT)
echo "Wysłano zapytanie GET na http://localhost:$PORT"

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
