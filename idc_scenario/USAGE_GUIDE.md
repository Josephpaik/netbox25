# NetBox IDC 시나리오 사용 가이드

## 목차

1. [시작하기](#시작하기)
2. [Web UI를 통한 Import](#web-ui를-통한-import)
3. [Python 스크립트를 통한 Import](#python-스크립트를-통한-import)
4. [API를 통한 Import](#api를-통한-import)
5. [데이터 Export](#데이터-export)
6. [시뮬레이션 시나리오](#시뮬레이션-시나리오)
7. [문제 해결](#문제-해결)

---

## 시작하기

### 필수 요구사항

1. **NetBox 설치 및 실행**
   ```bash
   # NetBox 개발 서버 실행
   cd /home/user/netbox25/netbox
   python manage.py runserver
   ```

2. **API 토큰 생성**
   - NetBox UI 로그인: http://localhost:8000
   - 우측 상단 사용자 메뉴 → "Profile" → "API Tokens"
   - "Add a token" 버튼 클릭
   - "Write enabled" 체크 (읽기/쓰기 권한 필요)
   - 생성된 토큰 복사 (나중에 다시 볼 수 없으므로 안전하게 보관)

3. **CSV 파일 확인**
   ```bash
   cd /home/user/netbox25/idc_scenario/csv_templates
   ls -la
   ```

---

## Web UI를 통한 Import

NetBox Web UI를 통해 CSV 파일을 직접 업로드할 수 있습니다.

### 단계별 가이드

#### 1단계: Sites Import

1. **네비게이션**
   - 메뉴: `Organization` → `Sites`
   - 또는 URL: http://localhost:8000/dcim/sites/

2. **Import 버튼 클릭**
   - 우측 상단의 `Import` 버튼 클릭

3. **CSV 데이터 입력**
   - "CSV Data" 텍스트 영역에 `01_sites.csv` 파일 내용을 붙여넣기
   - 또는 "Choose File" 버튼으로 파일 업로드

4. **필드 매핑 확인**
   - NetBox가 자동으로 CSV 헤더를 필드에 매핑
   - 필요시 드롭다운에서 수동 조정

5. **Submit**
   - 하단의 `Submit` 버튼 클릭
   - 검증 오류가 있으면 빨간색으로 표시됨
   - 성공하면 "Imported X sites" 메시지 표시

#### 2단계: Manufacturers Import

1. `DCIM` → `Devices` → `Manufacturers`
2. `Import` 버튼 클릭
3. `02_manufacturers.csv` 파일 내용 붙여넣기
4. Submit

#### 3단계: Device Roles Import

1. `DCIM` → `Devices` → `Device Roles`
2. `Import` 버튼 클릭
3. `03_device_roles.csv` 파일 내용 붙여넣기
4. Submit

#### 4단계: Device Types Import

1. `DCIM` → `Devices` → `Device Types`
2. `Import` 버튼 클릭
3. `04_device_types.csv` 파일 내용 붙여넣기
4. **주의**: `manufacturer` 필드는 이미 생성된 Manufacturer의 이름과 정확히 일치해야 함
5. Submit

#### 5단계: Locations Import

1. `DCIM` → `Sites & Racks` → `Locations`
2. `Import` 버튼 클릭
3. `05_locations.csv` 파일 내용 붙여넣기
4. **주의**: `site` 필드는 이미 생성된 Site의 이름과 일치해야 함
5. Submit

#### 6단계: Racks Import

1. `DCIM` → `Sites & Racks` → `Racks`
2. `Import` 버튼 클릭
3. `06_racks.csv` 파일 내용 붙여넣기
4. Submit

#### 7-8단계: Devices Import

1. `DCIM` → `Devices` → `Devices`
2. `Import` 버튼 클릭
3. **먼저** `07_devices_datacenter.csv` 업로드 (데이터센터 장비)
4. 완료 후 다시 Import 페이지로 이동
5. `08_devices_test.csv` 업로드 (테스트 장비)

#### 9단계: Interfaces Import

1. `DCIM` → `Devices` → `Interfaces`
2. `Import` 버튼 클릭
3. `09_interfaces.csv` 파일 내용 붙여넣기
4. **주의**: `device` 필드는 "장비명" 형식 (예: SMS-WEB01)
5. Submit

#### 10단계: VLANs Import

1. `IPAM` → `VLANs`
2. `Import` 버튼 클릭
3. `10_vlans.csv` 파일 내용 붙여넣기
4. Submit

#### 11단계: Prefixes Import

1. `IPAM` → `Prefixes`
2. `Import` 버튼 클릭
3. `11_prefixes.csv` 파일 내용 붙여넣기
4. Submit

#### 12단계: IP Addresses Import

1. `IPAM` → `IP Addresses`
2. `Import` 버튼 클릭
3. `12_ip_addresses.csv` 파일 내용 붙여넣기
4. **주의**: `assigned_object` 형식은 "장비명:인터페이스명" (예: SMS-WEB01:eno2)
5. Submit

### Web UI Import 장점

- 시각적 피드백 (즉시 오류 확인)
- 필드 매핑 자동/수동 조정 가능
- 단계별 진행 가능
- 개별 레코드 수정 용이

### Web UI Import 단점

- 대량 데이터 업로드 시 시간 소요
- 반복 작업에 부적합
- 의존성 순서를 수동으로 관리해야 함

---

## Python 스크립트를 통한 Import

대량 데이터를 자동으로 업로드하려면 제공된 Python 스크립트를 사용하세요.

### 설치

```bash
# 필수 라이브러리 설치
pip install requests

# 스크립트 실행 권한 부여
chmod +x upload_script.py
```

### 사용법

#### 1. 연결 테스트

```bash
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_API_TOKEN_HERE \
  --test
```

출력 예시:
```
✓ NetBox 연결 성공: http://localhost:8000
✓ 연결 테스트 완료!
```

#### 2. Dry Run (검증만 수행, 실제 업로드 안 함)

```bash
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_API_TOKEN_HERE \
  --dry-run
```

출력 예시:
```
================================================================================
NetBox IDC Scenario 검증 시작
================================================================================

[DRY RUN] 업로드 중: 01_sites.csv -> dcim/sites
--------------------------------------------------------------------------------
  ✓ [1] SMS Pangyo (검증 통과)
--------------------------------------------------------------------------------
결과: 성공 1, 실패 0

...

================================================================================
검증 완료
================================================================================

총 결과:
  - 성공: 39
  - 실패: 0

✓ 모든 데이터가 성공적으로 검증되었습니다!
```

#### 3. 실제 업로드

```bash
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_API_TOKEN_HERE
```

#### 4. 특정 파일만 업로드

```bash
python upload_script.py \
  --url http://localhost:8000 \
  --token YOUR_API_TOKEN_HERE \
  --file 01_sites.csv
```

### Python 스크립트 장점

- 자동화 가능 (CI/CD 통합)
- 대량 데이터 빠른 처리
- 의존성 순서 자동 관리
- 오류 로깅 및 재시도 가능
- Dry run으로 사전 검증

### Python 스크립트 단점

- 초기 설정 필요 (Python, 라이브러리)
- 커맨드 라인 사용 필요
- 오류 발생 시 디버깅 어려움

---

## API를 통한 Import

NetBox REST API를 직접 사용하여 데이터를 업로드할 수 있습니다.

### cURL 예시

#### Site 생성

```bash
curl -X POST http://localhost:8000/api/dcim/sites/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "SMS Pangyo",
    "slug": "sms-pangyo",
    "status": "active",
    "physical_address": "경기도 성남시 분당구 판교역로 166",
    "description": "SMS 사 본사 사옥"
  }'
```

#### Device 생성

```bash
curl -X POST http://localhost:8000/api/dcim/devices/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "SMS-WEB01",
    "device_type": 1,
    "device_role": 6,
    "site": 1,
    "status": "active"
  }'
```

### Python requests 예시

```python
import requests

NETBOX_URL = "http://localhost:8000"
TOKEN = "your-token-here"

headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

# Site 생성
site_data = {
    "name": "SMS Pangyo",
    "slug": "sms-pangyo",
    "status": "active"
}

response = requests.post(
    f"{NETBOX_URL}/api/dcim/sites/",
    headers=headers,
    json=site_data
)

if response.status_code == 201:
    site = response.json()
    print(f"Site created: {site['id']}")
else:
    print(f"Error: {response.json()}")
```

---

## 데이터 Export

NetBox에서 데이터를 Export하는 방법입니다.

### Web UI Export

1. **리스트 페이지 이동**
   - 예: `DCIM` → `Devices`

2. **필터 적용** (선택사항)
   - 좌측 필터 패널에서 조건 선택
   - 예: Status=Active, Site=SMS Pangyo

3. **Export 버튼 클릭**
   - 우측 상단 `Export` 드롭다운 메뉴

4. **형식 선택**
   - **CSV**: 표 형식, Excel에서 열기 가능
   - **YAML**: 구조화된 데이터, 재import 용이
   - **Export Template**: 커스텀 템플릿 (JSON, XML 등)

5. **파일 다운로드**
   - 브라우저 다운로드 폴더에 저장

### API Export

#### 모든 Devices 조회

```bash
curl -X GET "http://localhost:8000/api/dcim/devices/?limit=1000" \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Accept: application/json"
```

#### 특정 조건으로 필터링

```bash
# Active 상태의 Web Server만 조회
curl -X GET "http://localhost:8000/api/dcim/devices/?status=active&role=web-server" \
  -H "Authorization: Token YOUR_TOKEN" \
  -H "Accept: application/json"
```

#### Python으로 Export

```python
import requests
import csv

NETBOX_URL = "http://localhost:8000"
TOKEN = "your-token-here"

headers = {"Authorization": f"Token {TOKEN}"}

# 모든 Devices 조회
response = requests.get(
    f"{NETBOX_URL}/api/dcim/devices/",
    headers=headers,
    params={"limit": 1000}
)

devices = response.json()['results']

# CSV로 저장
with open('devices_export.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['name', 'status', 'site', 'device_type'])
    writer.writeheader()

    for device in devices:
        writer.writerow({
            'name': device['name'],
            'status': device['status']['value'],
            'site': device['site']['name'],
            'device_type': device['device_type']['model']
        })

print(f"Exported {len(devices)} devices to devices_export.csv")
```

---

## 시뮬레이션 시나리오

실제 IDC 운영 시나리오를 시뮬레이션합니다.

### 시나리오 1: 신규 서버 프로비저닝

**목표**: 데이터센터에 새로운 웹 서버를 추가

```python
import requests

NETBOX_URL = "http://localhost:8000"
TOKEN = "your-token-here"

headers = {
    "Authorization": f"Token {TOKEN}",
    "Content-Type": "application/json"
}

# 1. Device 생성
device_data = {
    "name": "SMS-WEB05",
    "device_type": 1,  # Dell PowerEdge R650
    "device_role": 6,  # Web Server
    "site": 1,         # SMS Pangyo
    "location": 2,     # B1F Datacenter
    "rack": 2,         # DC-R02
    "position": 31,
    "face": "front",
    "status": "planned",
    "serial": "SN-WEB05-2024024",
    "asset_tag": "ASSET-024",
    "description": "웹 서버 05 - 신규 마이크로서비스"
}

response = requests.post(
    f"{NETBOX_URL}/api/dcim/devices/",
    headers=headers,
    json=device_data
)

device_id = response.json()['id']
print(f"Device created: {device_id}")

# 2. Interface 생성
interface_data = {
    "device": device_id,
    "name": "eno2",
    "type": "1000base-t",
    "enabled": True
}

response = requests.post(
    f"{NETBOX_URL}/api/dcim/interfaces/",
    headers=headers,
    json=interface_data
)

interface_id = response.json()['id']
print(f"Interface created: {interface_id}")

# 3. IP Address 할당
ip_data = {
    "address": "10.100.10.14/24",
    "status": "active",
    "dns_name": "web05.sms.local",
    "assigned_object_type": "dcim.interface",
    "assigned_object_id": interface_id
}

response = requests.post(
    f"{NETBOX_URL}/api/ipam/ip-addresses/",
    headers=headers,
    json=ip_data
)

print(f"IP assigned: {response.json()['address']}")

# 4. 상태를 Active로 변경
response = requests.patch(
    f"{NETBOX_URL}/api/dcim/devices/{device_id}/",
    headers=headers,
    json={"status": "active"}
)

print("Server provisioning completed!")
```

### 시나리오 2: 테스트 제품 관리

**목표**: 새로운 테스트 제품 반입 → 테스트 → 출하

```python
# 1. 테스트 제품 반입 (상태: planned)
test_device = {
    "name": "SMS-TEST-SG3K-004",
    "device_type": 12,  # SMS SecureGate SG-3000
    "device_role": 14,  # Security Appliance
    "site": 1,
    "location": 3,      # 3F Test Lab
    "rack": 13,         # TEST-R01
    "position": 22,
    "status": "planned",
    "serial": "SN-SG3K-2025004",
    "description": "고객사 D 납품 예정"
}

response = requests.post(f"{NETBOX_URL}/api/dcim/devices/", headers=headers, json=test_device)
device_id = response.json()['id']
print(f"Test device registered: {device_id}")

# 2. 테스트 시작 (상태: staged)
requests.patch(
    f"{NETBOX_URL}/api/dcim/devices/{device_id}/",
    headers=headers,
    json={"status": "staged", "comments": "1주일 단기 테스트 시작"}
)
print("Test started (staged)")

# 3. 테스트 완료, 출하 대기 (상태: inventory)
requests.patch(
    f"{NETBOX_URL}/api/dcim/devices/{device_id}/",
    headers=headers,
    json={"status": "inventory", "comments": "테스트 완료, 출하 대기 중"}
)
print("Test completed (inventory)")

# 4. 출하 완료 (상태: decommissioning)
requests.patch(
    f"{NETBOX_URL}/api/dcim/devices/{device_id}/",
    headers=headers,
    json={"status": "decommissioning", "comments": "고객사 D에 납품 완료"}
)
print("Shipped (decommissioning)")

# 5. 기록 삭제 (선택사항)
# requests.delete(f"{NETBOX_URL}/api/dcim/devices/{device_id}/", headers=headers)
# print("Device record deleted")
```

### 시나리오 3: 네트워크 장애 대응

**목표**: 장애 발생 장비를 offline 상태로 변경하고, 예비 장비 활성화

```python
# 1. 장애 장비 상태 변경
failed_device_id = 20  # SMS-WEB01

requests.patch(
    f"{NETBOX_URL}/api/dcim/devices/{failed_device_id}/",
    headers=headers,
    json={
        "status": "offline",
        "comments": "디스크 장애 발생, 긴급 점검 필요"
    }
)
print("Failed device marked as offline")

# 2. 예비 장비 활성화
spare_device_id = 30  # 예비 서버

requests.patch(
    f"{NETBOX_URL}/api/dcim/devices/{spare_device_id}/",
    headers=headers,
    json={
        "status": "active",
        "comments": "SMS-WEB01 장애 대체 투입"
    }
)
print("Spare device activated")

# 3. IP 주소 재할당
old_ip = "10.100.10.10/24"

# 기존 IP 할당 해제
response = requests.get(
    f"{NETBOX_URL}/api/ipam/ip-addresses/",
    headers=headers,
    params={"address": old_ip}
)
ip_id = response.json()['results'][0]['id']

requests.patch(
    f"{NETBOX_URL}/api/ipam/ip-addresses/{ip_id}/",
    headers=headers,
    json={"assigned_object_type": None, "assigned_object_id": None}
)

# 새 장비에 IP 할당
# (Interface ID를 먼저 조회해야 함)
print("IP reassigned to spare device")
```

### 시나리오 4: 정기 점검 리포트

**목표**: 모든 장비 상태를 조회하여 리포트 생성

```python
import csv
from datetime import datetime

# 모든 장비 조회
response = requests.get(
    f"{NETBOX_URL}/api/dcim/devices/",
    headers=headers,
    params={"limit": 1000}
)

devices = response.json()['results']

# 상태별 통계
status_count = {}
for device in devices:
    status = device['status']['label']
    status_count[status] = status_count.get(status, 0) + 1

print("=== 장비 상태 통계 ===")
for status, count in status_count.items():
    print(f"{status}: {count}대")

# CSV 리포트 생성
report_filename = f"device_report_{datetime.now().strftime('%Y%m%d')}.csv"

with open(report_filename, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Name', 'Status', 'Site', 'Location', 'Rack', 'Serial', 'Last Updated'])

    for device in devices:
        writer.writerow([
            device['name'],
            device['status']['label'],
            device['site']['name'],
            device['location']['name'] if device['location'] else 'N/A',
            device['rack']['name'] if device['rack'] else 'N/A',
            device['serial'] or 'N/A',
            device['last_updated']
        ])

print(f"Report saved: {report_filename}")
```

---

## 문제 해결

### 일반적인 오류

#### 1. "Object with this slug already exists"

**원인**: slug 필드가 중복됨

**해결**:
- 기존 객체를 삭제하거나
- CSV 파일에서 slug 값을 변경

#### 2. "Unable to resolve device type"

**원인**: DeviceType이 아직 생성되지 않음

**해결**:
- Import 순서 확인: Manufacturer → DeviceType → Device
- DeviceType CSV에서 manufacturer 이름이 정확한지 확인

#### 3. "Invalid choice for status"

**원인**: 잘못된 status 값

**해결**:
- 허용되는 값 확인:
  - Device: `planned`, `staged`, `active`, `offline`, `decommissioning`, `inventory`
  - Site: `planned`, `staging`, `active`, `decommissioning`, `retired`

#### 4. "position is already occupied"

**원인**: 랙의 동일한 위치에 이미 장비가 있음

**해결**:
- CSV에서 position 값을 변경
- 또는 기존 장비를 다른 위치로 이동

#### 5. API 토큰 인증 실패

**원인**: 잘못된 토큰 또는 권한 부족

**해결**:
- 토큰 재생성: Profile → API Tokens
- "Write enabled" 체크 확인
- 토큰을 환경 변수로 저장:
  ```bash
  export NETBOX_TOKEN="your-token-here"
  python upload_script.py --url http://localhost:8000 --token $NETBOX_TOKEN
  ```

### 디버깅 팁

#### 1. API 응답 확인

```bash
# 상세 응답 보기
curl -v -X GET "http://localhost:8000/api/dcim/devices/" \
  -H "Authorization: Token YOUR_TOKEN"
```

#### 2. NetBox 로그 확인

```bash
# Django 개발 서버 로그 확인
cd /home/user/netbox25/netbox
python manage.py runserver
# 터미널에 실시간 로그 출력됨
```

#### 3. 데이터베이스 직접 확인

```bash
# PostgreSQL 접속
psql -U netbox -d netbox

# 테이블 조회
SELECT * FROM dcim_site;
SELECT * FROM dcim_device WHERE name LIKE 'SMS-%';
```

#### 4. Python 스크립트 디버깅

```python
# 상세 로깅 추가
import logging

logging.basicConfig(level=logging.DEBUG)

response = requests.post(url, json=data)
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")
```

---

## 추가 자료

- **NetBox 공식 문서**: https://docs.netbox.dev/
- **API 문서 (Swagger)**: http://localhost:8000/api/docs/
- **API 문서 (ReDoc)**: http://localhost:8000/api/redoc/
- **NetBox GitHub**: https://github.com/netbox-community/netbox
- **NetBox 커뮤니티**: https://github.com/netbox-community/netbox/discussions

---

## 연락처

문제가 발생하거나 질문이 있으시면:
- NetBox GitHub Issues: https://github.com/netbox-community/netbox/issues
- NetBox Slack: https://netdev.chat/ (#netbox 채널)
