aws-profile() {
  local profile_arg=""
  local profile_display="(default)"

  if [[ "$1" == "--profile" && -n "$2" ]]; then
    profile_arg="--profile $2"
    profile_display="($2)"
  elif [[ -n "$AWS_PROFILE" ]]; then
    profile_display="($AWS_PROFILE)"
    profile_arg="--profile $AWS_PROFILE"
  fi

  echo "🔍 AWS Profile: $profile_display"
  aws sts get-caller-identity $profile_arg 2>/dev/null | jq -r '"✅ Identity: \(.Arn)"' || {
    echo "❌ Unable to get identity. You may need to run: aws sso login --profile <name>"
    return 1
  }
}

