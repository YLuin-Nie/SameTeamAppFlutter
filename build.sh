#!/bin/bash

# Install Flutter SDK
echo "🔧 Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Enable Flutter Web support
flutter config --enable-web

# Get packages
flutter pub get

# Build the web app
flutter build web

# Move the output to a folder Vercel recognizes
cp -r build/web ./dist
