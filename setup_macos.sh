#!/bin/bash
# NetBox macOS 자동 설치 스크립트
# 사용법: ./setup_macos.sh

set -e  # 에러 발생 시 스크립트 중단

echo "======================================"
echo "NetBox macOS 설치 스크립트"
echo "======================================"
echo ""

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 성공 메시지
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# 경고 메시지
warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 에러 메시지
error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# 정보 메시지
info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# 1. 시스템 확인
echo "Step 1: 시스템 확인"
echo "-----------------------------------"

# macOS 버전 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "이 스크립트는 macOS에서만 실행할 수 있습니다."
fi
success "macOS 시스템 확인 완료"

# 2. Homebrew 확인 및 설치
echo ""
echo "Step 2: Homebrew 확인"
echo "-----------------------------------"

if ! command -v brew &> /dev/null; then
    warning "Homebrew가 설치되어 있지 않습니다. 설치를 시작합니다..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # M1/M2 Mac의 경우 PATH 설정
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew 설치 완료"
else
    success "Homebrew가 이미 설치되어 있습니다."
fi

# 3. Python 3.11 확인 및 설치
echo ""
echo "Step 3: Python 3.11 설치"
echo "-----------------------------------"

if ! command -v python3.11 &> /dev/null; then
    info "Python 3.11 설치 중..."
    brew install python@3.11
    success "Python 3.11 설치 완료"
else
    success "Python 3.11이 이미 설치되어 있습니다."
fi

# Python 버전 확인
PYTHON_VERSION=$(python3.11 --version)
success "Python 버전: $PYTHON_VERSION"

# 4. PostgreSQL 설치
echo ""
echo "Step 4: PostgreSQL 설치"
echo "-----------------------------------"

if ! command -v psql &> /dev/null; then
    info "PostgreSQL 설치 중..."
    brew install postgresql@15
    success "PostgreSQL 설치 완료"
else
    success "PostgreSQL이 이미 설치되어 있습니다."
fi

# PostgreSQL 서비스 시작
info "PostgreSQL 서비스 시작..."
brew services start postgresql@15
sleep 3  # 서비스 시작 대기
success "PostgreSQL 서비스 실행 중"

# 5. Redis 설치
echo ""
echo "Step 5: Redis 설치"
echo "-----------------------------------"

if ! command -v redis-server &> /dev/null; then
    info "Redis 설치 중..."
    brew install redis
    success "Redis 설치 완료"
else
    success "Redis가 이미 설치되어 있습니다."
fi

# Redis 서비스 시작
info "Redis 서비스 시작..."
brew services start redis
sleep 2  # 서비스 시작 대기
success "Redis 서비스 실행 중"

# 6. PostgreSQL 데이터베이스 생성
echo ""
echo "Step 6: PostgreSQL 데이터베이스 설정"
echo "-----------------------------------"

info "NetBox 데이터베이스 생성 중..."

# 데이터베이스가 이미 존재하는지 확인
if psql postgres -tAc "SELECT 1 FROM pg_database WHERE datname='netbox'" | grep -q 1; then
    warning "데이터베이스 'netbox'가 이미 존재합니다. 건너뜁니다."
else
    psql postgres << EOF
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'netbox123';
ALTER DATABASE netbox OWNER TO netbox;
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;
EOF
    success "데이터베이스 및 사용자 생성 완료"
fi

# 7. Python 가상환경 생성
echo ""
echo "Step 7: Python 가상환경 생성"
echo "-----------------------------------"

if [ -d "venv" ]; then
    warning "가상환경이 이미 존재합니다. 건너뜁니다."
else
    info "가상환경 생성 중..."
    python3.11 -m venv venv
    success "가상환경 생성 완료"
fi

# 가상환경 활성화
source venv/bin/activate
success "가상환경 활성화 완료"

# 8. Python 의존성 설치
echo ""
echo "Step 8: Python 패키지 설치"
echo "-----------------------------------"

info "pip 업그레이드 중..."
pip install --upgrade pip --quiet 2>/dev/null || {
    warning "pip 업그레이드 실패. SSL 인증서 문제가 있을 수 있습니다."
}

info "NetBox 의존성 설치 중 (몇 분 소요될 수 있습니다)..."

# 먼저 일반 설치 시도
if ! pip install -r requirements.txt --quiet 2>/dev/null; then
    warning "일반 설치 실패. SSL 인증서 오류가 감지되었습니다."
    echo ""
    echo "SSL 인증서 문제로 인해 설치가 실패했습니다."
    echo "신뢰할 수 있는 호스트를 사용하여 재시도합니다..."
    echo ""

    # trusted-host 플래그로 재시도
    info "신뢰할 수 있는 호스트로 재설치 중..."
    if pip install -r requirements.txt --trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host pypi.python.org; then
        success "Python 패키지 설치 완료 (trusted-host 사용)"
        echo ""
        warning "참고: SSL 인증서 검증을 우회하여 설치했습니다."
        echo "      보안을 위해 SSL_CERTIFICATE_TROUBLESHOOTING.md를 참조하여"
        echo "      올바른 CA 인증서를 설정하는 것을 권장합니다."
        echo ""

        # pip 설정 파일 생성 제안
        echo "향후 설치를 위해 pip 설정 파일을 생성하시겠습니까? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            mkdir -p ~/.pip
            cat > ~/.pip/pip.conf << 'EOF'
[global]
trusted-host = pypi.org
               files.pythonhosted.org
               pypi.python.org
EOF
            success "~/.pip/pip.conf 파일이 생성되었습니다."
            echo "이제 향후 pip 설치 시 SSL 오류가 발생하지 않습니다."
        fi
    else
        error "패키지 설치 실패. SSL_CERTIFICATE_TROUBLESHOOTING.md를 참조하세요."
    fi
else
    success "Python 패키지 설치 완료"
fi

# 9. NetBox 설정 파일 생성
echo ""
echo "Step 9: NetBox 설정 파일 생성"
echo "-----------------------------------"

if [ -f "netbox/netbox/configuration.py" ]; then
    warning "설정 파일이 이미 존재합니다. 건너뜁니다."
else
    info "설정 파일 생성 중..."
    cp netbox/netbox/configuration_example.py netbox/netbox/configuration.py

    # SECRET_KEY 생성
    SECRET_KEY=$(python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

    # macOS의 sed는 다르게 동작하므로 임시 파일 사용
    sed -i '' "s/SECRET_KEY = ''/SECRET_KEY = '$SECRET_KEY'/" netbox/netbox/configuration.py
    sed -i '' "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['localhost', '127.0.0.1', '[::1]']/" netbox/netbox/configuration.py

    success "설정 파일 생성 및 SECRET_KEY 설정 완료"
fi

# 10. 데이터베이스 마이그레이션
echo ""
echo "Step 10: 데이터베이스 마이그레이션"
echo "-----------------------------------"

info "데이터베이스 스키마 생성 중..."
python netbox/manage.py migrate --no-input
success "데이터베이스 마이그레이션 완료"

# 11. 슈퍼유저 생성 (자동)
echo ""
echo "Step 11: 관리자 계정 생성"
echo "-----------------------------------"

info "기본 관리자 계정 생성 중..."
export DJANGO_SUPERUSER_USERNAME=admin
export DJANGO_SUPERUSER_EMAIL=admin@localhost.com
export DJANGO_SUPERUSER_PASSWORD=admin123

python netbox/manage.py createsuperuser --noinput 2>/dev/null || warning "관리자 계정이 이미 존재합니다."
success "관리자 계정 준비 완료"
echo "  Username: admin"
echo "  Password: admin123"

# 12. 정적 파일 수집
echo ""
echo "Step 12: 정적 파일 수집"
echo "-----------------------------------"

info "정적 파일 수집 중..."
python netbox/manage.py collectstatic --no-input --clear > /dev/null
success "정적 파일 수집 완료"

# 13. 설치 완료
echo ""
echo "======================================"
echo "🎉 NetBox 설치가 완료되었습니다!"
echo "======================================"
echo ""
echo "다음 명령어로 NetBox를 실행하세요:"
echo ""
echo "  cd $(pwd)"
echo "  source venv/bin/activate"
echo "  python netbox/manage.py runserver"
echo ""
echo "그런 다음 브라우저에서 http://localhost:8000/ 에 접속하세요."
echo ""
echo "로그인 정보:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "테스트 데이터 업로드 가이드:"
echo "  - MACBOOK_INSTALL_GUIDE.md의 'Step 6: 테스트 데이터 업로드' 참조"
echo "  - idc_scenario/README.md 참조"
echo ""
echo "문제 해결 가이드:"
echo "  - MACBOOK_INSTALL_GUIDE.md의 '문제 해결' 섹션"
echo "  - SSL_CERTIFICATE_TROUBLESHOOTING.md (SSL 인증서 오류 시)"
echo ""
