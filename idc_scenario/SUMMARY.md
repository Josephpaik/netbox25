# NetBox IDC 시나리오 시뮬레이션 - 완료 요약

## 📋 프로젝트 개요

**목적**: NetBox의 기능과 화면을 테스트하기 위한 실제 IDC 운영 시나리오 작성 및 시뮬레이션 기능 개발

**시나리오**: 보안솔루션 전문기업 SMS사의 판교 신축 사옥 IDC 운영 (6개월차)

---

## ✅ 완료된 작업

### 1. NetBox 기존 기능 확인

**결과**: NetBox에는 이미 **CSV 기반 Bulk Import/Export 기능**이 내장되어 있습니다.

#### Import 기능
- **Web UI**: 각 모델의 리스트 페이지에서 `Import` 버튼 → CSV 업로드
- **API**: REST API를 통한 프로그래매틱 접근
- **지원 형식**: CSV (직접 입력 또는 파일 업로드)

#### Export 기능
- **Web UI**: 리스트 페이지에서 `Export` 버튼 → CSV/YAML/Custom Template
- **API**: REST API를 통한 데이터 조회 및 다운로드

### 2. 시나리오 설계

**SMS사 판교 사옥 구성**:

```
📍 SMS 판교 사옥 (지하 4층, 지상 9층)
│
├── 🏢 지하 1층 - 데이터센터
│   ├── 12개 랙 (각 42U)
│   ├── 60대 운영 서버
│   │   ├── 코어 네트워크 (라우터, 스위치, 방화벽)
│   │   ├── 웹 서버 (사내 포털 + 고객 SaaS)
│   │   ├── 애플리케이션 서버
│   │   ├── 데이터베이스 서버 (Oracle, MySQL)
│   │   ├── 인프라 서버 (AD, DNS, Mail)
│   │   └── 기타 (스토리지, 모니터링, 가상화)
│   └── 설비: 항온항습기, 화재경보기, 배터리실, 하론소화장비
│
└── 🧪 3층/4층/5층 - 테스트 공간
    ├── 3층: 단기 테스트 (1주일)
    ├── 4층: 중기 테스트 (1개월)
    └── 5층: 장기 테스트 (3개월+)

📦 연간 출하량: 약 800대 (보안 어플라이언스)
```

### 3. 데이터 구조 설계

총 **12개 자산 유형**에 대한 CSV 템플릿 작성:

| 순서 | 파일명 | 모델 | 샘플 수 | 설명 |
|------|--------|------|---------|------|
| 1 | 01_sites.csv | Site | 1 | SMS 판교 사옥 |
| 2 | 02_manufacturers.csv | Manufacturer | 7 | Dell, HPE, Supermicro, Cisco, Juniper, Arista, SMS |
| 3 | 03_device_roles.csv | DeviceRole | 15 | Core Router, Web Server, DB Server, Security Appliance 등 |
| 4 | 04_device_types.csv | DeviceType | 14 | PowerEdge R650, ProLiant DL380, SecureGate SG-3000 등 |
| 5 | 05_locations.csv | Location | 6 | B1F Datacenter, 3F/4F/5F Test Lab 등 |
| 6 | 06_racks.csv | Rack | 15 | DC-R01~DC-R12 (데이터센터), TEST-R01~03 (테스트) |
| 7 | 07_devices_datacenter.csv | Device | 29 | 데이터센터 운영 서버 |
| 8 | 08_devices_test.csv | Device | 9 | 테스트 제품 (SecureGate SG-1000/3000/5000) |
| 9 | 09_interfaces.csv | Interface | 40+ | 네트워크 인터페이스 |
| 10 | 10_vlans.csv | VLAN | 13 | Management, Web-DMZ, Application, Database 등 |
| 11 | 11_prefixes.csv | Prefix | 15 | 10.x.x.x/24 내부 대역, 192.168.1.x/24 공인 IP |
| 12 | 12_ip_addresses.csv | IPAddress | 28+ | 장비별 IP 할당 |

**총 샘플 데이터**: **175개 이상의 레코드**

### 4. CSV 템플릿 작성

각 자산 유형별로 실제 데이터 샘플을 포함한 CSV 파일 작성:

#### 예시: Device (SMS-WEB01)
```csv
name,site,location,rack,position,face,status,device_role,device_type,serial,asset_tag,description
SMS-WEB01,SMS Pangyo,B1F Datacenter,DC-R02,35,front,active,Web Server,Dell PowerEdge R650,SN-WEB01-2024020,ASSET-020,웹 서버 01 - 사내 포털
```

#### 예시: Test Device (SMS-TEST-SG3K-001)
```csv
name,site,location,rack,position,status,device_role,device_type,serial,description
SMS-TEST-SG3K-001,SMS Pangyo,3F Test Lab,TEST-R01,25,staged,Security Appliance,SMS SecureGate SG-3000,SN-SG3K-2025001,고객사 A 납품 예정 (1주일 테스트 중)
```

### 5. 자동화 스크립트 개발

**Python 업로드 스크립트** (`upload_script.py`):

#### 기능
- ✅ NetBox 연결 테스트
- ✅ Dry run (검증만 수행)
- ✅ 전체 CSV 파일 일괄 업로드
- ✅ 특정 파일만 선택 업로드
- ✅ 의존성 순서 자동 관리
- ✅ ForeignKey 자동 해결 (이름 → ID 변환)
- ✅ 오류 로깅 및 재시도
- ✅ 진행 상황 실시간 표시

#### 사용법
```bash
# 1. 연결 테스트
python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN --test

# 2. Dry run (검증만)
python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN --dry-run

# 3. 실제 업로드
python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN

# 4. 특정 파일만 업로드
python upload_script.py --url http://localhost:8000 --token YOUR_TOKEN --file 01_sites.csv
```

### 6. 문서화

#### README.md
- 시나리오 개요
- 데이터 업로드 순서
- CSV 파일 구조
- Import/Export 기능 사용 방법
- 주의사항 및 참고 자료

#### USAGE_GUIDE.md (상세 가이드)
- Web UI를 통한 단계별 Import
- Python 스크립트 사용법
- API를 통한 Import/Export
- 4가지 실전 시뮬레이션 시나리오:
  1. 신규 서버 프로비저닝
  2. 테스트 제품 관리 (반입 → 테스트 → 출하)
  3. 네트워크 장애 대응
  4. 정기 점검 리포트
- 문제 해결 가이드

---

## 📂 디렉토리 구조

```
idc_scenario/
├── README.md                       # 프로젝트 개요 및 사용 방법
├── USAGE_GUIDE.md                  # 상세 사용 가이드 (80KB+)
├── SUMMARY.md                      # 이 파일
├── upload_script.py                # Python 자동 업로드 스크립트
└── csv_templates/                  # CSV 템플릿 디렉토리
    ├── 01_sites.csv               # 1개 사이트
    ├── 02_manufacturers.csv       # 7개 제조사
    ├── 03_device_roles.csv        # 15개 역할
    ├── 04_device_types.csv        # 14개 모델
    ├── 05_locations.csv           # 6개 위치
    ├── 06_racks.csv               # 15개 랙
    ├── 07_devices_datacenter.csv  # 29대 운영 서버
    ├── 08_devices_test.csv        # 9대 테스트 제품
    ├── 09_interfaces.csv          # 40+ 인터페이스
    ├── 10_vlans.csv               # 13개 VLAN
    ├── 11_prefixes.csv            # 15개 IP 대역
    └── 12_ip_addresses.csv        # 28+ IP 주소
```

---

## 🚀 시작하기

### 1단계: NetBox 실행

```bash
cd /home/user/netbox25/netbox
python manage.py runserver
```

### 2단계: API 토큰 생성

1. http://localhost:8000 로그인
2. 우측 상단 사용자 메뉴 → "Profile" → "API Tokens"
3. "Add a token" 클릭
4. "Write enabled" 체크
5. 토큰 복사

### 3단계: 데이터 업로드

#### 방법 A: Web UI (수동)

1. `Organization` → `Sites` → `Import` 버튼
2. `csv_templates/01_sites.csv` 내용 붙여넣기
3. Submit
4. 순서대로 나머지 파일 반복

#### 방법 B: Python 스크립트 (자동)

```bash
cd /home/user/netbox25/idc_scenario

# 필수 라이브러리 설치
pip install requests

# 연결 테스트
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_TOKEN \
  --test

# Dry run (검증만)
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_TOKEN \
  --dry-run

# 실제 업로드
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_TOKEN
```

### 4단계: 데이터 확인

업로드 후 NetBox UI에서 확인:

- **Sites**: http://localhost:8000/dcim/sites/
- **Devices**: http://localhost:8000/dcim/devices/
- **Racks**: http://localhost:8000/dcim/racks/
- **IP Addresses**: http://localhost:8000/ipam/ip-addresses/

필터 적용:
- Site: SMS Pangyo
- Status: Active
- Location: B1F Datacenter

### 5단계: 시뮬레이션 실행

`USAGE_GUIDE.md`의 "시뮬레이션 시나리오" 섹션 참고:

1. **신규 서버 프로비저닝**: 새로운 웹 서버 추가
2. **테스트 제품 관리**: 제품 반입 → 테스트 → 출하
3. **네트워크 장애 대응**: 장애 장비 격리 및 예비 장비 투입
4. **정기 점검 리포트**: CSV 리포트 생성

---

## 📊 데이터 통계

### 자산 개요

| 자산 유형 | 개수 | 비고 |
|-----------|------|------|
| **Site** | 1 | SMS 판교 사옥 |
| **Manufacturer** | 7 | Dell, HPE, Supermicro, Cisco, Juniper, Arista, SMS |
| **DeviceRole** | 15 | 네트워크, 서버, 보안 등 |
| **DeviceType** | 14 | 실제 제품 모델 |
| **Location** | 6 | 데이터센터 + 테스트 실습실 |
| **Rack** | 15 | 12개 운영 + 3개 테스트 |
| **Device** | 38 | 29대 운영 + 9대 테스트 |
| **Interface** | 40+ | 각 장비별 네트워크 인터페이스 |
| **VLAN** | 13 | 용도별 네트워크 세그먼트 |
| **Prefix** | 15 | 내부 대역 + 공인 IP |
| **IPAddress** | 28+ | 장비별 IP 할당 |

### 장비 분류

#### 데이터센터 운영 장비 (29대)
- 코어 네트워크: 6대 (라우터 2, 방화벽 4)
- 웹 서버: 4대
- 애플리케이션 서버: 6대
- 데이터베이스 서버: 4대
- 인프라 서버: 5대 (AD, DNS, Mail)
- 기타: 4대 (스토리지, 모니터링)

#### 테스트 제품 (9대)
- SecureGate SG-1000: 3대 (장기 테스트)
- SecureGate SG-3000: 3대 (단기 테스트)
- SecureGate SG-5000: 3대 (중기 테스트)

### 네트워크 구성

- **Management VLAN (10)**: 10.10.10.0/24
- **Production VLANs (100-500)**: 각 용도별 세그먼트
- **Test VLAN (999)**: 10.999.10.0/24
- **Public IP**: 192.168.1.0/24 (외부 서비스용)

---

## 💡 핵심 기능

### NetBox 기존 기능 활용

✅ **CSV Bulk Import**
- Web UI를 통한 직관적인 업로드
- 자동 필드 매핑
- 실시간 유효성 검증
- 오류 메시지 표시

✅ **CSV/YAML Export**
- 필터 적용 가능
- 커스텀 템플릿 지원
- Excel 호환

✅ **REST API**
- 프로그래매틱 접근
- Bulk 작업 지원
- 인증 (Token-based)

### 추가 개발 항목

✅ **Python 자동화 스크립트**
- 의존성 관리
- ForeignKey 자동 해결
- Dry run 모드
- 진행 상황 표시

✅ **실전 시나리오**
- 4가지 운영 시나리오
- Python 코드 예시 제공
- API 활용 방법

---

## 🎯 활용 방안

### 1. NetBox 기능 테스트
- Import/Export 기능 검증
- API 성능 테스트
- UI/UX 평가
- 데이터 모델 이해

### 2. 교육 및 트레이닝
- 신규 사용자 온보딩
- IDC 운영 프로세스 교육
- API 사용법 학습
- 시나리오 기반 실습

### 3. 데모 및 PoC
- 고객사 데모
- 기능 프레젠테이션
- 실제 데이터 마이그레이션 사전 테스트

### 4. 개발 및 디버깅
- 플러그인 개발 테스트
- 커스텀 스크립트 검증
- 워크플로우 최적화

---

## 📝 주의사항

### 의존성 순서

반드시 다음 순서로 Import해야 합니다:

```
1. Sites
2. Manufacturers
3. DeviceRoles
4. DeviceTypes (Manufacturer 참조)
5. Locations (Site 참조)
6. Racks (Site, Location 참조)
7. Devices (Site, Location, Rack, DeviceType, DeviceRole 참조)
8. Interfaces (Device 참조)
9. VLANs (Site 참조)
10. Prefixes (Site, VLAN 참조)
11. IPAddresses (Interface, VLAN 참조)
```

### 필수 필드

각 모델의 필수 필드는 반드시 입력:
- Site: `name`, `slug`, `status`
- Device: `name`, `device_type`, `device_role`, `site`, `status`
- IPAddress: `address`, `status`

### Unique 제약

중복될 수 없는 필드:
- `slug`: 대부분의 모델
- `name`: Site, Device 등
- `address` + `vrf`: IPAddress

---

## 🔧 문제 해결

### 자주 발생하는 오류

1. **"Object with this slug already exists"**
   - 해결: 기존 객체 삭제 또는 slug 변경

2. **"Unable to resolve device type"**
   - 해결: DeviceType을 먼저 생성

3. **"position is already occupied"**
   - 해결: Rack position 값 변경

4. **API 토큰 인증 실패**
   - 해결: 토큰 재생성, "Write enabled" 확인

자세한 내용은 `USAGE_GUIDE.md`의 "문제 해결" 섹션 참고.

---

## 📚 참고 자료

- **NetBox 공식 문서**: https://docs.netbox.dev/
- **API 문서 (Swagger)**: http://localhost:8000/api/docs/
- **API 문서 (ReDoc)**: http://localhost:8000/api/redoc/
- **NetBox GitHub**: https://github.com/netbox-community/netbox
- **커뮤니티**: https://github.com/netbox-community/netbox/discussions

---

## ✨ 다음 단계

### 추가 개선 가능 항목

1. **더 많은 샘플 데이터**
   - Cables (케이블 연결)
   - Power Feeds (전원 공급)
   - VirtualMachines (가상 머신)
   - Circuits (회선)

2. **고급 시나리오**
   - 케이블 추적
   - 전력 소비 계산
   - 가상화 인벤토리
   - 네트워크 다이어그램 생성

3. **자동화 강화**
   - 정기 백업 스크립트
   - 변경 사항 모니터링
   - Webhook 통합
   - CI/CD 파이프라인 통합

4. **통합 개발**
   - Ansible Playbook 생성
   - Terraform Provider 연동
   - Prometheus 메트릭 수집
   - Grafana 대시보드

---

## 🎉 결론

NetBox의 기존 **CSV Import/Export 기능**을 활용하여:
- ✅ 실제 IDC 운영 시나리오 설계 완료
- ✅ 12개 자산 유형, 175+ 샘플 데이터 작성 완료
- ✅ Python 자동화 스크립트 개발 완료
- ✅ 상세 사용 가이드 및 4가지 실전 시나리오 문서화 완료

**별도의 기능 개발 없이** NetBox의 기본 기능만으로 IDC 자산 관리 및 시뮬레이션이 가능합니다! 🚀

---

**작성일**: 2025-10-31
**버전**: 1.0
**작성자**: Claude Code
