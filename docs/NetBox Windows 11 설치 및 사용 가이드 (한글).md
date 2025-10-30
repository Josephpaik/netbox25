# NetBox Windows 11 설치 및 사용 가이드 (한글)
WINDOWS11_INSTALLATION_TUTORIAL_KR.md  2025.10.30

## 목차
- [소개](#소개)
- [시스템 요구사항](#시스템-요구사항)
- [설치 방법 선택](#설치-방법-선택)
- [방법 1: Docker Desktop 사용 (권장)](#방법-1-docker-desktop-사용-권장)
- [방법 2: WSL2 사용](#방법-2-wsl2-사용)
- [주요 기능 사용 가이드](#주요-기능-사용-가이드)
- [문제 해결](#문제-해결)

---

## 소개

**NetBox**는 네트워크 인프라 관리를 위한 오픈소스 웹 애플리케이션입니다. 이 가이드는 Windows 11에서 NetBox를 설치하고 주요 기능을 테스트하는 방법을 단계별로 안내합니다.

**설치 시간**: 약 30-60분
**난이도**: 중급 (명령줄 사용 경험 필요)

---

## 시스템 요구사항

- **운영체제**: Windows 11 (64-bit)
- **프로세서**: 64-bit 프로세서 (가상화 지원 필요)
- **메모리**: 최소 8GB RAM 권장
- **디스크 공간**: 최소 20GB 여유 공간
- **네트워크**: 인터넷 연결 필요

**NetBox 요구사항**:
- **Python**: 3.10 이상
- **PostgreSQL**: 14 이상
- **Redis**: 4.0 이상

---

## 설치 방법 선택

Windows 11에서 NetBox를 설치하는 3가지 방법이 있습니다:

### 1. Docker Desktop 사용 ⭐ **권장**
- **장점**: 가장 간단하고 빠른 설치, 의존성 관리 자동화
- **단점**: Docker 개념 이해 필요
- **추천 대상**: 빠르게 시작하고 싶은 사용자

### 2. WSL2 (Windows Subsystem for Linux) 사용
- **장점**: Linux 환경에서 네이티브로 실행, 높은 성능
- **단점**: WSL2 설정 필요, Linux 명령어 지식 필요
- **추천 대상**: Linux 환경에 익숙한 사용자

### 3. 네이티브 Windows 설치 ❌ **권장하지 않음**
- **장점**: Windows 환경에서 직접 실행
- **단점**: 복잡한 설정, 많은 문제 발생 가능
- **추천 대상**: 특별한 이유가 있는 경우만

이 가이드에서는 **방법 1 (Docker Desktop)**과 **방법 2 (WSL2)**를 다룹니다.

---

## 방법 1: Docker Desktop 사용 (권장)

Docker를 사용하면 모든 의존성이 포함된 컨테이너로 NetBox를 실행할 수 있습니다.

### 1.1 Docker Desktop 설치

#### 1.1.1 시스템 요구사항 확인

1. **Windows + R** 키를 눌러 `msinfo32` 실행
2. **시스템 요약**에서 확인:
   - **시스템 종류**: x64 기반 PC
   - **Hyper-V 요구 사항**: 모두 '예'로 표시되어야 함

#### 1.1.2 WSL 2 활성화

Docker Desktop은 WSL 2를 사용합니다. 먼저 WSL 2를 활성화합니다.

**PowerShell을 관리자 권한으로 실행**:

```powershell
# WSL 및 가상 머신 플랫폼 기능 활성화
wsl --install

# 컴퓨터 재시작 (필수)
```

**재시작 후**:

```powershell
# WSL 버전 확인
wsl --list --verbose

# WSL 2로 기본 버전 설정
wsl --set-default-version 2
```

#### 1.1.3 Docker Desktop 다운로드 및 설치

1. **Docker Desktop 다운로드**: https://www.docker.com/products/docker-desktop/
2. 다운로드한 `Docker Desktop Installer.exe` 실행
3. 설치 옵션:
   - ✅ **Use WSL 2 instead of Hyper-V** (권장)
   - ✅ **Add shortcut to desktop**
4. **Install** 클릭
5. 설치 완료 후 **재시작**

#### 1.1.4 Docker Desktop 시작 및 확인

1. **Docker Desktop** 실행
2. **Accept** (서비스 약관 동의)
3. Docker Desktop이 시작될 때까지 대기 (좌측 하단에 초록색 표시)

**PowerShell에서 확인**:

```powershell
# Docker 버전 확인
docker --version
# 출력 예: Docker version 24.0.7, build afdd53b

# Docker Compose 버전 확인
docker compose version
# 출력 예: Docker Compose version v2.23.0

# Docker 작동 테스트
docker run hello-world
# 출력: Hello from Docker!
```

---

### 1.2 NetBox Docker 설치

#### 1.2.1 Git 설치 (필요한 경우)

Git이 없다면 설치합니다:

1. **Git 다운로드**: https://git-scm.com/download/win
2. 설치 후 **PowerShell 재시작**

#### 1.2.2 NetBox Docker 저장소 클론

**PowerShell 또는 명령 프롬프트**:

```powershell
# 작업 디렉토리로 이동 (예: 사용자 문서 폴더)
cd $HOME\Documents

# NetBox Docker 저장소 클론
git clone https://github.com/netbox-community/netbox-docker.git
cd netbox-docker

# 디렉토리 확인
ls
```

#### 1.2.3 환경 설정

```powershell
# 환경 변수 파일 생성
cp env\netbox.env.example env\netbox.env
cp env\postgres.env.example env\postgres.env
cp env\redis.env.example env\redis.env
cp env\redis-cache.env.example env\redis-cache.env

# docker-compose 오버라이드 파일 생성
cp docker-compose.override.yml.example docker-compose.override.yml
```

**env\netbox.env 파일 편집** (메모장이나 VS Code 사용):

```bash
# SECRET_KEY 생성
# PowerShell에서 랜덤 키 생성:
# -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 50 | % {[char]$_})

SECRET_KEY=your-generated-secret-key-here
ALLOWED_HOSTS=*
```

**env\postgres.env 파일 편집**:

```bash
POSTGRES_DB=netbox
POSTGRES_USER=netbox
POSTGRES_PASSWORD=netbox123
```

#### 1.2.4 NetBox Docker 실행

```powershell
# Docker 컨테이너 빌드 및 실행 (첫 실행 시 5-10분 소요)
docker compose up -d

# 컨테이너 상태 확인
docker compose ps

# 로그 확인 (문제 발생 시)
docker compose logs -f netbox
```

**예상 출력**:
```
NAME                          STATUS
netbox-docker-netbox-1        Up (healthy)
netbox-docker-netbox-worker-1 Up (healthy)
netbox-docker-postgres-1      Up (healthy)
netbox-docker-redis-1         Up (healthy)
netbox-docker-redis-cache-1   Up (healthy)
```

#### 1.2.5 슈퍼유저(관리자) 생성

```powershell
# 슈퍼유저 생성 (컨테이너 내부에서 실행)
docker compose exec netbox python manage.py createsuperuser

# 입력 프롬프트:
# Username: admin
# Email address: admin@example.com
# Password: admin123
# Password (again): admin123
# Superuser created successfully.
```

#### 1.2.6 웹 브라우저로 접속

웹 브라우저를 열고:

```
http://localhost:8000
```

**로그인**:
- **Username**: `admin`
- **Password**: `admin123`

**성공!** 🎉 NetBox 대시보드가 표시됩니다!

---

### 1.3 Docker 명령어 요약

```powershell
# NetBox 시작
docker compose up -d

# NetBox 중지
docker compose stop

# NetBox 재시작
docker compose restart

# NetBox 완전 종료 및 제거
docker compose down

# NetBox 로그 확인
docker compose logs -f netbox

# 데이터베이스 백업
docker compose exec -T postgres pg_dump -U netbox netbox > backup.sql

# 데이터베이스 복원
cat backup.sql | docker compose exec -T postgres psql -U netbox netbox

# 컨테이너 내부 접속 (디버깅)
docker compose exec netbox bash
```

---

### 1.4 Docker 버전 업데이트

```powershell
# 저장소 업데이트
git pull

# 새 이미지 다운로드
docker compose pull

# 컨테이너 재생성
docker compose up -d
```

---

## 방법 2: WSL2 사용

WSL2를 사용하면 Windows에서 실제 Linux 환경을 실행할 수 있습니다.

### 2.1 WSL2 및 Ubuntu 설치

#### 2.1.1 WSL2 설치

**PowerShell을 관리자 권한으로 실행**:

```powershell
# WSL 설치 (Ubuntu가 기본으로 설치됨)
wsl --install

# 컴퓨터 재시작
```

**재시작 후, Ubuntu 자동 실행**:
- **Username** 입력: 원하는 사용자 이름 (예: `netbox`)
- **Password** 입력: 비밀번호 설정

#### 2.1.2 Ubuntu 업데이트

**Ubuntu 터미널**:

```bash
# 패키지 목록 업데이트
sudo apt update

# 패키지 업그레이드
sudo apt upgrade -y
```

---

### 2.2 필수 패키지 설치

```bash
# Python 3.11 설치
sudo apt install -y python3.11 python3.11-venv python3.11-dev python3-pip

# PostgreSQL 설치
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Redis 설치
sudo apt install -y redis-server

# 기타 필수 도구
sudo apt install -y git build-essential libxml2-dev libxslt1-dev libffi-dev libssl-dev zlib1g-dev
```

---

### 2.3 PostgreSQL 설정

```bash
# PostgreSQL 서비스 시작
sudo service postgresql start

# PostgreSQL 자동 시작 설정
sudo systemctl enable postgresql

# PostgreSQL 사용자 전환
sudo -u postgres psql

# PostgreSQL 프롬프트에서:
```

```sql
-- NetBox용 데이터베이스 생성
CREATE DATABASE netbox;

-- NetBox용 사용자 생성
CREATE USER netbox WITH PASSWORD 'netbox123';

-- 권한 부여
ALTER DATABASE netbox OWNER TO netbox;
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;

-- 종료
\q
```

---

### 2.4 Redis 설정

```bash
# Redis 서비스 시작
sudo service redis-server start

# Redis 작동 확인
redis-cli ping
# 응답: PONG
```

---

### 2.5 NetBox 설치

#### 2.5.1 소스코드 다운로드

```bash
# 작업 디렉토리로 이동
cd ~

# NetBox 저장소 클론
git clone https://github.com/netbox-community/netbox.git
cd netbox

# 최신 stable 버전으로 체크아웃
git checkout master
```

#### 2.5.2 Python 가상환경 생성

```bash
# 가상환경 생성
python3.11 -m venv venv

# 가상환경 활성화
source venv/bin/activate

# 프롬프트가 (venv)로 시작하면 성공
```

#### 2.5.3 Python 의존성 설치

```bash
# pip 업그레이드
pip install --upgrade pip

# NetBox 의존성 설치 (5-10분 소요)
pip install -r requirements.txt

# 설치 확인
pip list | grep Django
# Django가 목록에 나타나면 성공
```

---

### 2.6 NetBox 설정

#### 2.6.1 설정 파일 생성

```bash
# netbox 디렉토리로 이동
cd netbox

# 설정 예제 파일 복사
cp netbox/configuration_example.py netbox/configuration.py
```

#### 2.6.2 SECRET_KEY 생성

```bash
# SECRET_KEY 생성
python3 generate_secret_key.py

# 출력된 키를 복사해둡니다
```

#### 2.6.3 설정 파일 편집

```bash
# nano 에디터로 설정 파일 열기
nano netbox/configuration.py

# 또는 Windows의 텍스트 에디터 사용:
# notepad.exe netbox/configuration.py
```

**다음 설정 수정**:

```python
# 1. ALLOWED_HOSTS
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '::1', '*']

# 2. DATABASE
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'netbox',
        'USER': 'netbox',
        'PASSWORD': 'netbox123',
        'HOST': 'localhost',
        'PORT': '',
        'CONN_MAX_AGE': 300,
    }
}

# 3. REDIS (기본값 유지)
# 변경사항 없음

# 4. SECRET_KEY
SECRET_KEY = 'your-generated-secret-key'  # 2.6.2단계에서 생성한 키

# 5. DEBUG 모드 (개발/테스트용)
DEBUG = True

# 6. TIME_ZONE (선택사항)
TIME_ZONE = 'Asia/Seoul'
```

**저장하고 종료** (nano: Ctrl+X → Y → Enter)

#### 2.6.4 설정 검증

```bash
# NetBox 설정 확인
python3 manage.py check

# 성공 메시지:
# System check identified no issues (0 silenced).
```

---

### 2.7 데이터베이스 초기화

```bash
# 데이터베이스 마이그레이션 (2-3분 소요)
python3 manage.py migrate

# 슈퍼유저 생성
python3 manage.py createsuperuser
# Username: admin
# Email: admin@example.com
# Password: admin123
# Password (again): admin123

# 정적 파일 수집
python3 manage.py collectstatic --noinput
```

---

### 2.8 NetBox 실행

#### 2.8.1 개발 서버 시작

**터미널 1 (Ubuntu)**:

```bash
cd ~/netbox/netbox
source ../venv/bin/activate
python3 manage.py runserver 0.0.0.0:8000
```

#### 2.8.2 백그라운드 워커 시작

**새 Ubuntu 터미널 열기** (PowerShell에서 `wsl` 명령):

```bash
cd ~/netbox/netbox
source ../venv/bin/activate
python3 manage.py rqworker
```

#### 2.8.3 Windows에서 접속

웹 브라우저 열기:

```
http://localhost:8000
```

**로그인**:
- **Username**: `admin`
- **Password**: `admin123`

**성공!** 🎉

---

### 2.9 WSL2 자동 시작 스크립트 (선택사항)

매번 수동으로 서비스를 시작하기 번거롭다면 시작 스크립트를 만듭니다.

**~/start-netbox.sh 파일 생성**:

```bash
nano ~/start-netbox.sh
```

**내용**:

```bash
#!/bin/bash

# PostgreSQL 시작
sudo service postgresql start

# Redis 시작
sudo service redis-server start

# 가상환경 활성화
source ~/netbox/venv/bin/activate

# NetBox 디렉토리로 이동
cd ~/netbox/netbox

echo "NetBox 시작 준비 완료!"
echo ""
echo "다음 명령어로 서버를 시작하세요:"
echo "  python3 manage.py runserver 0.0.0.0:8000"
echo ""
echo "새 터미널에서 워커를 시작하세요:"
echo "  cd ~/netbox/netbox && source ../venv/bin/activate"
echo "  python3 manage.py rqworker"
```

**실행 권한 부여**:

```bash
chmod +x ~/start-netbox.sh
```

**사용법**:

```bash
# WSL 터미널에서
~/start-netbox.sh
```

---

## 주요 기능 사용 가이드

NetBox의 주요 기능들을 테스트해봅니다. (Docker 및 WSL 공통)

### 1. 사이트(Site) 생성하기

#### 단계:

1. **로그인**: `http://localhost:8000` (admin / admin123)
2. **상단 메뉴**: `Organization` → `Sites` 클릭
3. **오른쪽 상단**: `+ Add` 버튼 클릭
4. **정보 입력**:
   - **Name**: `Seoul DC1`
   - **Slug**: `seoul-dc1` (자동 생성)
   - **Status**: `Active` 선택
   - **Description**: `서울 본사 데이터센터`
5. **Create** 버튼 클릭

**결과**: 첫 번째 사이트 생성 완료! ✅

---

### 2. 제조사(Manufacturer) 생성하기

1. **상단 메뉴**: `Devices` → `Device Types` → `Manufacturers`
2. **+ Add** 버튼 클릭
3. **정보 입력**:
   - **Name**: `Cisco`
   - **Slug**: `cisco` (자동)
   - **Description**: `Cisco Systems, Inc.`
4. **Create** 클릭

**추가 제조사**:
- `Juniper Networks`
- `Arista Networks`

---

### 3. 장비 역할(Device Role) 생성하기

1. **Devices** → **Device Roles**
2. **+ Add** 클릭
3. **정보 입력**:
   - **Name**: `Core Router`
   - **Slug**: `core-router`
   - **Color**: 빨강 선택
   - **Description**: `코어 라우터`
4. **Create** 클릭

**추가 역할**:
- `Access Switch` (파랑)
- `Distribution Switch` (초록)
- `Firewall` (주황)

---

### 4. 장비 타입(Device Type) 생성하기

1. **Devices** → **Device Types**
2. **+ Add** 클릭
3. **정보 입력**:
   - **Manufacturer**: `Cisco` 선택
   - **Model**: `Catalyst 9300-48P`
   - **Slug**: `catalyst-9300-48p`
   - **U Height**: `1`
   - **Part Number**: `C9300-48P`
4. **Create** 클릭

---

### 5. 랙(Rack) 생성하기

1. **Devices** → **Racks**
2. **+ Add** 클릭
3. **정보 입력**:
   - **Site**: `Seoul DC1`
   - **Name**: `Rack-A01`
   - **Status**: `Active`
   - **Width**: `19 inches`
   - **Height (U)**: `42`
4. **Create** 클릭

**결과**: 랙 시각화 화면을 볼 수 있습니다! 🔲

---

### 6. 장비(Device) 생성하기

1. **Devices** → **Devices**
2. **+ Add** 클릭
3. **정보 입력**:
   - **Name**: `seoul-core-rt01`
   - **Device Role**: `Core Router`
   - **Device Type**: `Catalyst 9300-48P`
   - **Site**: `Seoul DC1`
   - **Rack**: `Rack-A01`
   - **Position**: `40`
   - **Face**: `Front`
   - **Status**: `Active`
   - **Serial Number**: `FCH2XXX1234`
4. **Create** 클릭

---

### 7. 인터페이스(Interface) 추가하기

1. **Devices** 목록에서 `seoul-core-rt01` 클릭
2. **Interfaces** 탭 클릭
3. **+ Add Interface** 클릭
4. **정보 입력**:
   - **Name**: `GigabitEthernet0/0/0`
   - **Type**: `1000BASE-T (1GE)`
   - **Enabled**: ✅ 체크
   - **Description**: `Uplink to Distribution`
5. **Create** 클릭

---

### 8. IP 주소 할당하기

#### 8.1 프리픽스 생성:

1. **IPAM** → **Prefixes**
2. **+ Add** 클릭
3. **정보 입력**:
   - **Prefix**: `10.0.0.0/24`
   - **Status**: `Active`
   - **Site**: `Seoul DC1`
4. **Create** 클릭

#### 8.2 IP 주소 생성:

1. **IPAM** → **IP Addresses**
2. **+ Add** 클릭
3. **정보 입력**:
   - **IP Address**: `10.0.0.1/24`
   - **Status**: `Active`
   - **DNS Name**: `seoul-core-rt01.example.com`
4. **Create** 클릭

#### 8.3 IP를 인터페이스에 할당:

1. 생성한 IP `10.0.0.1/24` 클릭 → **Edit**
2. **Assigned Object**:
   - **Device**: `seoul-core-rt01`
   - **Interface**: `GigabitEthernet0/0/0`
3. **Save** 클릭

4. **Devices** → `seoul-core-rt01` → **Edit**
5. **Primary IPv4**: `10.0.0.1/24` 선택
6. **Save** 클릭

**결과**: 장비에 IP 주소 할당 완료! 🌐

---

### 9. VLAN 생성하기

1. **IPAM** → **VLANs**
2. **+ Add** 클릭
3. **정보 입력**:
   - **Site**: `Seoul DC1`
   - **VLAN ID**: `100`
   - **Name**: `Management`
   - **Status**: `Active`
4. **Create** 클릭

**추가 VLAN**:
- **VLAN 200** - `Servers`
- **VLAN 300** - `Voice`

---

### 10. REST API 사용하기

#### API 토큰 생성:

1. **우측 상단 사용자 아이콘** → **API Tokens**
2. **+ Add Token** 클릭
3. **Write enabled** ✅ 체크
4. **Create** 클릭
5. **토큰 복사** (예: `abc123def456...`)

#### PowerShell에서 API 테스트:

```powershell
# 모든 사이트 조회
$token = "your-token-here"
$headers = @{
    "Authorization" = "Token $token"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -Uri "http://localhost:8000/api/dcim/sites/" -Headers $headers

# 특정 장비 조회
Invoke-RestMethod -Uri "http://localhost:8000/api/dcim/devices/?name=seoul-core-rt01" -Headers $headers

# 새 사이트 생성
$body = @{
    name = "Busan DC1"
    slug = "busan-dc1"
    status = "active"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/dcim/sites/" -Method Post -Headers $headers -Body $body
```

#### API 문서 확인:

브라우저에서:
```
http://localhost:8000/api/docs/
```

**결과**: Swagger UI로 전체 API 문서 확인! 📚

---

### 11. GraphQL API 사용하기

1. 브라우저에서 접속: `http://localhost:8000/graphql/`
2. 왼쪽 패널에 쿼리 입력:

```graphql
query {
  site_list {
    id
    name
    status
    description
  }
}
```

3. **▶ 실행 버튼** 클릭
4. 오른쪽 패널에 JSON 결과 확인

---

### 12. CSV 일괄 가져오기 (Bulk Import)

1. **Devices** → **Devices** 목록
2. **Import** 버튼 클릭
3. **CSV 데이터 입력**:

```csv
name,device_role,device_type,site,status
seoul-access-sw02,access-switch,catalyst-9300-48p,seoul-dc1,active
seoul-access-sw03,access-switch,catalyst-9300-48p,seoul-dc1,active
seoul-access-sw04,access-switch,catalyst-9300-48p,seoul-dc1,active
```

4. **Submit** → **Import** 클릭

**결과**: 3개 장비가 한 번에 생성! ⚡

---

### 13. 다크 모드 전환

1. **우측 상단 사용자 아이콘** → **Preferences**
2. **Color Mode**: `Dark` 선택
3. **Update** 클릭

**결과**: 다크 모드 활성화! 🌙

---

## 문제 해결

### Docker 관련 문제

#### 문제 1: Docker Desktop이 시작되지 않음

**증상**: Docker Desktop 실행 시 오류

**해결책**:

```powershell
# WSL 재시작
wsl --shutdown

# Docker Desktop 재시작
```

---

#### 문제 2: 포트 8000이 사용 중

**증상**: `Error: Port 8000 is already in use`

**해결책**:

```powershell
# 포트 사용 중인 프로세스 확인
netstat -ano | findstr :8000

# 프로세스 종료 (PID 확인 후)
taskkill /PID <PID> /F

# 또는 다른 포트 사용
# docker-compose.override.yml 파일에서 포트 변경:
# ports:
#   - "8080:8080"
```

---

#### 문제 3: 컨테이너가 Unhealthy 상태

**증상**: `docker compose ps`에서 unhealthy 표시

**해결책**:

```powershell
# 컨테이너 로그 확인
docker compose logs netbox

# 컨테이너 재시작
docker compose restart netbox

# 완전히 재빌드
docker compose down
docker compose up -d --build
```

---

### WSL2 관련 문제

#### 문제 4: PostgreSQL 연결 오류

**증상**: `could not connect to server`

**해결책**:

```bash
# PostgreSQL 서비스 상태 확인
sudo service postgresql status

# PostgreSQL 시작
sudo service postgresql start

# 연결 테스트
psql -U netbox -d netbox -h localhost
```

---

#### 문제 5: Redis 연결 오류

**증상**: `Redis connection error`

**해결책**:

```bash
# Redis 서비스 상태 확인
sudo service redis-server status

# Redis 시작
sudo service redis-server start

# 연결 테스트
redis-cli ping
```

---

#### 문제 6: WSL에서 Windows 파일 시스템 접근 느림

**증상**: WSL에서 `/mnt/c/` 경로 사용 시 매우 느림

**해결책**:

```bash
# WSL 홈 디렉토리 사용 (권장)
cd ~

# Windows 파일 시스템 대신 WSL 파일 시스템에 NetBox 설치
# Windows에서 WSL 파일에 접근: \\wsl$\Ubuntu\home\<username>\netbox
```

---

#### 문제 7: 메모리 부족 오류

**증상**: WSL에서 메모리 부족 메시지

**해결책**:

**C:\Users\<사용자명>\.wslconfig 파일 생성**:

```ini
[wsl2]
memory=4GB
processors=2
swap=2GB
```

**적용**:

```powershell
# WSL 재시작
wsl --shutdown
```

---

### 일반적인 문제

#### 문제 8: 정적 파일이 로드되지 않음

**증상**: CSS/JavaScript가 적용되지 않음

**해결책** (WSL):

```bash
cd ~/netbox/netbox
source ../venv/bin/activate
python3 manage.py collectstatic --clear --noinput
```

**해결책** (Docker):

```powershell
docker compose exec netbox python manage.py collectstatic --noinput
```

---

#### 문제 9: 방화벽 차단

**증상**: 다른 컴퓨터에서 접속 불가

**해결책**:

1. **Windows Defender 방화벽** 열기
2. **고급 설정** → **인바운드 규칙**
3. **새 규칙** → **포트** → **TCP 8000** 허용

---

## Windows에서 유용한 팁

### 1. Windows Terminal 사용

**Windows Terminal** 설치 (Microsoft Store):
- 여러 탭 지원
- 향상된 UI
- WSL, PowerShell, CMD 통합

### 2. VS Code와 WSL 통합

**VS Code 설치**: https://code.visualstudio.com/

**WSL 확장 설치**:
1. VS Code 실행
2. 확장 탭에서 "WSL" 검색
3. "WSL" (Microsoft) 설치

**WSL에서 VS Code 열기**:

```bash
cd ~/netbox
code .
```

### 3. 자동 시작 설정

**Windows 작업 스케줄러**를 사용해 부팅 시 자동 시작:

1. **작업 스케줄러** 실행
2. **작업 만들기**
3. **트리거**: 시스템 시작 시
4. **작업**: PowerShell 스크립트 실행

**PowerShell 스크립트 예시** (`start-netbox.ps1`):

```powershell
# Docker 사용 시
cd $HOME\Documents\netbox-docker
docker compose up -d

# 또는 WSL 사용 시
wsl -d Ubuntu -e bash -c "cd ~/netbox && ~/start-netbox.sh"
```

---

## 추가 학습 자료

### 공식 문서
- **NetBox 공식 문서**: https://docs.netbox.dev
- **REST API 문서**: http://localhost:8000/api/docs/
- **GitHub**: https://github.com/netbox-community/netbox
- **Docker 문서**: https://docs.docker.com/

### 커뮤니티
- **공식 Slack**: https://netdev.chat/
- **Discussion Forum**: https://github.com/netbox-community/netbox/discussions

### 데모 사이트
- **공식 데모**: https://demo.netbox.dev

---

## 요약

축하합니다! 🎉 Windows 11에서 NetBox를 성공적으로 설치했습니다!

**설치한 방법**:
- ✅ **Docker Desktop** (컨테이너 방식)
- ✅ **WSL2** (Linux 환경)

**테스트한 기능**:
- ✅ 사이트, 제조사, 장비 역할, 장비 타입
- ✅ 랙, 장비, 인터페이스
- ✅ IP 주소 및 VLAN
- ✅ REST API 및 GraphQL
- ✅ CSV 일괄 가져오기

**다음 단계**:
1. 공식 문서 탐색
2. 실제 네트워크 인프라 모델링
3. API를 활용한 자동화 스크립트 작성
4. 플러그인 설치 및 커스터마이징

**프로덕션 배포**는 별도의 가이드를 참고하세요:
- https://docs.netbox.dev/en/stable/installation/

---

**문서 작성일**: 2025-10-30
**NetBox 버전**: 4.4.4
**작성자**: Claude Code

질문이나 문제가 있다면 NetBox 커뮤니티나 GitHub Issues를 활용하세요!

#정보보안(SMS)/NetBox#
