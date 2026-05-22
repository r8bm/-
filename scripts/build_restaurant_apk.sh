#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/apps/restaurant_app"
if [ ! -f android/gradlew ] && [ ! -f android/gradle.properties ]; then
  "$ROOT/scripts/prepare_flutter_projects.sh"
fi
flutter build apk --release
mkdir -p "$ROOT/dist"
cp build/app/outputs/flutter-apk/app-release.apk "$ROOT/dist/delivery-restaurant.apk"
echo "Built: $ROOT/dist/delivery-restaurant.apk"
