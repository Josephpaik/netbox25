# NetBox 맥북 설치 체크리스트

## ⚡ 빠른 시작 (자동 설치)

```bash
# 1. 저장소 클론 (아직 안했다면)
cd ~
git clone https://github.com/Josephpaik/netbox25.git
cd netbox25

# 2. 자동 설치 스크립트 실행
./setup_macos.sh

# 3. NetBox 실행
source venv/bin/activate
python netbox/manage.py runserver

# 4. 브라우저에서 접속
# http://localhost:8000/
# Username: admin
# Password: admin123
```

---

## 📋 수동 설치 체크리스트

자동 설치가 실패하거나 수동 설치를 원하는 경우 사용하세요.

### Phase 1: 환경 준비

- [ ] **1.1** macOS 버전 확인 (10.15 이상)
  ```bash
  sw_vers
  ```

- [ ] **1.2** Homebrew 설치
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- [ ] **1.3** Python 3.11 설치
  ```bash
  brew install python@3.11
  python3.11 --version
  ```

- [ ] **1.4** PostgreSQL 설치 및 시작
  ```bash
  brew install postgresql@15
  brew services start postgresql@15
  ```

- [ ] **1.5** Redis 설치 및 시작
  ```bash
  brew install redis
  brew services start redis
  redis-cli ping  # 응답: PONG
  ```

### Phase 2: 데이터베이스 설정

- [ ] **2.1** PostgreSQL 데이터베이스 생성
  ```sql
  psql postgres
  CREATE DATABASE netbox;
  CREATE USER netbox WITH PASSWORD 'netbox123';
  ALTER DATABASE netbox OWNER TO netbox;
  GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;
  \q
  ```

- [ ] **2.2** 데이터베이스 연결 테스트
  ```bash
  psql -U netbox -d netbox -h localhost
  # 비밀번호: netbox123
  ```

### Phase 3: NetBox 설치

- [ ] **3.1** 저장소 클론
  ```bash
  cd ~
  git clone https://github.com/Josephpaik/netbox25.git
  cd netbox25
  ```

- [ ] **3.2** Python 가상환경 생성
  ```bash
  python3.11 -m venv venv
  source venv/bin/activate
  ```

- [ ] **3.3** Python 의존성 설치
  ```bash
  pip install --upgrade pip
  pip install -r requirements.txt
  ```

- [ ] **3.4** 설정 파일 생성
  ```bash
  cp netbox/netbox/configuration_example.py netbox/netbox/configuration.py
  ```

- [ ] **3.5** SECRET_KEY 생성 및 설정
  ```bash
  python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
  # 출력된 키를 configuration.py의 SECRET_KEY에 붙여넣기
  ```

- [ ] **3.6** configuration.py 편집
  - `SECRET_KEY` 설정
  - `ALLOWED_HOSTS = ['localhost', '127.0.0.1', '[::1]']`
  - DATABASE 설정 확인
  - REDIS 설정 확인

### Phase 4: 초기화

- [ ] **4.1** 데이터베이스 마이그레이션
  ```bash
  python netbox/manage.py migrate
  ```

- [ ] **4.2** 슈퍼유저 생성
  ```bash
  python netbox/manage.py createsuperuser
  # Username: admin
  # Email: admin@localhost.com
  # Password: admin123 (또는 원하는 비밀번호)
  ```

- [ ] **4.3** 정적 파일 수집
  ```bash
  python netbox/manage.py collectstatic --no-input
  ```

### Phase 5: 실행 및 확인

- [ ] **5.1** NetBox 실행
  ```bash
  python netbox/manage.py runserver
  ```

- [ ] **5.2** 브라우저 접속 확인
  - URL: http://localhost:8000/
  - 로그인: admin / admin123

- [ ] **5.3** 대시보드 표시 확인

---

## 📁 테스트 데이터 업로드 체크리스트

### 업로드 순서 (반드시 순서대로!)

- [ ] **1** Sites (사이트)
  - DCIM > Sites > Import
  - 파일: `idc_scenario/csv_templates/01_sites.csv`

- [ ] **2** Manufacturers (제조사)
  - DCIM > Device Types > Manufacturers > Import
  - 파일: `02_manufacturers.csv`

- [ ] **3** Device Roles (장비 역할)
  - DCIM > Devices > Device Roles > Import
  - 파일: `03_device_roles.csv`

- [ ] **4** Device Types (장비 모델)
  - DCIM > Device Types > Import
  - 파일: `04_device_types.csv`

- [ ] **5** Locations (위치/층)
  - DCIM > Sites > Locations > Import
  - 파일: `05_locations.csv`

- [ ] **6** Racks (랙/캐비넷)
  - DCIM > Racks > Import
  - 파일: `06_racks.csv`

- [ ] **7** Devices - 데이터센터
  - DCIM > Devices > Import
  - 파일: `07_devices_datacenter.csv`

- [ ] **8** Devices - 테스트 제품
  - DCIM > Devices > Import
  - 파일: `08_devices_test.csv`

- [ ] **9** Interfaces (네트워크 인터페이스)
  - DCIM > Interfaces > Import
  - 파일: `09_interfaces.csv`

- [ ] **10** VLANs
  - IPAM > VLANs > Import
  - 파일: `10_vlans.csv`

- [ ] **11** Prefixes (IP 대역)
  - IPAM > Prefixes > Import
  - 파일: `11_prefixes.csv`

- [ ] **12** IP Addresses (IP 주소)
  - IPAM > IP Addresses > Import
  - 파일: `12_ip_addresses.csv`

---

## ✅ 업로드 결과 확인

### 데이터 검증

- [ ] **Sites**: SMS Pangyo 1개 사이트
- [ ] **Manufacturers**: Dell, HP, Cisco 등 여러 제조사
- [ ] **Device Roles**: Server, Switch, Firewall 등
- [ ] **Device Types**: 다양한 서버/장비 모델
- [ ] **Locations**: B1F-DataCenter, 3F/4F/5F-TestLab 등
- [ ] **Racks**: DC-RACK-01 ~ DC-RACK-12 (12개)
- [ ] **Devices**: 약 60대 이상 (데이터센터 + 테스트)
- [ ] **Interfaces**: 각 장비별 네트워크 인터페이스
- [ ] **VLANs**: Management, Production, Test VLAN
- [ ] **Prefixes**: 10.0.0.0/8, 172.16.0.0/12 등
- [ ] **IP Addresses**: 할당된 IP 주소들

### 시각적 확인

- [ ] **랙 뷰 확인**
  1. DCIM > Racks
  2. "DC-RACK-01" 클릭
  3. 랙 다이어그램에서 서버 배치 확인

- [ ] **사이트 구조 확인**
  1. DCIM > Sites
  2. "SMS Pangyo" 클릭
  3. Locations 탭에서 건물 층별 구조 확인

- [ ] **IP 할당 현황 확인**
  1. IPAM > Prefixes
  2. 각 Prefix의 Utilization 확인

- [ ] **장비 검색 테스트**
  1. DCIM > Devices
  2. 검색 필터 사용 (예: Status=Active)
  3. 결과 확인

---

## 🔧 문제 해결 체크리스트

### PostgreSQL 연결 오류

- [ ] 서비스 실행 확인
  ```bash
  brew services list | grep postgresql
  ```
- [ ] 서비스 재시작
  ```bash
  brew services restart postgresql@15
  ```
- [ ] 수동 연결 테스트
  ```bash
  psql -U netbox -d netbox -h localhost
  ```

### Redis 연결 오류

- [ ] 서비스 실행 확인
  ```bash
  brew services list | grep redis
  ```
- [ ] 서비스 재시작
  ```bash
  brew services restart redis
  ```
- [ ] 연결 테스트
  ```bash
  redis-cli ping
  ```

### SECRET_KEY 오류

- [ ] SECRET_KEY 재생성
  ```bash
  python3 -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
  ```
- [ ] configuration.py에 붙여넣기

### CSS 스타일 미적용

- [ ] 정적 파일 재수집
  ```bash
  python netbox/manage.py collectstatic --clear --no-input
  ```

### CSV Import 실패

- [ ] 순서 확인: Sites → Manufacturers → DeviceTypes → Devices
- [ ] 필수 필드 확인
- [ ] 에러 메시지 확인 및 데이터 수정

---

## 📚 참고 문서

- [ ] **설치 가이드**: `MACBOOK_INSTALL_GUIDE.md`
- [ ] **IDC 시나리오**: `idc_scenario/README.md`
- [ ] **프로젝트 가이드**: `CLAUDE.md`
- [ ] **NetBox 공식 문서**: https://docs.netbox.dev/

---

## 🎉 완료!

모든 체크리스트를 완료했다면 축하합니다!

이제 다음을 시도해보세요:
- 장비 추가/수정/삭제
- 랙 시각화 및 U 공간 관리
- IP 주소 할당 및 관리
- VLAN 구성
- 검색 및 필터링
- 보고서 Export (CSV, YAML)

즐거운 NetBox 사용되세요! 🚀
