# NetBox 사용자 가이드

> **대상**: Windows/macOS 사용자
> **목적**: NetBox를 사용하여 네트워크 인프라 정보 관리

---

## 목차

1. [시작하기](#1-시작하기)
2. [기본 인터페이스](#2-기본-인터페이스)
3. [네트워크 장비 관리](#3-네트워크-장비-관리)
4. [IP 주소 관리](#4-ip-주소-관리)
5. [랙 및 위치 관리](#5-랙-및-위치-관리)
6. [CSV 데이터 가져오기/내보내기](#6-csv-데이터-가져오기내보내기)
7. [검색 및 필터링](#7-검색-및-필터링)
8. [보고서 생성](#8-보고서-생성)
9. [자주 묻는 질문](#9-자주-묻는-질문)

---

## 1. 시작하기

### 1.1 접속 방법

#### Windows 사용자
1. **브라우저 열기**: Chrome, Edge, Firefox 중 하나
2. **주소 입력**: 관리자가 제공한 URL 입력
   - 예: `https://netbox.example.com`
   - 또는 `http://192.168.1.100`

#### macOS 사용자
1. **브라우저 열기**: Safari, Chrome, Firefox 중 하나
2. **주소 입력**: 관리자가 제공한 URL 입력

**권장 브라우저**:
- Google Chrome (최신 버전)
- Microsoft Edge (최신 버전)
- Mozilla Firefox (최신 버전)
- Safari (macOS 최신 버전)

### 1.2 로그인

1. NetBox 홈페이지 접속
2. 우측 상단 **Log In** 버튼 클릭
3. 관리자가 제공한 계정 정보 입력:
   - **Username**: 사용자 이름
   - **Password**: 비밀번호
4. **Log In** 버튼 클릭

![로그인 화면 예시]

### 1.3 첫 로그인 후 비밀번호 변경 (권장)

1. 우측 상단 **사용자 아이콘** 클릭
2. **Profile** 메뉴 선택
3. **Change Password** 탭 클릭
4. 새 비밀번호 입력 및 확인
5. **Update** 버튼 클릭

---

## 2. 기본 인터페이스

### 2.1 메인 네비게이션

NetBox 상단에는 주요 메뉴가 있습니다:

#### **Organization** (조직)
- Sites (사이트/지점)
- Locations (위치/층)
- Racks (랙/캐비넷)
- Tenants (테넌트/부서)
- Contacts (연락처)

#### **Devices** (장비)
- Devices (네트워크 장비)
- Device Types (장비 모델)
- Device Roles (장비 역할)
- Platforms (플랫폼/OS)
- Manufacturers (제조사)

#### **Connections** (연결)
- Cables (케이블)
- Interfaces (인터페이스)
- Console Connections (콘솔 연결)
- Power Connections (전원 연결)

#### **IPAM** (IP 주소 관리)
- IP Addresses (IP 주소)
- Prefixes (IP 대역)
- VLANs (VLAN)
- VRFs (가상 라우팅)

#### **Virtualization** (가상화)
- Virtual Machines (가상 머신)
- Clusters (클러스터)
- VM Interfaces (VM 인터페이스)

### 2.2 대시보드

로그인 후 대시보드에서 다음 정보를 확인할 수 있습니다:
- 총 사이트 수
- 총 장비 수
- 총 IP 주소 수
- 최근 변경 내역
- 시스템 상태

---

## 3. 네트워크 장비 관리

### 3.1 장비 목록 보기

1. 상단 메뉴: **Devices > Devices** 클릭
2. 장비 목록이 테이블 형태로 표시됩니다

**테이블 컬럼**:
- Name (이름)
- Status (상태)
- Site (사이트)
- Rack (랙)
- Device Type (모델)
- Device Role (역할)
- IP Address (IP 주소)

### 3.2 장비 상세 정보 보기

1. 장비 목록에서 **장비 이름** 클릭
2. 장비 상세 페이지에서 다음 정보 확인:
   - **Details**: 기본 정보
   - **Interfaces**: 네트워크 인터페이스
   - **IP Addresses**: 할당된 IP
   - **Console Ports**: 콘솔 포트
   - **Power Ports**: 전원 포트
   - **Change Log**: 변경 이력

### 3.3 새 장비 추가

1. **Devices > Devices** 메뉴
2. 우측 상단 **Add** 버튼 클릭
3. 필수 정보 입력:
   - **Name**: 장비 이름 (예: SW-01)
   - **Device Role**: 역할 선택 (예: Switch)
   - **Device Type**: 모델 선택 (예: Cisco Catalyst 2960)
   - **Site**: 사이트 선택
   - **Location**: 위치 선택 (선택사항)
   - **Rack**: 랙 선택 (선택사항)
   - **Status**: 상태 선택 (예: Active)
4. 선택 정보 입력:
   - Serial Number (시리얼 번호)
   - Asset Tag (자산 태그)
   - Comments (설명)
5. **Create** 버튼 클릭

### 3.4 장비 수정

1. 장비 상세 페이지에서 **Edit** 버튼 클릭
2. 정보 수정
3. **Update** 버튼 클릭

### 3.5 장비 삭제

1. 장비 상세 페이지에서 **Delete** 버튼 클릭
2. 확인 팝업에서 **Confirm** 클릭

⚠️ **주의**: 삭제된 데이터는 복구할 수 없습니다!

---

## 4. IP 주소 관리

### 4.1 IP 주소 목록 보기

1. 상단 메뉴: **IPAM > IP Addresses** 클릭
2. 할당된 모든 IP 주소 확인

### 4.2 새 IP 주소 추가

1. **IPAM > IP Addresses** 메뉴
2. **Add** 버튼 클릭
3. 정보 입력:
   - **Address**: IP 주소 (예: 192.168.1.10/24)
   - **VRF**: VRF 선택 (선택사항)
   - **Status**: 상태 (Active, Reserved, Deprecated 등)
   - **DNS Name**: 호스트명 (선택사항)
   - **Description**: 설명
4. **Assignment** 섹션에서:
   - **Interface**: 장비 인터페이스 선택 (선택사항)
5. **Create** 버튼 클릭

### 4.3 IP 대역(Prefix) 관리

1. **IPAM > Prefixes** 메뉴
2. **Add** 버튼으로 새 대역 추가
3. 정보 입력:
   - **Prefix**: IP 대역 (예: 192.168.1.0/24)
   - **Site**: 사이트 선택
   - **VLAN**: VLAN 선택 (선택사항)
   - **Status**: 상태
   - **Description**: 설명
4. **Create** 버튼 클릭

### 4.4 사용 가능한 IP 확인

1. Prefix 상세 페이지에서 **IP Addresses** 탭 클릭
2. **Utilization** 게이지에서 사용률 확인
3. **Available IPs** 버튼 클릭하여 사용 가능한 IP 목록 확인

---

## 5. 랙 및 위치 관리

### 5.1 사이트 관리

#### 사이트 목록 보기
1. **Organization > Sites** 메뉴
2. 모든 사이트 목록 확인

#### 새 사이트 추가
1. **Add** 버튼 클릭
2. 정보 입력:
   - **Name**: 사이트 이름 (예: Seoul Datacenter)
   - **Slug**: URL용 식별자 (자동 생성, 예: seoul-datacenter)
   - **Status**: 상태 (예: Active)
   - **Region**: 지역 (선택사항)
   - **Physical Address**: 실제 주소
   - **Description**: 설명
3. **Create** 버튼 클릭

### 5.2 위치(Location) 관리

위치는 사이트 내의 물리적 위치를 나타냅니다 (예: 건물, 층, 방).

1. **Organization > Locations** 메뉴
2. **Add** 버튼으로 새 위치 추가:
   - **Name**: 위치 이름 (예: B1F-DataCenter)
   - **Site**: 소속 사이트 선택
   - **Parent**: 상위 위치 (선택사항, 계층 구조)
   - **Description**: 설명
3. **Create** 버튼 클릭

### 5.3 랙 관리

#### 랙 목록 보기
1. **Organization > Racks** 메뉴
2. 모든 랙 목록 확인

#### 새 랙 추가
1. **Add** 버튼 클릭
2. 정보 입력:
   - **Name**: 랙 이름 (예: DC-RACK-01)
   - **Site**: 사이트 선택
   - **Location**: 위치 선택
   - **Status**: 상태
   - **Height**: 높이 (U 단위, 기본 42U)
   - **Width**: 폭 (19인치, 23인치)
   - **Outer Dimensions**: 외부 치수 (선택사항)
3. **Create** 버튼 클릭

#### 랙 뷰(시각화) 보기
1. 랙 상세 페이지에서 **Elevations** 탭 클릭
2. 랙의 전면/후면 다이어그램에서 장비 배치 확인
3. 빈 공간(U)은 회색으로 표시
4. 장비를 클릭하면 상세 정보 확인 가능

---

## 6. CSV 데이터 가져오기/내보내기

### 6.1 CSV 데이터 가져오기 (Import)

CSV 파일을 사용하여 대량의 데이터를 빠르게 추가할 수 있습니다.

#### 예시: 장비 목록 Import

1. **Devices > Devices** 메뉴
2. 우측 상단 **Import** 버튼 클릭
3. Import 페이지에서 두 가지 방법 선택:
   - **Direct Input**: CSV 내용을 직접 붙여넣기
   - **Upload File**: CSV 파일 업로드

#### Direct Input 방법:
```csv
name,device_role,device_type,site,status
SW-01,Switch,Cisco Catalyst 2960,Seoul DC,active
SW-02,Switch,Cisco Catalyst 2960,Seoul DC,active
FW-01,Firewall,Cisco ASA 5516,Seoul DC,active
```

4. **Submit** 버튼 클릭
5. NetBox가 자동으로 데이터 검증
6. 오류가 없으면 **Create** 버튼 클릭하여 최종 생성

#### CSV 파일 형식 주의사항:
- ✅ **첫 줄은 컬럼 이름 (헤더)**
- ✅ **필수 필드는 반드시 포함**
- ✅ **UTF-8 인코딩 사용**
- ✅ **날짜 형식: YYYY-MM-DD**
- ✅ **외래 키는 이름 또는 slug 사용** (예: site 이름)

#### CSV Template 다운로드:
1. Import 페이지 하단의 **CSV Template** 링크 클릭
2. 샘플 CSV 파일 다운로드
3. 엑셀 또는 텍스트 편집기로 편집
4. 업로드

### 6.2 CSV 데이터 내보내기 (Export)

#### 전체 목록 Export:
1. 목록 페이지 (예: Devices 목록)
2. 우측 상단 **Export** 드롭다운 메뉴 클릭
3. 형식 선택:
   - **CSV**: 쉼표로 구분된 텍스트
   - **YAML**: YAML 형식
   - **Table**: 현재 보이는 테이블 그대로
4. 파일 자동 다운로드

#### 필터링 후 Export:
1. 검색 필터 적용 (예: Status=Active인 장비만)
2. 필터링된 결과에서 **Export** 클릭
3. 선택한 데이터만 Export됨

### 6.3 Excel에서 CSV 편집

#### Windows Excel:
1. CSV 파일을 Excel로 열기
2. 데이터 편집
3. **다른 이름으로 저장** → 형식: **CSV (쉼표로 분리)(*.csv)** 선택
4. 저장 시 인코딩 확인 (UTF-8)

#### macOS Numbers/Excel:
1. CSV 파일을 Numbers 또는 Excel로 열기
2. 데이터 편집
3. **파일 > 내보내기 > CSV** 선택
4. UTF-8 인코딩 확인 후 저장

---

## 7. 검색 및 필터링

### 7.1 전역 검색 (Global Search)

1. 상단 검색 바에 키워드 입력
2. 모든 객체 유형에서 검색
3. 결과는 객체 유형별로 그룹화되어 표시

**검색 가능한 항목**:
- 장비 이름
- IP 주소
- 시리얼 번호
- 자산 태그
- 설명 (Description)
- 코멘트 (Comments)

### 7.2 목록 필터링

각 목록 페이지에서 우측의 **Filters** 패널을 사용하여 필터링할 수 있습니다.

#### 예시: 장비 필터링
1. **Devices > Devices** 메뉴
2. 우측 **Filters** 패널에서:
   - **Site**: 특정 사이트 선택
   - **Status**: Active, Offline 등 선택
   - **Device Role**: Switch, Router 등 선택
   - **Manufacturer**: Cisco, Dell 등 선택
3. **Apply** 버튼 클릭 (자동 적용되는 경우도 있음)

### 7.3 고급 필터

여러 조건을 조합하여 복잡한 검색 가능:

#### 예시: "Seoul DC 사이트의 Active 상태 Cisco 스위치만 보기"
1. **Site** = Seoul DC
2. **Status** = Active
3. **Device Role** = Switch
4. **Manufacturer** = Cisco

### 7.4 필터 저장 (Saved Filters)

자주 사용하는 필터를 저장할 수 있습니다:

1. 필터 설정 후
2. 우측 상단 **Save Filter** 버튼 클릭
3. 필터 이름 입력 (예: "Seoul Active Switches")
4. **Create** 클릭
5. 다음부터 **Saved Filters** 드롭다운에서 빠르게 선택 가능

---

## 8. 보고서 생성

### 8.1 기본 보고서

NetBox는 다양한 내장 보고서를 제공합니다:

1. **Organization > Reports** 메뉴
2. 사용 가능한 보고서 목록 확인
3. 보고서 선택 후 **Run Report** 버튼 클릭

**주요 보고서**:
- IP 주소 사용 현황
- 랙 공간 사용률
- 장비 인벤토리
- VLAN 할당 현황

### 8.2 커스텀 보고서

Export 기능을 사용하여 커스텀 보고서 생성:

1. 원하는 데이터 필터링
2. Export로 CSV 다운로드
3. Excel/Google Sheets에서 분석 및 시각화

### 8.3 API를 통한 자동 보고서

관리자에게 요청하여 API를 사용한 자동 보고서 생성 가능.

---

## 9. 자주 묻는 질문

### Q1: 비밀번호를 잊어버렸어요.
**A**: 관리자에게 연락하여 비밀번호 재설정을 요청하세요.

### Q2: 장비를 삭제했는데 복구할 수 있나요?
**A**: 삭제된 데이터는 복구할 수 없습니다. 중요한 데이터는 삭제 전 관리자와 상의하세요.

### Q3: CSV Import 시 오류가 발생해요.
**A**: 다음 사항을 확인하세요:
- CSV 파일이 UTF-8 인코딩인지 확인
- 필수 필드가 모두 포함되어 있는지 확인
- 외래 키 값(Site, Device Type 등)이 이미 존재하는지 확인
- 오류 메시지를 읽고 해당 행을 수정

### Q4: 여러 장비를 한번에 수정할 수 있나요?
**A**: 네, Bulk Edit 기능을 사용하세요:
1. 목록에서 수정할 장비 체크박스 선택
2. 하단 **Bulk Edit** 버튼 클릭
3. 변경할 필드 값 입력
4. **Apply** 클릭

### Q5: 모바일에서도 사용할 수 있나요?
**A**: 네, NetBox는 반응형 디자인으로 모바일 브라우저에서도 사용 가능합니다. 단, 데스크톱에서 더 편리합니다.

### Q6: 장비의 변경 이력을 볼 수 있나요?
**A**: 네, 장비 상세 페이지의 **Change Log** 탭에서 모든 변경 이력을 확인할 수 있습니다.

### Q7: IP 주소를 자동으로 할당할 수 있나요?
**A**: Prefix 상세 페이지에서 **Available IPs** 버튼을 클릭하면 사용 가능한 IP 목록이 표시되고, **+ Assign** 버튼으로 빠르게 할당할 수 있습니다.

### Q8: 다른 사용자가 누가 작업했는지 알 수 있나요?
**A**: Change Log에서 작업자 이름과 시간을 확인할 수 있습니다.

---

## 10. 유용한 팁

### 💡 Tip 1: 키보드 단축키
- **/** : 전역 검색 포커스
- **Ctrl + K** (Windows) / **Cmd + K** (Mac): 빠른 검색

### 💡 Tip 2: Bulk Operations
대량의 데이터를 처리할 때는 CSV Import/Export를 활용하세요.

### 💡 Tip 3: Tags 활용
장비나 IP에 태그를 추가하여 그룹화하고 빠르게 검색할 수 있습니다.

### 💡 Tip 4: 북마크 기능
자주 사용하는 객체는 북마크에 추가하여 빠르게 접근할 수 있습니다.

### 💡 Tip 5: 코멘트 활용
장비나 IP에 상세한 코멘트를 추가하여 팀원들과 정보를 공유하세요.

---

## 11. 추가 지원

### 📚 참고 자료
- **NetBox 공식 문서**: https://docs.netbox.dev/
- **API 문서**: https://your-netbox-server/api/docs/

### 📞 지원 요청
문제가 발생하거나 질문이 있으면:
1. 관리자에게 이메일 문의
2. 사내 IT 헬프데스크 티켓 생성
3. 스크린샷과 함께 상세한 설명 제공

---

## 축하합니다! 🎉

이제 NetBox를 사용하여 네트워크 인프라를 효율적으로 관리할 수 있습니다.

**다음 단계**:
1. 실습 환경에서 테스트해보기
2. 간단한 장비 추가 연습
3. CSV Import 연습
4. 검색 및 필터링 연습

즐거운 NetBox 사용되세요! 🚀
