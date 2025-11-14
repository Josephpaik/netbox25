#!/bin/bash
# NetBox macOS 자동 설치 스크립트
# 사용법: ./setup_macos.sh
# 버전: 2.0

set -e  # 에러 발생 시 스크립트 중단

echo "======================================"
echo "NetBox macOS 설치 스크립트 v2.0"
echo "======================================"
echo ""

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# 헤더 메시지
header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# 설치 디렉토리 저장
INSTALL_DIR=$(pwd)
NETBOX_DIR="${INSTALL_DIR}/netbox"
VENV_DIR="${INSTALL_DIR}/venv"
CONFIG_FILE="${NETBOX_DIR}/netbox/configuration.py"

# 1. 시스템 확인
header "Step 1: 시스템 확인"

# macOS 버전 확인
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "이 스크립트는 macOS에서만 실행할 수 있습니다."
fi

# 시스템 정보 출력
info "Operating System: $(sw_vers -productName) $(sw_vers -productVersion)"
info "Architecture: $(uname -m)"
success "macOS 시스템 확인 완료"

# 2. Homebrew 확인 및 설치
header "Step 2: Homebrew 확인 및 설치"

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
header "Step 3: Python 3.11 설치"

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
header "Step 4: PostgreSQL 설치"

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
header "Step 5: Redis 설치"

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
header "Step 6: PostgreSQL 데이터베이스 설정"

info "NetBox 데이터베이스 생성 중..."

# PostgreSQL이 실행 중인지 확인
if ! pgrep -x postgres > /dev/null; then
    warning "PostgreSQL이 실행되고 있지 않습니다. 서비스를 시작합니다..."
    brew services start postgresql@15
    sleep 5
fi

# 데이터베이스가 이미 존재하는지 확인
if psql postgres -tAc "SELECT 1 FROM pg_database WHERE datname='netbox'" 2>/dev/null | grep -q 1; then
    warning "데이터베이스 'netbox'가 이미 존재합니다."

    # 사용자 권한 확인
    info "데이터베이스 권한 확인 중..."
else
    info "새 데이터베이스 및 사용자 생성 중..."
    psql postgres << EOF
-- 기존 사용자가 있다면 삭제 (에러 무시)
DROP USER IF EXISTS netbox;

-- 데이터베이스 생성
CREATE DATABASE netbox ENCODING 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';

-- 사용자 생성
CREATE USER netbox WITH PASSWORD 'netbox123';

-- 데이터베이스 소유권 부여
ALTER DATABASE netbox OWNER TO netbox;

-- 권한 부여
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;

-- PostgreSQL 13+ 호환성을 위한 추가 권한
\c netbox
GRANT ALL ON SCHEMA public TO netbox;
EOF
    success "데이터베이스 및 사용자 생성 완료"
fi

# 데이터베이스 연결 테스트
info "데이터베이스 연결 테스트 중..."
if PGPASSWORD=netbox123 psql -h localhost -U netbox -d netbox -c "SELECT version();" > /dev/null 2>&1; then
    success "데이터베이스 연결 성공"
else
    error "데이터베이스 연결 실패. PostgreSQL 설정을 확인하세요."
fi

# 7. Python 가상환경 생성
header "Step 7: Python 가상환경 생성"

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
header "Step 8: Python 패키지 설치"

info "pip 업그레이드 중..."
pip install --upgrade pip --quiet

info "NetBox 의존성 설치 중 (몇 분 소요될 수 있습니다)..."
pip install -r requirements.txt --quiet
success "Python 패키지 설치 완료"

# 9. NetBox 설정 파일 생성
header "Step 9: NetBox 설정 파일 생성"

if [ -f "${CONFIG_FILE}" ]; then
    warning "설정 파일이 이미 존재합니다."

    # SECRET_KEY가 기본값인지 확인
    if grep -q "development-secret-key-change-this-in-production-use-setup-script" "${CONFIG_FILE}"; then
        info "개발용 SECRET_KEY 발견. 새로운 SECRET_KEY 생성 중..."

        # 가상환경에서 Django 사용하여 SECRET_KEY 생성
        NEW_SECRET_KEY=$(source "${VENV_DIR}/bin/activate" && python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

        # macOS의 sed는 -i 다음에 ''가 필요
        sed -i '' "s/development-secret-key-change-this-in-production-use-setup-script/$NEW_SECRET_KEY/" "${CONFIG_FILE}"
        success "새로운 SECRET_KEY 생성 완료"
    else
        info "SECRET_KEY가 이미 설정되어 있습니다."
    fi
else
    info "설정 파일이 없습니다. configuration.py를 확인하세요."

    # configuration.py가 이미 있어야 함 (repository에 포함)
    if [ ! -f "${CONFIG_FILE}" ]; then
        # 백업으로 example에서 복사
        warning "configuration.py를 찾을 수 없습니다. configuration_example.py에서 복사합니다..."
        cp "${NETBOX_DIR}/netbox/configuration_example.py" "${CONFIG_FILE}"

        # SECRET_KEY 생성
        info "SECRET_KEY 생성 중..."
        NEW_SECRET_KEY=$(source "${VENV_DIR}/bin/activate" && python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")

        # 기본 설정 적용
        sed -i '' "s/SECRET_KEY = ''/SECRET_KEY = '$NEW_SECRET_KEY'/" "${CONFIG_FILE}"
        sed -i '' "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['localhost', '127.0.0.1', '[::1]']/" "${CONFIG_FILE}"
        sed -i '' "s/'USER': ''/'USER': 'netbox'/" "${CONFIG_FILE}"
        sed -i '' "s/'PASSWORD': ''/'PASSWORD': 'netbox123'/" "${CONFIG_FILE}"
        sed -i '' "s/DEBUG = False/DEBUG = True/" "${CONFIG_FILE}"

        success "설정 파일 생성 완료"
    else
        # SECRET_KEY만 업데이트
        info "SECRET_KEY 생성 중..."
        NEW_SECRET_KEY=$(source "${VENV_DIR}/bin/activate" && python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())")
        sed -i '' "s/development-secret-key-change-this-in-production-use-setup-script/$NEW_SECRET_KEY/" "${CONFIG_FILE}"
        success "SECRET_KEY 설정 완료"
    fi
fi

# 설정 파일 검증
info "설정 파일 검증 중..."
if grep -q "SECRET_KEY = ''" "${CONFIG_FILE}"; then
    error "SECRET_KEY가 설정되지 않았습니다."
fi
success "설정 파일 검증 완료"

# 10. 데이터베이스 마이그레이션
header "Step 10: 데이터베이스 마이그레이션"

info "데이터베이스 스키마 생성 중..."
if python "${NETBOX_DIR}/manage.py" migrate --no-input; then
    success "데이터베이스 마이그레이션 완료"
else
    error "데이터베이스 마이그레이션 실패. 로그를 확인하세요."
fi

# 마이그레이션 상태 확인
info "마이그레이션 상태 확인 중..."
python "${NETBOX_DIR}/manage.py" showmigrations --list | tail -5

# 11. 슈퍼유저 생성 (자동)
header "Step 11: 관리자 계정 생성"

info "기본 관리자 계정 생성 중..."
export DJANGO_SUPERUSER_USERNAME=admin
export DJANGO_SUPERUSER_EMAIL=admin@localhost.com
export DJANGO_SUPERUSER_PASSWORD=admin123

if python "${NETBOX_DIR}/manage.py" createsuperuser --noinput 2>/dev/null; then
    success "관리자 계정 생성 완료"
    info "  Username: admin"
    info "  Email: admin@localhost.com"
    info "  Password: admin123"
else
    warning "관리자 계정이 이미 존재합니다."
    info "  기존 계정을 사용하세요."
fi

# 12. 정적 파일 수집
header "Step 12: 정적 파일 수집"

info "정적 파일 수집 중..."
if python "${NETBOX_DIR}/manage.py" collectstatic --no-input --clear > /dev/null 2>&1; then
    success "정적 파일 수집 완료"
else
    warning "정적 파일 수집 중 경고가 발생했습니다 (무시 가능)"
fi

# 13. 설치 검증
header "Step 13: 설치 검증"

info "NetBox 설치 검증 중..."

# Django 설정 확인
if python "${NETBOX_DIR}/manage.py" check --deploy 2>/dev/null; then
    success "Django 설정 검증 완료"
else
    warning "일부 설정 검증 실패 (개발 환경에서는 정상)"
fi

# 서비스 상태 확인
info "서비스 상태 확인 중..."
echo ""
echo "PostgreSQL 상태:"
brew services list | grep postgresql || echo "  서비스 정보를 확인할 수 없습니다"
echo ""
echo "Redis 상태:"
brew services list | grep redis || echo "  서비스 정보를 확인할 수 없습니다"
echo ""

# 14. 설치 완료
header "🎉 NetBox 설치가 완료되었습니다!"

echo ""
echo -e "${GREEN}======================================"
echo "설치 요약"
echo -e "======================================${NC}"
echo ""
echo "설치 위치: ${INSTALL_DIR}"
echo "NetBox 디렉토리: ${NETBOX_DIR}"
echo "가상환경: ${VENV_DIR}"
echo "설정 파일: ${CONFIG_FILE}"
echo ""
echo -e "${BLUE}======================================"
echo "다음 단계"
echo -e "======================================${NC}"
echo ""
echo "1. NetBox 서버 시작:"
echo ""
echo -e "   ${YELLOW}cd ${INSTALL_DIR}${NC}"
echo -e "   ${YELLOW}source venv/bin/activate${NC}"
echo -e "   ${YELLOW}python netbox/manage.py runserver${NC}"
echo ""
echo "2. 브라우저에서 접속:"
echo ""
echo -e "   ${BLUE}http://localhost:8000/${NC}"
echo ""
echo "3. 로그인 정보:"
echo ""
echo -e "   Username: ${GREEN}admin${NC}"
echo -e "   Password: ${GREEN}admin123${NC}"
echo ""
echo -e "${BLUE}======================================"
echo "추가 옵션"
echo -e "======================================${NC}"
echo ""
echo "백그라운드 작업 처리 (선택사항):"
echo -e "   ${YELLOW}python netbox/manage.py rqworker${NC}"
echo ""
echo "테스트 데이터 로드:"
echo "   - Web UI를 통한 CSV 가져오기"
echo "   - idc_scenario/README.md 참조"
echo "   - idc_scenario/upload_script.py 사용"
echo ""
echo "관련 문서:"
echo "   - MACBOOK_INSTALL_GUIDE.md (한글 설치 가이드)"
echo "   - QUICKSTART_CHECKLIST.md (빠른 시작 체크리스트)"
echo "   - idc_scenario/USAGE_GUIDE.md (테스트 데이터 가이드)"
echo ""
echo -e "${GREEN}======================================"
echo "문제 해결"
echo -e "======================================${NC}"
echo ""
echo "서비스 재시작:"
echo -e "   ${YELLOW}brew services restart postgresql@15${NC}"
echo -e "   ${YELLOW}brew services restart redis${NC}"
echo ""
echo "데이터베이스 초기화 (주의!):"
echo -e "   ${YELLOW}python netbox/manage.py flush${NC}"
echo ""
echo "더 많은 도움말:"
echo "   - MACBOOK_INSTALL_GUIDE.md의 '문제 해결' 섹션"
echo "   - https://docs.netbox.dev/"
echo ""
echo -e "${GREEN}설치를 완료했습니다! 즐거운 NetBox 사용 되세요! 🚀${NC}"
echo ""
