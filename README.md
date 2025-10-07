# Ghost Blog Docker Setup

이 프로젝트는 Docker Compose를 사용하여 Ghost 블로그를 호스팅하는 설정입니다.

## 구성 요소

- **Ghost**: 블로그 플랫폼 (포트 2368)
- **Nginx**: 리버스 프록시 (포트 80)

> **참고**: 이 설정은 외부 로드 밸런서에서 SSL을 처리하는 환경을 위한 것입니다. VM은 HTTP(80포트)만 노출합니다.

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

### 2. 컨테이너 실행

```bash
docker-compose up -d
```

### 3. Ghost 설정

브라우저에서 로드 밸런서를 통해 `https://yourdomain.com/ghost`에 접속하여 Ghost 관리자 계정을 설정하세요.

### 4. 로드 밸런서 설정

외부 로드 밸런서에서 다음과 같이 설정하세요:
- **백엔드**: 이 VM의 80포트
- **프로토콜**: HTTP → HTTPS
- **헬스체크**: `GET /health` (HTTP 200 응답)

## 디렉토리 구조

```
├── docker-compose.yml      # Docker Compose 설정
├── nginx/                 # Nginx 설정 파일들
│   ├── nginx.conf
│   └── conf.d/
├── content/               # Ghost 콘텐츠 (테마, 설정 등)
└── data/                  # Ghost 데이터 및 런타임 파일
```

## 주의사항

- `data/` 디렉토리에는 Ghost 데이터베이스와 런타임 파일들이 저장되므로 백업이 필요합니다.
- `.env` 파일에는 민감한 정보가 포함되어 있으므로 Git에 커밋하지 마세요.
- SSL은 외부 로드 밸런서에서 처리되므로, Ghost URL은 HTTPS로 설정하되 이 서버는 HTTP로만 동작합니다.

## 유지보수

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
```

### 헬스체크 확인

```bash
# 로컬에서 헬스체크 엔드포인트 테스트
curl http://localhost/health
```