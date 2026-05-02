# if has error
$ErrorActionPreference = "Stop"

# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"
Write-Host "JAVA_HOME set to $env:JAVA_HOME"

# Go to script directory (project root)
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

Write-Host "Cleaning project..."
flutter clean

Write-Host "Getting dependencies..."
flutter pub get

Write-Host "Running build_runner..."
dart run build_runner build --delete-conflicting-outputs

Write-Host "Building APK (release)..."
flutter build apk --release

Write-Host "APK build completed!"

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "Output location: $apkPath"

if (Test-Path $apkPath) {
    Write-Host "APK found ✅"
} else {
    Write-Error "APK not found ❌"
    exit 1
}