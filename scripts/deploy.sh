#!/bin/bash
# Builds and installs Spotify Insights to Applications folder
# Usage: ./scripts/deploy.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Spotify Insights"

cd "$PROJECT_DIR"

echo "Building $APP_NAME..."
flutter build macos --release

echo "Installing to /Applications..."
rm -rf "/Applications/$APP_NAME.app"
cp -R "build/macos/Build/Products/Release/spotify_insights.app" "/Applications/$APP_NAME.app"

echo "✓ Installed to /Applications/$APP_NAME.app"

