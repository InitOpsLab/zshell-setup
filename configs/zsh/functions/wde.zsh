# wde: "wd but open in VS Code" (shares ~/.warprc; colon-separated: mark:path)

wde() {
  command -v code >/dev/null 2>&1 || { echo "code: not found in PATH"; return 127; }

  local rc="${WARP_FILE:-$HOME/.warprc}"
  [[ -f "$rc" ]] || : > "$rc"

  _wde_expand_tilde() {
    case "$1" in
      "~"|"~/"* ) print -r -- "${1/#\~/$HOME}" ;;
      * )         print -r -- "$1" ;;
    esac
  }

  _wde_lookup() {
    local mark="$1" line k v out=""
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%$'\r'}"
      [[ -z "$line" || "$line" = \#* ]] && continue
      k="${line%%:*}"; v="${line#*:}"
      k="${k#"${k%%[![:space:]]*}"}"; k="${k%"${k##*[![:space:]]}"}"
      [[ "$k" = "$mark" ]] && out="$v"
    done < "$rc"
    [[ -n "$out" ]] && _wde_expand_tilde "$out"
  }

  _wde_list() {
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
Usage: wde [point...] | [command]

Open wd bookmarks directly in VS Code. Shares ~/.warprc with wd.

Commands:
  <point> [point...]   Open one or more warp points in VS Code
  ls|list              List warp points
  add <point>          Add current directory as a warp point
  rm  <point>          Remove a warp point
  clean                Remove points pointing to non-existent dirs
  help, -h             Show this help

Examples:
  wde api
  wde api helm-charts deploy-service
  wde ls
  wde add docs
EOF
      ;;
    ls|list)
      _wde_list
      ;;
    add)
      [[ -z "$2" ]] && { echo "wde add: missing name"; return 1; }
      printf '%s:%s\n' "$2" "$PWD" >> "$rc"
      echo "Added warp point '$2' -> $PWD"
      ;;
    rm)
      [[ -z "$2" ]] && { echo "wde rm: missing name"; return 1; }
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
        v="$(_wde_expand_tilde "$v")"
        [[ -d "$v" ]] && printf '%s:%s\n' "$k" "$v" >> "$tmp"
      done < "$rc"
      mv "$tmp" "$rc"
      echo "Cleaned invalid warp points."
      ;;
    "")
      code .
      ;;
    *)
      local dirs=()

      for mark in "$@"; do
        local dir="$(_wde_lookup "$mark")"
        if [[ -n "$dir" && -d "$dir" ]]; then
          dirs+=("$dir")
        else
          echo "wde: skipping invalid warp point: $mark" >&2
        fi
      done

      if [[ ${#dirs[@]} -eq 0 ]]; then
        echo "wde: no valid warp points found" >&2
        return 1
      fi

      code "${dirs[@]}"
      ;;
  esac
}

_wde__marks_arr() {
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

_wde() {
  local -a marks subcmds already_used
  marks=(${(f)"$(_wde__marks_arr)"})
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

_wde_compctl_all() { reply=(ls list add rm clean help ${(f)"$(_wde__marks_arr)"}); }

if (( $+functions[compdef] )); then
  compdef _wde wde
else
  compctl -K _wde_compctl_all wde 2>/dev/null
fi
