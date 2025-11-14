# NetBox 로컬 개발 환경 설치 가이드 (Windows 11)

> **대상**: 개발자
> **환경**: Windows 11
> **목적**: NetBox 로컬 개발 환경 구축

---

## 목차

1. [시스템 요구사항](#1-시스템-요구사항)
2. [필수 소프트웨어 설치](#2-필수-소프트웨어-설치)
3. [PostgreSQL 설치 및 설정](#3-postgresql-설치-및-설정)
4. [Redis 설치 및 설정](#4-redis-설치-및-설정)
5. [Git 설치 및 저장소 클론](#5-git-설치-및-저장소-클론)
6. [Python 가상 환경 설정](#6-python-가상-환경-설정)
7. [NetBox 설정](#7-netbox-설정)
8. [프론트엔드 개발 환경 설정](#8-프론트엔드-개발-환경-설정)
9. [개발 서버 실행](#9-개발-서버-실행)
10. [테스트 실행](#10-테스트-실행)
11. [문제 해결](#11-문제-해결)
12. [추가 도구](#12-추가-도구)

---

## 1. 시스템 요구사항

### 최소 사양
- **OS**: Windows 11 (64-bit)
- **CPU**: 2 코어
- **RAM**: 8GB
- **디스크**: 20GB 여유 공간
- **관리자 권한**: 소프트웨어 설치를 위한 관리자 권한 필요

### 권장 사양
- **CPU**: 4 코어 이상
- **RAM**: 16GB 이상
- **디스크**: 50GB 이상 (SSD 권장)

### 필수 소프트웨어 버전
- Python 3.10 이상
- PostgreSQL 12 이상
- Redis 6.0 이상
- Git 2.x
- Node.js 18.x 이상 (프론트엔드 개발용)

---

## 2. 필수 소프트웨어 설치

### 2.1 Python 설치

1. **Python 공식 웹사이트에서 다운로드**
   - [https://www.python.org/downloads/](https://www.python.org/downloads/) 접속
   - Python 3.10 이상 버전 다운로드 (예: Python 3.11.x 또는 3.12.x)

2. **설치 실행**
   - 다운로드한 설치 파일 실행
   - ⚠️ **중요**: "Add Python to PATH" 체크박스 선택
   - "Install Now" 클릭

3. **설치 확인**
   ```powershell
   # PowerShell 또는 명령 프롬프트에서 실행
   python --version
   # 출력 예: Python 3.11.5

   pip --version
   # 출력 예: pip 23.x.x
   ```

### 2.2 Windows Terminal 설치 (권장)

개발 편의성을 위해 Windows Terminal 설치를 권장합니다.

1. Microsoft Store에서 "Windows Terminal" 검색 및 설치
2. 또는 PowerShell에서 설치:
   ```powershell
   winget install Microsoft.WindowsTerminal
   ```

---

## 3. PostgreSQL 설치 및 설정

### 3.1 PostgreSQL 다운로드 및 설치

1. **PostgreSQL 다운로드**
   - [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/) 접속
   - "Download the installer" 클릭
   - PostgreSQL 15 또는 16 버전 다운로드

2. **설치 진행**
   - 설치 파일 실행
   - 설치 경로: 기본값 사용 (예: `C:\Program Files\PostgreSQL\15`)
   - 구성 요소: 모두 선택 (PostgreSQL Server, pgAdmin 4, Stack Builder, Command Line Tools)
   - 데이터 디렉토리: 기본값 사용
   - **슈퍼유저 비밀번호 설정**: 안전한 비밀번호 입력 및 기억 (예: `netbox123!`)
   - 포트: 기본값 `5432` 사용
   - 로케일: 기본값 사용

3. **환경 변수 설정**
   ```powershell
   # PostgreSQL bin 디렉토리를 PATH에 추가 (관리자 PowerShell)
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\PostgreSQL\15\bin", [EnvironmentVariableTarget]::Machine)
   ```

### 3.2 NetBox용 데이터베이스 생성

1. **PostgreSQL 접속**
   ```powershell
   # PowerShell에서 실행 (비밀번호 입력 필요)
   psql -U postgres
   ```

2. **데이터베이스 및 사용자 생성**
   ```sql
   -- NetBox 데이터베이스 생성
   CREATE DATABASE netbox;

   -- NetBox 사용자 생성 (비밀번호는 변경하세요)
   CREATE USER netbox WITH PASSWORD 'netbox_password123!';

   -- 권한 부여
   ALTER DATABASE netbox OWNER TO netbox;
   GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;

   -- 종료
   \q
   ```

3. **연결 확인**
   ```powershell
   # NetBox 사용자로 데이터베이스 접속 테스트
   psql -U netbox -d netbox -h localhost
   # 비밀번호 입력 후 접속 확인
   \q
   ```

---

## 4. Redis 설치 및 설정

Windows에서 Redis를 실행하는 방법은 여러 가지가 있습니다. WSL2 또는 Memurai 사용을 권장합니다.

### 방법 1: WSL2 사용 (권장)

1. **WSL2 설치**
   ```powershell
   # 관리자 PowerShell에서 실행
   wsl --install
   # 재부팅 필요
   ```

2. **Ubuntu 설치 및 Redis 설치**
   ```bash
   # WSL Ubuntu 터미널에서 실행
   sudo apt update
   sudo apt install redis-server -y

   # Redis 서비스 시작
   sudo service redis-server start

   # 상태 확인
   redis-cli ping
   # 출력: PONG
   ```

3. **Redis 자동 시작 설정**
   ```bash
   # WSL Ubuntu에서
   echo "sudo service redis-server start" >> ~/.bashrc
   ```

### 방법 2: Memurai 사용 (WSL 없이)

1. **Memurai 다운로드**
   - [https://www.memurai.com/](https://www.memurai.com/) 접속
   - 무료 Developer Edition 다운로드

2. **설치 및 실행**
   - 설치 파일 실행
   - 기본 설정으로 설치
   - Memurai 서비스가 자동으로 시작됨

3. **연결 확인**
   ```powershell
   # PowerShell에서 (Memurai CLI 사용)
   memurai-cli ping
   # 출력: PONG
   ```

### 방법 3: Docker Desktop 사용

1. **Docker Desktop 설치**
   - [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop) 에서 다운로드 및 설치

2. **Redis 컨테이너 실행**
   ```powershell
   docker run -d --name redis -p 6379:6379 redis:latest

   # 상태 확인
   docker ps
   ```

---

## 5. Git 설치 및 저장소 클론

### 5.1 Git 설치

1. **Git 다운로드**
   - [https://git-scm.com/download/win](https://git-scm.com/download/win) 접속
   - 최신 버전 다운로드

2. **설치 옵션**
   - 기본 에디터: Visual Studio Code 또는 선호하는 에디터 선택
   - PATH 설정: "Git from the command line and also from 3rd-party software" 선택
   - 줄바꿈 변환: "Checkout as-is, commit Unix-style line endings" 권장
   - 나머지는 기본값 사용

3. **Git 설정**
   ```powershell
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"

   # 줄바꿈 설정 (중요)
   git config --global core.autocrlf input
   ```

### 5.2 NetBox 저장소 포크 및 클론

1. **GitHub에서 포크 생성**
   - [https://github.com/netbox-community/netbox](https://github.com/netbox-community/netbox) 접속
   - 오른쪽 상단의 "Fork" 버튼 클릭
   - 자신의 GitHub 계정으로 포크

2. **로컬에 클론**
   ```powershell
   # 작업 디렉토리로 이동 (예: C:\Dev)
   cd C:\Dev

   # 포크한 저장소 클론 (본인의 username으로 변경)
   git clone https://github.com/YOUR_USERNAME/netbox.git
   cd netbox
   ```

3. **원본 저장소를 upstream으로 추가**
   ```powershell
   git remote add upstream https://github.com/netbox-community/netbox.git
   git fetch upstream
   ```

4. **개발 브랜치 생성**
   ```powershell
   # main 브랜치에서 새 브랜치 생성
   git checkout main
   git checkout -b feature/your-feature-name
   ```

---

## 6. Python 가상 환경 설정

### 6.1 가상 환경 생성

```powershell
# NetBox 프로젝트 루트 디렉토리에서
cd C:\Dev\netbox

# 가상 환경 생성
python -m venv venv

# 또는 특정 위치에 생성하려면
# python -m venv C:\Dev\venvs\netbox
```

### 6.2 가상 환경 활성화

```powershell
# PowerShell에서
.\venv\Scripts\Activate.ps1

# 또는 명령 프롬프트(CMD)에서
.\venv\Scripts\activate.bat
```

⚠️ **PowerShell 실행 정책 오류 발생 시:**
```powershell
# 관리자 PowerShell에서 실행
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

활성화되면 프롬프트 앞에 `(venv)`가 표시됩니다:
```
(venv) PS C:\Dev\netbox>
```

### 6.3 Python 패키지 설치

```powershell
# 가상 환경이 활성화된 상태에서
python -m pip install --upgrade pip

# NetBox 의존성 설치
pip install -r requirements.txt
```

설치 시간이 다소 소요될 수 있습니다 (5-10분).

### 6.4 Pre-commit 설치

```powershell
# 코드 품질 검사 도구 설치
pip install ruff pre-commit

# pre-commit hook 활성화
pre-commit install
```

---

## 7. NetBox 설정

### 7.1 설정 파일 생성

```powershell
# netbox/netbox 디렉토리로 이동
cd netbox\netbox

# 설정 예제 파일 복사
copy configuration_example.py configuration.py
```

### 7.2 설정 파일 수정

`configuration.py` 파일을 텍스트 에디터로 열고 다음 항목을 수정합니다:

```python
# configuration.py

# 개발 환경에서는 모든 호스트 허용
ALLOWED_HOSTS = ['*']

# 데이터베이스 설정
DATABASE = {
    'NAME': 'netbox',                    # PostgreSQL 데이터베이스 이름
    'USER': 'netbox',                    # PostgreSQL 사용자
    'PASSWORD': 'netbox_password123!',   # PostgreSQL 비밀번호
    'HOST': 'localhost',                 # 데이터베이스 호스트
    'PORT': '',                          # 기본 포트 5432 사용
    'CONN_MAX_AGE': 300,
}

# Redis 설정
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

# SECRET_KEY 생성
# NetBox 루트 디렉토리에서 실행: python netbox/generate_secret_key.py
SECRET_KEY = 'your-secret-key-here'  # 실제 생성된 키로 교체

# 디버그 모드 활성화 (개발 환경)
DEBUG = True

# 개발자 모드 활성화 (마이그레이션 생성 가능)
DEVELOPER = True

# 미디어 파일 경로 (Windows 경로 형식)
MEDIA_ROOT = 'C:\\Dev\\netbox\\netbox\\media'
```

### 7.3 SECRET_KEY 생성

```powershell
# NetBox 루트 디렉토리로 돌아가기
cd ..\..

# SECRET_KEY 생성
python netbox\generate_secret_key.py
```

생성된 키를 복사하여 `configuration.py`의 `SECRET_KEY`에 붙여넣습니다.

### 7.4 데이터베이스 마이그레이션

```powershell
# netbox 디렉토리로 이동
cd netbox

# 마이그레이션 실행
python manage.py migrate
```

### 7.5 슈퍼유저 생성

```powershell
# 관리자 계정 생성
python manage.py createsuperuser

# 프롬프트에 따라 입력:
# Username: admin
# Email address: admin@example.com
# Password: (안전한 비밀번호 입력)
# Password (again): (비밀번호 재입력)
```

### 7.6 정적 파일 수집

```powershell
python manage.py collectstatic --no-input
```

---

## 8. 프론트엔드 개발 환경 설정

UI 개발을 위해서는 Node.js와 Yarn이 필요합니다.

### 8.1 Node.js 설치

1. **Node.js 다운로드**
   - [https://nodejs.org/](https://nodejs.org/) 접속
   - LTS 버전 다운로드 및 설치 (예: 18.x 또는 20.x)

2. **설치 확인**
   ```powershell
   node --version
   # 출력: v18.x.x 또는 v20.x.x

   npm --version
   # 출력: 9.x.x 또는 10.x.x
   ```

### 8.2 Yarn 설치

```powershell
# npm을 통해 Yarn 설치
npm install -g yarn

# 확인
yarn --version
# 출력: 1.22.x
```

### 8.3 프론트엔드 의존성 설치

```powershell
# NetBox 프로젝트의 project-static 디렉토리로 이동
cd C:\Dev\netbox\netbox\project-static

# 의존성 설치
yarn install
```

### 8.4 프론트엔드 빌드

```powershell
# 프로덕션 빌드
yarn build

# 또는 개발 모드 (파일 변경 감지 및 자동 재빌드)
yarn dev
```

---

## 9. 개발 서버 실행

### 9.1 Redis 서비스 시작 확인

```powershell
# WSL2 사용 시
wsl
sudo service redis-server start
exit

# Memurai 사용 시 - Windows Services에서 Memurai 서비스 확인
# Docker 사용 시
docker start redis
```

### 9.2 Django 개발 서버 실행

```powershell
# netbox 디렉토리에서 (가상 환경 활성화 상태)
cd C:\Dev\netbox\netbox

# 개발 서버 시작
python manage.py runserver
```

출력 예:
```
Performing system checks...

System check identified no issues (0 silenced).
November 14, 2025 - 10:30:00
Django version 5.2.x, using settings 'netbox.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CTRL-BREAK.
```

### 9.3 NetBox 접속

1. 웹 브라우저 열기
2. 주소: `http://127.0.0.1:8000` 또는 `http://localhost:8000`
3. 생성한 슈퍼유저 계정으로 로그인

### 9.4 RQ Worker 실행 (백그라운드 작업용)

별도의 터미널 창에서:

```powershell
# 가상 환경 활성화
cd C:\Dev\netbox
.\venv\Scripts\Activate.ps1

# RQ Worker 시작
cd netbox
python manage.py rqworker
```

---

## 10. 테스트 실행

### 10.1 전체 테스트 실행

```powershell
# netbox 디렉토리에서
cd C:\Dev\netbox\netbox

# 테스트 설정 파일 사용
$env:NETBOX_CONFIGURATION = "netbox.configuration_testing"

# 전체 테스트 실행
python manage.py test
```

### 10.2 병렬 테스트 실행 (빠른 실행)

```powershell
# 4개의 병렬 프로세스로 테스트
python manage.py test --parallel 4

# 데이터베이스 재사용 (더 빠름)
python manage.py test --parallel 4 --keepdb
```

### 10.3 특정 앱 테스트

```powershell
# DCIM 앱만 테스트
python manage.py test dcim.tests

# 특정 테스트 클래스
python manage.py test dcim.tests.test_models.DeviceTestCase

# 특정 테스트 메서드
python manage.py test dcim.tests.test_models.DeviceTestCase.test_device_creation
```

### 10.4 코드 커버리지 확인

```powershell
# coverage 패키지 설치
pip install coverage

# 커버리지와 함께 테스트 실행
coverage run --source="netbox/" manage.py test --parallel 4

# 커버리지 보고서 생성
coverage report --skip-covered --omit '*/migrations/*,*/tests/*'

# HTML 보고서 생성
coverage html
```

### 10.5 Linting 실행

```powershell
# NetBox 루트 디렉토리에서
cd C:\Dev\netbox

# Ruff 린터 실행
ruff check netbox/

# 자동 수정 가능한 문제 수정
ruff check --fix netbox/
```

---

## 11. 문제 해결

### 11.1 PostgreSQL 연결 오류

**증상**: `psycopg2.OperationalError: could not connect to server`

**해결 방법**:
```powershell
# PostgreSQL 서비스 상태 확인
# Windows Services (services.msc) 에서 "postgresql-x64-15" 서비스 확인
# 또는 PowerShell에서:
Get-Service -Name postgresql*

# 서비스 시작
Start-Service -Name "postgresql-x64-15"
```

### 11.2 Redis 연결 오류

**증상**: `redis.exceptions.ConnectionError: Error 10061`

**해결 방법**:

WSL2 사용 시:
```bash
wsl
sudo service redis-server status
sudo service redis-server start
```

Memurai 사용 시:
```powershell
# Windows Services에서 Memurai 서비스 확인 및 시작
Get-Service -Name Memurai
Start-Service -Name Memurai
```

Docker 사용 시:
```powershell
docker ps -a | findstr redis
docker start redis
```

### 11.3 PowerShell 실행 정책 오류

**증상**: `cannot be loaded because running scripts is disabled`

**해결 방법**:
```powershell
# CurrentUser 범위에서 실행 정책 변경
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 확인
Get-ExecutionPolicy -List
```

### 11.4 가상 환경 활성화 오류

**증상**: 가상 환경 활성화가 안 됨

**해결 방법**:
```powershell
# 전체 경로로 활성화 스크립트 실행
& "C:\Dev\netbox\venv\Scripts\Activate.ps1"

# 또는 명령 프롬프트(CMD) 사용
cmd
C:\Dev\netbox\venv\Scripts\activate.bat
```

### 11.5 pip 설치 오류 (Visual C++ 빌드 도구 필요)

**증상**: `error: Microsoft Visual C++ 14.0 or greater is required`

**해결 방법**:
1. Visual Studio Build Tools 설치:
   - [https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/)
   - "Build Tools for Visual Studio 2022" 다운로드
   - "Desktop development with C++" 워크로드 선택 및 설치

2. 또는 미리 컴파일된 바이너리 사용:
   ```powershell
   pip install --only-binary :all: psycopg2-binary
   ```

### 11.6 포트 충돌 오류

**증상**: `Error: That port is already in use.`

**해결 방법**:
```powershell
# 8000 포트를 사용 중인 프로세스 찾기
netstat -ano | findstr :8000

# 다른 포트로 서버 실행
python manage.py runserver 8080
```

### 11.7 데이터베이스 마이그레이션 오류

**증상**: `django.db.migrations.exceptions.InconsistentMigrationHistory`

**해결 방법**:
```powershell
# 데이터베이스 초기화 (개발 환경)
# PostgreSQL에서 데이터베이스 재생성
psql -U postgres
DROP DATABASE netbox;
CREATE DATABASE netbox;
ALTER DATABASE netbox OWNER TO netbox;
\q

# 마이그레이션 재실행
python manage.py migrate
python manage.py createsuperuser
```

### 11.8 정적 파일 로딩 오류

**증상**: CSS/JS 파일이 로드되지 않음

**해결 방법**:
```powershell
# 정적 파일 재수집
python manage.py collectstatic --clear --no-input

# 프론트엔드 재빌드
cd C:\Dev\netbox\netbox\project-static
yarn build
```

---

## 12. 추가 도구

### 12.1 PyCharm 설정 (권장 IDE)

PyCharm Professional 또는 Community Edition 사용을 권장합니다.

1. **프로젝트 열기**
   - PyCharm 실행
   - `Open` 클릭 → `C:\Dev\netbox` 선택

2. **Python 인터프리터 설정**
   - File → Settings → Project: netbox → Python Interpreter
   - 톱니바퀴 아이콘 → Add
   - Existing environment 선택
   - `C:\Dev\netbox\venv\Scripts\python.exe` 선택

3. **Django 지원 활성화**
   - File → Settings → Languages & Frameworks → Django
   - "Enable Django Support" 체크
   - Django project root: `C:\Dev\netbox\netbox`
   - Settings: `netbox/settings.py`
   - Manage script: `manage.py`

4. **실행 구성 생성**
   - Run → Edit Configurations
   - `+` → Django Server
   - Name: NetBox Development Server
   - Host: 127.0.0.1
   - Port: 8000
   - 적용 및 실행

### 12.2 Visual Studio Code 설정

1. **확장 프로그램 설치**
   - Python (Microsoft)
   - Django (Baptiste Darthenay)
   - GitLens
   - Pylance

2. **설정 파일 생성** (`.vscode/settings.json`)
   ```json
   {
     "python.defaultInterpreterPath": "${workspaceFolder}\\venv\\Scripts\\python.exe",
     "python.linting.enabled": true,
     "python.linting.pylintEnabled": false,
     "python.linting.flake8Enabled": true,
     "python.formatting.provider": "black",
     "editor.formatOnSave": true,
     "files.exclude": {
       "**/__pycache__": true,
       "**/*.pyc": true
     }
   }
   ```

3. **Launch 구성** (`.vscode/launch.json`)
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": "Django: NetBox",
         "type": "python",
         "request": "launch",
         "program": "${workspaceFolder}\\netbox\\manage.py",
         "args": ["runserver"],
         "django": true,
         "justMyCode": true
       }
     ]
   }
   ```

### 12.3 데모 데이터 임포트

```powershell
# 데모 데이터 저장소 클론
cd C:\Dev
git clone https://github.com/netbox-community/netbox-demo-data.git

# NetBox 디렉토리로 이동
cd C:\Dev\netbox\netbox

# 데모 데이터 로드
python manage.py loaddata C:\Dev\netbox-demo-data\netbox-demo-data.json
```

### 12.4 유용한 PowerShell 별칭 설정

`$PROFILE` 파일에 추가 (PowerShell에서 `notepad $PROFILE` 실행):

```powershell
# NetBox 개발 별칭
function Activate-NetBox {
    Set-Location C:\Dev\netbox
    & .\venv\Scripts\Activate.ps1
}
Set-Alias -Name nbenv -Value Activate-NetBox

function Start-NetBox {
    Set-Location C:\Dev\netbox\netbox
    python manage.py runserver
}
Set-Alias -Name nbrun -Value Start-NetBox

function Test-NetBox {
    Set-Location C:\Dev\netbox\netbox
    $env:NETBOX_CONFIGURATION = "netbox.configuration_testing"
    python manage.py test --parallel 4 --keepdb
}
Set-Alias -Name nbtest -Value Test-NetBox
```

사용 예:
```powershell
# 가상 환경 활성화 및 디렉토리 이동
nbenv

# NetBox 실행
nbrun

# 테스트 실행
nbtest
```

---

## 개발 워크플로우 요약

### 일반적인 개발 세션

```powershell
# 1. 가상 환경 활성화
cd C:\Dev\netbox
.\venv\Scripts\Activate.ps1

# 2. 최신 코드 가져오기
git fetch upstream
git merge upstream/main

# 3. 새 브랜치 생성
git checkout -b 1234-fix-bug-description

# 4. 필요한 서비스 시작
# Redis (WSL2)
wsl
sudo service redis-server start
exit

# 5. 개발 서버 시작
cd netbox
python manage.py runserver

# 6. 코드 수정 및 테스트
# (별도 터미널)
python manage.py test dcim.tests.test_models

# 7. 변경사항 커밋
git add .
git commit -m "Fixes #1234: Fix bug description"

# 8. Pre-commit 검사 자동 실행
# (ruff, Django checks 등)

# 9. Push 및 PR 생성
git push origin 1234-fix-bug-description
# GitHub에서 Pull Request 생성
```

---

## 참고 자료

- **NetBox 공식 문서**: [https://docs.netbox.dev/](https://docs.netbox.dev/)
- **NetBox GitHub**: [https://github.com/netbox-community/netbox](https://github.com/netbox-community/netbox)
- **개발 가이드**: [Getting Started](development/getting-started.md)
- **기여 가이드**: [CONTRIBUTING.md](../CONTRIBUTING.md)
- **커뮤니티**: NetDev Slack (#netbox 채널)

---

## 업데이트 이력

- **2025-11-14**: Windows 11 개발 환경 초기 가이드 작성

---

**문의사항이나 문제가 있으시면 GitHub Issues에 보고해주세요.**
