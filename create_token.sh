#!/bin/bash

# Configuration
PERSONAL_TOKEN=""
API_URL="http://localhost:8080/api/v4/groups"

# Show usage
usage() {
  echo "Usage: $0 -g <group_id> -n <token_name> -s <scopes_comma_separated> [-e <expires_at YYYY-MM-DD>]"
  echo "Options:"
  echo "  -g   GitLab Group ID"
  echo "  -n   Token Name"
  echo "  -s   Scopes (comma separated). Selectable scopes: api | read_api | read_repository | write_repository | read_registry | write_registry"
  echo "  -e   (Optional) Expiration date in format YYYY-MM-DD"
  exit 1
}

# Create JSON payload
create_payload() {
  local data
  local expires_at_value
  
  if date -d today >/dev/null 2>&1; then
    expires_at_value="${EXPIRES_AT:-$(date -d 'next year -1 day' +%Y-%m-%d)}"
  else
    expires_at_value="${EXPIRES_AT:-$(date -v+1y -v-1d +%Y-%m-%d)}"
  fi

  data=$(jq -n \
    --arg name "$TOKEN_NAME" \
    --argjson scopes "$(echo "[\"${SCOPES//,/\",\"}\"]")" \
    --arg expires_at "$expires_at_value" \
    --argjson access_level 30 \
    '{name: $name, scopes: $scopes, expires_at: $expires_at, access_level: $access_level}')
    # NOTE: access_levelは一旦、30（Developer）で固定
    # 必要があれば、40（Maintainer）にする

  echo "$data"
}

# Request token
request_token() {
  local payload=$1
  local raw_response_file=$2

  echo "Creating GitLab Group Access Token..."
  curl --silent --show-error --fail --request POST "${API_URL}/${GROUP_ID}/access_tokens" \
       --header "PRIVATE-TOKEN: ${PERSONAL_TOKEN}" \
       --header "Content-Type: application/json" \
       --data "${payload}" > "$raw_response_file" || {
         echo "Failed to create token"
         exit 1
       }
}

# Format response
format_response() {
  local raw_response_file=$1
  local response_file=$2
  local token_file=$3

  jq '.' "$raw_response_file" | tee "$response_file"

  local token
  token=$(jq -r '.token' "$response_file")

  if [[ "$token" == "null" || -z "$token" ]]; then
    echo "Token not found in response"
    exit 1
  fi

  echo "Access Token: $token"
  echo "$token" > "$token_file"
  # echo "Token saved to $token_file"
  # echo "Response saved to $response_file"
  # echo "Token creation completed."
}

# Execute API Request
create_token() {
  local payload
  local raw_response_file="raw_response.json"
  local response_file="response.json"
  local token_file="created_token.txt"

  payload=$(create_payload)

  request_token "$payload" "$raw_response_file"
  format_response "$raw_response_file" "$response_file" "$token_file"
}

# Parse arguments
while getopts "g:n:s:e:" opt; do
  case $opt in
    g) GROUP_ID="$OPTARG" ;;
    n) TOKEN_NAME="$OPTARG" ;;
    s) SCOPES="$OPTARG" ;;
    e) EXPIRES_AT="$OPTARG" ;;
    *) usage ;;
  esac
done

# Validate required arguments
if [[ -z "$GROUP_ID" || -z "$PERSONAL_TOKEN" || -z "$TOKEN_NAME" || -z "$SCOPES" ]]; then
  usage "$@"
fi

# Execute
create_token "$@"