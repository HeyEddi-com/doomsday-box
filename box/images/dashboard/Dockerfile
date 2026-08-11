# syntax=docker/dockerfile:1
# Multi-arch dashboard: build with Node, serve with nginx
FROM node:22-bookworm-slim AS build
WORKDIR /src
COPY dashboard/package.json dashboard/package-lock.json* /src/
RUN npm install
COPY dashboard/ /src/
RUN npm run build

FROM nginx:1.27-alpine
COPY images/dashboard/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/dist /usr/share/nginx/html
EXPOSE 80
