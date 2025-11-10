# NetBox 서버 관리자 가이드

> **대상**: 서버 관리자
> **목적**: NetBox 서버의 일상 운영, 관리, 유지보수

---

## 목차

1. [일상 관리 작업](#1-일상-관리-작업)
2. [사용자 계정 관리](#2-사용자-계정-관리)
3. [백업 및 복구](#3-백업-및-복구)
4. [업데이트 및 패치](#4-업데이트-및-패치)
5. [모니터링](#5-모니터링)
6. [성능 튜닝](#6-성능-튜닝)
7. [보안 관리](#7-보안-관리)
8. [로그 관리](#8-로그-관리)
9. [문제 해결](#9-문제-해결)
10. [비상 상황 대응](#10-비상-상황-대응)

---

## 1. 일상 관리 작업

### 1.1 서비스 상태 확인

```bash
# 모든 NetBox 서비스 상태 확인
sudo systemctl status netbox netbox-rq nginx postgresql-15 redis

# 간단한 상태 확인
sudo systemctl is-active netbox && echo "NetBox: Running" || echo "NetBox: Stopped"
sudo systemctl is-active nginx && echo "Nginx: Running" || echo "Nginx: Stopped"
```

### 1.2 디스크 사용량 확인

```bash
# 전체 디스크 사용량
df -h

# NetBox 디렉토리 사용량
du -sh /opt/netbox
du -sh /var/log/netbox
du -sh /var/lib/pgsql

# 데이터베이스 크기 확인
sudo -u postgres psql -c "SELECT pg_database.datname, pg_size_pretty(pg_database_size(pg_database.datname)) AS size FROM pg_database;"
```

### 1.3 서비스 재시작

```bash
# NetBox 재시작
sudo systemctl restart netbox netbox-rq

# Nginx만 재시작 (설정 변경 후)
sudo systemctl restart nginx

# PostgreSQL 재시작 (주의: 서비스 중단됨)
sudo systemctl restart postgresql-15

# Redis 재시작
sudo systemctl restart redis
```

### 1.4 로그 확인

```bash
# 실시간 로그 모니터링
sudo journalctl -u netbox -f

# 최근 100줄 로그 확인
sudo journalctl -u netbox -n 100

# Gunicorn 에러 로그
sudo tail -f /var/log/netbox/gunicorn-error.log

# Nginx 액세스 로그
sudo tail -f /var/log/nginx/netbox-access.log
```

---

## 2. 사용자 계정 관리

### 2.1 Django 관리 쉘 접속

```bash
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py shell
```

### 2.2 사용자 생성

#### 웹 UI에서 생성
1. Admin 계정으로 로그인
2. **Admin > Users** 메뉴
3. **Add User** 버튼 클릭
4. 사용자 정보 입력
5. **Save** 버튼 클릭

#### 명령줄에서 생성
```bash
# 일반 사용자 생성
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.create_user('username', 'email@example.com', 'password')
EOF

# 관리자 생성
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py createsuperuser
```

### 2.3 비밀번호 재설정

```bash
# 특정 사용자 비밀번호 재설정
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py changepassword username
```

### 2.4 권한 관리

NetBox는 Django의 권한 시스템을 사용합니다:
- **View**: 객체 조회
- **Add**: 객체 생성
- **Change**: 객체 수정
- **Delete**: 객체 삭제

권한은 웹 UI에서 **Admin > Groups** 또는 **Admin > Object Permissions**에서 설정합니다.

---

## 3. 백업 및 복구

### 3.1 자동 백업 스크립트

```bash
# 백업 스크립트 생성
sudo nano /usr/local/bin/netbox-backup.sh
```

**netbox-backup.sh 내용**:
```bash
#!/bin/bash
BACKUP_DIR="/backup/netbox"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p ${BACKUP_DIR}

# 데이터베이스 백업
echo "Backing up database..."
sudo -u postgres pg_dump netbox | gzip > ${BACKUP_DIR}/netbox_db_${DATE}.sql.gz

# 미디어 파일 백업
echo "Backing up media files..."
tar -czf ${BACKUP_DIR}/netbox_media_${DATE}.tar.gz -C /opt/netbox/netbox media

# 설정 파일 백업
echo "Backing up configuration..."
tar -czf ${BACKUP_DIR}/netbox_config_${DATE}.tar.gz -C /opt/netbox/netbox/netbox configuration.py

# 7일 이상 된 백업 삭제
find ${BACKUP_DIR} -name "netbox_*" -mtime +7 -delete

echo "Backup completed: ${BACKUP_DIR}"
```

```bash
# 실행 권한 부여
sudo chmod +x /usr/local/bin/netbox-backup.sh

# Cron 등록 (매일 새벽 2시)
sudo crontab -e
```

Cron 항목 추가:
```
0 2 * * * /usr/local/bin/netbox-backup.sh >> /var/log/netbox/backup.log 2>&1
```

### 3.2 수동 백업

```bash
# 즉시 백업 실행
sudo /usr/local/bin/netbox-backup.sh
```

### 3.3 복구

#### 데이터베이스 복구
```bash
# 서비스 중지
sudo systemctl stop netbox netbox-rq

# 데이터베이스 삭제 및 재생성
sudo -u postgres psql <<EOF
DROP DATABASE netbox;
CREATE DATABASE netbox;
ALTER DATABASE netbox OWNER TO netbox;
EOF

# 백업 복원
gunzip < /backup/netbox/netbox_db_20250110_020000.sql.gz | sudo -u postgres psql netbox

# 서비스 재시작
sudo systemctl start netbox netbox-rq
```

#### 미디어 파일 복구
```bash
# 기존 미디어 파일 백업
sudo mv /opt/netbox/netbox/media /opt/netbox/netbox/media.old

# 백업 파일 복원
sudo tar -xzf /backup/netbox/netbox_media_20250110_020000.tar.gz -C /opt/netbox/netbox

# 권한 설정
sudo chown -R netbox:netbox /opt/netbox/netbox/media
```

---

## 4. 업데이트 및 패치

### 4.1 마이너 업데이트 (예: 3.6.1 → 3.6.2)

```bash
# 서비스 중지
sudo systemctl stop netbox netbox-rq

# netbox 사용자로 전환
sudo -u netbox -i
cd /opt/netbox

# 백업 (권장)
git branch backup-$(date +%Y%m%d)

# 최신 코드 pull
git pull origin main

# 가상환경 활성화
source venv/bin/activate

# 의존성 업데이트
pip install -r requirements.txt --upgrade

# 마이그레이션
python netbox/manage.py migrate

# 정적 파일 재수집
python netbox/manage.py collectstatic --no-input

# 로그아웃
exit

# 서비스 재시작
sudo systemctl start netbox netbox-rq

# 상태 확인
sudo systemctl status netbox
```

### 4.2 메이저 업데이트 (예: 3.6 → 4.0)

메이저 버전 업데이트는 중요한 변경사항이 포함될 수 있으므로:
1. 공식 릴리스 노트 확인
2. 테스트 환경에서 먼저 테스트
3. 전체 백업 수행
4. 유지보수 시간대에 수행

### 4.3 시스템 패키지 업데이트

```bash
# Rocky Linux 패키지 업데이트
sudo dnf update -y

# PostgreSQL 업데이트 (메이저 버전 업그레이드는 주의)
sudo dnf update postgresql15\*

# 재부팅 필요 여부 확인
sudo needs-restarting -r
```

---

## 5. 모니터링

### 5.1 서비스 모니터링

#### Systemd 상태 모니터링
```bash
# 서비스 실패 확인
systemctl --failed

# 특정 서비스 로그
sudo journalctl -u netbox --since "1 hour ago"
```

#### 리소스 사용량 모니터링
```bash
# CPU, 메모리 사용량
top
htop  # 설치 필요: sudo dnf install htop

# NetBox 프로세스만 확인
ps aux | grep gunicorn
ps aux | grep rqworker
```

### 5.2 데이터베이스 모니터링

```bash
# PostgreSQL 활성 연결 수
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname='netbox';"

# 느린 쿼리 확인
sudo -u postgres psql -c "SELECT pid, now() - pg_stat_activity.query_start AS duration, query FROM pg_stat_activity WHERE state = 'active' ORDER BY duration DESC LIMIT 5;"

# 데이터베이스 크기
sudo -u postgres psql -c "SELECT pg_size_pretty(pg_database_size('netbox'));"
```

### 5.3 웹 서버 모니터링

```bash
# Nginx 활성 연결 수
sudo netstat -an | grep :80 | grep ESTABLISHED | wc -l

# Nginx 액세스 로그 통계
sudo tail -n 1000 /var/log/nginx/netbox-access.log | awk '{print $9}' | sort | uniq -c | sort -rn
# 응답 코드별 통계: 200, 404, 500 등

# 실시간 요청 모니터링
sudo tail -f /var/log/nginx/netbox-access.log | grep -v "/static/"
```

### 5.4 외부 모니터링 도구 (선택사항)

- **Prometheus + Grafana**: 메트릭 수집 및 시각화
- **Nagios/Zabbix**: 서비스 상태 모니터링
- **ELK Stack**: 로그 분석
- **Uptime Kuma**: 간단한 웹 모니터링

---

## 6. 성능 튜닝

### 6.1 Gunicorn Workers 조정

```bash
# CPU 코어 수 확인
nproc

# gunicorn.py 편집
sudo nano /opt/netbox/gunicorn.py
```

권장 설정:
```python
# Workers: (CPU 코어 수 * 2) + 1
workers = 9  # 4 코어 서버의 경우

# Threads: 2-4 권장
threads = 3

# 타임아웃
timeout = 120
```

### 6.2 PostgreSQL 튜닝

```bash
# PostgreSQL 설정 편집
sudo nano /var/lib/pgsql/15/data/postgresql.conf
```

권장 설정 (8GB RAM 기준):
```ini
# 메모리 설정
shared_buffers = 2GB                 # RAM의 25%
effective_cache_size = 6GB           # RAM의 75%
maintenance_work_mem = 512MB
work_mem = 16MB

# 연결 설정
max_connections = 200

# 쿼리 플래너
random_page_cost = 1.1               # SSD 사용 시

# WAL 설정
wal_buffers = 16MB
checkpoint_completion_target = 0.9
```

재시작:
```bash
sudo systemctl restart postgresql-15
```

### 6.3 Redis 튜닝

```bash
sudo nano /etc/redis/redis.conf
```

권장 설정:
```ini
# 메모리 제한
maxmemory 2gb
maxmemory-policy allkeys-lru

# Persistent 설정
save 900 1
save 300 10
save 60 10000

# TCP Backlog
tcp-backlog 511
```

### 6.4 Nginx 튜닝

```bash
sudo nano /etc/nginx/nginx.conf
```

권장 설정:
```nginx
worker_processes auto;
worker_connections 1024;

# 버퍼 크기
client_body_buffer_size 128k;
client_max_body_size 25m;
client_header_buffer_size 1k;

# 타임아웃
keepalive_timeout 65;
client_body_timeout 12;
client_header_timeout 12;
send_timeout 10;

# Gzip 압축
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
```

---

## 7. 보안 관리

### 7.1 SSL/TLS 인증서 관리

```bash
# Let's Encrypt 인증서 갱신
sudo certbot renew

# 수동 갱신 테스트
sudo certbot renew --dry-run

# 인증서 만료 날짜 확인
sudo certbot certificates
```

### 7.2 방화벽 관리

```bash
# 현재 방화벽 규칙 확인
sudo firewall-cmd --list-all

# 특정 IP만 허용 (예시)
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="http" accept'
sudo firewall-cmd --reload

# SSH 포트 변경 (선택사항)
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

### 7.3 보안 업데이트

```bash
# 보안 업데이트만 설치
sudo dnf update --security

# 자동 보안 업데이트 설정
sudo dnf install -y dnf-automatic
sudo systemctl enable --now dnf-automatic.timer
```

### 7.4 접근 로그 분석

```bash
# 실패한 로그인 시도 확인
sudo journalctl -u netbox | grep "login failed"

# 특정 IP의 요청 확인
sudo grep "192.168.1.100" /var/log/nginx/netbox-access.log

# 가장 많이 접속한 IP 확인
sudo awk '{print $1}' /var/log/nginx/netbox-access.log | sort | uniq -c | sort -rn | head -10
```

---

## 8. 로그 관리

### 8.1 로그 로테이션

```bash
# Logrotate 설정
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

### 8.2 로그 확인 명령어

```bash
# 에러만 필터링
sudo journalctl -u netbox -p err

# 특정 날짜 로그
sudo journalctl -u netbox --since "2025-01-10" --until "2025-01-11"

# 특정 키워드 검색
sudo journalctl -u netbox | grep "error"

# 로그 크기 확인
sudo du -sh /var/log/netbox
sudo journalctl --disk-usage
```

### 8.3 로그 정리

```bash
# 7일 이상 된 로그 삭제
sudo journalctl --vacuum-time=7d

# 크기 제한 (1GB)
sudo journalctl --vacuum-size=1G
```

---

## 9. 문제 해결

### 9.1 서비스가 시작되지 않음

```bash
# 자세한 에러 로그 확인
sudo journalctl -u netbox -xe

# 설정 파일 검증
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py check

# 수동 실행으로 에러 확인
sudo -u netbox /opt/netbox/venv/bin/gunicorn -c /opt/netbox/gunicorn.py netbox.wsgi:application
```

### 9.2 데이터베이스 연결 오류

```bash
# PostgreSQL 상태 확인
sudo systemctl status postgresql-15

# 연결 테스트
sudo -u netbox psql -h localhost -U netbox -d netbox -W

# 로그 확인
sudo tail -f /var/lib/pgsql/15/data/log/postgresql-*.log
```

### 9.3 성능 저하

```bash
# 데이터베이스 VACUUM 실행
sudo -u postgres psql netbox -c "VACUUM ANALYZE;"

# PostgreSQL 통계 재생성
sudo -u postgres psql netbox -c "ANALYZE;"

# Gunicorn workers 재시작
sudo systemctl restart netbox
```

### 9.4 디스크 공간 부족

```bash
# 큰 파일 찾기
sudo find /var/log -type f -size +100M

# 오래된 로그 삭제
sudo find /var/log -type f -name "*.gz" -mtime +30 -delete

# 불필요한 패키지 정리
sudo dnf autoremove
```

---

## 10. 비상 상황 대응

### 10.1 서비스 완전 중단 시

```bash
# 1. 모든 서비스 상태 확인
sudo systemctl status netbox netbox-rq nginx postgresql-15 redis

# 2. 에러 로그 확인
sudo journalctl -xe

# 3. 서비스 재시작 (순서대로)
sudo systemctl restart postgresql-15
sudo systemctl restart redis
sudo systemctl restart netbox netbox-rq
sudo systemctl restart nginx
```

### 10.2 데이터베이스 손상 시

```bash
# 1. 서비스 중지
sudo systemctl stop netbox netbox-rq

# 2. 데이터베이스 복구 시도
sudo -u postgres pg_resetwal /var/lib/pgsql/15/data

# 3. 실패 시 백업에서 복원
# (3.3 복구 섹션 참조)
```

### 10.3 긴급 연락처 및 절차

1. **즉시 조치**:
   - 서비스 중단 알림
   - 에러 로그 수집
   - 최근 변경사항 확인

2. **복구 우선순위**:
   1. 데이터베이스 복구
   2. NetBox 서비스 재시작
   3. 웹 서버 재시작
   4. 기능 확인

3. **사후 조치**:
   - 원인 분석
   - 재발 방지 대책
   - 문서화

---

## 11. 유용한 관리 명령어

### Django 관리 명령어

```bash
# NetBox 쉘 (Django ORM 사용 가능)
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py nbshell

# 데이터베이스 일관성 검사
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py validate_models

# 캐시 삭제
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py clearcache

# RQ Worker 상태 확인
sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py rqstats
```

### 시스템 정보 수집

```bash
# 시스템 정보 한번에 확인
cat << EOF
=== System Info ===
$(uname -a)

=== NetBox Version ===
$(sudo -u netbox /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py version)

=== Services Status ===
$(sudo systemctl is-active netbox netbox-rq nginx postgresql-15 redis)

=== Disk Usage ===
$(df -h | grep -E '/$|/opt|/var')

=== Memory Usage ===
$(free -h)
EOF
```

---

## 12. 참고 자료

- **공식 문서**: https://docs.netbox.dev/
- **설치 가이드**: SERVER_INSTALL_GUIDE_ROCKY.md
- **사용자 가이드**: USER_GUIDE.md
- **GitHub**: https://github.com/netbox-community/netbox

---

**문의사항이나 문제가 발생하면 로그를 수집하여 기술 지원팀에 문의하세요.**
