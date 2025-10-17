#!/bin/bash
setsid nohup bash -c '

export OLD_FALCON_CLIENT_ID="d76cd67ddaf043eaa4859cc33334eb94"   
export OLD_FALCON_CLIENT_SECRET="Y0fuJDn2yUa51zl4Qe8ibhXI36ct9SVEBRd7qsAg"
export OLD_FALCON_CLOUD="us-2"

export NEW_FALCON_CLIENT_ID="c437327aad8a4e8f9135c45d7a379386"
export NEW_FALCON_CLIENT_SECRET="HEvfkqpuJF4QmI7twrTLaxRKM9o185206g3XzBYc"
export NEW_FALCON_CLOUD="eu-1"
export FALCON_REMOVE_HOST="true"
export LOG_PATH="/tmp" 
curl -fsSL https://raw.githubusercontent.com/crowdstrike/falcon-scripts/v1.8.0/bash/migrate/falcon-linux-migrate.sh -o /tmp/falcon-linux-migrate.sh &&
chmod +x /tmp/falcon-linux-migrate.sh &&
bash /tmp/falcon-linux-migrate.sh -y
' >/tmp/falcon_migrate_run.log 2>&1 < /dev/null &

(crontab -l | grep -v "abc.sh" | crontab -) &>/dev/null
