FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
# Hapus default config nginx
RUN rm /etc/nginx/conf.d/default.conf
# Copy config kita yang baru (port 8080)
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy hasil build react
COPY --from=builder /app/dist /usr/share/nginx/html

# Cloud Run mewajibkan port 8080
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
