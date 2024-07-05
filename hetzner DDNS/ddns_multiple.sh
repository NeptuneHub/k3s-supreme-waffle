#!/bin/bash

# Configuration
CREDENTIALS_FILE="/etc/hetzner-ddns-credentials.txt"
DOMAIN_NAME="example.com"
RECORD_NAMES=("record1" "record2" "record3") # Add as many record names as needed
RECORD_TYPE="A" # or AAAA for IPv6

# Get API Token from credentials file
API_TOKEN=$(<"$CREDENTIALS_FILE")

if [ -z "$API_TOKEN" ]; then
  echo "Error: API token not found or empty in $CREDENTIALS_FILE"
  exit 1
fi

# Get the current public IP address
CURRENT_IP=$(curl -4 -s https://ip.hetzner.com)

# Get Zone ID
ZONE_ID=$(curl -s -X GET \
  -H "Auth-API-Token: ${API_TOKEN}" \
  "https://dns.hetzner.com/api/v1/zones" | jq -r ".zones[] | select(.name==\"${DOMAIN_NAME}\") | .id")

if [ -z "$ZONE_ID" ]; then
  echo "Error: Zone ID not found for domain ${DOMAIN_NAME}"
  exit 1
fi

# Function to update DNS record
update_dns_record() {
  local RECORD_NAME=$1
  local RECORD_ID=$(curl -s -X GET \
    -H "Auth-API-Token: ${API_TOKEN}" \
    "https://dns.hetzner.com/api/v1/records?zone_id=${ZONE_ID}" | jq -r ".records[] | select(.name==\"${RECORD_NAME}\") | .id")

  if [ -z "$RECORD_ID" ]; then
    echo "Error: Record ID not found for record ${RECORD_NAME}"
    return
  fi

  local DNS_RECORD=$(curl -s -X GET \
    -H "Auth-API-Token: ${API_TOKEN}" \
    "https://dns.hetzner.com/api/v1/records/${RECORD_ID}" | jq -r '.record.value')

  # Compare the current IP with the DNS record value
  if [ "$CURRENT_IP" != "$DNS_RECORD" ]; then
    # Update the DNS record if the IP has changed
    curl -s -X PUT \
      -H "Content-Type: application/json" \
      -H "Auth-API-Token: ${API_TOKEN}" \
      -d "{
            \"value\": \"${CURRENT_IP}\",
            \"ttl\": 60,
            \"type\": \"${RECORD_TYPE}\",
            \"name\": \"${RECORD_NAME}\",
            \"zone_id\": \"${ZONE_ID}\"
          }" \
      "https://dns.hetzner.com/api/v1/records/${RECORD_ID}"
  
    echo "DNS record for ${RECORD_NAME} updated to ${CURRENT_IP}"
  else
    echo "DNS record for ${RECORD_NAME} is already up-to-date"
  fi
}

# Loop through each record name to update
for RECORD_NAME in "${RECORD_NAMES[@]}"; do
  update_dns_record "$RECORD_NAME"
done
