list_node_labels() {
  local NODEPOOL=""
  while getopts "p:h" opt; do
    case ${opt} in
      p) NODEPOOL="${OPTARG}" ;;
      h)
        echo "Usage: list_node_labels [-p <nodepool>]"
        echo "  -p <nodepool>   Filter by karpenter.sh/nodepool label"
        echo "  -h              Show help"
        return 0
        ;;
      *) echo "Invalid option"; return 1 ;;
    esac
  done

  local LABEL_FILTER=""
  if [[ -n "$NODEPOOL" ]]; then
    LABEL_FILTER="-l karpenter.sh/nodepool=${NODEPOOL}"
    echo "Fetching nodes for nodepool: ${NODEPOOL}"
  else
    echo "Fetching all nodes..."
  fi
  echo

  local TMPFILE
  TMPFILE=$(mktemp /tmp/node-labels.XXXXXX)

  kubectl get nodes $LABEL_FILTER -o json | jq -r '
    .items[] |
    {
      name: .metadata.name,
      labels: .metadata.labels
    } |
    .name as $n |
    "NODE: " + $n,
    (to_entries | map("  " + .key + "=" + .value) | .[])
  ' > "$TMPFILE"

  if ! grep -q "NODE:" "$TMPFILE"; then
    echo "No nodes found."
    rm -f "$TMPFILE"
    return 0
  fi

  cat "$TMPFILE"
  echo
  echo "------ Label Summary ------"

  grep -v '^NODE:' "$TMPFILE" | awk -F= '{print $1}' | sed 's/^ *//' | sort | uniq -c | sort -nr | awk '{printf "%4d  %s\n", $1, $2}'

  local total_nodes
  total_nodes=$(grep -c '^NODE:' "$TMPFILE")
  echo
  echo "Total nodes: $total_nodes"
  echo "Unique label keys: $(grep -v '^NODE:' "$TMPFILE" | awk -F= '{print $1}' | sort -u | wc -l)"

  rm -f "$TMPFILE"
}
