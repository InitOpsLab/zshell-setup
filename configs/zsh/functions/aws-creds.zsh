# AWS SSO credentials helper
# Copy credentials from AWS SSO console, then run `aws-creds`
aws-creds() {
  local clip
  clip=$(pbpaste)

  local key_id secret token
  key_id=$(echo "$clip" | grep -oE 'AWS_ACCESS_KEY_ID="[^"]+"' | cut -d'"' -f2)
  secret=$(echo "$clip" | grep -oE 'AWS_SECRET_ACCESS_KEY="[^"]+"' | cut -d'"' -f2)
  token=$(echo "$clip" | grep -oE 'AWS_SESSION_TOKEN="[^"]+"' | cut -d'"' -f2)

  if [[ -z "$key_id" || -z "$secret" || -z "$token" ]]; then
    echo "Error: Could not parse AWS credentials from clipboard"
    echo "Make sure you copied the 'Set AWS environment variables' block from SSO"
    return 1
  fi

  export AWS_ACCESS_KEY_ID="$key_id"
  export AWS_SECRET_ACCESS_KEY="$secret"
  export AWS_SESSION_TOKEN="$token"

  echo "AWS credentials exported successfully"
  echo "  AWS_ACCESS_KEY_ID: ${key_id:0:8}..."
}
