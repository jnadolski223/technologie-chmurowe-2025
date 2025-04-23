FROM node:18-alpine
WORKDIR /express-app
COPY ./app/package.json .
RUN npm install
COPY ./app .
EXPOSE 3000
CMD ["npm", "run", "start"]
