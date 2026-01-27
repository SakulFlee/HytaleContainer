#!/usr/bin/env bash

check_status() {
  if [ $? -ne 0 ]; then
    echo "Something went wrong!"
    exit -1
  fi
}

echo "--- Hytale Server Launcher ---"
echo "Java Options: $JAVA_OPTIONS"

# Below will be empty if file doesn't exist
UPDATE_REQUIRED=0
if [ -f /opt/hytale/VERSION ]; then
  echo "Existing version tag found! Checking for updates ..."

  CURRENT_VERSION="$(cat /opt/hytale/VERSION)"
  echo "Current version: $CURRENT_VERSION"

  LATEST_VERSION="$(/opt/hytale-downloader/hytale-downloader-linux-amd64 -print-version)"
  echo "Latest version: $LATEST_VERSION"

  diff <(echo "$CURRENT_VERSION") <(echo "$LATEST_VERSION")
  UPDATE_REQUIRED=$?
else
  echo "No version tag found! Assuming first run."
  UPDATE_REQUIRED=1

  mkdir -p /opt/hytale
fi

if [ -f /opt/hytale-downloader-secret/.hytale-downloader-credentials.json ]; then
  echo "Kubernetes credentials found! Copying ..."
  cp -f /opt/hytale-downloader-secret/.hytale-downloader-credentials.json /opt/hytale/.hytale-downloader-credentials.json
fi

if [[ $UPDATE_REQUIRED -eq 1 ]]; then
  echo "Update required!"

  # Will download the server ZIP file
  cd /opt/hytale-downloader
  ./hytale-downloader-linux-amd64 -credentials-path /opt/hytale/.hytale-downloader-credentials.json
  check_status

  # Find ZIP file
  ZIP_FILE="$(find . -type f -name '*.zip' -exec basename {} \;)"
  check_status

  # Extract server ZIP 
  unzip -d /opt/hytale -o $ZIP_FILE
  check_status

  # Version tag server
  echo "${ZIP_FILE%.zip}" > /opt/hytale/VERSION

  # Remove download to save space
  rm "$ZIP_FILE"
else
  echo "Update not required!"
fi

if [ ! -f /opt/hytale/Server/HytaleServer.jar ]; then
  echo "Something went wrong, the required server files were not found!"
  exit -1
else
  # Run server
  cd /opt/hytale/Server
  exec java -XX:AOTCache=HytaleServer.aot $JAVA_OPTIONS -jar HytaleServer.jar --assets ../Assets.zip
  check_status
fi

echo "--- Exiting ---"

