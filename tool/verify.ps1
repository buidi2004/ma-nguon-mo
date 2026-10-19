<#
.SYNOPSIS
    Lane kiểm tra chuẩn cho OpenFlix (nhanh / đầy đủ / e2e).

.DESCRIPTION
    Ba lane loại trừ nhau, bắt buộc chọn đúng một:

      -Fast : `dart analyze lib` + 2 file test nhanh (admin telemetry, auth nav)
      -Full : `flutter test --no-pub --exclude-tags e2e`  (toàn bộ suite trừ e2e)
      -E2E  : `flutter test --no-pub --tags e2e test/e2e_real_backend_test.dart`
              (cần mạng tới VPS PocketBase)

    Mọi bước đều in thời gian chạy (giây) và script thoát với exit code 1 nếu
    có bất kỳ bước nào thất bại. KHÔNG chạy `pub get`; luôn dùng `--no-pub`.

.EXAMPLE
    pwsh tool/verify.ps1 -Fast

.EXAMPLE
    pwsh tool/verify.ps1 -Full
#>
[CmdletBinding()]
param(
    [switch]$Fast,
    [switch]$Full,
    [switch]$E2E
)

$ErrorActionPreference = 'Continue'

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

$chosen = @()
if ($Fast) { $chosen += 'Fast' }
if ($Full) { $chosen += 'Full' }
if ($E2E) { $chosen += 'E2E' }

if ($chosen.Count -ne 1) {
    Write-Host "LOI: phai chon dung 1 trong -Fast | -Full | -E2E (dang chon $($chosen.Count))." -ForegroundColor Red
    Write-Host "  -Fast : dart analyze lib + test/admin_security_and_telemetry_test.dart + test/auth_navigation_flow_test.dart"
    Write-Host "  -Full : flutter test --no-pub --exclude-tags e2e"
    Write-Host "  -E2E  : flutter test --no-pub --tags e2e test/e2e_real_backend_test.dart"
    Pop-Location
    exit 2
}

$lane = $chosen[0]
$script:failed = 0
$script:timings = [ordered]@{}
$totalWatch = [System.Diagnostics.Stopwatch]::StartNew()

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    Write-Host ''
    Write-Host "=== $Name ===" -ForegroundColor Cyan
    Write-Host "> $Command $($Arguments -join ' ')" -ForegroundColor DarkGray

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    & $Command @Arguments 2>&1 | Out-Host
    $exitCode = $LASTEXITCODE
    $sw.Stop()

    $seconds = [math]::Round($sw.Elapsed.TotalSeconds, 1)
    $script:timings[$Name] = $seconds

    if ($exitCode -eq 0) {
        Write-Host ("[PASS] {0} - {1}s" -f $Name, $seconds) -ForegroundColor Green
    }
    else {
        Write-Host ("[FAIL] {0} - {1}s (exit {2})" -f $Name, $seconds, $exitCode) -ForegroundColor Red
        $script:failed++
    }
}

Write-Host "OpenFlix verify - lane $lane (root: $repoRoot)" -ForegroundColor Yellow

switch ($lane) {
    'Fast' {
        Invoke-Step -Name 'dart analyze lib' -Command 'dart' -Arguments @('analyze', 'lib')
        Invoke-Step -Name 'fast widget tests' -Command 'flutter' -Arguments @(
            'test', '--no-pub',
            'test/admin_security_and_telemetry_test.dart',
            'test/auth_navigation_flow_test.dart'
        )
    }
    'Full' {
        Invoke-Step -Name 'full suite (excl e2e)' -Command 'flutter' -Arguments @(
            'test', '--no-pub', '--exclude-tags', 'e2e'
        )
    }
    'E2E' {
        Invoke-Step -Name 'e2e real backend' -Command 'flutter' -Arguments @(
            'test', '--no-pub', '--tags', 'e2e', 'test/e2e_real_backend_test.dart'
        )
    }
}

$totalWatch.Stop()
$totalSeconds = [math]::Round($totalWatch.Elapsed.TotalSeconds, 1)

Write-Host ''
Write-Host '--- summary ---' -ForegroundColor Yellow
foreach ($key in $script:timings.Keys) {
    Write-Host ("  {0,-28} {1,7}s" -f $key, $script:timings[$key])
}
Write-Host ("  {0,-28} {1,7}s" -f 'TOTAL', $totalSeconds)

Pop-Location

if ($script:failed -gt 0) {
    Write-Host "Ket qua: FAIL ($($script:failed) buoc loi)" -ForegroundColor Red
    exit 1
}

Write-Host 'Ket qua: PASS' -ForegroundColor Green
exit 0
