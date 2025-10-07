# Ghost Blog Docker Setup

이 프로젝트는 Docker Compose를 사용하여 Ghost 블로그를 호스팅하는 설정입니다.

## 구성 요소

- **Ghost**: 블로그 플랫폼 (포트 2368)
- **Nginx**: 리버스 프록시 및 SSL 터미네이션 (포트 80, 443)
- **Certbot**: Let's Encrypt SSL 인증서 자동 관리

## 설정 방법

### 1. 환경 변수 설정

`.env.example` 파일을 `.env`로 복사하고 실제 값으로 수정하세요:

```bash
cp .env.example .env
```

`.env` 파일에서 다음 값들을 설정하세요:
- `GHOST_URL`: 블로그 도메인 (예: https://yourdomain.com)
- `DB_HOST`: 데이터베이스 호스트
- `DB_PORT`: 데이터베이스 포트 (기본값: 3306)
- `DB_USER`: 데이터베이스 사용자명
- `DB_PASSWORD`: 데이터베이스 비밀번호
- `DB_NAME`: 데이터베이스 이름

### 2. SSL 인증서 초기화

최초 SSL 인증서를 발급받기 위해 초기화 스크립트를 실행하세요:

```bash
chmod +x init-cert.sh
./init-cert.sh your-domain.com your-email@example.com
```

### 3. 컨테이너 실행

```bash
docker-compose up -d
```

### 4. Ghost 설정

브라우저에서 `https://yourdomain.com/ghost`에 접속하여 Ghost 관리자 계정을 설정하세요.

## 디렉토리 구조

```
├── docker-compose.yml      # Docker Compose 설정
├── init-cert.sh           # SSL 인증서 초기화 스크립트
├── nginx/                 # Nginx 설정 파일들
│   ├── nginx.conf
│   └── conf.d/
├── certbot/               # Let's Encrypt 인증서 저장소
├── content/               # Ghost 콘텐츠 (테마, 설정 등)
└── data/                  # Ghost 데이터 및 런타임 파일
```

## 주의사항

- `data/` 디렉토리에는 Ghost 데이터베이스와 런타임 파일들이 저장되므로 백업이 필요합니다.
- `certbot/` 디렉토리에는 SSL 인증서가 저장되므로 보안에 주의하세요.
- `.env` 파일에는 민감한 정보가 포함되어 있으므로 Git에 커밋하지 마세요.

## 유지보수

### SSL 인증서 갱신

Certbot이 자동으로 인증서를 갱신하지만, 수동으로 갱신하려면:

```bash
docker-compose exec certbot certbot renew
docker-compose exec nginx nginx -s reload
```

### 백업

```bash
# Ghost 데이터베이스 백업
docker-compose exec ghost ghost backup

# 전체 데이터 디렉토리 백업
sudo tar -czf ghost-backup-$(date +%Y%m%d).tar.gz data/
```

## 문제 해결

### 로그 확인

```bash
# Ghost 로그
docker-compose logs ghost

# Nginx 로그
docker-compose logs nginx

# Certbot 로그
docker-compose logs certbot
```