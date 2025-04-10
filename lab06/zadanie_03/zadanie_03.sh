#!/bin/bash

info() {
    echo -e "\n\033[1;34m[$1]\033[0m $2"
}

info "SIEĆ" "Tworzenie sieci frontend_network"
docker network create --driver bridge frontend_network

info "SIEĆ" "Tworzenie sieci backend_network"
docker network create --driver bridge backend_network

info "KONTENER" "Uruchamianie kontenera frontend"
docker run -dit --name frontend --network frontend_network nginx

info "AKTUALIZACJA" "Instalowanie narzędzia ping w kontenerze frontend"
docker exec -it frontend apt update
docker exec -it frontend apt install -y iputils-ping

info "KONTENER" "Uruchamianie kontenera backend"
docker run -dit --name backend --network frontend_network python
docker network connect backend_network backend

info "AKTUALIZACJA" "Instalowanie narzędzia ping w kontenerze backend"
docker exec -it backend apt update
docker exec -it backend apt install -y iputils-ping

info "KONTENER" "Uruchamianie kontenera database"
docker run -dit --name database --network backend_network -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password -e POSTGRES_DB=testdb postgres

info "AKTUALIZACJA" "Instalowanie narzędzia ping w kontenerze database"
docker exec -it database apt update
docker exec -it database apt install -y iputils-ping

info "TESTOWANIE [1/6]" "Sprawdzanie połączenia z backend z poziomu frontend"
docker exec -it frontend ping -c 4 backend && echo "SUKCES: frontend jest połączony z backend" || echo "BŁĄD: Nie można nawiązać połączenia z backend"

info "TESTOWANIE [2/6]" "Sprawdzanie połączenia z database z poziomu frontend"
docker exec -it frontend ping -c 4 database && echo "BŁĄD: frontend jest połączony z database" || echo "SUKCES: Nie można nawiązać połączenia z database"

info "TESTOWANIE [3/6]" "Sprawdzanie połączenia z frontend z poziomu backend"
docker exec -it backend ping -c 4 frontend && echo "SUKCES: backend jest połączony z frontend" || echo "BŁĄD: Nie można nawiązać połączenia z frontend"

info "TESTOWANIE [4/6]" "Sprawdzanie połączenia z database z poziomu backend"
docker exec -it backend ping -c 4 database && echo "SUKCES: backend jest połączony z database" || echo "BŁĄD: Nie można nawiązać połączenia z database"

info "TESTOWANIE [5/6]" "Sprawdzanie połączenia z frontend z poziomu database"
docker exec -it database ping -c 4 frontend && echo "BŁĄD: database jest połączony z frontend" || echo "SUKCES: Nie można nawiązać połączenia z frontend"

info "TESTOWANIE [6/6]" "Sprawdzanie połączenia z backend z poziomu database"
docker exec -it database ping -c 4 backend && echo "SUKCES: database jest połączony z backend" || echo "BŁĄD: Nie można nawiązać połączenia z backend"
