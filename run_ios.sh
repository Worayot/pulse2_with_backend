#!/bin/bash

# Exit on error
set -e

echo "Setting up environment..."

# Set JAVA_HOME (optional for Flutter, but safe to keep consistent)
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Go to project root
cd "$(dirname "$0")"

echo "Cleaning Flutter project..."
flutter clean

echo "Fetching dependencies..."
flutter pub get

echo "Installing iOS pods..."
cd ios
pod install --repo-update
cd ..

echo "Checking connected devices..."
flutter devices

echo "Running on iOS..."
flutter run

echo "iOS build & run completed!"

# chmod +x run_ios.sh
# ./run_ios.sh