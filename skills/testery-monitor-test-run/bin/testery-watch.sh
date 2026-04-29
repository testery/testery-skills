#!/usr/bin/env bash
# testery-watch: live ANSI dashboard for a Testery test run.
#
# Polls the Testery API for run status every POLL_SECONDS, renders a multi-line
# dashboard with progress bar, counts, ETA, and currently-running tests.
# Exits 0 when the run completes successfully, 1 on test failure or error.
#
# Usage:
#   testery-watch.sh <test-run-id> [--token TOKEN] [--poll N] [--api URL]
#
# Falls back to the TESTERY_TOKEN env var (or ~/.testery/credentials) for auth.
# TESTERY_API_URL overrides the default API endpoint.

set -euo pipefail

POLL_SECONDS="${TESTERY_WATCH_POLL:-3}"
API_URL="${TESTERY_API_URL:-https://api.testery.io}"
TOKEN="${TESTERY_TOKEN:-}"
RUN_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --token) TOKEN="$2"; shift 2 ;;
    --poll)  POLL_SECONDS="$2"; shift 2 ;;
    --api)   API_URL="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) RUN_ID="$1"; shift ;;
  esac
done

# Load token from credentials file if not in env
if [[ -z "$TOKEN" && -f "$HOME/.testery/credentials" ]]; then
  TOKEN="$(grep -E '^TESTERY_TOKEN=' "$HOME/.testery/credentials" | head -n1 | cut -d= -f2-)"
fi

if [[ -z "$RUN_ID" ]]; then echo "error: missing test-run-id" >&2; exit 2; fi
if [[ -z "$TOKEN" ]];  then echo "error: no TESTERY_TOKEN set (or run /testery-onboard)" >&2; exit 2; fi
command -v jq   >/dev/null || { echo "error: jq not found on PATH"   >&2; exit 2; }
command -v curl >/dev/null || { echo "error: curl not found on PATH" >&2; exit 2; }

# ---------- ANSI helpers ----------
ESC=$'\033'
HIDE_CURSOR="${ESC}[?25l"
SHOW_CURSOR="${ESC}[?25h"
CLEAR_LINE="${ESC}[2K"
HOME_LINE="${ESC}[G"

# Color helpers (NO_COLOR aware)
if [[ -n "${NO_COLOR:-}" || ! -t 1 ]]; then
  c_dim=""; c_bold=""; c_reset=""; c_red=""; c_grn=""; c_ylw=""; c_blu=""; c_gry=""
else
  c_reset="${ESC}[0m"; c_bold="${ESC}[1m"; c_dim="${ESC}[2m"
  c_red="${ESC}[31m"; c_grn="${ESC}[32m"; c_ylw="${ESC}[33m"; c_blu="${ESC}[34m"; c_gry="${ESC}[90m"
fi

cleanup() {
  printf "%s" "$SHOW_CURSOR"
  # leave the final dashboard frame in place; just put cursor on a new line below it.
  printf "\n"
}
trap cleanup EXIT INT TERM

# Track how many lines the previous frame rendered so we can clear them all.
prev_lines=0

# Re-detect terminal width on every frame (handles resize).
term_cols() { tput cols 2>/dev/null || echo 80; }

repeat_char() {
  local char="$1" count="$2" out=""
  while [[ $count -gt 0 ]]; do out+="$char"; ((count--)); done
  printf "%s" "$out"
}

format_duration() {
  local s=$1
  if (( s < 0 )); then s=0; fi
  printf "%02d:%02d" $((s/60)) $((s%60))
}

# Fetch run status. Echoes a single-line JSON blob with the fields we care about.
fetch_status() {
  local resp
  resp="$(curl -fsS -H "Authorization: Bearer $TOKEN" "$API_URL/test-runs/$RUN_ID" 2>/dev/null || echo '{}')"
  local results
  results="$(curl -fsS -H "Authorization: Bearer $TOKEN" "$API_URL/test-runs/$RUN_ID/test-run-tests" 2>/dev/null || echo '[]')"
  jq -nc --argjson run "$resp" --argjson tests "$results" '
    {
      id:        ($run.id // null),
      status:    ($run.status // "UNKNOWN"),
      project:   ($run.project // $run.projectKey // ""),
      env:       ($run.environment // $run.environmentKey // ""),
      startedAt: ($run.startedAt // $run.createdAt // null),
      total:     ($tests | length),
      pass:      [$tests[] | select(.status=="PASS"  or .status=="PASSED")]   | length,
      fail:      [$tests[] | select(.status=="FAIL"  or .status=="FAILED")]   | length,
      skip:      [$tests[] | select(.status=="SKIP"  or .status=="SKIPPED" or .status=="PENDING" or .status=="IGNORED")] | length,
      running:   [$tests[] | select(.status=="RUNNING" or .status=="IN_PROGRESS")] | length,
      queued:    [$tests[] | select(.status=="QUEUED" or .status=="PENDING_RUN")]  | length,
      now: ([$tests[] | select(.status=="RUNNING" or .status=="IN_PROGRESS") | (.name // .testName // .description // "test")][0:5])
    }'
}

# Render one frame. Args = JSON status blob.
render() {
  local blob="$1"
  local cols=$(term_cols)
  (( cols > 100 )) && cols=100
  (( cols < 50 ))  && cols=50

  local status project env total pass fail skip running queued
  status=$(jq -r '.status'  <<<"$blob")
  project=$(jq -r '.project // ""' <<<"$blob")
  env=$(jq -r '.env     // ""' <<<"$blob")
  total=$(jq -r '.total'   <<<"$blob")
  pass=$(jq -r  '.pass'    <<<"$blob")
  fail=$(jq -r  '.fail'    <<<"$blob")
  skip=$(jq -r  '.skip'    <<<"$blob")
  running=$(jq -r '.running' <<<"$blob")
  queued=$(jq -r  '.queued'  <<<"$blob")

  local started_unix elapsed eta_str pct
  started_unix=$(jq -r '.startedAt // empty' <<<"$blob" \
    | { read -r ts; [[ -n "$ts" ]] && date -d "$ts" +%s 2>/dev/null || echo "$EPOCHSECONDS"; })
  elapsed=$(( EPOCHSECONDS - started_unix ))
  if (( total > 0 )); then
    pct=$(( ( (pass + fail + skip) * 100 ) / total ))
  else
    pct=0
  fi
  if (( pass + fail + skip > 0 && pct > 0 && pct < 100 )); then
    local eta_secs=$(( elapsed * (100 - pct) / pct ))
    eta_str="~$(format_duration "$eta_secs")"
  else
    eta_str="?"
  fi

  # Progress bar
  local bar_w=$(( cols - 18 ))
  (( bar_w < 10 )) && bar_w=10
  local filled=$(( pct * bar_w / 100 ))
  local empty=$((  bar_w - filled ))
  local bar
  bar="${c_grn}$(repeat_char "█" "$filled")${c_gry}$(repeat_char "░" "$empty")${c_reset}"

  # Top/bottom borders
  local inner=$(( cols - 2 ))
  local top="╭$(repeat_char "─" "$inner")╮"
  local bot="╰$(repeat_char "─" "$inner")╯"

  # Build frame in an array so we can count lines.
  local -a lines=()
  lines+=( "${c_bold}${top}${c_reset}" )
  lines+=( "$(printf '│ %sTestery%s · run %s%s%s · %s @ %s' "$c_bold" "$c_reset" "$c_blu" "$RUN_ID" "$c_reset" "$project" "$env")$(printf '%*s' $(( cols - 2 - ${#project} - ${#env} - ${#RUN_ID} - 22 )) '')│" )
  lines+=( "│ $(printf '%*s' "$inner" '')│" )
  lines+=( "│ ${bar} $(printf '%3d%%' "$pct") $(printf '%*s' $(( inner - bar_w - 7 )) '')│" )
  lines+=( "│ $(printf '%*s' "$inner" '')│" )
  lines+=( "$(printf '│ ✅ %s%2d%s passed   ❌ %s%2d%s failed   ⏭️  %s%2d%s skipped   🟡 %s%2d%s running' \
              "$c_grn" "$pass" "$c_reset" \
              "$c_red" "$fail" "$c_reset" \
              "$c_dim" "$skip" "$c_reset" \
              "$c_ylw" "$running" "$c_reset")$(printf '%*s' 1 '')│" )
  lines+=( "$(printf '│ ⏱  elapsed: %s%s%s   eta: %s%s%s   queued: %d / total: %d' \
              "$c_bold" "$(format_duration "$elapsed")" "$c_reset" \
              "$c_bold" "$eta_str" "$c_reset" \
              "$queued" "$total")$(printf '%*s' 1 '')│" )
  lines+=( "│ $(printf '%*s' "$inner" '')│" )
  lines+=( "│ ${c_dim}Now running:${c_reset}$(printf '%*s' $(( inner - 13 )) '')│" )

  local count_now=0
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    # truncate to fit
    local maxlen=$(( inner - 6 ))
    if [[ ${#name} -gt $maxlen ]]; then name="${name:0:$((maxlen-1))}…"; fi
    lines+=( "$(printf '│   🟡 %s%s' "$name" "$(printf '%*s' $(( inner - 5 - ${#name} )) '')")│" )
    count_now=$(( count_now + 1 ))
  done < <(jq -r '.now[]' <<<"$blob")

  if (( count_now == 0 )); then
    local msg="(waiting for tests to start…)"
    [[ "$status" == "RUNNING" || "$status" == "IN_PROGRESS" ]] || msg="status: $status"
    lines+=( "│   ${c_dim}${msg}${c_reset}$(printf '%*s' $(( inner - 3 - ${#msg} )) '')│" )
  fi

  lines+=( "${c_bold}${bot}${c_reset}" )

  # Move cursor up over the previous frame, then redraw.
  if (( prev_lines > 0 )); then
    printf "%s[%dA" "$ESC" "$prev_lines"
  fi
  for l in "${lines[@]}"; do
    printf "%s%s%s\n" "$CLEAR_LINE" "$HOME_LINE" "$l"
  done
  prev_lines=${#lines[@]}
}

# ---------- main loop ----------
printf "%s" "$HIDE_CURSOR"

while true; do
  blob="$(fetch_status)"
  render "$blob"
  status=$(jq -r '.status' <<<"$blob")
  case "$status" in
    PASS|PASSED|COMPLETE|COMPLETED|SUCCESS|SUCCEEDED) exit_code=0; break ;;
    FAIL|FAILED|ERROR|ERRORED|CANCELLED|CANCELED)     exit_code=1; break ;;
  esac
  sleep "$POLL_SECONDS"
done

exit "${exit_code:-0}"
