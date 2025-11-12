# NetBox 맥북 설치 가이드

## 목차
1. [사전 준비](#1-사전-준비)
2. [의존성 설치](#2-의존성-설치)
3. [NetBox 설정](#3-netbox-설정)
4. [데이터베이스 초기화](#4-데이터베이스-초기화)
5. [NetBox 실행](#5-netbox-실행)
6. [테스트 데이터 업로드](#6-테스트-데이터-업로드)
7. [문제 해결](#7-문제-해결)

---

## 1. 사전 준비

### 1.1 시스템 요구사항
- **macOS**: 10.15 (Catalina) 이상
- **메모리**: 최소 4GB RAM (8GB 권장)
- **저장공간**: 최소 2GB 여유 공간
- **인터넷 연결**: 패키지 다운로드용

### 1.2 현재 환경 확인

터미널을 열고 다음 명령어로 현재 설치된 버전을 확인하세요:

```bash
# macOS 버전 확인
sw_vers

# Python 버전 확인 (3.10 이상 필요)
python3 --version

# Homebrew 설치 확인
brew --version

# PostgreSQL 확인
psql --version

# Redis 확인
redis-server --version
```

---

## 2. 의존성 설치

### 2.1 Homebrew 설치 (없는 경우)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

설치 후 터미널을 재시작하거나 다음 명령어 실행:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2.2 PostgreSQL 설치

```bash
# PostgreSQL 설치
brew install postgresql@15

# PostgreSQL 서비스 시작
brew services start postgresql@15

# 설치 확인
psql --version
```

### 2.3 Redis 설치

```bash
# Redis 설치
brew install redis

# Redis 서비스 시작
brew services start redis

# Redis 연결 테스트
redis-cli ping
# 응답: PONG
```

### 2.4 Python 3.10+ 설치

```bash
# Python 3.11 설치 (권장)
brew install python@3.11

# Python 버전 확인
python3.11 --version

# pip 업그레이드
python3.11 -m pip install --upgrade pip
```

### 2.5 Git으로 NetBox 다운로드

```bash
# 작업 디렉토리로 이동 (예: 홈 디렉토리)
cd ~

# NetBox 저장소 클론
git clone https://github.com/Josephpaik/netbox25.git
cd netbox25

# 현재 브랜치 확인
git branch
```

---

## 3. NetBox 설정

### 3.1 PostgreSQL 데이터베이스 생성

```bash
# PostgreSQL 접속 (비밀번호 없이 로컬 접속)
psql postgres

# PostgreSQL 프롬프트에서 다음 명령어 실행:
```

```sql
-- 데이터베이스 생성
CREATE DATABASE netbox;

-- NetBox 전용 사용자 생성
CREATE USER netbox WITH PASSWORD 'netbox123';

-- 권한 부여
ALTER DATABASE netbox OWNER TO netbox;
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;

-- 연결 확인
\c netbox

-- 종료
\q
```

### 3.2 Python 가상환경 생성

```bash
# 가상환경 생성
python3.11 -m venv venv

# 가상환경 활성화
source venv/bin/activate

# 가상환경 활성화 확인 (프롬프트 앞에 (venv) 표시됨)
which python
# 출력: /Users/yourname/netbox25/venv/bin/python
```

### 3.3 Python 의존성 설치

```bash
# NetBox 의존성 설치
pip install -r requirements.txt

# 설치 확인
pip list | grep Django
```

### 3.4 NetBox 설정 파일 생성

```bash
# 설정 예제 파일 복사
cp netbox/netbox/configuration_example.py netbox/netbox/configuration.py

# 설정 파일 편집
nano netbox/netbox/configuration.py
# 또는
code netbox/netbox/configuration.py  # VS Code 사용 시
# 또는
vim netbox/netbox/configuration.py
```

**중요 설정 항목** (configuration.py에서 수정):

```python
# 필수: SECRET_KEY 생성
# 터미널에서 다음 명령어 실행:
# python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
# 출력된 키를 아래에 붙여넣기
ALLOWED_HOSTS = ['localhost', '127.0.0.1', '[::1]']

DATABASE = {
    'NAME': 'netbox',               # PostgreSQL 데이터베이스 이름
    'USER': 'netbox',               # PostgreSQL 사용자
    'PASSWORD': 'netbox123',        # PostgreSQL 비밀번호
    'HOST': 'localhost',            # PostgreSQL 호스트
    'PORT': '',                     # PostgreSQL 포트 (기본값 사용)
    'CONN_MAX_AGE': 300,
}

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

# 한국어 인터페이스 활성화 (선택사항)
# 아래 주석 해제:
LANGUAGE_CODE = 'ko-kr'
TIME_ZONE = 'Asia/Seoul'
```

**SECRET_KEY 생성 명령어**:
```bash
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

생성된 키를 복사해서 `configuration.py`의 `SECRET_KEY` 변수에 붙여넣으세요.

---

## 4. 데이터베이스 초기화

### 4.1 데이터베이스 마이그레이션

```bash
# 가상환경이 활성화된 상태에서 실행
cd ~/netbox25

# 데이터베이스 스키마 생성
python netbox/manage.py migrate

# 성공 메시지:
# Running migrations:
#   Applying contenttypes.0001_initial... OK
#   Applying auth.0001_initial... OK
#   ...
```

### 4.2 슈퍼유저 계정 생성

```bash
# 관리자 계정 생성
python netbox/manage.py createsuperuser

# 프롬프트에서 입력:
# Username: admin
# Email address: admin@example.com
# Password: (비밀번호 입력 - 화면에 표시되지 않음)
# Password (again): (비밀번호 재입력)
```

**테스트 계정 정보 설정**:
- Username: `admin`
- Email: `wk.paik@somansa.com`
- Password: `admin1234!` (실제 운영 환경에서는 강력한 비밀번호 사용)

### 4.3 정적 파일 수집

```bash
# 정적 파일(CSS, JS, 이미지) 수집
python netbox/manage.py collectstatic --no-input

# 성공 메시지:
# X static files copied to '/Users/yourname/netbox25/netbox/static'
```

---

## 5. NetBox 실행

### 5.1 개발 서버 실행

```bash
# NetBox 개발 서버 시작
python netbox/manage.py runserver

# 성공 메시지:
# Django version 5.2.x, using settings 'netbox.settings'
# Starting development server at http://127.0.0.1:8000/
# Quit the server with CONTROL-C.
```

### 5.2 웹 브라우저로 접속

1. 브라우저를 열고 다음 주소로 접속:
   ```
   http://127.0.0.1:8000/
   또는
   http://localhost:8000/
   ```

2. **로그인**:
   - Username: `admin`
   - Password: (생성한 비밀번호)

3. **NetBox 대시보드 확인**:
   - 상단 네비게이션 메뉴가 보이면 성공!

---

## 6. 테스트 데이터 업로드

### 6.1 IDC 시나리오 시뮬레이션 데이터

NetBox에 SMS사 판교 사옥 IDC 시뮬레이션 데이터를 업로드합니다.

**데이터 위치**: `idc_scenario/csv_templates/`

**업로드 순서** (의존성 때문에 반드시 순서대로!):

#### Step 1: Sites (사이트)
1. 브라우저에서 **DCIM > Sites** 메뉴 클릭
2. 우측 상단 **Import** 버튼 클릭
3. "Upload file" 탭 선택
4. `01_sites.csv` 파일 업로드
5. **Submit** 버튼 클릭
6. 결과: "SMS Pangyo" 사이트 생성

#### Step 2: Manufacturers (제조사)
1. **DCIM > Device Types > Manufacturers** 메뉴
2. **Import** 버튼 클릭
3. `02_manufacturers.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 3: Device Roles (장비 역할)
1. **DCIM > Devices > Device Roles** 메뉴
2. **Import** 버튼 클릭
3. `03_device_roles.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 4: Device Types (장비 모델)
1. **DCIM > Device Types** 메뉴
2. **Import** 버튼 클릭
3. `04_device_types.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 5: Locations (위치/층)
1. **DCIM > Sites > Locations** 메뉴
2. **Import** 버튼 클릭
3. `05_locations.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 6: Racks (랙/캐비넷)
1. **DCIM > Racks** 메뉴
2. **Import** 버튼 클릭
3. `06_racks.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 7: Devices - 데이터센터 (운영 서버)
1. **DCIM > Devices** 메뉴
2. **Import** 버튼 클릭
3. `07_devices_datacenter.csv` 파일 업로드
4. **Submit** 버튼 클릭
5. 결과: 약 60대 서버 생성

#### Step 8: Devices - 테스트 제품
1. **DCIM > Devices** 메뉴
2. **Import** 버튼 클릭
3. `08_devices_test.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 9: Interfaces (네트워크 인터페이스)
1. **DCIM > Devices > Interfaces** 메뉴
2. **Import** 버튼 클릭
3. `09_interfaces.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 10: VLANs
1. **IPAM > VLANs** 메뉴
2. **Import** 버튼 클릭
3. `10_vlans.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 11: Prefixes (IP 대역)
1. **IPAM > Prefixes** 메뉴
2. **Import** 버튼 클릭
3. `11_prefixes.csv` 파일 업로드
4. **Submit** 버튼 클릭

#### Step 12: IP Addresses (IP 주소)
1. **IPAM > IP Addresses** 메뉴
2. **Import** 버튼 클릭
3. `12_ip_addresses.csv` 파일 업로드
4. **Submit** 버튼 클릭

### 6.2 데이터 업로드 확인

모든 CSV 파일 업로드 후 다음을 확인하세요:

1. **Sites**: SMS Pangyo 사이트 1개
2. **Manufacturers**: Dell, HP, Cisco 등
3. **Device Roles**: Server, Switch, Firewall 등
4. **Device Types**: 여러 서버/장비 모델
5. **Locations**: B1F-DataCenter, 3F-TestLab-A 등
6. **Racks**: 12개 랙 (DC-RACK-01 ~ DC-RACK-12)
7. **Devices**: 약 60대 데이터센터 서버 + 테스트 장비
8. **Interfaces**: 각 장비의 네트워크 인터페이스
9. **VLANs**: Management, Production, Test VLAN 등
10. **Prefixes**: IP 대역 (10.0.0.0/8, 172.16.0.0/12)
11. **IP Addresses**: 할당된 IP 주소들

### 6.3 시각적 확인

#### 랙 뷰 확인:
1. **DCIM > Racks** 메뉴
2. "DC-RACK-01" 클릭
3. 랙 다이어그램에서 서버 배치 확인

#### 사이트 맵:
1. **DCIM > Sites** 메뉴
2. "SMS Pangyo" 클릭
3. Locations 탭에서 건물 구조 확인

#### IP 할당 현황:
1. **IPAM > Prefixes** 메뉴
2. 각 Prefix 클릭하여 할당률(Utilization) 확인

---

## 7. 문제 해결

### 7.1 PostgreSQL 연결 오류

**증상**:
```
django.db.utils.OperationalError: could not connect to server
```

**해결**:
```bash
# PostgreSQL 서비스 상태 확인
brew services list | grep postgresql

# PostgreSQL 재시작
brew services restart postgresql@15

# 수동 연결 테스트
psql -U netbox -d netbox -h localhost
# 비밀번호: netbox123
```

### 7.2 Redis 연결 오류

**증상**:
```
redis.exceptions.ConnectionError: Error connecting to Redis
```

**해결**:
```bash
# Redis 서비스 상태 확인
brew services list | grep redis

# Redis 재시작
brew services restart redis

# 수동 연결 테스트
redis-cli ping
# 응답: PONG
```

### 7.3 SECRET_KEY 오류

**증상**:
```
django.core.exceptions.ImproperlyConfigured: The SECRET_KEY setting must not be empty
```

**해결**:
```bash
# SECRET_KEY 생성
python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# 출력된 키를 netbox/netbox/configuration.py의 SECRET_KEY에 붙여넣기
```

### 7.4 Static 파일 404 오류

**증상**: 웹페이지는 뜨지만 CSS가 적용되지 않음

**해결**:
```bash
# 정적 파일 재수집
python netbox/manage.py collectstatic --clear --no-input
```

### 7.5 Migration 오류

**증상**:
```
django.db.migrations.exceptions.InconsistentMigrationHistory
```

**해결**:
```bash
# 데이터베이스 삭제 후 재생성
psql postgres
DROP DATABASE netbox;
CREATE DATABASE netbox;
ALTER DATABASE netbox OWNER TO netbox;
\q

# 마이그레이션 재실행
python netbox/manage.py migrate
```

### 7.6 CSV Import 오류

**증상**: "Foreign key constraint failed" 또는 "Object not found"

**해결**:
- CSV 파일을 **반드시 순서대로** 업로드하세요 (01 → 02 → ... → 12)
- Sites, Manufacturers를 먼저 생성하지 않으면 Device 생성 시 오류 발생

### 7.7 포트 충돌 오류

**증상**:
```
Error: That port is already in use.
```

**해결**:
```bash
# 다른 포트로 실행
python netbox/manage.py runserver 8080

# 브라우저에서 http://localhost:8080/ 접속
```

---

## 8. 추가 정보

### 8.1 서버 종료 방법

개발 서버를 종료하려면:
```bash
# 터미널에서 Ctrl+C 입력
```

### 8.2 가상환경 비활성화

작업 완료 후 가상환경을 비활성화하려면:
```bash
deactivate
```

### 8.3 다음 실행 시

NetBox를 다시 실행하려면:

```bash
cd ~/netbox25
source venv/bin/activate
python netbox/manage.py runserver
```

**서비스들이 실행 중인지 확인**:
```bash
brew services list
# postgresql@15: started
# redis: started
```

### 8.4 유용한 명령어

```bash
# NetBox 쉘 (Django ORM 사용 가능)
python netbox/manage.py nbshell

# 백업 생성
pg_dump -U netbox netbox > netbox_backup.sql

# 백업 복원
psql -U netbox netbox < netbox_backup.sql

# 로그 확인
python netbox/manage.py runserver --verbosity=3
```

---

## 9. 참고 자료

- **NetBox 공식 문서**: https://docs.netbox.dev/
- **IDC 시나리오 가이드**: `idc_scenario/README.md`
- **API 문서**: http://localhost:8000/api/docs/
- **설정 예제**: `netbox/netbox/configuration_example.py`

---

## 축하합니다! 🎉

NetBox가 성공적으로 설치되었습니다!

이제 SMS사 판교 IDC 시나리오 데이터를 탐색하고, NetBox의 다양한 기능을 테스트해보세요:
- 장비 검색 및 필터링
- 랙 뷰 및 시각화
- IP 주소 관리
- VLAN 구성
- 케이블 연결 추적
- 보고서 생성 및 Export

즐거운 NetBox 사용되세요! 🚀
