FROM docker.io/debian:trixie-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    openjdk-21-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -g 1000 hytale && \
    useradd -u 1000 -g hytale -m -s /bin/bash hytale

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
