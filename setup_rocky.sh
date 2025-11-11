#!/bin/bash
# NetBox Rocky Linux 자동 설치 스크립트
# 사용법: sudo ./setup_rocky.sh

set -e  # 에러 발생 시 스크립트 중단

# Root 권한 확인
if [ "$EUID" -ne 0 ]; then
    echo "이 스크립트는 root 권한으로 실행해야 합니다."
    echo "사용법: sudo ./setup_rocky.sh"
    exit 1
fi

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 메시지 함수
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

info() {
    echo -e "${BLUE}→ $1${NC}"
}

echo "=============================================="
echo "NetBox Rocky Linux 자동 설치 스크립트"
echo "=============================================="
echo ""

# 설정 변수
NETBOX_USER="netbox"
NETBOX_HOME="/opt/netbox"
DB_NAME="netbox"
DB_USER="netbox"
NGINX_CONF="/etc/nginx/conf.d/netbox.conf"

# 사용자 입력
read -p "PostgreSQL 비밀번호 입력: " -s DB_PASSWORD
echo ""
read -p "서버 도메인 또는 IP 입력 (예: netbox.example.com 또는 192.168.1.100): " SERVER_NAME
echo ""

# Step 1: 시스템 업데이트
echo ""
echo "Step 1: 시스템 업데이트"
echo "----------------------------------------------"
info "시스템 패키지 업데이트 중..."
dnf update -y > /dev/null 2>&1
success "시스템 업데이트 완료"

# Step 2: EPEL 저장소 설치
echo ""
echo "Step 2: EPEL 저장소 설치"
echo "----------------------------------------------"
info "EPEL 저장소 설치 중..."
dnf install -y epel-release > /dev/null 2>&1
success "EPEL 저장소 설치 완료"

# Step 3: Python 3.11 설치
echo ""
echo "Step 3: Python 3.11 설치"
echo "----------------------------------------------"
info "Python 3.11 설치 중..."
dnf install -y python3.11 python3.11-devel python3.11-pip > /dev/null 2>&1
success "Python 3.11 설치 완료 ($(python3.11 --version))"

# Step 4: 필수 패키지 설치
echo ""
echo "Step 4: 필수 패키지 설치"
echo "----------------------------------------------"
info "빌드 도구 및 라이브러리 설치 중..."
dnf install -y gcc git libxml2-devel libxslt-devel libffi-devel \
    openssl-devel redhat-rpm-config postgresql-devel \
    libjpeg-devel zlib-devel > /dev/null 2>&1
success "필수 패키지 설치 완료"

# Step 5: PostgreSQL 설치
echo ""
echo "Step 5: PostgreSQL 설치"
echo "----------------------------------------------"
if ! command -v psql &> /dev/null; then
    info "PostgreSQL 15 설치 중..."
    dnf install -y postgresql15-server postgresql15-contrib > /dev/null 2>&1

    info "PostgreSQL 초기화 중..."
    postgresql-15-setup initdb > /dev/null 2>&1

    # pg_hba.conf 수정
    PG_HBA="/var/lib/pgsql/15/data/pg_hba.conf"
    sed -i 's/host    all             all             127.0.0.1\/32            ident/host    all             all             127.0.0.1\/32            md5/' $PG_HBA

    systemctl enable postgresql-15 --now > /dev/null 2>&1
    sleep 3
    success "PostgreSQL 설치 및 시작 완료"
else
    success "PostgreSQL이 이미 설치되어 있습니다"
fi

# Step 6: PostgreSQL 데이터베이스 생성
echo ""
echo "Step 6: PostgreSQL 데이터베이스 생성"
echo "----------------------------------------------"
info "NetBox 데이터베이스 생성 중..."

sudo -u postgres psql <<EOF > /dev/null 2>&1
CREATE DATABASE ${DB_NAME};
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
ALTER DATABASE ${DB_NAME} OWNER TO ${DB_USER};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO ${DB_USER};
EOF

if [ $? -eq 0 ]; then
    success "데이터베이스 생성 완료"
else
    warning "데이터베이스가 이미 존재하거나 생성 중 오류 발생"
fi

# Step 7: Redis 설치
echo ""
echo "Step 7: Redis 설치"
echo "----------------------------------------------"
if ! command -v redis-server &> /dev/null; then
    info "Redis 설치 중..."
    dnf install -y redis > /dev/null 2>&1
    systemctl enable redis --now > /dev/null 2>&1
    success "Redis 설치 및 시작 완료"
else
    success "Redis가 이미 설치되어 있습니다"
fi

# Step 8: NetBox 사용자 생성
echo ""
echo "Step 8: NetBox 사용자 생성"
echo "----------------------------------------------"
if ! id -u ${NETBOX_USER} > /dev/null 2>&1; then
    info "NetBox 전용 사용자 생성 중..."
    useradd -r -d ${NETBOX_HOME} -s /bin/bash ${NETBOX_USER}
    success "NetBox 사용자 생성 완료"
else
    success "NetBox 사용자가 이미 존재합니다"
fi

# Step 9: NetBox 다운로드
echo ""
echo "Step 9: NetBox 다운로드"
echo "----------------------------------------------"
if [ ! -d "${NETBOX_HOME}" ]; then
    info "NetBox 저장소 클론 중..."
    cd /opt
    git clone https://github.com/Josephpaik/netbox25.git netbox > /dev/null 2>&1
    chown -R ${NETBOX_USER}:${NETBOX_USER} ${NETBOX_HOME}
    success "NetBox 다운로드 완료"
else
    warning "NetBox 디렉토리가 이미 존재합니다"
fi

# Step 10: Python 가상환경 생성
echo ""
echo "Step 10: Python 가상환경 생성"
echo "----------------------------------------------"
if [ ! -d "${NETBOX_HOME}/venv" ]; then
    info "Python 가상환경 생성 중..."
    sudo -u ${NETBOX_USER} python3.11 -m venv ${NETBOX_HOME}/venv
    success "가상환경 생성 완료"
else
    warning "가상환경이 이미 존재합니다"
fi

# Step 11: Python 의존성 설치
echo ""
echo "Step 11: Python 의존성 설치"
echo "----------------------------------------------"
info "Python 패키지 설치 중 (몇 분 소요될 수 있습니다)..."
sudo -u ${NETBOX_USER} ${NETBOX_HOME}/venv/bin/pip install --upgrade pip > /dev/null 2>&1
sudo -u ${NETBOX_USER} ${NETBOX_HOME}/venv/bin/pip install -r ${NETBOX_HOME}/requirements.txt > /dev/null 2>&1
sudo -u ${NETBOX_USER} ${NETBOX_HOME}/venv/bin/pip install gunicorn > /dev/null 2>&1
success "Python 패키지 설치 완료"

# Step 12: NetBox 설정 파일 생성
echo ""
echo "Step 12: NetBox 설정 파일 생성"
echo "----------------------------------------------"
if [ ! -f "${NETBOX_HOME}/netbox/netbox/configuration.py" ]; then
    info "설정 파일 생성 중..."
    cp ${NETBOX_HOME}/netbox/netbox/configuration_example.py ${NETBOX_HOME}/netbox/netbox/configuration.py

    # SECRET_KEY 생성
    SECRET_KEY=$(${NETBOX_HOME}/venv/bin/python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

    # 설정 파일 수정
    sed -i "s/SECRET_KEY = ''/SECRET_KEY = '${SECRET_KEY}'/" ${NETBOX_HOME}/netbox/netbox/configuration.py
    sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['${SERVER_NAME}', 'localhost', '127.0.0.1']/" ${NETBOX_HOME}/netbox/netbox/configuration.py
    sed -i "s/'PASSWORD': ''/'PASSWORD': '${DB_PASSWORD}'/" ${NETBOX_HOME}/netbox/netbox/configuration.py

    chown ${NETBOX_USER}:${NETBOX_USER} ${NETBOX_HOME}/netbox/netbox/configuration.py
    success "설정 파일 생성 완료"
else
    warning "설정 파일이 이미 존재합니다"
fi

# Step 13: 디렉토리 생성
echo ""
echo "Step 13: 디렉토리 생성"
echo "----------------------------------------------"
info "로그 및 미디어 디렉토리 생성 중..."
mkdir -p /var/log/netbox
chown ${NETBOX_USER}:${NETBOX_USER} /var/log/netbox

mkdir -p ${NETBOX_HOME}/netbox/media ${NETBOX_HOME}/netbox/reports ${NETBOX_HOME}/netbox/scripts
chown -R ${NETBOX_USER}:${NETBOX_USER} ${NETBOX_HOME}/netbox
success "디렉토리 생성 완료"

# Step 14: 데이터베이스 마이그레이션
echo ""
echo "Step 14: 데이터베이스 마이그레이션"
echo "----------------------------------------------"
info "데이터베이스 스키마 생성 중..."
sudo -u ${NETBOX_USER} ${NETBOX_HOME}/venv/bin/python ${NETBOX_HOME}/netbox/manage.py migrate --no-input > /dev/null 2>&1
success "데이터베이스 마이그레이션 완료"

# Step 15: 슈퍼유저 생성
echo ""
echo "Step 15: 관리자 계정 생성"
echo "----------------------------------------------"
info "기본 관리자 계정 생성 중..."
sudo -u ${NETBOX_USER} ${NETBOX_HOME}/venv/bin/python ${NETBOX_HOME}/netbox/manage.py shell <<EOF > /dev/null 2>&1
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@localhost.com', 'admin123')
EOF
success "관리자 계정 생성 완료 (Username: admin, Password: admin123)"
warning "보안을 위해 로그인 후 비밀번호를 변경하세요!"

# Step 16: 정적 파일 수집
echo ""
echo "Step 16: 정적 파일 수집"
echo "----------------------------------------------"
info "정적 파일 수집 중..."
sudo -u ${NETBOX_USER} ${NETBOX_HOME}/venv/bin/python ${NETBOX_HOME}/netbox/manage.py collectstatic --no-input > /dev/null 2>&1
success "정적 파일 수집 완료"

# Step 17: Gunicorn 설정
echo ""
echo "Step 17: Gunicorn 설정"
echo "----------------------------------------------"
info "Gunicorn 설정 파일 생성 중..."
cat > ${NETBOX_HOME}/gunicorn.py <<'GUNICORN_EOF'
bind = 'unix:/opt/netbox/netbox.sock'
workers = 4
threads = 3
timeout = 120
accesslog = '/var/log/netbox/gunicorn-access.log'
errorlog = '/var/log/netbox/gunicorn-error.log'
loglevel = 'info'
proc_name = 'netbox'
user = 'netbox'
group = 'netbox'
GUNICORN_EOF
chown ${NETBOX_USER}:${NETBOX_USER} ${NETBOX_HOME}/gunicorn.py
success "Gunicorn 설정 완료"

# Step 18: Systemd 서비스 파일 생성
echo ""
echo "Step 18: Systemd 서비스 설정"
echo "----------------------------------------------"
info "NetBox 서비스 파일 생성 중..."

cat > /etc/systemd/system/netbox.service <<'SERVICE_EOF'
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
SERVICE_EOF

cat > /etc/systemd/system/netbox-rq.service <<'RQ_SERVICE_EOF'
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
RQ_SERVICE_EOF

systemctl daemon-reload
systemctl enable netbox netbox-rq > /dev/null 2>&1
success "Systemd 서비스 설정 완료"

# Step 19: Nginx 설치 및 설정
echo ""
echo "Step 19: Nginx 설치 및 설정"
echo "----------------------------------------------"
if ! command -v nginx &> /dev/null; then
    info "Nginx 설치 중..."
    dnf install -y nginx > /dev/null 2>&1
    success "Nginx 설치 완료"
else
    success "Nginx가 이미 설치되어 있습니다"
fi

info "Nginx 설정 파일 생성 중..."
cat > ${NGINX_CONF} <<NGINX_EOF
upstream netbox {
    server unix:/opt/netbox/netbox.sock fail_timeout=0;
}

server {
    listen 80;
    server_name ${SERVER_NAME};
    client_max_body_size 25m;

    location /static/ {
        alias /opt/netbox/netbox/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location /media/ {
        alias /opt/netbox/netbox/media/;
        expires 7d;
        add_header Cache-Control "public";
    }

    location / {
        proxy_pass http://netbox;
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        proxy_connect_timeout 90;
        proxy_send_timeout 90;
        proxy_read_timeout 90;
    }

    access_log /var/log/nginx/netbox-access.log;
    error_log /var/log/nginx/netbox-error.log;
}
NGINX_EOF

nginx -t > /dev/null 2>&1 || error "Nginx 설정 오류"
systemctl enable nginx > /dev/null 2>&1
success "Nginx 설정 완료"

# Step 20: 방화벽 설정
echo ""
echo "Step 20: 방화벽 설정"
echo "----------------------------------------------"
if systemctl is-active --quiet firewalld; then
    info "방화벽 규칙 추가 중..."
    firewall-cmd --permanent --add-service=http > /dev/null 2>&1
    firewall-cmd --permanent --add-service=https > /dev/null 2>&1
    firewall-cmd --reload > /dev/null 2>&1
    success "방화벽 설정 완료"
else
    warning "Firewalld가 실행되고 있지 않습니다"
fi

# Step 21: SELinux 설정
echo ""
echo "Step 21: SELinux 설정"
echo "----------------------------------------------"
if getenforce | grep -q "Enforcing"; then
    info "SELinux 정책 설정 중..."
    setsebool -P httpd_can_network_connect 1 > /dev/null 2>&1

    # SELinux 컨텍스트 설정
    semanage fcontext -a -t httpd_sys_rw_content_t "/opt/netbox/netbox\.sock" > /dev/null 2>&1 || true
    restorecon -Rv /opt/netbox/ > /dev/null 2>&1

    success "SELinux 설정 완료"
else
    warning "SELinux가 Enforcing 모드가 아닙니다"
fi

# Step 22: 서비스 시작
echo ""
echo "Step 22: 서비스 시작"
echo "----------------------------------------------"
info "NetBox 서비스 시작 중..."
systemctl start netbox netbox-rq
sleep 3

if systemctl is-active --quiet netbox; then
    success "NetBox 서비스 시작 완료"
else
    error "NetBox 서비스 시작 실패. 로그를 확인하세요: journalctl -u netbox -xe"
fi

info "Nginx 서비스 시작 중..."
systemctl start nginx

if systemctl is-active --quiet nginx; then
    success "Nginx 서비스 시작 완료"
else
    error "Nginx 서비스 시작 실패"
fi

# 완료
echo ""
echo "=============================================="
echo "🎉 NetBox 설치가 완료되었습니다!"
echo "=============================================="
echo ""
echo "접속 정보:"
echo "  URL: http://${SERVER_NAME}/"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "⚠️  보안 권장사항:"
echo "  1. 로그인 후 admin 비밀번호를 변경하세요"
echo "  2. SSL/TLS 인증서를 설정하세요 (Let's Encrypt 권장)"
echo "  3. 정기 백업을 설정하세요"
echo ""
echo "서비스 상태 확인:"
echo "  sudo systemctl status netbox"
echo "  sudo systemctl status netbox-rq"
echo "  sudo systemctl status nginx"
echo ""
echo "로그 확인:"
echo "  sudo journalctl -u netbox -f"
echo "  sudo tail -f /var/log/netbox/gunicorn-error.log"
echo ""
echo "자세한 내용은 다음 문서를 참조하세요:"
echo "  - 설치 가이드: docs/SERVER_INSTALL_GUIDE_ROCKY.md"
echo "  - 관리 가이드: docs/SERVER_ADMIN_GUIDE.md"
echo ""
