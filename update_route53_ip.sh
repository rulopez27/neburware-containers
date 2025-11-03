#!/usr/bin/env bash

# CONFIG

TTL=300
LOGFILE="/var/log/route53_ddns.log"
# LOGFILE="./route53_ddns.log"

# Hosted Zones with multiple records each
# Example:
#   ZONE_ID => record1 record2 record3 ...
declare -A ZONES
ZONES["Z03900392GJKFNA0MXOV3"]="neburware.com."
ZONES["Z010495721FBW2VTENFFO"]="cloud.neburware.com."
ZONES["Z08548352D4ONG2Q16V5P"]="smtp.neburware.com."

# GET PUBLIC IP
CURRENT_IP=$(curl -s https://checkip.amazonaws.com)

# LAST IP CACHE (avoid AWS calls if same)
LAST_IP_FILE="/tmp/last_public_ip.txt"
LAST_IP=$(cat "$LAST_IP_FILE" 2>/dev/null)

if [ "$CURRENT_IP" == "$LAST_IP" ]; then
  echo "$(date): IP did not change ($CURRENT_IP)" >> "$LOGFILE"
  exit 0
fi

# LOOP: hosted zones → records in each zone
for HOSTED_ZONE_ID in "${!ZONES[@]}"; do
  for RECORD_NAME in ${ZONES[$HOSTED_ZONE_ID]}; do

    CHANGE_BATCH=$(cat <<EOF
{
  "Comment": "Auto-update public IP via cron",
  "Changes": [{
    "Action": "UPSERT",
    "ResourceRecordSet": {
      "Name": "$RECORD_NAME",
      "Type": "A",
      "TTL": $TTL,
      "ResourceRecords": [{ "Value": "$CURRENT_IP" }]
    }
  }]
}
EOF
)

    aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTED_ZONE_ID" \
      --change-batch "$CHANGE_BATCH"

    if [ $? -eq 0 ]; then
      echo "$(date): [$HOSTED_ZONE_ID] Updated $RECORD_NAME → $CURRENT_IP" >> "$LOGFILE"
    else
      echo "$(date): [$HOSTED_ZONE_ID] ERROR updating $RECORD_NAME" >> "$LOGFILE"
    fi

  done
done

# update cache
echo "$CURRENT_IP" > "$LAST_IP_FILE"
