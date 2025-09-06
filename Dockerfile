FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Install rclone
RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip \
    && unzip rclone-current-linux-amd64.zip \
    && cd rclone-*-linux-amd64 \
    && cp rclone /usr/bin/ \
    && chown root:root /usr/bin/rclone \
    && chmod 755 /usr/bin/rclone

# Copy rclone.conf from repo into container
RUN mkdir -p /root/.config/rclone
COPY rclone.conf /root/.config/rclone/rclone.conf

# Working dir
WORKDIR /app

# Expose Render's $PORT
CMD ["sh", "-c", "rclone serve webdav blomp1-chunker: \
  --addr :$PORT \
  --vfs-cache-mode full \
  --vfs-cache-max-size 15G \
  --vfs-cache-max-age 1h \
  --vfs-read-chunk-size 128M \
  --vfs-read-chunk-size-limit off \
  --buffer-size 128M \
  --dir-cache-time 1h \
  --poll-interval 30s \
  --transfers 4 \
  --checkers 8 \
  --no-modtime \
  --fast-list"]
