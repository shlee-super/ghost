#!/bin/bash

# 도메인과 이메일 설정
domain="leecod.ing"  # 실제 도메인으로 변경하세요
email="shlee.super@gmail.com"

# 필요한 디렉토리 생성
mkdir -p certbot/www
mkdir -p certbot/conf
mkdir -p nginx/conf.d

# nginx 설정 파일 생성
cat > nginx/conf.d/default.conf << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${domain};
    
    location /.well-known/acme-challenge/ {
        allow all;
        root /var/www/certbot;
        try_files \$uri =404;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name ${domain};

    ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;

    location / {
        proxy_pass http://ghost:2368;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy