# Zadanie 2 - polecenia do wykonania  

1. Utworzenie sieci typu **bridge** o nazwie `my_network`  
```bash
docker network create --driver bridge my_network
```  

2. Uruchomienie kontenera o nazwie `db` z użyciem obrazu `mysql:5.7`  
```bash
docker run -d --name db --network my_network -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_DATABASE=my_database -p 3306:3306 mysql:5.7
```  

3. Utworzenie prostej struktury danych w bazie danych w kontenerze `db`  
```sql
CREATE DATABASE users_database;
USE users_database;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL
);
INSERT INTO users(name, email) VALUES ('Jan Kowalski', 'jan.kowalski@example.com'), ('Anna Nowak', 'anna.nowak@example.com');
```  

4. Utworzenie obrazu zawierającego aplikację bazując na obrazie `nodejs`  
```dockerfile
FROM node:18
WORKDIR /app
COPY ./app /app
RUN npm install
EXPOSE 8080
CMD ["npm", "run", "start"]
```
```bash
docker build -t my_node_app .
```  

5. Uruchomienie kontenera o nazwie `web` z użyciem wcześniej utworzonego obrazu aplikacji w `nodejs`  
```bash
docker run -dit --name web --network my_network -p 8080:8080 my_node_app
```