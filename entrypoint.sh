#!/usr/bin/env bash

echo "--- Hytale Server Launcher ---"
echo "Java Options: $JAVA_OPTIONS"

# Below will be empty if file doesn't exist
UPDATE_REQUIRED=0
if [ -f /opt/hytale/VERSION ]; then
  echo "Existing version tag found! Checking for updates ..."

  CURRENT_VERSION="$(cat /opt/hytale/VERSION)"
  echo "Current version: $CURRENT_VERSION"

  LATEST_VERSION="$(/opt/hytale-downloader/hytale-downloader -print-version)"
  echo "Latest version: $LATEST_VERSION"

  diff <(echo "$CURRENT_VERSION") <(echo "$LATEST_VERSION")
  UPDATE_REQUIRED=$?
else
  echo "No version tag found! Assuming first run."
  UPDATE_REQUIRED=1
fi

if [[ $UPDATE_REQUIRED -eq 1 ]]; then
  echo "Update required!"

  # Will download the server ZIP file
  pushd /opt/hytale-downloader
  exec hytale-downloader-linux-amd64 -credentials-path /opt/hytale/.hytale-downloader-credentials.json

  # Find ZIP file
  ZIP_FILE="$(find . -type f -name '*.zip' -exec basename {} \;)"

  # Extract server ZIP 
  unzip -d /opt/hytale -o $ZIP_FILE

  # Version tag server
  echo "$ZIP_FILE" > /opt/hytale/VERSION

  popd
else
  echo "Update not required!"
fi

if [ ! -f /opt/hytale/Server/HytaleServer.jar ]; then
  echo "Something went wrong, the required server files were not found!"
  exit -1
else
  # Run server
  pushd /opt/hytale/Server
  exec java -XX:AOTCache=HytaleServer.aot $JAVA_OPTIONS -jar /opt/hytale/Server/HytaleServer.jar --assets /opt/hytale/Assets.zip
  pod
fi

echo "--- Exiting ---"

