# wdn: "wd but open in nvim" (shares ~/.warprc; colon-separated: mark:path)

wdn() {
  command -v nvim >/dev/null 2>&1 || { echo "nvim: not found in PATH"; return 127; }

  local rc="${WARP_FILE:-$HOME/.warprc}"
  local workspace_dir="$HOME/.cache/nvim/workspaces"
  [[ -f "$rc" ]] || : > "$rc"

  _wdn_expand_tilde() {
    case "$1" in
      "~"|"~/"* ) print -r -- "${1/#\~/$HOME}" ;;
      * )         print -r -- "$1" ;;
    esac
  }

  _wdn_lookup() {
    local mark="$1" line k v out=""
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%$'\r'}"
      [[ -z "$line" || "$line" = \#* ]] && continue
      k="${line%%:*}"; v="${line#*:}"
      k="${k#"${k%%[![:space:]]*}"}"; k="${k%"${k##*[![:space:]]}"}"
      [[ "$k" = "$mark" ]] && out="$v"
    done < "$rc"
    [[ -n "$out" ]] && _wdn_expand_tilde "$out"
  }

  _wdn_list() {
    local line k v
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%$'\r'}"
      [[ -z "$line" || "$line" = \#* || "$line" != *:* ]] && continue
      k="${line%%:*}"; v="${line#*:}"
      k="${k#"${k%%[![:space:]]*}"}"; k="${k%"${k##*[![:space:]]}"}"
      v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"
      printf '%-20s -> %s\n' "$k" "$v"
    done < "$rc"
  }

  case "$1" in
    -h|--help|help)
      cat <<'EOF'
Usage: wdn [point...] | [command]

Open wd bookmarks directly in nvim. Shares ~/.warprc with wd.

Commands:
  <point> [point...]   Open one or more warp points in nvim
  ls|list              List warp points
  add <point>          Add current directory as a warp point
  rm  <point>          Remove a warp point
  clean                Remove points pointing to non-existent dirs
  help, -h             Show this help

Examples:
  wdn api
  wdn api helm-charts deploy-service
  wdn ls
  wdn add docs
EOF
      ;;
    ls|list)
      _wdn_list
      ;;
    add)
      [[ -z "$2" ]] && { echo "wdn add: missing name"; return 1; }
      printf '%s:%s\n' "$2" "$PWD" >> "$rc"
      echo "Added warp point '$2' -> $PWD"
      ;;
    rm)
      [[ -z "$2" ]] && { echo "wdn rm: missing name"; return 1; }
      {
        local line k
        while IFS= read -r line || [[ -n "$line" ]]; do
          [[ "$line" != *:* ]] && { print -r -- "$line"; continue; }
          k="${line%%:*}"
          k="${k#"${k%%[![:space:]]*}"}"; k="${k%"${k##*[![:space:]]}"}"
          [[ "$k" == "$2" ]] || print -r -- "$line"
        done < "$rc"
      } > "${rc}.tmp" && mv "${rc}.tmp" "$rc"
      echo "Removed warp point '$2'"
      ;;
    clean)
      local tmp="${rc}.tmp" line k v
      : > "$tmp"
      while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%$'\r'}"
        [[ -z "$line" || "$line" = \#* || "$line" != *:* ]] && continue
        k="${line%%:*}"; v="${line#*:}"
        v="${v#"${v%%[![:space:]]*}"}"; v="${v%"${v##*[![:space:]]}"}"
        v="$(_wdn_expand_tilde "$v")"
        [[ -d "$v" ]] && printf '%s:%s\n' "$k" "$v" >> "$tmp"
      done < "$rc"
      mv "$tmp" "$rc"
      echo "Cleaned invalid warp points."
      ;;
    "")
      nvim .
      ;;
    *)
      local projects=() dirs=()

      for mark in "$@"; do
        local dir="$(_wdn_lookup "$mark")"
        if [[ -n "$dir" && -d "$dir" ]]; then
          projects+=("$mark")
          dirs+=("$dir")
        else
          echo "wdn: skipping invalid warp point: $mark" >&2
        fi
      done

      if [[ ${#projects[@]} -eq 0 ]]; then
        echo "wdn: no valid warp points found" >&2
        return 1
      fi

      if [[ ${#projects[@]} -eq 1 ]]; then
        nvim "${dirs[1]}"
      else
        local ws_name="${(j:+:)projects}"
        local ws_path="$workspace_dir/$ws_name"
        mkdir -p "$workspace_dir"
        [[ -d "$ws_path" ]] && rm -rf "$ws_path"
        mkdir -p "$ws_path"

        for i in {1..${#projects[@]}}; do
          ln -sf "${dirs[$i]}" "$ws_path/${projects[$i]}"
        done

        echo "Workspace: $ws_name (${#projects[@]} projects)"
        nvim "$ws_path"
      fi
      ;;
  esac
}

_wdn__marks_arr() {
  local rc="${WARP_FILE:-$HOME/.warprc}"
  local line k out=()
  [[ -r "$rc" ]] || { echo; return 0; }
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%$'\r'}"
    [[ -z "$line" || "$line" = \#* || "$line" != *:* ]] && continue
    k="${line%%:*}"
    k="${k#"${k%%[![:space:]]*}"}"; k="${k%"${k##*[![:space:]]}"}"
    [[ -n "$k" ]] && out+="$k"
  done < "$rc"
  print -l -- $out
}

_wdn() {
  local -a marks subcmds already_used
  marks=(${(f)"$(_wdn__marks_arr)"})
  subcmds=(ls list add rm clean help)

  if (( CURRENT == 2 )); then
    compadd -a subcmds
    [[ ${#marks} -gt 0 ]] && compadd -a marks
  elif (( CURRENT >= 3 )); then
    local first="${words[2]}"
    if [[ ${marks[(I)${first}]} -gt 0 ]]; then
      already_used=(${words[2,CURRENT-1]})
      local -a remaining=()
      for m in $marks; do
        [[ ${already_used[(I)$m]} -eq 0 ]] && remaining+=("$m")
      done
      [[ ${#remaining} -gt 0 ]] && compadd -a remaining
    fi
  fi
}

_wdn_compctl_all() { reply=(ls list add rm clean help ${(f)"$(_wdn__marks_arr)"}); }

if (( $+functions[compdef] )); then
  compdef _wdn wdn
else
  compctl -K _wdn_compctl_all wdn 2>/dev/null
fi
