#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/apps/driver_app"
if [ ! -f android/gradlew ] && [ ! -f android/gradle.properties ]; then
  "$ROOT/scripts/prepare_flutter_projects.sh"
fi
flutter build apk --release
mkdir -p "$ROOT/dist"
cp build/app/outputs/flutter-apk/app-release.apk "$ROOT/dist/delivery-driver.apk"
echo "Built: $ROOT/dist/delivery-driver.apk"
