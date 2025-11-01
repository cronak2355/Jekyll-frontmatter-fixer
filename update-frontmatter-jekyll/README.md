# Jekyll Front Matter Converter

Jekyll 블로그의 마크다운 파일들의 Front Matter를 일괄 변환하는 PowerShell 도구입니다.

## 🚀 특징

- ✅ 사용자 정의 가능한 Front Matter 형식
- ✅ JSON 설정 파일을 통한 유연한 구성
- ✅ 기존 필드 값 보존 또는 덮어쓰기 옵션
- ✅ UTF-8 인코딩 지원 (한글 깨짐 방지)
- ✅ 배치 처리로 여러 파일 동시 변환

## 📋 요구사항

- Windows PowerShell 5.1 이상 또는 PowerShell Core 7+
- Jekyll 블로그 프로젝트

## 🔧 설치

1. 리포지토리 클론 또는 `Convert-FrontMatter.ps1` 파일 다운로드
2. Jekyll 블로그의 `_posts` 폴더에 스크립트 배치

```powershell
# 다운로드한 위치로 이동
cd your-jekyll-blog/_posts
```

## 📖 사용법

### 1. 기본 사용

```powershell
./Convert-FrontMatter.ps1
```

처음 실행하면 `frontmatter-config.json` 설정 파일이 자동으로 생성됩니다.

### 2. 설정 파일 수정

`frontmatter-config.json` 파일을 열어 원하는 형식으로 수정합니다.

```json
{
  "fields": [
    {
      "key": "layout",
      "value": "post",
      "type": "static"
    },
    {
      "key": "title",
      "value": "",
      "type": "preserve",
      "quote": true
    },
    {
      "key": "date",
      "value": "",
      "type": "preserve",
      "quote": false
    },
    {
      "key": "categories",
      "value": ["KRAFTON JUNGLE"],
      "type": "static",
      "format": "array"
    },
    {
      "key": "tags",
      "value": ["Programming"],
      "type": "static",
      "format": "array"
    }
  ],
  "preserveOtherFields": false,
  "filePattern": "*.md"
}
```

### 3. 변환 실행

설정을 완료한 후 다시 스크립트를 실행합니다.

```powershell
./Convert-FrontMatter.ps1
```

### 4. 고급 옵션

```powershell
# 다른 디렉토리 지정
./Convert-FrontMatter.ps1 -PostsDirectory "./my-posts"

# 다른 설정 파일 사용
./Convert-FrontMatter.ps1 -ConfigFile "custom-config.json"

# 둘 다 지정
./Convert-FrontMatter.ps1 -PostsDirectory "./my-posts" -ConfigFile "custom-config.json"
```

## ⚙️ 설정 파일 옵션

### 필드 타입 (type)

- **`static`**: 항상 설정된 값을 사용
- **`preserve`**: 기존 값을 유지 (없으면 설정 값 사용)
- **`default`**: 기존 값이 있으면 유지, 없거나 비어있으면 설정 값 사용

### 필드 옵션

- **`key`**: Front Matter 키 이름
- **`value`**: 사용할 값
- **`type`**: 필드 타입 (위 참조)
- **`quote`**: true면 값을 따옴표로 감싸기 (선택사항)
- **`format`**: "array"로 설정하면 배열 형식 `[item1, item2]` 사용 (선택사항)

### 전역 옵션

- **`preserveOtherFields`**: true면 설정에 없는 기존 필드도 보존
- **`filePattern`**: 처리할 파일 패턴 (기본: `*.md`)

## 📝 예시

### 예시 1: 기본 블로그 포스트

**변환 전:**
```yaml
---
title: "My First Post"
description: "This is my first post"
date: 2025-01-15
---
```

**설정:**
```json
{
  "fields": [
    {
      "key": "layout",
      "value": "post",
      "type": "static"
    },
    {
      "key": "title",
      "type": "preserve",
      "quote": true
    },
    {
      "key": "date",
      "type": "preserve"
    },
    {
      "key": "categories",
      "value": ["Blog"],
      "type": "static",
      "format": "array"
    }
  ],
  "preserveOtherFields": false
}
```

**변환 후:**
```yaml
---
layout: post
title: "My First Post"
date: 2025-01-15
categories: [Blog]
---
```

### 예시 2: 기술 블로그

**설정:**
```json
{
  "fields": [
    {
      "key": "layout",
      "value": "post",
      "type": "static"
    },
    {
      "key": "title",
      "type": "preserve",
      "quote": true
    },
    {
      "key": "date",
      "type": "preserve"
    },
    {
      "key": "author",
      "value": "John Doe",
      "type": "default",
      "quote": true
    },
    {
      "key": "categories",
      "value": ["Tech", "Tutorial"],
      "type": "static",
      "format": "array"
    },
    {
      "key": "tags",
      "value": [],
      "type": "preserve",
      "format": "array"
    }
  ],
  "preserveOtherFields": true
}
```

### 예시 3: 다국어 블로그

**설정:**
```json
{
  "fields": [
    {
      "key": "layout",
      "value": "post",
      "type": "static"
    },
    {
      "key": "title",
      "type": "preserve",
      "quote": true
    },
    {
      "key": "lang",
      "value": "ko",
      "type": "default"
    },
    {
      "key": "date",
      "type": "preserve"
    }
  ]
}
```

## ⚠️ 주의사항

1. **백업 필수**: 실행 전 반드시 파일을 백업하세요!
   ```bash
   git commit -am "backup before front matter conversion"
   ```

2. **테스트**: 먼저 소수의 파일로 테스트해보세요
   ```powershell
   # 테스트용 폴더에 복사
   Copy-Item "2025-01-01.md" "./test/"
   cd test
   ../Convert-FrontMatter.ps1
   ```

3. **인코딩**: 한글이 포함된 파일은 UTF-8 인코딩이 자동으로 적용됩니다

## 🤝 기여

버그 리포트, 기능 제안, PR은 언제나 환영합니다!

## 📄 라이선스

MIT License - 자유롭게 사용, 수정, 배포 가능합니다.

## 🔗 관련 링크

- [Jekyll 공식 문서](https://jekyllrb.com/)
- [Front Matter 가이드](https://jekyllrb.com/docs/front-matter/)

## ❓ 문제 해결

### Q: "Front matter를 찾을 수 없음" 오류가 나요
A: 파일이 `---`로 시작하는 Front Matter 형식인지 확인하세요.

### Q: 한글이 깨져요
A: 스크립트가 자동으로 UTF-8 인코딩을 사용합니다. 그래도 문제가 있다면 원본 파일의 인코딩을 확인하세요.

### Q: 특정 필드만 수정하고 나머지는 그대로 두고 싶어요
A: `preserveOtherFields`를 `true`로 설정하고, 수정하고 싶은 필드만 `type: "static"`으로 설정하세요.

### Q: 배열 형식이 제대로 안 나와요
A: `format: "array"`를 추가하고, `value`를 배열로 지정하세요: `"value": ["item1", "item2"]`

---

**Made with ❤️ for Jekyll bloggers**
