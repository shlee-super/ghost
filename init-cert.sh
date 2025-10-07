#!/bin/bash

# SSL 인증서 초기화 스크립트
# 사용법: ./init-cert.sh <domain> <email>

if [ "$#" -ne 2 ]; then
    echo "사용법: $0 <domain> <email>"
    echo "예시: $0 yourdomain.com your-email@example.com"
    exit 1
fi

# 매개변수에서 도메인과 이메일 가져오기
domain="$1"
email="$2"

echo "도메인: $domain"
echo "이메일: $email"

# 필요한 디렉토리 생성
mkdir -p certbot/www
mkdir -p certbot/conf

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