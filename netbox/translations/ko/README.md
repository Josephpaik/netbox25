# NetBox 한국어 번역 가이드 / Korean Translation Guide

## 한국어 (Korean)

### 개요

이 디렉토리는 NetBox의 한국어 번역 파일을 포함합니다. NetBox는 Django의 국제화(i18n) 프레임워크를 사용하여 다국어 지원을 제공합니다.

### 파일 구조

```
netbox/translations/ko/
├── README.md                    # 이 파일
├── TERMINOLOGY.md               # 한영 용어 사전
└── LC_MESSAGES/
    ├── django.po               # 번역 소스 파일 (수정 가능)
    └── django.mo               # 컴파일된 번역 파일 (자동 생성)
```

### 번역 파일 형식

- **django.po**: 사람이 읽고 편집할 수 있는 번역 소스 파일
- **django.mo**: 기계가 읽는 컴파일된 바이너리 파일 (직접 편집하지 않음)

### 번역 작업 방법

#### 1. Transifex를 통한 번역 (권장)

NetBox는 Transifex를 사용하여 번역을 관리합니다:

1. [Transifex NetBox 프로젝트](https://www.transifex.com/netbox-community/netbox/)에 가입
2. 한국어 팀에 참여 요청
3. 웹 인터페이스에서 번역 작업 수행
4. 변경사항은 정기적으로 NetBox 저장소에 동기화됩니다

#### 2. 로컬에서 직접 번역

로컬 개발 환경에서 직접 번역할 수도 있습니다:

```bash
# 1. django.po 파일 편집
vim netbox/translations/ko/LC_MESSAGES/django.po

# 2. 번역 컴파일 (배포 전에 실행)
cd netbox
python3 manage.py compilemessages -l ko

# 3. 개발 서버에서 테스트
python3 manage.py runserver

# 4. 브라우저에서 언어 설정 변경
# User Menu > Preferences > Language > Korean
```

#### 3. 번역 파일 업데이트

소스 코드가 업데이트되면 번역 파일을 동기화해야 합니다:

```bash
# 새로운 번역 가능한 문자열 추출
cd netbox
python3 manage.py makemessages -l ko -i "project-static/*"

# 기존 번역과 병합됨 (번역되지 않은 항목은 비어있음)
```

### 번역 가이드라인

#### 용어 일관성

**반드시 [TERMINOLOGY.md](TERMINOLOGY.md) 파일을 참조하여 일관된 용어를 사용하세요.**

예시:
- Device → 장치 (항상)
- Site → 사이트 (항상)
- Active → 활성 (항상)

#### 번역 스타일

1. **존댓말 사용**: UI 텍스트는 격식있는 존댓말(합니다 체) 사용
   - 예: "저장되었습니다", "생성하시겠습니까?"

2. **간결성**: 필드 레이블은 명사형으로 간결하게
   - 예: "이름", "설명", "상태"

3. **기술 용어**: 널리 알려진 기술 용어는 영어 그대로 사용
   - 예: VLAN, VRF, API, IP

4. **변수 보존**: 중괄호 변수는 그대로 유지
   ```
   msgid "Logged in as {user}."
   msgstr "{user}(으)로 로그인되었습니다."
   ```

5. **복수형 처리**: 한국어는 복수형 구분이 없으므로 동일한 형태 사용
   ```
   msgid "Device"
   msgid_plural "Devices"
   msgstr[0] "장치"
   ```

#### 번역 예시

**좋은 번역:**
```po
msgid "Your preferences have been updated."
msgstr "환경설정이 업데이트되었습니다."
```

**나쁜 번역:**
```po
msgid "Your preferences have been updated."
msgstr "너의 설정들이 업데이트 됐어."  # 비격식, 불필요한 복수 표현
```

### 번역 상태 확인

번역 진행률을 확인하려면:

```bash
# .po 파일에서 번역되지 않은 항목 찾기
cd netbox/translations/ko/LC_MESSAGES
grep -c "msgstr \"\"" django.po
```

### 번역 테스트

번역이 제대로 작동하는지 테스트:

1. **개발 서버 실행:**
   ```bash
   cd netbox
   python3 manage.py runserver
   ```

2. **브라우저에서 확인:**
   - 로그인 후 User Menu 클릭
   - Preferences 선택
   - Language를 "Korean"으로 변경
   - 저장 후 페이지 새로고침

3. **주요 확인 사항:**
   - 네비게이션 메뉴가 한국어로 표시되는가?
   - 버튼과 레이블이 한국어로 표시되는가?
   - 오류 메시지가 한국어로 표시되는가?
   - 레이아웃이 깨지지 않는가?

### 기여하기

한국어 번역에 기여하려면:

1. **Transifex 사용 (권장)**
   - 별도의 PR 없이 웹에서 직접 번역
   - 변경사항은 자동으로 동기화됨

2. **Pull Request 제출**
   - Fork NetBox 저장소
   - 번역 작업 수행
   - `django.po` 파일만 포함된 PR 생성 (.mo 파일은 제외)
   - PR 제목: "Update Korean translations"
   - 설명에 변경 사항 요약 포함

### 문의 및 지원

- **GitHub Issues**: 번역 관련 문제나 제안
- **NetDev Slack**: #netbox 채널에서 질문
- **Transifex**: 번역 플랫폼 내 토론 기능 사용

### 참고 자료

- [Django 국제화 문서](https://docs.djangoproject.com/en/stable/topics/i18n/)
- [GNU gettext 매뉴얼](https://www.gnu.org/software/gettext/manual/)
- [NetBox 번역 가이드](../../docs/development/translations.md)
- [한영 용어 사전](TERMINOLOGY.md)

---

## English

### Overview

This directory contains the Korean translation files for NetBox. NetBox uses Django's internationalization (i18n) framework to provide multi-language support.

### File Structure

```
netbox/translations/ko/
├── README.md                    # This file
├── TERMINOLOGY.md               # Korean-English terminology dictionary
└── LC_MESSAGES/
    ├── django.po               # Translation source file (editable)
    └── django.mo               # Compiled translation file (auto-generated)
```

### Translation File Formats

- **django.po**: Human-readable translation source file
- **django.mo**: Machine-readable compiled binary file (do not edit directly)

### How to Contribute Translations

#### 1. Via Transifex (Recommended)

NetBox uses Transifex for translation management:

1. Sign up at [Transifex NetBox Project](https://www.transifex.com/netbox-community/netbox/)
2. Request to join the Korean translation team
3. Translate using the web interface
4. Changes are automatically synced to the NetBox repository

#### 2. Direct Local Translation

You can also translate directly in your local development environment:

```bash
# 1. Edit the django.po file
vim netbox/translations/ko/LC_MESSAGES/django.po

# 2. Compile translations (before deployment)
cd netbox
python3 manage.py compilemessages -l ko

# 3. Test on development server
python3 manage.py runserver

# 4. Change language in browser
# User Menu > Preferences > Language > Korean
```

#### 3. Updating Translation Files

When source code is updated, sync the translation files:

```bash
# Extract new translatable strings
cd netbox
python3 manage.py makemessages -l ko -i "project-static/*"

# Merges with existing translations (new items are empty)
```

### Translation Guidelines

#### Terminology Consistency

**Always refer to [TERMINOLOGY.md](TERMINOLOGY.md) for consistent terminology.**

Examples:
- Device → 장치 (always)
- Site → 사이트 (always)
- Active → 활성 (always)

#### Translation Style

1. **Formal/Polite tone**: Use formal Korean (합니다 체) for UI text
   - Example: "저장되었습니다", "생성하시겠습니까?"

2. **Conciseness**: Use noun forms for field labels
   - Example: "이름", "설명", "상태"

3. **Technical terms**: Keep widely-known technical terms in English
   - Example: VLAN, VRF, API, IP

4. **Preserve variables**: Keep curly-brace variables unchanged
   ```
   msgid "Logged in as {user}."
   msgstr "{user}(으)로 로그인되었습니다."
   ```

5. **Plural handling**: Korean has no plural distinction; use same form
   ```
   msgid "Device"
   msgid_plural "Devices"
   msgstr[0] "장치"
   ```

#### Translation Examples

**Good translation:**
```po
msgid "Your preferences have been updated."
msgstr "환경설정이 업데이트되었습니다."
```

**Bad translation:**
```po
msgid "Your preferences have been updated."
msgstr "너의 설정들이 업데이트 됐어."  # Informal, unnecessary plural
```

### Checking Translation Status

To check translation progress:

```bash
# Find untranslated entries in .po file
cd netbox/translations/ko/LC_MESSAGES
grep -c "msgstr \"\"" django.po
```

### Testing Translations

To test if translations work properly:

1. **Run development server:**
   ```bash
   cd netbox
   python3 manage.py runserver
   ```

2. **Check in browser:**
   - Login and click User Menu
   - Select Preferences
   - Change Language to "Korean"
   - Save and refresh page

3. **Key checks:**
   - Are navigation menus in Korean?
   - Are buttons and labels in Korean?
   - Are error messages in Korean?
   - Is the layout intact (no broken UI)?

### Contributing

To contribute Korean translations:

1. **Use Transifex (Recommended)**
   - Translate directly on the web without PRs
   - Changes are automatically synced

2. **Submit Pull Request**
   - Fork the NetBox repository
   - Make translation changes
   - Create PR with only `django.po` file (exclude .mo files)
   - PR title: "Update Korean translations"
   - Include summary of changes in description

### Support and Contact

- **GitHub Issues**: For translation-related issues or suggestions
- **NetDev Slack**: Ask questions in #netbox channel
- **Transifex**: Use discussion features within the translation platform

### References

- [Django Internationalization Documentation](https://docs.djangoproject.com/en/stable/topics/i18n/)
- [GNU gettext Manual](https://www.gnu.org/software/gettext/manual/)
- [NetBox Translation Guide](../../docs/development/translations.md)
- [Korean-English Terminology Dictionary](TERMINOLOGY.md)

---

## 버전 이력 / Version History

- **v1.0** (2025-01-25): Initial Korean translation support
  - Added Korean to LANGUAGES in settings.py
  - Created initial django.po with 265+ translations
  - Established terminology dictionary
  - Created translation guide

## 라이선스 / License

Korean translations are distributed under the same license as NetBox (Apache 2.0).

## 번역팀 / Translation Team

Korean Translation Team <netbox-ko@lists.netbox.dev>

For questions about Korean translation, please contact the team via GitHub Issues or Slack.
