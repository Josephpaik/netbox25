# NetBox 서버 설치 가이드 (Rocky Linux)

> **대상**: 서버 관리자
> **환경**: Rocky Linux 8/9
> **목적**: 프로덕션 환경 NetBox 서버 구축

---

## 목차

1. [시스템 요구사항](#1-시스템-요구사항)
2. [기본 시스템 설정](#2-기본-시스템-설정)
3. [의존성 설치](#3-의존성-설치)
4. [PostgreSQL 설정](#4-postgresql-설정)
5. [Redis 설정](#5-redis-설정)
6. [NetBox 설치](#6-netbox-설치)
7. [Gunicorn 설정](#7-gunicorn-설정)
8. [Nginx 설정](#8-nginx-설정)
9. [Systemd 서비스 설정](#9-systemd-서비스-설정)
10. [방화벽 설정](#10-방화벽-설정)
11. [SSL/TLS 설정](#11-ssltls-설정)
12. [서비스 시작](#12-서비스-시작)
13. [동작 확인](#13-동작-확인)
14. [문제 해결](#14-문제-해결)

---

## 1. 시스템 요구사항

### 최소 사양
- **CPU**: 2 코어
- **RAM**: 4GB
- **디스크**: 20GB
- **OS**: Rocky Linux 8.x 또는 9.x

### 권장 사양
- **CPU**: 4 코어 이상
- **RAM**: 8GB 이상
- **디스크**: 50GB 이상 (SSD 권장)
- **네트워크**: 1Gbps

### 필수 소프트웨어
- Python 3.10 이상
- PostgreSQL 12 이상
- Redis 6.0 이상
- Nginx 또는 Apache

---

## 2. 기본 시스템 설정

### 2.1 시스템 업데이트

```bash
# root 또는 sudo 권한으로 실행
sudo dnf update -y
```

### 2.2 SELinux 설정 (선택사항)

프로덕션 환경에서는 SELinux를 Enforcing 모드로 유지하는 것을 권장합니다.

```bash
# SELinux 상태 확인
getenforce

# Enforcing 모드로 설정 (영구적)
sudo setenforce 1
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
```

SELinux 정책 설정이 복잡한 경우, 개발/테스트 환경에서는 Permissive 모드 사용 가능:

```bash
# Permissive 모드 (로그만 기록, 차단하지 않음)
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
```

### 2.3 호스트명 설정

```bash
# 호스트명 설정
sudo hostnamectl set-hostname netbox.example.com

# /etc/hosts 파일 편집
sudo nano /etc/hosts
```

다음 내용 추가:
```
127.0.0.1   localhost localhost.localdomain
<서버IP>    netbox.example.com netbox
```

---

## 3. 의존성 설치

### 3.1 EPEL 저장소 활성화

```bash
sudo dnf install -y epel-release
```

### 3.2 Python 3.11 설치

```bash
# Python 3.11 설치
sudo dnf install -y python3.11 python3.11-devel python3.11-pip

# 버전 확인
python3.11 --version
```

### 3.3 필수 패키지 설치

```bash
sudo dnf install -y \
    gcc \
    git \
    libxml2-devel \
    libxslt-devel \
    libffi-devel \
    openssl-devel \
    redhat-rpm-config \
    postgresql-devel \
    libjpeg-devel \
    zlib-devel
```

---

## 4. PostgreSQL 설정

### 4.1 PostgreSQL 설치

```bash
# PostgreSQL 15 설치
sudo dnf install -y postgresql15-server postgresql15-contrib

# 데이터베이스 초기화
sudo postgresql-15-setup initdb

# 서비스 시작 및 자동 시작 설정
sudo systemctl enable postgresql-15 --now
sudo systemctl status postgresql-15
```

### 4.2 PostgreSQL 인증 설정

```bash
# pg_hba.conf 편집
sudo nano /var/lib/pgsql/15/data/pg_hba.conf
```

다음 줄을 찾아서 수정:
```
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
```

PostgreSQL 재시작:
```bash
sudo systemctl restart postgresql-15
```

### 4.3 데이터베이스 및 사용자 생성

```bash
# postgres 사용자로 전환
sudo -u postgres psql
```

PostgreSQL 프롬프트에서:
```sql
-- 데이터베이스 생성
CREATE DATABASE netbox;

-- 사용자 생성
CREATE USER netbox WITH PASSWORD 'your-secure-password-here';

-- 권한 부여
ALTER DATABASE netbox OWNER TO netbox;
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;

-- 인코딩 설정 확인
\l netbox

-- 종료
\q
```

### 4.4 연결 테스트

```bash
# 연결 테스트
psql -U netbox -d netbox -h localhost -W
# 비밀번호 입력 후 접속 확인
\q
```

---

## 5. Redis 설정

### 5.1 Redis 설치

```bash
# Redis 설치
sudo dnf install -y redis

# 서비스 시작 및 자동 시작 설정
sudo systemctl enable redis --now
sudo systemctl status redis
```

### 5.2 Redis 설정 (선택사항)

```bash
# Redis 설정 파일 편집
sudo nano /etc/redis/redis.conf
```

권장 설정:
```
# 메모리 제한 (예: 1GB)
maxmemory 1gb
maxmemory-policy allkeys-lru

# 영구 저장 활성화 (선택)
save 900 1
save 300 10
save 60 10000

# 로그 레벨
loglevel notice
```

설정 변경 후 재시작:
```bash
sudo systemctl restart redis
```

### 5.3 Redis 연결 테스트

```bash
redis-cli ping
# 응답: PONG
```

---

## 6. NetBox 설치

### 6.1 NetBox 사용자 생성

보안을 위해 전용 사용자 계정 생성:

```bash
sudo useradd -r -d /opt/netbox -s /bin/bash netbox
```

### 6.2 NetBox 다운로드

```bash
# /opt 디렉토리로 이동
cd /opt

# Git으로 클론 (또는 공식 릴리스 다운로드)
sudo git clone https://github.com/Josephpaik/netbox25.git netbox

# 소유권 변경
sudo chown -R netbox:netbox /opt/netbox
```

### 6.3 Python 가상환경 생성

```bash
# netbox 사용자로 전환
sudo -u netbox -i

# 가상환경 생성
cd /opt/netbox
python3.11 -m venv venv

# 가상환경 활성화
source venv/bin/activate

# pip 업그레이드
pip install --upgrade pip
```

### 6.4 Python 의존성 설치

```bash
# NetBox 의존성 설치
pip install -r requirements.txt

# Gunicorn 설치 (WSGI 서버)
pip install gunicorn

# 설치 확인
pip list | grep -E "Django|gunicorn"
```

### 6.5 NetBox 설정

```bash
# 설정 파일 복사
cp netbox/netbox/configuration_example.py netbox/netbox/configuration.py

# 설정 파일 편집
nano netbox/netbox/configuration.py
```

**중요 설정 항목**:

```python
# SECRET_KEY 생성
# 터미널에서 실행: python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
SECRET_KEY = 'your-generated-secret-key-here'

# 허용 호스트 (서버 IP 또는 도메인)
ALLOWED_HOSTS = ['netbox.example.com', '192.168.1.100', 'localhost']

# 데이터베이스 설정
DATABASE = {
    'NAME': 'netbox',
    'USER': 'netbox',
    'PASSWORD': 'your-secure-password-here',
    'HOST': 'localhost',
    'PORT': '',
    'CONN_MAX_AGE': 300,
}

# Redis 설정
REDIS = {
    'tasks': {
        'HOST': 'localhost',
        'PORT': 6379,
        'PASSWORD': '',
        'DATABASE': 0,
        'SSL': False,
    },
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'PASSWORD': '',
        'DATABASE': 1,
        'SSL': False,
    }
}

# 미디어 및 정적 파일 경로
MEDIA_ROOT = '/opt/netbox/netbox/media'
REPORTS_ROOT = '/opt/netbox/netbox/reports'
SCRIPTS_ROOT = '/opt/netbox/netbox/scripts'

# 이메일 설정 (선택사항)
EMAIL = {
    'SERVER': 'smtp.example.com',
    'PORT': 587,
    'USERNAME': 'netbox@example.com',
    'PASSWORD': 'email-password',
    'USE_SSL': False,
    'USE_TLS': True,
    'TIMEOUT': 10,
    'FROM_EMAIL': 'netbox@example.com',
}

# 로그 설정
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/netbox/netbox.log',
            'maxBytes': 10485760,  # 10MB
            'backupCount': 5,
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['file'],
        'level': 'INFO',
    },
}
```

### 6.6 SECRET_KEY 생성

```bash
# SECRET_KEY 생성
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

생성된 키를 `configuration.py`의 `SECRET_KEY`에 붙여넣기

### 6.7 디렉토리 생성 및 권한 설정

```bash
# 로그 디렉토리
sudo mkdir -p /var/log/netbox
sudo chown netbox:netbox /var/log/netbox

# 미디어 디렉토리
mkdir -p /opt/netbox/netbox/media
mkdir -p /opt/netbox/netbox/reports
mkdir -p /opt/netbox/netbox/scripts
```

### 6.8 데이터베이스 마이그레이션

```bash
# 가상환경 활성화 상태에서
cd /opt/netbox
source venv/bin/activate

# 마이그레이션 실행
python netbox/manage.py migrate
```

### 6.9 슈퍼유저 생성

```bash
# 관리자 계정 생성
python netbox/manage.py createsuperuser

# 입력:
# Username: admin
# Email: admin@example.com
# Password: (강력한 비밀번호)
```

### 6.10 정적 파일 수집

```bash
# 정적 파일 수집
python netbox/manage.py collectstatic --no-input
```

### 6.11 설치 테스트

```bash
# 개발 서버로 테스트 (임시)
python netbox/manage.py runserver 0.0.0.0:8000

# 다른 터미널에서 접속 테스트
curl http://localhost:8000/

# Ctrl+C로 종료
```

---

## 7. Gunicorn 설정

### 7.1 Gunicorn 설정 파일 생성

```bash
# netbox 사용자로
sudo -u netbox -i
cd /opt/netbox

# Gunicorn 설정 파일 생성
nano gunicorn.py
```

**gunicorn.py 내용**:

```python
# Gunicorn configuration for NetBox

# Bind to Unix socket
bind = 'unix:/opt/netbox/netbox.sock'

# Worker processes
workers = 4  # CPU 코어 수 * 2 + 1
threads = 3

# Timeout
timeout = 120

# Logging
accesslog = '/var/log/netbox/gunicorn-access.log'
errorlog = '/var/log/netbox/gunicorn-error.log'
loglevel = 'info'

# Process naming
proc_name = 'netbox'

# User and group
user = 'netbox'
group = 'netbox'
```

### 7.2 테스트 실행

```bash
# 가상환경 활성화
source venv/bin/activate

# Gunicorn 테스트 실행
gunicorn -c gunicorn.py netbox.wsgi:application

# Ctrl+C로 종료
```

---

## 8. Nginx 설정

### 8.1 Nginx 설치

```bash
# root로 돌아가기
exit

# Nginx 설치
sudo dnf install -y nginx

# 서비스 활성화 (아직 시작하지 않음)
sudo systemctl enable nginx
```

### 8.2 Nginx 설정 파일 생성

```bash
sudo nano /etc/nginx/conf.d/netbox.conf
```

**netbox.conf 내용**:

```nginx
upstream netbox {
    server unix:/opt/netbox/netbox.sock fail_timeout=0;
}

server {
    listen 80;
    server_name netbox.example.com;  # 실제 도메인으로 변경

    client_max_body_size 25m;

    # Redirect to HTTPS (SSL 설정 후)
    # return 301 https://$server_name$request_uri;

    # 정적 파일
    location /static/ {
        alias /opt/netbox/netbox/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 미디어 파일
    location /media/ {
        alias /opt/netbox/netbox/media/;
        expires 7d;
        add_header Cache-Control "public";
    }

    # NetBox 애플리케이션
    location / {
        proxy_pass http://netbox;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;

        # Timeouts
        proxy_connect_timeout 90;
        proxy_send_timeout 90;
        proxy_read_timeout 90;
    }

    # Logging
    access_log /var/log/nginx/netbox-access.log;
    error_log /var/log/nginx/netbox-error.log;
}
```

### 8.3 Nginx 설정 테스트

```bash
# 설정 파일 문법 검사
sudo nginx -t

# 성공 메시지:
# nginx: configuration file /etc/nginx/nginx.conf test is successful
```

---

## 9. Systemd 서비스 설정

### 9.1 NetBox 서비스 파일 생성

```bash
sudo nano /etc/systemd/system/netbox.service
```

**netbox.service 내용**:

```ini
[Unit]
Description=NetBox WSGI Service
Documentation=https://docs.netbox.dev/
After=network-online.target postgresql-15.target redis.target
Wants=network-online.target

[Service]
Type=notify
User=netbox
Group=netbox
WorkingDirectory=/opt/netbox/netbox
Environment="PATH=/opt/netbox/venv/bin"
ExecStart=/opt/netbox/venv/bin/gunicorn -c /opt/netbox/gunicorn.py netbox.wsgi:application
Restart=on-failure
RestartSec=5
TimeoutStartSec=0
KillMode=mixed

[Install]
WantedBy=multi-user.target
```

### 9.2 NetBox RQ Worker 서비스 (백그라운드 작업)

```bash
sudo nano /etc/systemd/system/netbox-rq.service
```

**netbox-rq.service 내용**:

```ini
[Unit]
Description=NetBox RQ Worker
Documentation=https://docs.netbox.dev/
After=network-online.target postgresql-15.target redis.target
Wants=network-online.target

[Service]
Type=simple
User=netbox
Group=netbox
WorkingDirectory=/opt/netbox/netbox
Environment="PATH=/opt/netbox/venv/bin"
ExecStart=/opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py rqworker
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### 9.3 Systemd 데몬 리로드

```bash
# 데몬 리로드
sudo systemctl daemon-reload

# 서비스 활성화
sudo systemctl enable netbox netbox-rq
```

---

## 10. 방화벽 설정

### 10.1 Firewalld 설정

```bash
# Firewalld 상태 확인
sudo systemctl status firewalld

# 활성화되어 있지 않으면 시작
sudo systemctl enable firewalld --now

# HTTP/HTTPS 포트 허용
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# 방화벽 리로드
sudo firewall-cmd --reload

# 설정 확인
sudo firewall-cmd --list-all
```

### 10.2 SELinux 정책 (SELinux 사용 시)

```bash
# Nginx가 네트워크 연결 허용
sudo setsebool -P httpd_can_network_connect 1

# Nginx가 Unix 소켓 사용 허용
sudo chcon -Rt httpd_sys_content_t /opt/netbox/netbox.sock

# SELinux 컨텍스트 영구 설정
sudo semanage fcontext -a -t httpd_sys_rw_content_t "/opt/netbox/netbox\.sock"
sudo restorecon -Rv /opt/netbox/
```

---

## 11. SSL/TLS 설정

### 11.1 Let's Encrypt 인증서 (무료)

```bash
# Certbot 설치
sudo dnf install -y certbot python3-certbot-nginx

# 인증서 발급
sudo certbot --nginx -d netbox.example.com

# 프롬프트에서:
# - 이메일 입력
# - 이용 약관 동의
# - HTTP를 HTTPS로 리디렉션할지 선택 (권장: 2번)

# 자동 갱신 테스트
sudo certbot renew --dry-run
```

### 11.2 Nginx SSL 설정 (Certbot이 자동 설정)

Certbot이 자동으로 `/etc/nginx/conf.d/netbox.conf`를 수정하여 SSL 설정을 추가합니다.

수동 설정이 필요한 경우:

```nginx
server {
    listen 443 ssl http2;
    server_name netbox.example.com;

    ssl_certificate /etc/letsencrypt/live/netbox.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/netbox.example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # 나머지 설정은 위와 동일
    # ...
}

# HTTP to HTTPS 리디렉션
server {
    listen 80;
    server_name netbox.example.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 12. 서비스 시작

### 12.1 모든 서비스 시작

```bash
# PostgreSQL (이미 실행 중)
sudo systemctl status postgresql-15

# Redis (이미 실행 중)
sudo systemctl status redis

# NetBox 메인 서비스 시작
sudo systemctl start netbox

# NetBox RQ Worker 시작
sudo systemctl start netbox-rq

# Nginx 시작
sudo systemctl start nginx

# 서비스 상태 확인
sudo systemctl status netbox
sudo systemctl status netbox-rq
sudo systemctl status nginx
```

### 12.2 서비스 로그 확인

```bash
# NetBox 로그
sudo journalctl -u netbox -f

# NetBox RQ Worker 로그
sudo journalctl -u netbox-rq -f

# Nginx 로그
sudo tail -f /var/log/nginx/netbox-access.log
sudo tail -f /var/log/nginx/netbox-error.log

# Gunicorn 로그
sudo tail -f /var/log/netbox/gunicorn-access.log
sudo tail -f /var/log/netbox/gunicorn-error.log
```

---

## 13. 동작 확인

### 13.1 웹 브라우저 접속

1. **HTTP**: http://netbox.example.com/ 또는 http://서버IP/
2. **HTTPS**: https://netbox.example.com/

### 13.2 로그인

- Username: `admin`
- Password: (생성한 비밀번호)

### 13.3 기능 테스트

- [ ] 로그인 성공
- [ ] 대시보드 표시
- [ ] DCIM > Sites 접속
- [ ] 새 Site 생성
- [ ] CSV Import 테스트
- [ ] API 접속: https://netbox.example.com/api/

---

## 14. 문제 해결

### 14.1 502 Bad Gateway 오류

**원인**: Gunicorn이 실행되지 않거나 소켓 파일 권한 문제

**해결**:
```bash
# Gunicorn 상태 확인
sudo systemctl status netbox

# 로그 확인
sudo journalctl -u netbox -n 50

# 소켓 파일 확인
ls -la /opt/netbox/netbox.sock

# 권한 수정
sudo chown netbox:netbox /opt/netbox/netbox.sock
sudo chmod 660 /opt/netbox/netbox.sock

# Nginx 사용자가 소켓에 접근할 수 있도록
sudo usermod -a -G netbox nginx

# 서비스 재시작
sudo systemctl restart netbox nginx
```

### 14.2 Static 파일이 로드되지 않음

**해결**:
```bash
# 정적 파일 재수집
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input

# Nginx 설정 확인
sudo nginx -t

# SELinux 컨텍스트 확인 및 수정
sudo chcon -Rt httpd_sys_content_t /opt/netbox/netbox/static/
```

### 14.3 데이터베이스 연결 오류

**해결**:
```bash
# PostgreSQL 상태 확인
sudo systemctl status postgresql-15

# 연결 테스트
psql -U netbox -d netbox -h localhost -W

# pg_hba.conf 확인
sudo cat /var/lib/pgsql/15/data/pg_hba.conf | grep -v "^#"

# PostgreSQL 재시작
sudo systemctl restart postgresql-15
```

### 14.4 Redis 연결 오류

**해결**:
```bash
# Redis 상태 확인
sudo systemctl status redis

# 연결 테스트
redis-cli ping

# Redis 재시작
sudo systemctl restart redis
```

### 14.5 Permission Denied 오류

**해결**:
```bash
# 파일 소유권 확인 및 수정
sudo chown -R netbox:netbox /opt/netbox

# 로그 디렉토리 권한
sudo chown -R netbox:netbox /var/log/netbox
sudo chmod -R 755 /var/log/netbox

# 미디어 디렉토리 권한
sudo chmod -R 755 /opt/netbox/netbox/media
```

### 14.6 서비스가 시작되지 않음

**해결**:
```bash
# 자세한 로그 확인
sudo journalctl -u netbox -xe

# 설정 파일 문법 확인
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py check

# Gunicorn 수동 실행으로 에러 확인
sudo -u netbox /opt/netbox/venv/bin/gunicorn -c /opt/netbox/gunicorn.py netbox.wsgi:application
```

---

## 15. 백업 및 복구

### 15.1 데이터베이스 백업

```bash
# 백업 스크립트
sudo -u postgres pg_dump netbox > /backup/netbox_$(date +%Y%m%d).sql

# 자동 백업 (cron)
sudo crontab -e
# 매일 새벽 2시 백업
0 2 * * * sudo -u postgres pg_dump netbox > /backup/netbox_$(date +\%Y\%m\%d).sql
```

### 15.2 미디어 파일 백업

```bash
# rsync로 백업
rsync -av /opt/netbox/netbox/media/ /backup/netbox-media/

# tar로 압축 백업
tar -czf /backup/netbox-media_$(date +%Y%m%d).tar.gz /opt/netbox/netbox/media/
```

### 15.3 복구

```bash
# 데이터베이스 복구
sudo -u postgres psql netbox < /backup/netbox_20250110.sql

# 미디어 파일 복구
rsync -av /backup/netbox-media/ /opt/netbox/netbox/media/
```

---

## 16. 유지보수

### 16.1 업데이트

```bash
# NetBox 사용자로 전환
sudo -u netbox -i
cd /opt/netbox

# Git pull
git pull

# 가상환경 활성화
source venv/bin/activate

# 의존성 업데이트
pip install -r requirements.txt --upgrade

# 마이그레이션
python netbox/manage.py migrate

# 정적 파일 재수집
python netbox/manage.py collectstatic --no-input

# 서비스 재시작
exit
sudo systemctl restart netbox netbox-rq
```

### 16.2 로그 로테이션

```bash
# /etc/logrotate.d/netbox 생성
sudo nano /etc/logrotate.d/netbox
```

내용:
```
/var/log/netbox/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 netbox netbox
    sharedscripts
    postrotate
        systemctl reload netbox > /dev/null 2>&1 || true
    endscript
}
```

---

## 17. 참고 자료

- **NetBox 공식 문서**: https://docs.netbox.dev/
- **설치 가이드**: https://docs.netbox.dev/en/stable/installation/
- **관리 가이드**: SERVER_ADMIN_GUIDE.md
- **사용자 가이드**: USER_GUIDE.md

---

## 축하합니다! 🎉

NetBox 서버가 성공적으로 설치되었습니다!

**다음 단계**:
1. SSL 인증서 설정
2. 정기 백업 자동화
3. 모니터링 설정
4. 사용자 계정 생성
5. IDC 시나리오 데이터 업로드

서버 운영에 대한 자세한 내용은 **SERVER_ADMIN_GUIDE.md**를 참조하세요.
