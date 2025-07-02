eks_connect() {
  local cluster_name=$1
  local region=$2
  local profile=$3

  if [[ -z "$cluster_name" || -z "$region" || -z "$profile" ]]; then
    echo "Usage: eks_connect <cluster_name> <region> <aws_profile>"
    return 1
  fi

  aws eks update-kubeconfig --region "$region" --name "$cluster_name" --profile "$profile"
}

