FROM node:20-alpine

# Build-time version label — passed by GitHub Actions as the Git short SHA
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
LABEL version=${APP_VERSION}

WORKDIR /app

# Install dependencies first so this layer is cached unless package*.json changes
COPY package*.json ./
RUN npm install --omit=dev

COPY . .

EXPOSE 3500

CMD ["node", "server.js"]
