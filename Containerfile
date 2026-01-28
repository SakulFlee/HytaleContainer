FROM docker.io/debian:trixie-slim

# Install dependencies
RUN apt-get update \
 && apt-get install -y curl unzip wget apt-transport-https gpg netcat-traditional \
 && wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null \
 && echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list > /dev/null \
 && apt-get update \
 && apt-get install -y temurin-25-jre \
 && rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -g 1000 hytale && \
    useradd -u 1000 -g hytale -m -s /bin/bash hytale

# Create EMPTY machine-id
RUN touch /etc/machine-id && chown 1000:1000 /etc/machine-id

# Create directories
RUN mkdir -p /opt/hytale /opt/hytale-downloader && \
    chown -R hytale:hytale /opt/hytale /opt/hytale-downloader

# Download and setup Hytale downloader
RUN cd /opt/hytale-downloader && \
    curl -L https://downloader.hytale.com/hytale-downloader.zip -o hytale-downloader.zip && \    
    unzip hytale-downloader.zip && \
    chmod +x hytale-downloader-linux-amd64 && \
    rm hytale-downloader.zip

# Switch to hytale user
USER hytale

# Set working directory
WORKDIR /opt/hytale

# Expose game port
EXPOSE 5520/udp

COPY --chown=hytale:hytale --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
