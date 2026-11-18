param([Parameter(Mandatory = $true)][string]$JavaHome)

$ErrorActionPreference = 'Stop'
$javaPath = Join-Path $JavaHome 'bin\java.exe'
if (-not (Test-Path -LiteralPath $javaPath)) {
    throw "Java executable not found: $javaPath"
}
$previousJavaHome = $env:JAVA_HOME
$previousPath = $env:PATH
try {
    $env:JAVA_HOME = (Resolve-Path -LiteralPath $JavaHome).Path
    $env:PATH = (Join-Path $env:JAVA_HOME 'bin') + ';' + $env:PATH
    Push-Location (Join-Path $PSScriptRoot '..\android')
    try {
        & .\gradlew.bat assembleDebug
        if ($LASTEXITCODE -ne 0) { throw 'Android build failed.' }
    } finally { Pop-Location }
} finally {
    $env:JAVA_HOME = $previousJavaHome
    $env:PATH = $previousPath
}
