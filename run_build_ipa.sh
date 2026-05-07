#!/bin/bash

set -e

echo "🚀 Building iOS IPA (Release)..."

# Ensure correct Java (safe for your backend tools)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

cd "$(dirname "$0")"

echo "🔍 Checking Xcode installation..."
xcodebuild -version || { echo "❌ Xcode not found"; exit 1; }

echo "🔍 Checking iOS SDK..."
xcodebuild -sdk iphoneos -version || {
  echo "❌ iOS SDK missing. Install it via Xcode → Settings → Platforms"
  exit 1
}

echo "🧹 Cleaning Flutter..."
flutter clean

echo "📦 Getting Flutter dependencies..."
flutter pub get

dart run build_runner build --delete-conflicting-outputs

echo "📦 Installing CocoaPods..."
cd ios
pod install
# pod install --repo-update
cd ..

echo "🏗️ Building IPA (Release)..."
flutter build ipa --release

echo "📦 Checking output..."
ls -lh build/ios/ipa/ || echo "⚠️ IPA folder not found"

echo "🎉 DONE - IPA build completed!"

# chmod +x run_build_ipa.sh
# ./run_build_ipa.sh