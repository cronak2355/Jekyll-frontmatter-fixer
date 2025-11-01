# Jekyll Front Matter Converter
# 사용자가 원하는 형식으로 Front Matter를 일괄 변환하는 도구

param(
    [Parameter(Mandatory=$false)]
    [string]$PostsDirectory = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "frontmatter-config.json"
)

# 설정 파일이 없으면 기본 설정 파일 생성
if (-not (Test-Path $ConfigFile)) {
    Write-Host "⚠️  설정 파일이 없습니다. 기본 설정 파일을 생성합니다: $ConfigFile" -ForegroundColor Yellow
    
    $defaultConfig = @{
        "fields" = @(
            @{
                "key" = "layout"
                "value" = "post"
                "type" = "static"
            },
            @{
                "key" = "title"
                "value" = ""
                "type" = "preserve"
                "quote" = $true
            },
            @{
                "key" = "date"
                "value" = ""
                "type" = "preserve"
                "quote" = $false
            },
            @{
                "key" = "categories"
                "value" = @("KRAFTON JUNGLE")
                "type" = "static"
                "format" = "array"
            },
            @{
                "key" = "tags"
                "value" = @("Programming")
                "type" = "static"
                "format" = "array"
            }
        )
        "preserveOtherFields" = $false
        "filePattern" = "*.md"
    }
    
    $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile -Encoding UTF8
    Write-Host "✅ 기본 설정 파일이 생성되었습니다. 필요에 따라 수정하세요." -ForegroundColor Green
    Write-Host "📝 설정을 수정한 후 다시 실행하세요.`n" -ForegroundColor Cyan
    exit
}

# 설정 파일 읽기
try {
    $config = Get-Content $ConfigFile -Encoding UTF8 -Raw | ConvertFrom-Json
} catch {
    Write-Host "❌ 설정 파일을 읽는 중 오류가 발생했습니다: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "🔄 Front Matter 변환을 시작합니다...`n" -ForegroundColor Cyan

$filePattern = if ($config.filePattern) { $config.filePattern } else { "*.md" }
$filesProcessed = 0
$filesSuccess = 0
$filesFailed = 0

Get-ChildItem $PostsDirectory -Filter $filePattern | ForEach-Object {
    $file = $_.FullName
    $filesProcessed++
    
    try {
        # UTF-8 인코딩으로 명시적으로 읽기
        $content = Get-Content $file -Encoding UTF8 -Raw
        
        # Front matter 패턴 매칭
        if ($content -match '(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$') {
            $oldFrontMatter = $matches[1]
            $bodyContent = $matches[2]
            
            # 기존 Front Matter 파싱
            $existingFields = @{}
            $oldFrontMatter -split "`n" | ForEach-Object {
                $line = $_.Trim()
                if ($line -match '^([^:]+):\s*(.*)$') {
                    $key = $matches[1].Trim()
                    $value = $matches[2].Trim()
                    # 따옴표 제거
                    $value = $value -replace '^"(.*)"$', '$1'
                    $value = $value -replace "^'(.*)'$", '$1'
                    $existingFields[$key] = $value
                }
            }
            
            # 새로운 Front Matter 생성
            $newFrontMatterLines = @("---")
            
            foreach ($field in $config.fields) {
                $key = $field.key
                $value = $null
                
                # 필드 타입에 따라 값 결정
                switch ($field.type) {
                    "static" {
                        # 정적 값 사용
                        $value = $field.value
                    }
                    "preserve" {
                        # 기존 값 유지
                        if ($existingFields.ContainsKey($key)) {
                            $value = $existingFields[$key]
                        } else {
                            $value = $field.value
                        }
                    }
                    "default" {
                        # 기존 값이 있으면 사용, 없으면 기본값
                        if ($existingFields.ContainsKey($key) -and $existingFields[$key]) {
                            $value = $existingFields[$key]
                        } else {
                            $value = $field.value
                        }
                    }
                }
                
                # 값 포맷팅
                if ($null -ne $value) {
                    $formattedValue = $value
                    
                    # 배열 형식
                    if ($field.format -eq "array" -and $value -is [Array]) {
                        $formattedValue = "[" + ($value -join ", ") + "]"
                    }
                    # 문자열 배열을 그대로 사용
                    elseif ($field.format -eq "array" -and $value -match '^\[.*\]$') {
                        $formattedValue = $value
                    }
                    # 따옴표 처리
                    elseif ($field.quote -eq $true -and $value -notmatch '^".*"$') {
                        $formattedValue = "`"$value`""
                    }
                    
                    $newFrontMatterLines += "$key: $formattedValue"
                }
            }
            
            # 다른 필드 보존 옵션
            if ($config.preserveOtherFields -eq $true) {
                $configKeys = $config.fields | ForEach-Object { $_.key }
                foreach ($key in $existingFields.Keys) {
                    if ($key -notin $configKeys) {
                        $value = $existingFields[$key]
                        $newFrontMatterLines += "$key: $value"
                    }
                }
            }
            
            $newFrontMatterLines += "---"
            
            # 새로운 내용 생성
            $newFrontMatter = $newFrontMatterLines -join "`n"
            $newContent = $newFrontMatter + "`n" + $bodyContent
            
            # UTF-8 without BOM으로 저장
            $lines = $newContent -split "`r?`n"
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllLines($file, $lines, $utf8NoBom)
            
            Write-Host "✅ $($_.Name)" -ForegroundColor Green
            $filesSuccess++
        } else {
            Write-Host "⚠️  $($_.Name): Front matter를 찾을 수 없음" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $($_.Name): $($_.Exception.Message)" -ForegroundColor Red
        $filesFailed++
    }
}

Write-Host "`n📊 변환 완료!" -ForegroundColor Cyan
Write-Host "   처리된 파일: $filesProcessed" -ForegroundColor White
Write-Host "   성공: $filesSuccess" -ForegroundColor Green
Write-Host "   실패: $filesFailed" -ForegroundColor Red
