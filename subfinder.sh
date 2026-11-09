
#!/bin/bash

# Automatic Subdomain Enumeration
# Passive Reconnaissance

if [ -z "$1" ]; then
    echo "Usage: bash subdomain.sh example.com"
    exit 1
fi

DOMAIN="$1"
OUTPUT="${DOMAIN}_subdomains.txt"
TEMP=$(mktemp -d)

echo "[+] Target: $DOMAIN"
echo "[+] Starting Subdomain Enumeration..."

# Subfinder
if command -v subfinder >/dev/null 2>&1; then
    echo "[+] Running Subfinder..."
    subfinder -d "$DOMAIN" -all -silent \
    >> "$TEMP/subs.txt"
fi

# Assetfinder
if command -v assetfinder >/dev/null 2>&1; then
    echo "[+] Running Assetfinder..."
    assetfinder --subs-only "$DOMAIN" \
    >> "$TEMP/subs.txt"
fi

# Amass Passive
if command -v amass >/dev/null 2>&1; then
    echo "[+] Running Amass..."
    amass enum -passive -d "$DOMAIN" \
    >> "$TEMP/subs.txt"
fi

# Findomain
if command -v findomain >/dev/null 2>&1; then
    echo "[+] Running Findomain..."
    findomain -t "$DOMAIN" -q \
    >> "$TEMP/subs.txt"
fi

# crt.sh
if command -v curl >/dev/null 2>&1; then
    echo "[+] Running crt.sh..."
    curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" |
    jq -r '.[].name_value' 2>/dev/null |
    sed 's/\*\.//g' >> "$TEMP/subs.txt"
fi

# Clean and filter
grep -E "(^|\.)${DOMAIN//./\\.}$" "$TEMP/subs.txt" 2>/dev/null |
tr '[:upper:]' '[:lower:]' |
sort -u > "$OUTPUT"

rm -rf "$TEMP"

echo " "
echo "[+] Enumeration Completed!"
echo "[+] Total Subdomains: $(wc -l < "$OUTPUT")"
echo "[+] Saved File: $OUTPUT"
