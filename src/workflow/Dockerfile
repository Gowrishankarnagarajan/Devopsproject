FROM node:18-slim

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY . .

EXPOSE 8081

CMD ["npm", "start"]
