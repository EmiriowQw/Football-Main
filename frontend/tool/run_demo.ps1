param([string]$Device, [switch]$Cloud)

$ErrorActionPreference = 'Stop'
$frontend = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repo = Split-Path $frontend
$runtime = Join-Path $repo 'runtime'
$portable = Test-Path (Join-Path $runtime 'node\node.exe')
$sdk = @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT, (Join-Path $env:USERPROFILE 'AppData\Local\Android\Sdk')) |
    Where-Object { $_ -and (Test-Path (Join-Path $_ 'platform-tools\adb.exe')) } | Select-Object -First 1
if (-not $sdk) { throw 'Android SDK not found. Use the laptop with Android Studio and an Android Virtual Device installed.' }
$adb = Join-Path $sdk 'platform-tools\adb.exe'

if (-not $Device) {
    $online = & $adb devices | Where-Object { $_ -match '^emulator-\d+\s+device$' } | Select-Object -First 1
    if ($online) { $Device = ($online -split '\s+')[0] }
}

if (-not $Device) {
    $avdTool = Join-Path $sdk 'emulator\emulator.exe'
    $availableAvds = @(& $avdTool -list-avds)
    $avd = $availableAvds | Select-Object -First 1
    if (-not $avd) { throw 'No Android Virtual Device is configured.' }
    if (-not (& $adb devices | Where-Object { $_ -match '^emulator-\d+' })) {
        Start-Process -FilePath $avdTool -ArgumentList @('-avd', $avd, '-no-boot-anim')
    }
    Write-Host "Waiting for Android emulator..."
    $deadline = (Get-Date).AddMinutes(4)
    do {
        Start-Sleep -Seconds 2
        $online = & $adb devices | Where-Object { $_ -match '^emulator-\d+\s+device$' } | Select-Object -First 1
        if ($online) {
            $candidate = ($online -split '\s+')[0]
            if ((& $adb -s $candidate shell getprop sys.boot_completed) -match '^1$') { $Device = $candidate }
        }
    } until ($Device -or (Get-Date) -gt $deadline)
    if (-not $Device) { throw 'Android emulator did not finish booting.' }
}

if (-not $Cloud) {
    if ($Device -notmatch '^emulator-\d+$') { throw 'Local demo requires an Android Emulator.' }
    function Test-FirebaseDemo {
        try {
            $response = Invoke-RestMethod 'http://127.0.0.1:4400/emulators' -TimeoutSec 2
            return $response.auth.port -eq 9099 -and $response.firestore.port -eq 8088
        } catch { return $false }
    }
    if (-not (Test-FirebaseDemo)) {
        $cliRelative = 'rules-tests/node_modules/firebase-tools/lib/bin/firebase.js'
        if ($portable) { $cliRelative = '../runtime/node_modules/firebase-tools/lib/bin/firebase.js' }
        $cli = Join-Path $frontend $cliRelative
        if (-not (Test-Path $cli)) { throw 'Local Firebase CLI is missing. Run npm ci in frontend/rules-tests.' }
        $restored = @{}
        $settings = @{}
        if ($portable) {
            $node = Join-Path $runtime 'node\node.exe'
            $settings['JAVA_HOME'] = Join-Path $runtime 'java'
            $settings['PATH'] = (Join-Path $settings['JAVA_HOME'] 'bin') + ';' + $env:PATH
            $settings['FIREBASE_EMULATORS_PATH'] = Join-Path $runtime 'firebase-cache'
            $settings['XDG_CONFIG_HOME'] = Join-Path $runtime 'local-config'
            $settings['FIREBASE_TOKEN'] = $null
            $settings['GOOGLE_APPLICATION_CREDENTIALS'] = $null
            $settings['CI'] = 'true'
        } else {
            $node = (Get-Command node).Source
            $localJava = Get-ChildItem (Join-Path $repo '.tools\jdk21') -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($localJava) { $settings['JAVA_HOME'] = $localJava.FullName }
        }
        New-Item -ItemType Directory -Force (Join-Path $frontend 'build') | Out-Null
        try {
            foreach ($key in $settings.Keys) {
                $restored[$key] = [Environment]::GetEnvironmentVariable($key, 'Process')
                [Environment]::SetEnvironmentVariable($key, $settings[$key], 'Process')
            }
            Start-Process -WindowStyle Hidden -FilePath $node -WorkingDirectory $frontend `
                -ArgumentList @($cliRelative, 'emulators:start', '--only', 'auth,firestore', '--project', 'demo-football-day', '--config', 'firebase.test.json', '--non-interactive') `
                -RedirectStandardOutput (Join-Path $frontend 'build\firebase-demo.log') `
                -RedirectStandardError (Join-Path $frontend 'build\firebase-demo-error.log')
        } finally {
            foreach ($key in $restored.Keys) { [Environment]::SetEnvironmentVariable($key, $restored[$key], 'Process') }
        }
        $deadline = (Get-Date).AddMinutes(2)
        while (-not (Test-FirebaseDemo) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 2 }
        if (-not (Test-FirebaseDemo)) { throw 'Firebase emulators did not start. See frontend/build/firebase-demo.log.' }
    }
}

$apkName = if ($Cloud) { 'football-day-google.apk' } else { 'football-day-demo.apk' }
$apk = Join-Path $frontend "build\demo\$apkName"
if (-not (Test-Path $apk)) {
    if ($portable) { throw "The demo ZIP is incomplete. Missing $apkName." }
    $localJava = Get-ChildItem (Join-Path $repo '.tools\jdk21') -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    $previousJava = $env:JAVA_HOME
    if ($localJava) { $env:JAVA_HOME = $localJava.FullName }
    $gradleArgs = @('assembleDebug', '--console=plain')
    if (-not $Cloud) {
        $flag = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('FOOTBALL_DEMO=true'))
        $gradleArgs += "-Pdart-defines=$flag"
    }
    Push-Location (Join-Path $frontend 'android')
    try {
        & .\gradlew.bat @gradleArgs
        if ($LASTEXITCODE -ne 0) { throw 'Android build failed.' }
    } finally {
        Pop-Location
        $env:JAVA_HOME = $previousJava
    }
    New-Item -ItemType Directory -Force (Split-Path $apk) | Out-Null
    Copy-Item (Join-Path $frontend 'build\app\outputs\flutter-apk\app-debug.apk') $apk
}
& $adb -s $Device install -r $apk
if ($LASTEXITCODE -ne 0) { throw 'APK installation failed.' }
& $adb -s $Device shell am start -n 'com.example.basketvibe/.MainActivity'
if ($LASTEXITCODE -ne 0) { throw 'Football Day did not start.' }
