#!/bin/bash

# Đảm bảo script dừng nếu có lỗi
set -e

# Lấy phiên bản từ đối số dòng lệnh
BEDROCK_VERSION="$1"

# Cập nhật và cài các gói cần thiết
apt update
apt install -y zip unzip wget curl

cd /app/data

RANDVERSION=$(echo $((1 + $RANDOM % 4000)))

# Tải phiên bản mới nhất nếu không có tham số hoặc là "latest"
if [ -z "${BEDROCK_VERSION}" ] || [ "${BEDROCK_VERSION}" == "latest" ]; then
  echo "Downloading latest Bedrock server"

  curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.${RANDVERSION}.212 Safari/537.36" \
    -H "Accept-Language: en" -H "Accept-Encoding: gzip, deflate" \
    -o versions.html.gz https://net-secondary.web.minecraft-services.net/api/v1.0/download/links

  DOWNLOAD_URL=$(zgrep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/[^"]*' versions.html.gz)
else
  echo "Downloading Bedrock server version: ${BEDROCK_VERSION}"
  DOWNLOAD_URL="https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${BEDROCK_VERSION}.zip"
fi

DOWNLOAD_FILE=$(basename "${DOWNLOAD_URL}")

# Sao lưu file cấu hình hiện tại
rm -f *.bak versions.html.gz
cp server.properties server.properties.bak 2>/dev/null || true
cp permissions.json permissions.json.bak 2>/dev/null || true
cp allowlist.json allowlist.json.bak 2>/dev/null || true

# Tải về và giải nén
curl -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.${RANDVERSION}.212 Safari/537.36" \
  -H "Accept-Language: en" -o "${DOWNLOAD_FILE}" "${DOWNLOAD_URL}"

unzip -o "${DOWNLOAD_FILE}"
rm -f "${DOWNLOAD_FILE}"

# Khôi phục file cấu hình
cp -f server.properties.bak server.properties 2>/dev/null || true
cp -f permissions.json.bak permissions.json 2>/dev/null || true
cp -f allowlist.json.bak allowlist.json 2>/dev/null || true

chmod +x bedrock_server

echo "✅ Install Completed"
