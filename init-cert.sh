#!/bin/bash

# 도메인과 이메일 설정
domain="leecod.ing"
email="shlee.super@gmail.com"

# 필요한 디렉토리 생성
mkdir -p certbot/www
mkdir -p certbot/conf
mkdir -p nginx/conf.d

# nginx 설정 파일 생성
cat > nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name leecod.ing;
    
    location /.well-known/acme-challenge/ {
        allow all;
        root /var/www/certbot;
        try_files $uri =404;
    }

    location / {
        return 301 https://$host$request_uri;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name leecod.ing;

    ssl_certificate /etc/letsencrypt/live/leecod.ing/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/leecod.ing/privkey.pem;

    location / {
        proxy_pass http://ghost:2368;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# nginx.conf 생성
cat > nginx/nginx.conf << 'EOF'
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
}
EOF

# 기존 컨테이너 정리
docker compose down

# nginx 설정 테스트
docker compose up -d nginx
echo "Nginx 시작 대기 중..."
sleep 5

# certbot 실행
docker compose run --rm certbot certonly \
    --webroot \
    --webroot-path /var/www/certbot \
    --email $email \
    --agree-tos \
    --no-eff-email \
    -d $domain \
    --force-renewal

# 컨테이너 재시작
docker compose down
docker compose up -d