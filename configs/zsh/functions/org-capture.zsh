org_capture() {
  local task=""
  local tags=""
  local deadline=""
  local timestamp=$(date "+[%Y-%m-%d %a]")
  local deadline_line=""

  for arg in "$@"; do
    case $arg in
      --deadline=*)
        deadline="${arg#*=}"
        if date -j > /dev/null 2>&1; then
          weekday=$(date -j -f "%Y-%m-%d" "$deadline" "+%a")
        else
          weekday=$(date -d "$deadline" "+%a")
        fi
        deadline_line="  DEADLINE: <${deadline} ${weekday}>"
        ;;
      :*) tags="$arg" ;;
      *)  [[ -z "$task" ]] && task="$arg" ;;
    esac
  done

  [[ -z "$task" ]] && echo "Usage: org_capture \"task\" [:tags:] [--deadline=YYYY-MM-DD]" && return 1

  {
    echo -n "* TODO ${task}"
    [[ -n "$tags" ]] && echo -n " ${tags}"
    echo
    [[ -n "$deadline_line" ]] && echo "$deadline_line"
    echo "  Captured: $timestamp"
    echo
  } >> ~/notes/inbox.org

  echo "Captured: $task $tags ${deadline:+(due $deadline)}"
}
