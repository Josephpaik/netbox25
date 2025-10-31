# NetBox IDC 운영 시나리오 시뮬레이션

## 시나리오 개요

### SMS사 판교 사옥 IDC 시뮬레이션

**회사**: SMS사 (보안솔루션 전문기업)
**위치**: 경기도 판교 신축 사옥 (지하 4층, 지상 9층)
**가동 기간**: 6개월

### 시설 구성

#### 1. 데이터 센터 (지하 1층)
- **설비**: 항온항습기, 화재경보기, 배터리실, 하론소화장비
- **캐비넷**: 12개 랙 (각 42U)
- **운영 서버**: 약 60대 (대내외 서비스용)
- **용도**:
  - 사내 인프라 서버 (Active Directory, Mail, File Server 등)
  - 고객사 대상 SaaS 플랫폼 서버
  - 개발/스테이징 환경

#### 2. 테스트/제작 공간 (3층, 4층, 5층)
- **용도**: 고객사 납품용 보안제품 (어플라이언스 서버) 제작 및 테스트
- **테스트 기간**:
  - 단기: 1주일 정도
  - 장기: 3개월 이상
- **연간 출하량**: 약 800대

## 데이터 업로드 순서

NetBox에 데이터를 업로드할 때는 **의존성 순서**를 따라야 합니다:

1. **Site** (사이트 정보)
2. **Manufacturer** (제조사)
3. **DeviceRole** (장비 역할)
4. **DeviceType** (장비 모델)
5. **RackRole** (랙 역할) - 선택사항
6. **Location** (위치/층 정보)
7. **Rack** (랙/캐비넷)
8. **Device** (실제 장비)
9. **Interface** (네트워크 인터페이스)
10. **VLAN** (VLAN 정보)
11. **Prefix** (IP 대역)
12. **IPAddress** (IP 주소)

## CSV 파일 구조 및 샘플 데이터

각 자산 유형별 CSV 파일이 `csv_templates/` 디렉토리에 준비되어 있습니다.

### 파일 목록

```
csv_templates/
├── 01_sites.csv                # 사이트 정보
├── 02_manufacturers.csv        # 제조사
├── 03_device_roles.csv         # 장비 역할
├── 04_device_types.csv         # 장비 모델
├── 05_locations.csv            # 위치/층
├── 06_racks.csv                # 랙/캐비넷
├── 07_devices_datacenter.csv  # 데이터센터 서버
├── 08_devices_test.csv         # 테스트 제품
├── 09_interfaces.csv           # 네트워크 인터페이스
├── 10_vlans.csv                # VLAN
├── 11_prefixes.csv             # IP 대역
└── 12_ip_addresses.csv         # IP 주소
```

## NetBox Import/Export 기능 사용 방법

### 1. CSV 데이터 Import (업로드)

#### Web UI를 통한 Import

1. **네비게이션**:
   - 각 객체 유형의 리스트 페이지로 이동
   - 예: `DCIM > Sites` 또는 `DCIM > Devices`

2. **Import 버튼 클릭**:
   - 리스트 페이지 우측 상단의 `Import` 버튼 클릭

3. **CSV 파일 업로드**:
   - "Direct input" 탭: CSV 내용을 직접 붙여넣기
   - "Upload file" 탭: CSV 파일 선택 후 업로드

4. **필드 매핑 확인**:
   - NetBox가 자동으로 CSV 헤더와 모델 필드를 매핑
   - 필요시 수동으로 조정

5. **검증 및 저장**:
   - "Submit" 버튼 클릭
   - 오류가 있으면 표시되고, 성공하면 객체 생성

#### API를 통한 Import

```bash
# 예시: Site 생성
curl -X POST http://localhost:8000/api/dcim/sites/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "SMS Pangyo",
    "slug": "sms-pangyo",
    "status": "active"
  }'
```

### 2. 데이터 Export (다운로드)

#### Web UI를 통한 Export

1. **리스트 페이지에서**:
   - 필터를 적용하여 원하는 객체 선택
   - 우측 상단 `Export` 드롭다운 메뉴 클릭

2. **Export 형식 선택**:
   - **CSV**: 표 형식으로 모든 필드 export
   - **YAML**: YAML 형식으로 export
   - **Custom Template**: 사용자 정의 템플릿 사용

3. **파일 다운로드**:
   - 선택한 형식으로 파일이 자동 다운로드됨

#### API를 통한 Export

```bash
# 모든 사이트 조회
curl -X GET http://localhost:8000/api/dcim/sites/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Accept: application/json"

# CSV 형식으로 export (API에서는 JSON이 기본)
# Web UI의 export 기능을 사용하거나 별도 스크립트 필요
```

### 3. Python 스크립트를 통한 Bulk Import

```python
import requests
import csv

NETBOX_URL = "http://localhost:8000"
TOKEN = "your-api-token-here"

headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

# CSV 파일 읽기 및 API로 생성
with open('01_sites.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        response = requests.post(
            f"{NETBOX_URL}/api/dcim/sites/",
            headers=headers,
            json=row
        )
        if response.status_code == 201:
            print(f"Created: {row['name']}")
        else:
            print(f"Error: {response.json()}")
```

## 테스트 시나리오

### 시나리오 1: 초기 구축
1. Site, Location, Rack 생성
2. 60대 운영 서버 배치
3. 네트워크 구성 (VLAN, IP 할당)

### 시나리오 2: 신규 테스트 제품 반입
1. 3층 테스트 공간에 신규 제품 등록
2. 임시 IP 할당
3. 테스트 시작

### 시나리오 3: 테스트 완료 및 출하
1. 테스트 제품 상태 변경 (staged → decommissioning)
2. IP 회수
3. 장비 삭제 또는 아카이브

### 시나리오 4: 정기 점검
1. 모든 장비 리스트 export
2. 상태 확인 (active, offline 등)
3. 보고서 생성

## 주의사항

1. **의존성**: 반드시 순서대로 import해야 합니다 (Site → Manufacturer → DeviceType → Device)
2. **필수 필드**: 각 모델의 필수 필드는 반드시 입력해야 합니다
3. **유효성 검증**: Import 전 NetBox가 자동으로 데이터 유효성을 검증합니다
4. **중복 방지**: slug, name 등 unique 필드는 중복되지 않아야 합니다
5. **권한**: Import/Export 작업은 적절한 권한이 필요합니다

## 참고 자료

- NetBox 공식 문서: https://docs.netbox.dev/
- CSV Import 가이드: https://docs.netbox.dev/en/stable/models/
- API 문서: http://localhost:8000/api/docs/
