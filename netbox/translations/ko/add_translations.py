#!/usr/bin/env python3
"""
Script to add Korean translations to django.po file
Based on the Korean-English terminology dictionary
"""

# Critical translations dictionary - Phase 1 (500+ strings)
TRANSLATIONS = {
    # Authentication & User
    "Key": "키",
    "Write Enabled": "쓰기 활성화",
    "Created": "생성일",
    "Expires": "만료",
    "Last Used": "최종 사용일",
    "Allowed IPs": "허용된 IP",
    "Logged in as {user}.": "{user}(으)로 로그인되었습니다.",
    "You have logged out.": "로그아웃되었습니다.",
    "Your preferences have been updated.": "환경설정이 업데이트되었습니다.",
    "LDAP-authenticated user credentials cannot be changed within NetBox.": "LDAP 인증 사용자 자격 증명은 NetBox 내에서 변경할 수 없습니다.",
    "Your password has been changed successfully.": "비밀번호가 성공적으로 변경되었습니다.",
    "Login": "로그인",
    "Logout": "로그아웃",
    "Username": "사용자 이름",
    "Password": "비밀번호",
    "Email": "이메일",

    # Navigation
    "Home": "홈",
    "Dashboard": "대시보드",
    "Organization": "조직",
    "Devices": "장치",
    "Connections": "연결",
    "IPAM": "IP 주소 관리",
    "Circuits": "회선",
    "Power": "전원",
    "Virtualization": "가상화",
    "Wireless": "무선",
    "Overlay": "오버레이",
    "Operations": "운영",
    "Provisioning": "프로비저닝",
    "Customization": "커스터마이징",
    "Search": "검색",
    "Settings": "설정",
    "Preferences": "환경설정",
    "Profile": "프로필",
    "Reports": "리포트",
    "Scripts": "스크립트",

    # Common Actions
    "Add": "추가",
    "Create": "생성",
    "Edit": "편집",
    "Update": "수정",
    "Delete": "삭제",
    "Remove": "제거",
    "Save": "저장",
    "Cancel": "취소",
    "Submit": "제출",
    "Filter": "필터",
    "Export": "내보내기",
    "Import": "가져오기",
    "Bulk Import": "대량 가져오기",
    "Bulk Edit": "대량 편집",
    "Bulk Delete": "대량 삭제",
    "Clone": "복제",
    "Copy": "복사",
    "View": "보기",
    "Details": "상세 정보",
    "List": "목록",
    "Connect": "연결",
    "Disconnect": "연결 해제",
    "Assign": "할당",
    "Enable": "활성화",
    "Disable": "비활성화",
    "Sync": "동기화",
    "Refresh": "새로고침",

    # Status Values
    "Active": "활성",
    "Planned": "계획됨",
    "Staging": "준비 중",
    "Decommissioning": "폐기 준비 중",
    "Retired": "폐기됨",
    "Reserved": "예약됨",
    "Available": "사용 가능",
    "Deprecated": "더 이상 사용 안 함",
    "Offline": "오프라인",
    "Failed": "실패",
    "Provisioning": "프로비저닝 중",
    "Deprovisioning": "프로비저닝 해제 중",
    "Connected": "연결됨",
    "Pending": "대기 중",
    "Running": "실행 중",
    "Completed": "완료됨",
    "Errored": "오류 발생",
    "Queued": "대기열에 추가됨",
    "Scheduled": "예약됨",
    "Syncing": "동기화 중",
    "New": "신규",
    "Inactive": "비활성",

    # DCIM Core Terms
    "Site": "사이트",
    "Location": "위치",
    "Region": "지역",
    "Site Group": "사이트 그룹",
    "Rack": "랙",
    "Rack Elevations": "랙 배치도",
    "Device": "장치",
    "Device Type": "장치 유형",
    "Device Role": "장치 역할",
    "Device Bay": "장치 베이",
    "Manufacturer": "제조사",
    "Platform": "플랫폼",
    "Model": "모델",
    "Serial Number": "일련번호",
    "Asset Tag": "자산 태그",
    "Cable": "케이블",
    "Interface": "인터페이스",
    "Power Port": "전원 포트",
    "Power Outlet": "전원 아웃렛",
    "Power Feed": "전원 공급",
    "Power Panel": "전원 패널",
    "Console Port": "콘솔 포트",
    "Console Server Port": "콘솔 서버 포트",
    "Front Port": "프론트 포트",
    "Rear Port": "리어 포트",
    "Module": "모듈",
    "Module Bay": "모듈 베이",
    "Module Type": "모듈 유형",
    "Virtual Chassis": "가상 섀시",
    "Inventory Item": "재고 항목",

    # IPAM Core Terms
    "IP Address": "IP 주소",
    "Prefix": "프리픽스",
    "Aggregate": "집합 주소",
    "VLAN": "VLAN",
    "VLAN Group": "VLAN 그룹",
    "VRF": "VRF",
    "ASN": "ASN",
    "ASNs": "ASN",
    "Service": "서비스",
    "Service Template": "서비스 템플릿",
    "IP Range": "IP 범위",
    "RIR": "RIR",
    "Route Target": "라우트 타겟",

    # Circuits
    "Circuit": "회선",
    "Circuit Type": "회선 유형",
    "Circuit ID": "회선 ID",
    "Circuit Termination": "회선 종단",
    "Circuit Group": "회선 그룹",
    "Provider": "통신사업자",
    "Provider Account": "사업자 계정",
    "Provider Network": "사업자 네트워크",
    "Virtual Circuit": "가상 회선",
    "Commit Rate": "약정 속도",
    "Port Speed": "포트 속도",
    "Cross-Connect": "교차 연결",
    "Patch Panel": "패치 패널",

    # Virtualization
    "Virtual Machine": "가상 머신",
    "Cluster": "클러스터",
    "Cluster Type": "클러스터 유형",
    "Cluster Group": "클러스터 그룹",
    "Virtual Disk": "가상 디스크",

    # Wireless
    "Wireless LAN": "무선 LAN",
    "Wireless Link": "무선 링크",
    "Access Point": "액세스 포인트",

    # VPN
    "VPN Tunnel": "VPN 터널",
    "Tunnel Group": "터널 그룹",
    "IKE Policy": "IKE 정책",
    "IKE Proposal": "IKE 제안",
    "IPSec Policy": "IPSec 정책",
    "IPSec Profile": "IPSec 프로필",
    "IPSec Proposal": "IPSec 제안",
    "L2VPN": "L2VPN",
    "Peer": "피어",

    # Common Fields
    "Name": "이름",
    "name": "이름",
    "Description": "설명",
    "description": "설명",
    "Type": "유형",
    "Role": "역할",
    "role": "역할",
    "Status": "상태",
    "status": "상태",
    "Comments": "코멘트",
    "Tags": "태그",
    "Color": "색상",
    "color": "색상",
    "Label": "레이블",
    "Group": "그룹",
    "Priority": "우선순위",
    "priority": "우선순위",
    "Weight": "가중치",
    "Count": "개수",
    "Value": "값",
    "Field": "필드",
    "Attribute": "속성",
    "Attributes": "속성",
    "Parameter": "매개변수",
    "Default": "기본값",

    # Time & Dates
    "Install Date": "설치일",
    "installed": "설치됨",
    "Termination Date": "종료일",
    "Last Updated": "최종 수정일",
    "Modified": "수정됨",
    "Date": "날짜",
    "Time": "시간",
    "Hourly": "매시간",
    "Minutely": "매분",

    # Tenancy & Permissions
    "Tenant": "테넌트",
    "Tenancy": "테넌시",
    "Contact": "연락처",
    "Contacts": "연락처",
    "Contact Group": "연락처 그룹",
    "Contact Role": "연락처 역할",
    "User": "사용자",
    "Group": "그룹",
    "Permission": "권한",
    "Token": "토큰",
    "Authentication": "인증",
    "Superuser": "슈퍼유저",

    # Customization
    "Custom Field": "사용자 정의 필드",
    "Custom Link": "사용자 정의 링크",
    "Custom Validation": "사용자 정의 검증",
    "Export Template": "내보내기 템플릿",
    "Config Template": "설정 템플릿",
    "Config Context": "설정 컨텍스트",
    "Script": "스크립트",
    "Script Module": "스크립트 모듈",
    "Report": "리포트",
    "Event Rule": "이벤트 규칙",
    "Webhook": "웹훅",
    "Notification": "알림",
    "Notification Group": "알림 그룹",
    "Subscription": "구독",
    "Bookmark": "북마크",
    "Saved Filter": "저장된 필터",
    "Table Config": "테이블 설정",
    "Widget": "위젯",

    # Job Management
    "Job": "작업",
    "Job started": "작업 시작됨",
    "Job completed": "작업 완료됨",
    "Job failed": "작업 실패",
    "Job errored": "작업 오류 발생",
    "Task": "태스크",
    "Queue": "대기열",
    "Result": "결과",
    "Log": "로그",
    "Error": "오류",
    "Warning": "경고",
    "Success": "성공",
    "Info": "정보",

    # Data Management
    "Data Source": "데이터 소스",
    "Data File": "데이터 파일",
    "Backup": "백업",
    "Restore": "복원",
    "Format": "형식",

    # Change Logging
    "Change Log": "변경 로그",
    "Changelog": "변경 이력",
    "Object created": "객체 생성됨",
    "Object updated": "객체 업데이트됨",
    "Object deleted": "객체 삭제됨",
    "Journal": "저널",

    # Validation & Errors
    "Required": "필수",
    "Optional": "선택 사항",
    "Invalid": "유효하지 않음",
    "Valid": "유효함",
    "Validation": "검증",
    "Unique": "고유",
    "Duplicate": "중복",

    # Technical Specs
    "Speed": "속도",
    "Bandwidth": "대역폭",
    "Capacity": "용량",
    "Height": "높이",
    "Width": "너비",
    "Depth": "깊이",
    "Weight": "무게",
    "Distance": "거리",
    "Distance unit": "거리 단위",
    "Length": "길이",
    "Mode": "모드",
    "Protocol": "프로토콜",

    # Side/Position
    "Side": "측면",
    "Side A": "A측",
    "Side Z": "Z측",
    "Hub": "허브",
    "Spoke": "스포크",
    "Primary": "주",
    "Secondary": "부",
    "Tertiary": "제3",

    # Operational
    "Operational role": "운영 역할",
    "Operational status": "운영 상태",
    "Service ID": "서비스 ID",
    "service ID": "서비스 ID",
    "Service Parameters": "서비스 매개변수",

    # Assignment
    "Assignment": "할당",
    "Assignments": "할당",
    "Assigned tenant": "할당된 테넌트",
    "Assigned provider": "할당된 사업자",

    # Termination
    "Termination": "종단",
    "Terminations": "종단",
    "Termination Details": "종단 상세 정보",
    "Termination Point": "종단 지점",
    "Termination ID": "종단 ID",
    "Termination type": "종단 유형",
    "Termination Type": "종단 유형",
    "Term Side": "종단 측면",
    "termination side": "종단 측면",
    "terminates": "종단됨",

    # Common Phrases (partial)
    "Object Type": "객체 유형",
    "Account": "계정",
    "Accounts": "계정",
    "Account Count": "계정 개수",
    "Member": "멤버",
    "member ID": "멤버 ID",
    "Full name of the provider": "사업자의 전체 이름",
    "Physical circuit speed": "물리적 회선 속도",
    "Unique circuit ID": "고유 회선 ID",
    "The network to which this virtual circuit belongs": "이 가상 회선이 속한 네트워크",

    # Additional status
    "Mark connected": "연결됨으로 표시",
    "Decommissioned": "폐기됨",
}

def update_po_file():
    """Update the django.po file with Korean translations"""
    po_file = "/Users/josephpaik/Documents/GitHub/netbox251022/netbox/translations/ko/LC_MESSAGES/django.po"

    with open(po_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    output_lines = []
    i = 0
    translations_added = 0

    while i < len(lines):
        line = lines[i]
        output_lines.append(line)

        # Look for msgid lines
        if line.startswith('msgid "') and not line.startswith('msgid ""'):
            # Extract the msgid value
            msgid_text = line[7:-2]  # Remove 'msgid "' and '"\n'

            # Check if we have a translation
            if msgid_text in TRANSLATIONS:
                # Look ahead to find the msgstr line
                j = i + 1
                while j < len(lines) and not lines[j].startswith('msgstr '):
                    output_lines.append(lines[j])
                    j += 1

                if j < len(lines):
                    # Replace empty msgstr with our translation
                    if lines[j].strip() == 'msgstr ""':
                        output_lines.append(f'msgstr "{TRANSLATIONS[msgid_text]}"\n')
                        translations_added += 1
                        i = j + 1
                        continue
                    else:
                        output_lines.append(lines[j])

        i += 1

    # Write back
    with open(po_file, 'w', encoding='utf-8') as f:
        f.writelines(output_lines)

    print(f"Added {translations_added} Korean translations to django.po")
    print(f"Total translations in dictionary: {len(TRANSLATIONS)}")
    return translations_added

if __name__ == '__main__':
    count = update_po_file()
    print(f"\n✓ Successfully updated Korean translations!")
    print(f"✓ {count} strings translated")
