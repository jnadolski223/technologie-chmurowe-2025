# Zadanie 1 - polecenia do wykonania  

1. Utworzenie sieci typu **bridge** o nazwie `my_bridge` i przypisanie do niej adresu IP `192.168.1.0/24` i bramy `192.168.1.1`  
```bash
docker network create --driver bridge --subnet 192.168.1.0/24 --gateway 192.168.1.1 my_bridge
```  

2. Uruchomienie kontenera na bazie obrazu `Alpine Linux` i przypisanie go do sieci `my_bridge`  
```bash
docker run -dit --name my_alpine_container --network my_bridge alpine
```  

3. Sprawdzenie połaczenia sieciowego wewnątrz kontenera `my_alpine_container`  
```bash
docker exec -it my_alpine_container ping -c 4 192.168.1.1
```  

4. Wyświetlenie informacji o sieci `my_bridge`  
```bash
docker network inspect my_bridge
```  
