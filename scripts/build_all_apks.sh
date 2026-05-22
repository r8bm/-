#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/prepare_flutter_projects.sh"
"$ROOT/scripts/build_driver_apk.sh"
"$ROOT/scripts/build_restaurant_apk.sh"
echo "All APKs are in $ROOT/dist"
