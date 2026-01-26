#!/usr/bin/env bash

echo "--- Hytale Server Launcher ---"
echo "Java Options: $JAVA_OPTIONS"

# Below will be empty if file doesn't exist
CURRENT_VERSION="$(cat /opt/hytale/VERSION)"
NEW_VERSION="$(/opt/hytale-downloader/hytale-downloader -print-version)"

diff <(echo "$CURRENT_VERSION") <(echo "$NEW_VERSION")
if [[ $? -eq 1 ]]; then
  echo "Update required!"

  # Will download the server ZIP file
  pushd /opt/hytale-downlader
  exec hytale-downloader-linux-amd64

  # Find ZIP file
  ZIP_FILE="$(find . -type f -name '*.zip' -exec basename {} \;)"

  # Extract server ZIP 
  unzip -d /opt/hytale -o $ZIP_FILE

  # Version tag server
  echo "$ZIP_FILE" > /opt/hytale/VERSION

  popd
fi

# Run server
pushd /opt/hytale/Server
exec java -XX:AOTCache=HytaleServer.aot $JAVA_OPTIONS -jar /opt/hytale/Server/HytaleServer.jar --assets /opt/hytale/Assets.zip
pod

echo "--- Exiting ---"

