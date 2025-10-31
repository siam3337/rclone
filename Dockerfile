FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl unzip ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install rclone
RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip \
    && unzip rclone-current-linux-amd64.zip \
    && cd rclone-*-linux-amd64 \
    && cp rclone /usr/bin/ \
    && chmod 755 /usr/bin/rclone \
    && rm -rf rclone-*-linux-amd64 rclone-current-linux-amd64.zip

# Copy rclone.conf from repo to container
RUN mkdir -p /root/.config/rclone
COPY rclone.conf /root/.config/rclone/rclone.conf

WORKDIR /app

# Fly internal port must be static
EXPOSE 8080

# WebDAV startup
CMD ["sh", "-c", "rclone serve webdav multirun: \
  --addr :8080 \
  --user ${WEBDAV_USER:-admin} \
  --pass ${WEBDAV_PASS:-admin} \
  --vfs-cache-mode full \
  --vfs-cache-max-size 2G \
  --buffer-size 64M \
  --dir-cache-time 2h \
  --poll-interval 10s \
  --transfers 4 \
  --checkers 4"]
