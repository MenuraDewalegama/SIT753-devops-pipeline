FROM node:slim

WORKDIR /app

COPY . .

WORKDIR /app/jukebox-backend
RUN npm install
RUN npm install --dev

WORKDIR /app/jukebox-backend
CMD ["npm", "start"]

EXPOSE 3000