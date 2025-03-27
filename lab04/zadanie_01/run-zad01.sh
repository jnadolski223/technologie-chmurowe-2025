#!/bin/bash

file_name="index.html"
volume_name="nginx_data"

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "WOLUMIN" "Tworzenie woluminu Docker o nazwie $volume_name"
docker volume create $volume_name

info "WERYFIKACJA" "Sprawdzanie czy plik $file_name istnieje w bieżącym katalogu"
if [ ! -f $file_name ]; then
    echo "Błąd: Plik $file_name nie istnieje w bieżącym katalogu"
    exit 1
fi

info "KOPIOWANIE" "Kopiowanie pliku $file_name do woluminu $volume_name"
docker run --rm -v $volume_name:/nginx_volume -v $(pwd):/tmp ubuntu sh -c "cp /tmp/index.html /nginx_volume"

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx i z zamontowanym woluminem $volume_name"
container_id=$(docker run -d --name my_nginx -p 80:80 -v nginx_data:/usr/share/nginx/html nginx)
echo "Utworzono kontener o ID: $container_id"
echo "Serwer Nginx działa pod adresem http://localhost:80"

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $container_id"
echo "docker rm $container_id"
