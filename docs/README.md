# NetBox 문서 목록

NetBox 설치, 관리, 사용에 필요한 모든 문서를 제공합니다.

---

## 📚 문서 구조

### 🔧 서버 관리자용 문서

#### 설치 가이드

| 문서 | 대상 환경 | 설명 |
|------|----------|------|
| [SERVER_INSTALL_GUIDE_ROCKY.md](./SERVER_INSTALL_GUIDE_ROCKY.md) | Rocky Linux 8/9 | 프로덕션 서버 설치 가이드 (Nginx, Gunicorn, PostgreSQL, Redis) |
| [../MACBOOK_INSTALL_GUIDE.md](../MACBOOK_INSTALL_GUIDE.md) | macOS 10.15+ | 로컬 개발 환경 설치 가이드 |

#### 자동 설치 스크립트

| 스크립트 | 환경 | 설명 |
|---------|------|------|
| [../setup_rocky.sh](../setup_rocky.sh) | Rocky Linux | 프로덕션 서버 자동 설치 스크립트 |
| [../setup_macos.sh](../setup_macos.sh) | macOS | 로컬 환경 자동 설치 스크립트 |

#### 운영 및 관리

| 문서 | 설명 |
|------|------|
| [SERVER_ADMIN_GUIDE.md](./SERVER_ADMIN_GUIDE.md) | 일상 관리, 백업, 업데이트, 모니터링, 문제 해결 |

### 👥 일반 사용자용 문서

| 문서 | 대상 | 설명 |
|------|------|------|
| [USER_GUIDE.md](./USER_GUIDE.md) | Windows/macOS 사용자 | NetBox 사용법 (접속, 장비 관리, CSV Import/Export, 검색) |

### ✅ 체크리스트

| 문서 | 설명 |
|------|------|
| [../QUICKSTART_CHECKLIST.md](../QUICKSTART_CHECKLIST.md) | macOS 설치 및 데이터 업로드 체크리스트 |

---

## 🚀 빠른 시작

### 서버 관리자

#### Rocky Linux 서버 구축 (프로덕션)
```bash
# 1. 서버에 SSH 접속
ssh user@server-ip

# 2. 저장소 클론
sudo git clone https://github.com/Josephpaik/netbox25.git /opt/netbox
cd /opt/netbox

# 3. 자동 설치 스크립트 실행
sudo ./setup_rocky.sh

# 4. 설치 완료 후 브라우저에서 접속
# http://your-server-ip/
```

자세한 내용: [SERVER_INSTALL_GUIDE_ROCKY.md](./SERVER_INSTALL_GUIDE_ROCKY.md)

#### macOS 로컬 환경 (개발/테스트)
```bash
# 1. 저장소 클론
git clone https://github.com/Josephpaik/netbox25.git
cd netbox25

# 2. 자동 설치 스크립트 실행
./setup_macos.sh

# 3. NetBox 실행
source venv/bin/activate
python netbox/manage.py runserver

# 4. 브라우저에서 http://localhost:8000/ 접속
```

자세한 내용: [MACBOOK_INSTALL_GUIDE.md](../MACBOOK_INSTALL_GUIDE.md)

### 일반 사용자

1. **접속**: 관리자가 제공한 URL로 접속
   - 예: `https://netbox.example.com`
2. **로그인**: 제공받은 계정으로 로그인
3. **사용법**: [USER_GUIDE.md](./USER_GUIDE.md) 참조

---

## 📖 문서별 상세 내용

### 1. SERVER_INSTALL_GUIDE_ROCKY.md
**대상**: 서버 관리자
**환경**: Rocky Linux 8/9
**내용**:
- 시스템 요구사항
- PostgreSQL, Redis, Nginx 설치 및 설정
- NetBox 설치 및 Gunicorn 설정
- Systemd 서비스 설정
- 방화벽 및 SELinux 설정
- SSL/TLS 인증서 설정
- 백업 및 복구
- 문제 해결

**주요 명령어**:
```bash
# 서비스 상태 확인
sudo systemctl status netbox nginx postgresql-15 redis

# 로그 확인
sudo journalctl -u netbox -f

# 백업
sudo /usr/local/bin/netbox-backup.sh
```

---

### 2. SERVER_ADMIN_GUIDE.md
**대상**: 서버 관리자
**내용**:
- 일상 관리 작업 (서비스 재시작, 로그 확인, 디스크 사용량)
- 사용자 계정 관리
- 백업 및 복구 자동화
- 업데이트 및 패치
- 성능 튜닝 (Gunicorn, PostgreSQL, Redis, Nginx)
- 보안 관리 (SSL, 방화벽, 보안 업데이트)
- 로그 관리 및 로테이션
- 모니터링 (서비스, 데이터베이스, 웹 서버)
- 문제 해결 및 비상 상황 대응

**주요 작업**:
- 매일: 서비스 상태 확인, 로그 확인
- 매주: 백업 확인, 디스크 사용량 확인
- 매월: 업데이트 적용, 성능 검토
- 분기별: 보안 감사, 백업 복구 테스트

---

### 3. USER_GUIDE.md
**대상**: Windows/macOS 일반 사용자
**내용**:
- NetBox 접속 및 로그인
- 기본 인터페이스 설명
- 네트워크 장비 관리 (추가, 수정, 삭제)
- IP 주소 관리 (IP 할당, Prefix 관리)
- 랙 및 위치 관리
- CSV 데이터 Import/Export
- 검색 및 필터링
- 보고서 생성
- 자주 묻는 질문
- 유용한 팁

**주요 작업**:
1. 새 장비 추가
2. IP 주소 할당
3. 랙에 장비 배치
4. CSV로 대량 데이터 Import
5. 필터링으로 특정 장비 검색
6. 보고서 Export

---

### 4. MACBOOK_INSTALL_GUIDE.md
**대상**: macOS 사용자 (개발자, 로컬 테스트)
**환경**: macOS 10.15+
**내용**:
- Homebrew, Python, PostgreSQL, Redis 설치
- NetBox 설정 및 초기화
- 개발 서버 실행
- IDC 시나리오 테스트 데이터 업로드
- 문제 해결

---

## 🔍 문서 검색 가이드

### 설치 관련
- **프로덕션 서버**: SERVER_INSTALL_GUIDE_ROCKY.md
- **로컬 개발**: MACBOOK_INSTALL_GUIDE.md
- **자동 설치**: setup_rocky.sh 또는 setup_macos.sh

### 운영 관련
- **일상 관리**: SERVER_ADMIN_GUIDE.md - "1. 일상 관리 작업"
- **백업/복구**: SERVER_ADMIN_GUIDE.md - "3. 백업 및 복구"
- **업데이트**: SERVER_ADMIN_GUIDE.md - "4. 업데이트 및 패치"
- **모니터링**: SERVER_ADMIN_GUIDE.md - "5. 모니터링"

### 사용 관련
- **로그인 방법**: USER_GUIDE.md - "1. 시작하기"
- **장비 관리**: USER_GUIDE.md - "3. 네트워크 장비 관리"
- **IP 관리**: USER_GUIDE.md - "4. IP 주소 관리"
- **CSV Import**: USER_GUIDE.md - "6. CSV 데이터 가져오기/내보내기"

### 문제 해결
- **서버 문제**: SERVER_ADMIN_GUIDE.md - "9. 문제 해결"
- **설치 오류**: SERVER_INSTALL_GUIDE_ROCKY.md - "14. 문제 해결"
- **사용자 FAQ**: USER_GUIDE.md - "9. 자주 묻는 질문"

---

## 📞 지원

### 기술 지원
- **이메일**: admin@example.com
- **사내 헬프데스크**: helpdesk@example.com
- **전화**: 02-XXXX-XXXX

### 외부 참고 자료
- **NetBox 공식 문서**: https://docs.netbox.dev/
- **NetBox GitHub**: https://github.com/netbox-community/netbox
- **NetBox Slack 커뮤니티**: https://netdev.chat/

---

## 📝 문서 업데이트 이력

| 날짜 | 버전 | 변경 내용 |
|------|------|-----------|
| 2025-01-10 | 1.0 | 초기 문서 작성 (Rocky Linux 설치, 관리, 사용자 가이드) |

---

## ⚖️ 라이선스

이 문서는 NetBox 프로젝트의 일부로, Apache 2.0 라이선스를 따릅니다.

---

**문서에 대한 피드백이나 개선 제안은 관리자에게 연락 주세요!**
