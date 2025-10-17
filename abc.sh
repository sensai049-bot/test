#!/bin/bash
setsid nohup bash -c '
set -euo pipefail

export OLD_FALCON_CLIENT_ID="d76cd67ddaf043eaa4859cc33334eb94"   
export OLD_FALCON_CLIENT_SECRET="Y0fuJDn2yUa51zl4Qe8ibhXI36ct9SVEBRd7qsAg"
export OLD_FALCON_CLOUD="us-2"

export NEW_FALCON_CLIENT_ID="c437327aad8a4e8f9135c45d7a379386"
export NEW_FALCON_CLIENT_SECRET="HEvfkqpuJF4QmI7twrTLaxRKM9o185206g3XzBYc"
export NEW_FALCON_CLOUD="eu-1"
export FALCON_REMOVE_HOST="true"
export LOG_PATH="/tmp" 
LOG=/tmp/falcon_migrate_$(date +%Y%m%d_%H%M%S).log
MIG=/tmp/falcon-linux-migrate.sh

echo "[INFO] Downloading official migrate script..." | tee -a "$LOG"
curl -fsSL https://raw.githubusercontent.com/crowdstrike/falcon-scripts/v1.8.0/bash/migrate/falcon-linux-migrate.sh -o "$MIG"
chmod +x "$MIG"

echo "[INFO] Starting migration..." | tee -a "$LOG"
timeout 15m bash "$MIG" >>"$LOG" 2>&1 || true

# Nếu bị PREUN lỗi
if rpm -q falcon-sensor >/dev/null 2>&1; then
  echo "[WARN] PREUN failed, forcing uninstall..." | tee -a "$LOG"
  systemctl stop falcon-sensor 2>/dev/null || true
  pkill -9 falcon-sensor 2>/dev/null || true
  modprobe -r falcon_lsm 2>/dev/null || true
  modprobe -r falcon 2>/dev/null || true
  rpm -e --nopreun falcon-sensor 2>>"$LOG" || rpm -e --noscripts falcon-sensor 2>>"$LOG" || true
  rm -rf /opt/CrowdStrike /etc/systemd/system/falcon-sensor.service
  systemctl daemon-reload
  echo "[INFO] Retrying migration..." | tee -a "$LOG"
  bash "$MIG" >>"$LOG" 2>&1 || true
fi

echo "[DONE] Migration finished. Log: $LOG" | tee -a "$LOG"
' >/tmp/falcon_wrapper.out 2>&1 < /dev/null &
