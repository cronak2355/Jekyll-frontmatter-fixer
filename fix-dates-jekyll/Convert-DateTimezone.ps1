# Jekyll Date Timezone Converter
# UTC 시간을 특정 시간대로 변환하는 도구

param(
    [Parameter(Mandatory=$false)]
    [string]$PostsDirectory = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = "timezone-config.json"
)

# 설정 파일이 없으면 기본 설정 파일 생성
if (-not (Test-Path $ConfigFile)) {
    Write-Host "⚠️  설정 파일이 없습니다. 기본 설정 파일을 생성합니다: $ConfigFile" -ForegroundColor Yellow
    
    $defaultConfig = @{
        "timezoneOffset" = 9
        "timezoneString" = "+0900"
        "timezoneName" = "KST (Korea Standard Time)"
        "filePattern" = "*.md"
        "convertUTC" = $true
        "addTimezoneToPlainDates" = $true
        "skipAlreadyConverted" = $true
    }
    
    $defaultConfig | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile -Encoding UTF8
    Write-Host "✅ 기본 설정 파일이 생성되었습니다. 필요에 따라 수정하세요." -ForegroundColor Green
    Write-Host "📝 설정을 수정한 후 다시 실행하세요.`n" -ForegroundColor Cyan
    Write-Host "💡 Tip: timezoneOffset을 변경하여 다른 시간대로 변환할 수 있습니다." -ForegroundColor Cyan
    Write-Host "   예) PST: -8, EST: -5, JST: 9, GMT: 0`n" -ForegroundColor Cyan
    exit
}

# 설정 파일 읽기
try {
    $config = Get-Content $ConfigFile -Encoding UTF8 -Raw | ConvertFrom-Json
} catch {
    Write-Host "❌ 설정 파일을 읽는 중 오류가 발생했습니다: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# 설정값 추출
$timezoneOffset = $config.timezoneOffset
$timezoneString = $config.timezoneString
$timezoneName = $config.timezoneName
$filePattern = if ($config.filePattern) { $config.filePattern } else { "*.md" }
$convertUTC = if ($null -eq $config.convertUTC) { $true } else { $config.convertUTC }
$addTimezoneToPlainDates = if ($null -eq $config.addTimezoneToPlainDates) { $true } else { $config.addTimezoneToPlainDates }
$skipAlreadyConverted = if ($null -eq $config.skipAlreadyConverted) { $true } else { $config.skipAlreadyConverted }

Write-Host "🔄 시간대 변환을 시작합니다..." -ForegroundColor Cyan
Write-Host "   타겟 시간대: $timezoneName (UTC$timezoneString)`n" -ForegroundColor White

$filesProcessed = 0
$filesChanged = 0
$datesConverted = 0

Get-ChildItem $PostsDirectory -Filter $filePattern | ForEach-Object {
    $file = $_.FullName
    $filesProcessed++
    
    try {
        # UTF-8 인코딩으로 명시적으로 읽기
        $lines = Get-Content $file -Encoding UTF8
        $changed = $false

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^date:\s*(.+)$") {
                $oldDateStr = $matches[1].Trim()
                $converted = $false

                # UTC 포맷 처리 (Z로 끝나는 경우)
                if ($convertUTC -and $oldDateStr -match "Z$") {
                    try {
                        # ISO 8601 UTC 포맷들
                        $formats = @(
                            "yyyy-MM-ddTHH:mm:ss.fffZ",
                            "yyyy-MM-ddTHH:mm:ss.ffZ",
                            "yyyy-MM-ddTHH:mm:ss.fZ",
                            "yyyy-MM-ddTHH:mm:ssZ"
                        )
                        
                        $dt = $null
                        foreach ($fmt in $formats) {
                            try {
                                # UTC 시간 파싱
                                $dt = [DateTime]::ParseExact($oldDateStr, $fmt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal)
                                break
                            } catch {}
                        }
                        
                        if ($dt -ne $null) {
                            # 시간대 오프셋 적용
                            $convertedDt = $dt.AddHours($timezoneOffset)
                            $newDateStr = $convertedDt.ToString("yyyy-MM-dd HH:mm:ss") + " $timezoneString"
                            $lines[$i] = "date: $newDateStr"
                            $changed = $true
                            $datesConverted++
                            Write-Host "✅ $($_.Name): $oldDateStr → $newDateStr"
                            $converted = $true
                        }
                    } catch {
                        Write-Host "⚠️  $($_.Name): UTC 파싱 실패 ($oldDateStr)" -ForegroundColor Yellow
                    }
                }
                # 이미 타임존 정보가 있는 경우
                elseif ($oldDateStr -match "[+-]\d{4}$") {
                    if ($skipAlreadyConverted) {
                        # 아무것도 하지 않음 (이미 변환됨)
                    } else {
                        Write-Host "ℹ️  $($_.Name): 이미 타임존 정보가 있음 ($oldDateStr)" -ForegroundColor Cyan
                    }
                }
                # 타임존 정보가 없는 일반 날짜
                elseif ($addTimezoneToPlainDates) {
                    try {
                        $formats = @(
                            "yyyy-MM-dd HH:mm:ss",
                            "yyyy-MM-dd"
                        )
                        
                        $dt = $null
                        $usedFormat = $null
                        foreach ($fmt in $formats) {
                            try {
                                $dt = [DateTime]::ParseExact($oldDateStr, $fmt, $null)
                                $usedFormat = $fmt
                                break
                            } catch {}
                        }
                        
                        if ($dt -ne $null) {
                            # 시간은 그대로, 타임존 정보만 추가
                            if ($usedFormat -eq "yyyy-MM-dd") {
                                $newDateStr = $dt.ToString("yyyy-MM-dd") + " 00:00:00 $timezoneString"
                            } else {
                                $newDateStr = $dt.ToString("yyyy-MM-dd HH:mm:ss") + " $timezoneString"
                            }
                            $lines[$i] = "date: $newDateStr"
                            $changed = $true
                            $datesConverted++
                            Write-Host "✅ $($_.Name): $oldDateStr → $newDateStr (타임존 추가)"
                            $converted = $true
                        }
                    } catch {
                        Write-Host "⚠️  $($_.Name): 날짜 파싱 실패 ($oldDateStr)" -ForegroundColor Yellow
                    }
                }
            }
        }

        if ($changed) {
            # UTF-8 without BOM으로 저장
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllLines($file, $lines, $utf8NoBom)
            $filesChanged++
        }
    } catch {
        Write-Host "❌ $($_.Name): 오류 발생 - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n📊 변환 완료!" -ForegroundColor Cyan
Write-Host "   처리된 파일: $filesProcessed" -ForegroundColor White
Write-Host "   변경된 파일: $filesChanged" -ForegroundColor Green
Write-Host "   변환된 날짜: $datesConverted" -ForegroundColor Green
