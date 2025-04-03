FROM ubuntu:latest AS builder
RUN apt update && apt install -y curl
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt install -y nodejs
WORKDIR /my-react-app
COPY ./app .
RUN npm install && npm run build

FROM nginx:latest
COPY --from=builder /my-react-app/build /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
