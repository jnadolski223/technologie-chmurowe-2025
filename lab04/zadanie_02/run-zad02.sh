#!/bin/bash

nginx_volume_name="nginx_data"
nodejs_volume_name="nodejs_data"
all_volumes_name="all_volumes"
nodejs_files_dir="app"
nginx_files_dir="/usr/share/nginx/html"

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "WOLUMEN" "Tworzenie wolumenu o nazwie $nodejs_volume_name"
docker volume create $nodejs_volume_name

info "KOPIOWANIE" "Kopiowanie zawartości katalogu $nodejs_files_dir do wolumenu $nodejs_volume_name"
docker run --rm -v $nodejs_volume_name:/app -v $(pwd):/tmp ubuntu sh -c "cp -r /tmp/$nodejs_files_dir/. /app"

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Node.js z zamontowanym wolumenem $nodejs_volume_name"
CONTAINER_ID=$(docker run -dit --name my_node -v $nodejs_volume_name:/app node)
echo "Utworzono kontener o ID: $CONTAINER_ID"

info "SPRZĄTANIE" "Aby zatrzymać i usunąć kontener, wykonaj:"
echo "docker stop $CONTAINER_ID"
echo "docker rm $CONTAINER_ID"

info "WERYFIKACJA" "Sprawdzanie czy wolumen $nginx_volume_name istnieje"
if docker volume inspect $nginx_volume_name >/dev/null 2>&1; then
    echo "Wolumen $nginx_volume_name już istnieje"
else
    echo "Błąd: Wolumen $nginx_volume_name nie istnieje"
    exit 1
fi

info "KONTENER" "Tworzenie i uruchamianie kontenera Docker z Nginx i z zamontowanym wolumenem $nginx_volume_name"
info "KOPIOWANIE" "Kopiowanie zawartości katalogu $nginx_files_dir do wolumenu $nginx_volume_name"
docker run --rm --name my_nginx -v $nginx_volume_name:/nginx_volume nginx sh -c "cp -r /usr/share/nginx/html/. /nginx_volume"

info "WOLUMEN" "Tworzenie wolumenu o nazwie $all_volumes_name"
docker volume create $all_volumes_name

info "KOPIOWANIE" "Kopiowanie zawartości wolumenów $nginx_volume_name i $nodejs_volume_name do wolumenu $all_volumes_name"
docker run --rm -v $nodejs_volume_name:/nodejs_volume -v $nginx_volume_name:/nginx_volume -v $all_volumes_name:/all_volumes_volume ubuntu sh -c "cp -r /nodejs_volume/. /all_volumes_volume && cp -r /nginx_volume/. /all_volumes_volume"
