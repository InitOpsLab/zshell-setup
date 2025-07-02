org_agenda() {
  local notes_dir="${ORG_NOTES_DIR:-$HOME/notes}"
  local tag_filter=""
  local reset='\033[0m'
  local gray='\033[90m'
  local blue='\033[94m'
  local yellow='\033[93m'
  local orange='\033[33m'
  local red='\033[91m'

  for arg in "$@"; do
    case $arg in
      --tag=*)
        tag_filter="${arg#*=}"
        ;;
    esac
  done

  echo -e "${blue}Org Agenda from: $notes_dir${reset}"
  [[ -n "$tag_filter" ]] && echo "Filtering by tag: $tag_filter"
  echo "-----------------------------------------"

  find "$notes_dir" -type f -name "*.org" | while read -r file; do
    local filename="$(basename "$file")"
    grep -EA1 "^\*+ (TODO|WAITING|BLOCKED)" "$file" | sed '/--/d' | while read -r line; do
      if [[ -n "$line" ]]; then
        # Check for tag if requested
        if [[ -n "$tag_filter" && ! "$line" =~ ":${tag_filter}:" ]]; then
          continue
        fi

        # Colorize based on status
        case "$line" in
          *TODO*) color="$yellow" ;;
          *WAITING*) color="$orange" ;;
          *BLOCKED*) color="$red" ;;
          *DEADLINE:*) color="$gray" ;;
          *) color="$reset" ;;
        esac

        echo -e "${blue}${filename}${reset}: ${color}${line}${reset}"
      fi
    done
  done
}

