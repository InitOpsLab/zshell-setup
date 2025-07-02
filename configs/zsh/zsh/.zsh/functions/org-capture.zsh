org_capture() {
  local usage="Usage: org_capture \"Task description\" [:tag1:tag2:] [--deadline=YYYY-MM-DD]"
  local task=""
  local tags=""
  local deadline=""
  local capture_date
  local deadline_line=""

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --deadline=*)
        deadline="${arg#*=}"
        ;;
      :*) # tags (e.g. :aws:rds:)
        tags="$arg"
        ;;
      *) # first plain argument is the task
        if [[ -z "$task" ]]; then
          task="$arg"
        fi
        ;;
    esac
  done

  if [[ -z "$task" ]]; then
    echo "$usage"
    return 1
  fi

  # Format current capture timestamp
  capture_date=$(date "+[%Y-%m-%d %a]")

  # Format deadline cross-platform
  if [[ -n "$deadline" ]]; then
    if date -j > /dev/null 2>&1; then
      # macOS
      weekday=$(date -j -f "%Y-%m-%d" "$deadline" "+%a")
    else
      # Linux
      weekday=$(date -d "$deadline" "+%a")
    fi
    deadline_line="  DEADLINE: <${deadline} ${weekday}>"
  fi

  # Append to inbox
  {
    echo -n "* TODO ${task}"
    [[ -n "$tags" ]] && echo -n " ${tags}"
    echo
    [[ -n "$deadline_line" ]] && echo "$deadline_line"
    echo "  Captured: ${capture_date}"
    echo
  } >> ~/notes/inbox.org

  echo "Captured: $task $tags ${deadline:+(due $deadline)}"
}

