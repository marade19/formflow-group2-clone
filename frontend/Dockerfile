# Stage 1: Build the React app
FROM node:20-alpine AS build

ARG APP_VERSION=dev
LABEL version=${APP_VERSION}

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx, which also proxies /api/ to the backend
FROM nginx:1.27-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD wget -q --spider http://localhost:80 || exit 1
CMD ["nginx", "-g", "daemon off;"]
