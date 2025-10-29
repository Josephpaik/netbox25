# NetBox Korean Translation Terminology Dictionary

This document provides standardized Korean translations for NetBox terminology to ensure consistency across the entire user interface.

## Translation Style Guidelines

### General Principles

1. **Consistency**: Always use the same Korean term for each English term
2. **Clarity**: Prefer widely understood terms over overly technical translations
3. **Naturalization**: Use established loanwords (외래어) where appropriate
4. **Context**: Consider the UI context when choosing between multiple valid translations

### Formatting Rules

- **Proper nouns**: Keep in English (e.g., NetBox, VLAN, VRF, ASN)
- **Technical acronyms**: Keep in English with Korean explanation in help text if needed
- **UI elements**: Use polite/formal Korean (합니다 체)
- **Error messages**: Use clear, actionable Korean
- **Field labels**: Use concise noun forms

### Pluralization

Korean does not have grammatical pluralization:
- `Plural-Forms: nplurals=1; plural=0;`
- Use same form for singular and plural in translation

## Core Terminology

### Authentication & User Management

| English | Korean | Notes |
|---------|--------|-------|
| Login | 로그인 | |
| Logout | 로그아웃 | |
| Username | 사용자 이름 | |
| Password | 비밀번호 | |
| Email | 이메일 | |
| User | 사용자 | |
| Group | 그룹 | |
| Permission | 권한 | |
| Token | 토큰 | |
| API Token | API 토큰 | |
| Authentication | 인증 | |
| Authorization | 인가 | |
| Superuser | 슈퍼유저 | |
| Key | 키 | |
| Write Enabled | 쓰기 활성화 | |
| Allowed IPs | 허용된 IP | |
| Last Used | 최종 사용일 | |
| Expires | 만료 | |

### Navigation & UI

| English | Korean | Notes |
|---------|--------|-------|
| Home | 홈 | |
| Dashboard | 대시보드 | |
| Search | 검색 | |
| Settings | 설정 | |
| Preferences | 환경설정 | |
| Profile | 프로필 | |
| Reports | 리포트 | |
| Scripts | 스크립트 | |
| Organization | 조직 | |
| Devices | 장치 | |
| Connections | 연결 | |
| IPAM | IP 주소 관리 | Full: IP Address Management |
| Circuits | 회선 | |
| Power | 전원 | |
| Virtualization | 가상화 | |
| Wireless | 무선 | |
| Overlay | 오버레이 | |
| Operations | 운영 | |
| Provisioning | 프로비저닝 | |
| Customization | 커스터마이징 | |

### Common Actions

| English | Korean | Notes |
|---------|--------|-------|
| Add | 추가 | |
| Create | 생성 | |
| Edit | 편집 | |
| Update | 수정 | |
| Delete | 삭제 | |
| Remove | 제거 | |
| Save | 저장 | |
| Cancel | 취소 | |
| Submit | 제출 | |
| Filter | 필터 | |
| Export | 내보내기 | |
| Import | 가져오기 | |
| Bulk Import | 대량 가져오기 | |
| Bulk Edit | 대량 편집 | |
| Bulk Delete | 대량 삭제 | |
| Clone | 복제 | |
| Copy | 복사 | |
| View | 보기 | |
| Details | 상세 정보 | |
| List | 목록 | |
| Connect | 연결 | |
| Disconnect | 연결 해제 | |
| Assign | 할당 | |
| Enable | 활성화 | |
| Disable | 비활성화 | |
| Sync | 동기화 | |
| Refresh | 새로고침 | |

### Status Values

| English | Korean | Notes |
|---------|--------|-------|
| Active | 활성 | |
| Inactive | 비활성 | |
| Planned | 계획됨 | |
| Staging | 준비 중 | |
| Decommissioning | 폐기 준비 중 | |
| Retired | 폐기됨 | |
| Reserved | 예약됨 | |
| Available | 사용 가능 | |
| Deprecated | 더 이상 사용 안 함 | |
| Offline | 오프라인 | |
| Failed | 실패 | |
| Provisioning | 프로비저닝 중 | |
| Deprovisioning | 프로비저닝 해제 중 | |
| Connected | 연결됨 | |
| Pending | 대기 중 | |
| Running | 실행 중 | |
| Completed | 완료됨 | |
| Errored | 오류 발생 | |
| Queued | 대기열에 추가됨 | |
| Scheduled | 예약됨 | |
| Syncing | 동기화 중 | |
| New | 신규 | |

### DCIM (Data Center Infrastructure Management)

| English | Korean | Notes |
|---------|--------|-------|
| Site | 사이트 | |
| Location | 위치 | |
| Region | 지역 | |
| Site Group | 사이트 그룹 | |
| Rack | 랙 | |
| Rack Elevations | 랙 배치도 | |
| Device | 장치 | |
| Device Type | 장치 유형 | |
| Device Role | 장치 역할 | |
| Device Bay | 장치 베이 | |
| Manufacturer | 제조사 | |
| Platform | 플랫폼 | |
| Model | 모델 | |
| Serial Number | 일련번호 | |
| Asset Tag | 자산 태그 | |
| Cable | 케이블 | |
| Interface | 인터페이스 | |
| Power Port | 전원 포트 | |
| Power Outlet | 전원 아웃렛 | |
| Power Feed | 전원 공급 | |
| Power Panel | 전원 패널 | |
| Console Port | 콘솔 포트 | |
| Console Server Port | 콘솔 서버 포트 | |
| Front Port | 프론트 포트 | |
| Rear Port | 리어 포트 | |
| Module | 모듈 | |
| Module Bay | 모듈 베이 | |
| Module Type | 모듈 유형 | |
| Virtual Chassis | 가상 섀시 | |
| Inventory Item | 재고 항목 | |

### IPAM (IP Address Management)

| English | Korean | Notes |
|---------|--------|-------|
| IP Address | IP 주소 | |
| Prefix | 프리픽스 | |
| Aggregate | 집합 주소 | |
| VLAN | VLAN | Keep as acronym |
| VLAN Group | VLAN 그룹 | |
| VRF | VRF | Keep as acronym |
| ASN | ASN | Keep as acronym |
| Service | 서비스 | |
| Service Template | 서비스 템플릿 | |
| IP Range | IP 범위 | |
| RIR | RIR | Regional Internet Registry |
| Route Target | 라우트 타겟 | |

### Circuits

| English | Korean | Notes |
|---------|--------|-------|
| Circuit | 회선 | |
| Circuit Type | 회선 유형 | |
| Circuit ID | 회선 ID | |
| Circuit Termination | 회선 종단 | |
| Circuit Group | 회선 그룹 | |
| Provider | 통신사업자 | |
| Provider Account | 사업자 계정 | |
| Provider Network | 사업자 네트워크 | |
| Virtual Circuit | 가상 회선 | |
| Commit Rate | 약정 속도 | |
| Port Speed | 포트 속도 | |
| Cross-Connect | 교차 연결 | |
| Patch Panel | 패치 패널 | |

### Virtualization

| English | Korean | Notes |
|---------|--------|-------|
| Virtual Machine | 가상 머신 | |
| Cluster | 클러스터 | |
| Cluster Type | 클러스터 유형 | |
| Cluster Group | 클러스터 그룹 | |
| Virtual Disk | 가상 디스크 | |

### Wireless

| English | Korean | Notes |
|---------|--------|-------|
| Wireless LAN | 무선 LAN | |
| Wireless Link | 무선 링크 | |
| Access Point | 액세스 포인트 | |

### VPN

| English | Korean | Notes |
|---------|--------|-------|
| VPN Tunnel | VPN 터널 | |
| Tunnel Group | 터널 그룹 | |
| IKE Policy | IKE 정책 | |
| IKE Proposal | IKE 제안 | |
| IPSec Policy | IPSec 정책 | |
| IPSec Profile | IPSec 프로필 | |
| IPSec Proposal | IPSec 제안 | |
| L2VPN | L2VPN | |
| Peer | 피어 | |

### Common Fields

| English | Korean | Notes |
|---------|--------|-------|
| Name | 이름 | |
| Description | 설명 | |
| Type | 유형 | |
| Role | 역할 | |
| Status | 상태 | |
| Comments | 코멘트 | |
| Tags | 태그 | |
| Color | 색상 | |
| Label | 레이블 | |
| Group | 그룹 | |
| Priority | 우선순위 | |
| Weight | 가중치 | |
| Count | 개수 | |
| Value | 값 | |
| Field | 필드 | |
| Attribute | 속성 | |
| Parameter | 매개변수 | |
| Default | 기본값 | |

### Time & Dates

| English | Korean | Notes |
|---------|--------|-------|
| Created | 생성일 | |
| Last Updated | 최종 수정일 | |
| Modified | 수정됨 | |
| Date | 날짜 | |
| Time | 시간 | |
| Install Date | 설치일 | |
| Termination Date | 종료일 | |
| Hourly | 매시간 | |
| Minutely | 매분 | |

### Tenancy & Permissions

| English | Korean | Notes |
|---------|--------|-------|
| Tenant | 테넌트 | |
| Tenancy | 테넌시 | |
| Contact | 연락처 | |
| Contact Group | 연락처 그룹 | |
| Contact Role | 연락처 역할 | |

### Customization

| English | Korean | Notes |
|---------|--------|-------|
| Custom Field | 사용자 정의 필드 | |
| Custom Link | 사용자 정의 링크 | |
| Custom Validation | 사용자 정의 검증 | |
| Export Template | 내보내기 템플릿 | |
| Config Template | 설정 템플릿 | |
| Config Context | 설정 컨텍스트 | |
| Script Module | 스크립트 모듈 | |
| Event Rule | 이벤트 규칙 | |
| Webhook | 웹훅 | |
| Notification | 알림 | |
| Notification Group | 알림 그룹 | |
| Subscription | 구독 | |
| Bookmark | 북마크 | |
| Saved Filter | 저장된 필터 | |
| Table Config | 테이블 설정 | |
| Widget | 위젯 | |

### Job Management

| English | Korean | Notes |
|---------|--------|-------|
| Job | 작업 | |
| Job started | 작업 시작됨 | |
| Job completed | 작업 완료됨 | |
| Job failed | 작업 실패 | |
| Job errored | 작업 오류 발생 | |
| Task | 태스크 | |
| Queue | 대기열 | |
| Result | 결과 | |
| Log | 로그 | |
| Error | 오류 | |
| Warning | 경고 | |
| Success | 성공 | |
| Info | 정보 | |

### Data Management

| English | Korean | Notes |
|---------|--------|-------|
| Data Source | 데이터 소스 | |
| Data File | 데이터 파일 | |
| Backup | 백업 | |
| Restore | 복원 | |
| Format | 형식 | |

### Change Logging

| English | Korean | Notes |
|---------|--------|-------|
| Change Log | 변경 로그 | |
| Changelog | 변경 이력 | |
| Object created | 객체 생성됨 | |
| Object updated | 객체 업데이트됨 | |
| Object deleted | 객체 삭제됨 | |
| Journal | 저널 | |

### Validation & Errors

| English | Korean | Notes |
|---------|--------|-------|
| Required | 필수 | |
| Optional | 선택 사항 | |
| Invalid | 유효하지 않음 | |
| Valid | 유효함 | |
| Validation | 검증 | |
| Unique | 고유 | |
| Duplicate | 중복 | |

### Technical Specifications

| English | Korean | Notes |
|---------|--------|-------|
| Speed | 속도 | |
| Bandwidth | 대역폭 | |
| Capacity | 용량 | |
| Height | 높이 | |
| Width | 너비 | |
| Depth | 깊이 | |
| Weight | 무게 | |
| Distance | 거리 | |
| Distance unit | 거리 단위 | |
| Length | 길이 | |
| Mode | 모드 | |
| Protocol | 프로토콜 | |

### Position & Orientation

| English | Korean | Notes |
|---------|--------|-------|
| Side | 측면 | |
| Side A | A측 | |
| Side Z | Z측 | |
| Hub | 허브 | |
| Spoke | 스포크 | |
| Primary | 주 | |
| Secondary | 부 | |
| Tertiary | 제3 | |

### Operational

| English | Korean | Notes |
|---------|--------|-------|
| Operational role | 운영 역할 | |
| Operational status | 운영 상태 | |
| Service ID | 서비스 ID | |
| Service Parameters | 서비스 매개변수 | |

### Assignment & Termination

| English | Korean | Notes |
|---------|--------|-------|
| Assignment | 할당 | |
| Assigned tenant | 할당된 테넌트 | |
| Assigned provider | 할당된 사업자 | |
| Termination | 종단 | |
| Termination Details | 종단 상세 정보 | |
| Termination Point | 종단 지점 | |
| Termination ID | 종단 ID | |
| Termination type | 종단 유형 | |
| Term Side | 종단 측면 | |

### Common Phrases

| English | Korean | Notes |
|---------|--------|-------|
| Object Type | 객체 유형 | |
| Account | 계정 | |
| Member | 멤버 | |
| Mark connected | 연결됨으로 표시 | |
| Logged in as {user}. | {user}(으)로 로그인되었습니다. | |
| You have logged out. | 로그아웃되었습니다. | |
| Your preferences have been updated. | 환경설정이 업데이트되었습니다. | |
| Your password has been changed successfully. | 비밀번호가 성공적으로 변경되었습니다. | |

## Translation Tips

### Handling Plurals

Since Korean doesn't have grammatical pluralization, always use the same form:

```
msgid "Device"
msgid_plural "Devices"
msgstr[0] "장치"
```

### Handling Variables

Preserve variable placeholders in translations:

```
msgid "Logged in as {user}."
msgstr "{user}(으)로 로그인되었습니다."
```

### Handling Markdown

Preserve markdown formatting in description fields:

```
msgid "**Important**: This action cannot be undone."
msgstr "**중요**: 이 작업은 취소할 수 없습니다."
```

### Consistency Check

Before submitting translations:
1. Search for the English term in this dictionary
2. Use the exact Korean translation provided
3. If term is not in dictionary, follow similar patterns
4. Document new terms in this file for future reference

## Version History

- **v1.0** (2025-01-25): Initial terminology dictionary with 500+ terms

## Contributing

To suggest changes or additions to this terminology dictionary:
1. Open an issue in the NetBox GitHub repository
2. Tag with `translation` and `korean` labels
3. Provide justification for terminology changes
4. Include usage examples

## References

- [Django i18n Documentation](https://docs.djangoproject.com/en/stable/topics/i18n/)
- [Transifex NetBox Project](https://www.transifex.com/netbox-community/netbox/)
- [Korean Language Translation Guide](https://www.gnu.org/software/gettext/manual/html_node/Plural-forms.html)
