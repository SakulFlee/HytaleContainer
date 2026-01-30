#!/usr/bin/env bash

check_status() {
  if [ $? -ne 0 ]; then
    echo "Something went wrong!"
    exit -1
  fi
}

echo "--- Hytale Server Launcher ---"
if [ -z "$JAVA_OPTIONS" ]; then
  echo "Java Options: None"
else
  echo "Java Options: $JAVA_OPTIONS"
fi

if [ -z "$MODS" ]; then
  echo "Mods: None"
else
  echo "Mods:"
  for mod in $MODS; do
    echo " - $mod"
  done
fi

if [ "$CLEAR_MODS" == "Enabled" ]; then
  echo "Clear mods: Enabled (all mod files will be removed!)"
else
  echo "Clear mods: Disabled"
fi

if [ ! -f /opt/hytale/.machine-id ]; then
  echo "No machine id found! Generating one ..."

  cat /proc/sys/kernel/random/uuid | tr -d '-' > /opt/hytale/.machine-id
fi

echo "Updating machine id ..."
cat /opt/hytale/.machine-id | tee /etc/machine-id

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
  stdbuf -oL -eL ./hytale-downloader-linux-amd64 -credentials-path /opt/hytale/.hytale-downloader-credentials.json
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

if [ "$CLEAR_MODS" == "Enabled" ]; then
  cd /opt/hytale/Server/mods

  echo "Clear mods is enabled ... all mod files will be removed!"
  rm -f *.jar *.zip
fi

if [ ! -z "$MODS" ]; then
  cd /opt/hytale/Server/mods

  echo "Mods will be downloaded!"
  for mod in $MODS; do
    echo "Downloading '$mod' ..."
    curl -LO "$mod"
    if [ $? -ne 0 ]; then
      echo "Something went wrong while downloading mods. Continuing anyways ..."
    fi
  done
fi

if [ ! -f /opt/hytale/Server/HytaleServer.jar ]; then
  echo "Something went wrong, the required server files were not found!"
  exit -1
else
  # Mark ready for probes
  touch /tmp/.ready

  # Run server
  cd /opt/hytale/Server
  exec java -XX:AOTCache=HytaleServer.aot $JAVA_OPTIONS -jar HytaleServer.jar --assets ../Assets.zip --accept-early-plugins
  check_status
fi

echo "--- Exiting ---"

