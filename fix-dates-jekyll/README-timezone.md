# Jekyll Date Timezone Converter

Jekyll 블로그의 마크다운 파일에서 UTC 시간을 원하는 시간대로 일괄 변환하는 PowerShell 도구입니다.

## 🚀 특징

- ✅ UTC → 원하는 시간대로 자동 변환
- ✅ 다양한 시간대 지원 (KST, JST, PST, EST, GMT 등)
- ✅ ISO 8601 UTC 형식 자동 인식
- ✅ 타임존 정보가 없는 날짜에 타임존 추가
- ✅ UTF-8 인코딩 지원 (한글 깨짐 방지)
- ✅ 이미 변환된 날짜는 자동으로 건너뜀

## 📋 요구사항

- Windows PowerShell 5.1 이상 또는 PowerShell Core 7+
- Jekyll 블로그 프로젝트

## 🔧 설치

1. `Convert-DateTimezone.ps1` 파일 다운로드
2. Jekyll 블로그의 `_posts` 폴더에 스크립트 배치

```powershell
cd your-jekyll-blog/_posts
```

## 📖 사용법

### 1. 기본 사용

```powershell
./Convert-DateTimezone.ps1
```

처음 실행하면 `timezone-config.json` 설정 파일이 자동으로 생성됩니다.

### 2. 설정 파일 수정

`timezone-config.json` 파일을 열어 원하는 시간대로 수정합니다.

```json
{
  "timezoneOffset": 9,
  "timezoneString": "+0900",
  "timezoneName": "KST (Korea Standard Time)",
  "filePattern": "*.md",
  "convertUTC": true,
  "addTimezoneToPlainDates": true,
  "skipAlreadyConverted": true
}
```

### 3. 변환 실행

설정을 완료한 후 다시 스크립트를 실행합니다.

```powershell
./Convert-DateTimezone.ps1
```

### 4. 고급 옵션

```powershell
# 다른 디렉토리 지정
./Convert-DateTimezone.ps1 -PostsDirectory "./my-posts"

# 다른 설정 파일 사용
./Convert-DateTimezone.ps1 -ConfigFile "timezone-pst.json"
```

## ⚙️ 설정 파일 옵션

### 필수 설정

- **`timezoneOffset`**: UTC로부터의 시간 차이 (숫자)
  - 예: KST = 9, JST = 9, PST = -8, EST = -5, GMT = 0
- **`timezoneString`**: 날짜 뒤에 붙을 타임존 문자열
  - 예: "+0900", "-0800", "+0000"
- **`timezoneName`**: 시간대 이름 (설명용)

### 선택 설정

- **`filePattern`**: 처리할 파일 패턴 (기본: `"*.md"`)
- **`convertUTC`**: UTC 형식 변환 여부 (기본: `true`)
- **`addTimezoneToPlainDates`**: 일반 날짜에 타임존 추가 여부 (기본: `true`)
- **`skipAlreadyConverted`**: 이미 타임존이 있는 날짜 건너뛰기 (기본: `true`)

## 📝 변환 예시

### 예시 1: UTC → KST

**변환 전:**
```yaml
date: 2025-01-15T16:30:00.000Z
```

**변환 후:**
```yaml
date: 2025-01-16 01:30:00 +0900
```

### 예시 2: UTC → PST

**설정:**
```json
{
  "timezoneOffset": -8,
  "timezoneString": "-0800",
  "timezoneName": "PST (Pacific Standard Time)"
}
```

**변환 전:**
```yaml
date: 2025-01-15T16:30:00Z
```

**변환 후:**
```yaml
date: 2025-01-15 08:30:00 -0800
```

### 예시 3: 타임존 정보 추가

**변환 전:**
```yaml
date: 2025-01-15 14:30:00
```

**변환 후:**
```yaml
date: 2025-01-15 14:30:00 +0900
```

## 🌍 주요 시간대 설정

### 한국 표준시 (KST)
```json
{
  "timezoneOffset": 9,
  "timezoneString": "+0900",
  "timezoneName": "KST (Korea Standard Time)"
}
```

### 일본 표준시 (JST)
```json
{
  "timezoneOffset": 9,
  "timezoneString": "+0900",
  "timezoneName": "JST (Japan Standard Time)"
}
```

### 미국 태평양 표준시 (PST)
```json
{
  "timezoneOffset": -8,
  "timezoneString": "-0800",
  "timezoneName": "PST (Pacific Standard Time)"
}
```

### 미국 동부 표준시 (EST)
```json
{
  "timezoneOffset": -5,
  "timezoneString": "-0500",
  "timezoneName": "EST (Eastern Standard Time)"
}
```

### 영국 표준시 (GMT)
```json
{
  "timezoneOffset": 0,
  "timezoneString": "+0000",
  "timezoneName": "GMT (Greenwich Mean Time)"
}
```

### 중국 표준시 (CST)
```json
{
  "timezoneOffset": 8,
  "timezoneString": "+0800",
  "timezoneName": "CST (China Standard Time)"
}
```

## ⚠️ 주의사항

1. **백업 필수**: 실행 전 반드시 파일을 백업하세요!
   ```bash
   git commit -am "backup before timezone conversion"
   ```

2. **테스트**: 먼저 소수의 파일로 테스트해보세요
   ```powershell
   # 테스트용 폴더에 복사
   Copy-Item "2025-01-01.md" "./test/"
   cd test
   ../Convert-DateTimezone.ps1
   ```

3. **일광절약시간**: 이 도구는 일광절약시간(DST)을 자동으로 처리하지 않습니다. 필요시 수동으로 조정하세요.

4. **재실행**: 이미 변환된 파일은 자동으로 건너뛰므로 안전하게 재실행할 수 있습니다.

## 🔧 고급 사용법

### UTC만 변환하고 나머지는 그대로

```json
{
  "convertUTC": true,
  "addTimezoneToPlainDates": false,
  "skipAlreadyConverted": true
}
```

### 모든 날짜에 타임존 강제 추가

```json
{
  "convertUTC": true,
  "addTimezoneToPlainDates": true,
  "skipAlreadyConverted": false
}
```

### 특정 확장자만 처리

```json
{
  "filePattern": "2025-*.md"
}
```

## 🤝 기여

버그 리포트, 기능 제안, PR은 언제나 환영합니다!

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.

## 🔗 관련 도구

- [Jekyll Front Matter Converter](https://github.com/yourusername/jekyll-frontmatter-converter) - Front Matter 일괄 변환 도구

## ❓ 문제 해결

### Q: 시간이 18시간 차이나요
A: `timezoneOffset`이 중복 적용되었을 수 있습니다. 원본 파일을 복구하고 다시 실행하세요.

### Q: 이미 변환된 파일을 다시 변환하고 싶어요
A: `skipAlreadyConverted`를 `false`로 설정하세요. 하지만 주의: 중복 변환될 수 있습니다!

### Q: 특정 파일만 변환하고 싶어요
A: `filePattern`을 `"2025-01-*.md"` 같은 패턴으로 설정하세요.

### Q: 여러 시간대를 동시에 사용해요
A: 여러 설정 파일을 만들고 `-ConfigFile` 옵션으로 각각 실행하세요.

### Q: 한글이 깨져요
A: 스크립트가 자동으로 UTF-8 인코딩을 사용합니다. 그래도 문제가 있다면 원본 파일의 인코딩을 확인하세요.

## 💡 팁

1. **배치 처리**: 여러 시간대 설정 파일을 만들어두고 필요할 때 사용하세요
2. **Git 통합**: Git hook으로 자동화할 수 있습니다
3. **검증**: 변환 후 Jekyll 빌드가 정상적으로 되는지 확인하세요

---

**Made with ❤️ for Jekyll bloggers worldwide**
