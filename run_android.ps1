# Set JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21"

Write-Host "JAVA_HOME set to $env:JAVA_HOME"

# Go to project root (optional if already there)
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

Write-Host "Running Flutter clean..."
flutter clean

if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter clean failed"
    exit 1
}

Write-Host "Getting dependencies..."
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter pub get failed"
    exit 1
}

Write-Host "Cleaning Android build..."
Set-Location android

Stop-Process -Name "java" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "kotlin" -Force -ErrorAction SilentlyContinue
./gradlew --stop

Start-Sleep -Seconds 2

./gradlew clean

if ($LASTEXITCODE -ne 0) {
    Write-Error "Gradle clean failed"
    exit 1
}

Set-Location ..

Write-Host "Running app..."
flutter run --android-skip-build-dependency-validation
# flutter run

if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter run failed"
    exit 1
}

Write-Host "Build & run completed successfully!"