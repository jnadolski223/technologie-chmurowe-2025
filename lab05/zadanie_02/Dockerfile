FROM node:latest
WORKDIR /my-express-app
COPY ./app .
RUN npm install
ENV MY_VARIABLE=UgaBuga
EXPOSE 3000
CMD ["npm", "run", "start"]
