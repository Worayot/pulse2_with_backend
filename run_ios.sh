#!/bin/bash

# Exit on error
set -e

echo "🚀 Setting up environment..."

# Set JAVA_HOME (safe to keep)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Go to project root
cd "$(dirname "$0")"

echo "🧹 Cleaning Flutter + iOS build cache..."
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# echo "🧹 Fixing DerivedData permissions..."
# sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData || true

echo "🧹 Cleaning Xcode DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData

echo "📦 Fetching dependencies..."
flutter pub get

echo "📦 Installing iOS pods..."
cd ios
pod install
# pod install --repo-update
cd ..

dart run build_runner build --delete-conflicting-outputs

echo "🏗️ Building iOS (debug)..."
flutter build ios --debug

echo "📱 Running on iOS device..."
flutter run

echo "✅ iOS build & run completed!"


# chmod +x run_ios.sh
# ./run_ios.sh