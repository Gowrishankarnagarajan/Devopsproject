FROM node:18-slim

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY . .

EXPOSE 8080

CMD ["npm", "start"]
# Dockerfile for Node.js application
# This Dockerfile sets up a Node.js environment, installs dependencies, and runs the application.   
