#!/bin/bash
# SafeRD - Set Google Maps API Key
# Usage: bash set_maps_key.sh YOUR_API_KEY

KEY="$1"
if [ -z "$KEY" ]; then
  echo "Usage: bash set_maps_key.sh AIzaSy..."
  exit 1
fi

MANIFEST="/opt/data/saferd/android/app/src/main/AndroidManifest.xml"

# Replace placeholder with real key
sed -i "s|YOUR_GOOGLE_MAPS_API_KEY|$KEY|g" "$MANIFEST"
echo "✅ API key set in AndroidManifest.xml"
cat "$MANIFEST" | grep -o 'AIza[^\"]*'
