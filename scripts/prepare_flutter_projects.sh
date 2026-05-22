#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
prepare_app() {
  local APP_DIR="$1"
  echo "Preparing Flutter Android shell in $APP_DIR"
  cd "$APP_DIR"
  rm -rf .dart_tool build
  cp -R lib /tmp/app_lib_backup
  cp pubspec.yaml /tmp/app_pubspec_backup.yaml
  cp analysis_options.yaml /tmp/app_analysis_backup.yaml
  mkdir -p /tmp/app_manifest_backup
  cp -R android/app/src/main/AndroidManifest.xml /tmp/app_manifest_backup/AndroidManifest.xml 2>/dev/null || true
  flutter create --platforms=android --overwrite .
  rm -rf lib
  cp -R /tmp/app_lib_backup lib
  cp /tmp/app_pubspec_backup.yaml pubspec.yaml
  cp /tmp/app_analysis_backup.yaml analysis_options.yaml
  mkdir -p android/app/src/main
  cp /tmp/app_manifest_backup/AndroidManifest.xml android/app/src/main/AndroidManifest.xml 2>/dev/null || true
  rm -rf /tmp/app_lib_backup /tmp/app_pubspec_backup.yaml /tmp/app_analysis_backup.yaml /tmp/app_manifest_backup
  flutter pub get
}
prepare_app "$ROOT/apps/driver_app"
prepare_app "$ROOT/apps/restaurant_app"
echo "Flutter projects are ready."
