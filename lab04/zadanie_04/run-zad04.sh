#!/bin/bash

function encrypt_volume() {
    local volume_name=$1
    local password=$2

    docker run --rm -v ${volume_name}:/volume -v $(pwd):/backup ubuntu tar czf /backup/${volume_name}.tar.gz -C /volume .

    echo "${password}" | gpg --batch --yes --passphrase-fd 0 -c ${volume_name}.tar.gz

    rm ${volume_name}.tar.gz

    echo "Wolumin ${volume_name} został zaszyfrowany jako ${volume_name}.tar.gz.gpg"
}

function decrypt_volume() {
    local volume_name=$1
    local password=$2

    echo "${password}" | gpg --batch --yes --passphrase-fd 0 -o ${volume_name}.tar.gz -d ${volume_name}.tar.gz.gpg

    docker volume create ${volume_name}
    docker run --rm -v ${volume_name}:/volume -v $(pwd):/backup ubuntu tar xzf /backup/${volume_name}.tar.gz -C /volume

    rm ${volume_name}.tar.gz

    echo "Wolumin ${volume_name} został odszyfrowany i przywrócony."
}

if [ $# -ne 3 ]; then
    echo "Błąd składni: skrypt wymaga 3 argumentów"
    echo "Użycie: $0 [encrypt|decrypt] nazwa_woluminu haslo"
    exit 1
elif [ "$1" == "encrypt" ]; then
    encrypt_volume $2 $3
elif [ "$1" == "decrypt" ]; then
    decrypt_volume $2 $3
else
    echo "Użycie: $0 [encrypt|decrypt] nazwa_woluminu haslo"
    exit 1
fi
