#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -r SCRIPT="${0##*/}"
declare -r FUNCTION="function %b() { echo '%b'; }; %b;"
declare -r TEXT_RESULT="%-20s %-4b  %6s  %8s\n"
declare -r ADOC_RESULT="| %s\n| %b\n| %s\n| %s\n\n"
declare -g RESULT=${TEXT_RESULT}
declare -g MODE=text
declare -A LOOKUP=(
  [33]="Exclamation mark"
  [34]="Double quote"
  [35]="Number sign"
  [36]="Dollar sign"
  [37]="Percent sign"
  [38]="Ampersand"
  [39]="Single quote"
  [40]="Left parenthesis"
  [41]="Right parenthesis"
  [42]="Asterisk"
  [43]="Plus sign"
  [46]="Period"
  [47]="Slash"
  [59]="Semicolon"
  [60]="Less-than"
  [61]="Equal"
  [62]="Greater-than"
  [63]="Question mark"
  [91]="Left square bracket"
  [92]="Backslash"
  [93]="Right square bracket"
  [96]="Grave accent"
  [123]="Left curly bracket"
  [124]="Pipe"
  [125]="Right curly bracket"
  [126]="Tilde"
)

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
function usage() {
  local exit_code=${1:-1}
  cat <<USAGE
  Usage:
    ${SCRIPT} [<options>]

  Options:
    -h --help      This message
    -a --asciidoc  Output as asciidoc table
    -t --text      Output as text table (Default)
USAGE
  exit ${exit_code}
}

function parse_options() {
  while (( ${#} > 0 )); do
    case "${1}" in
    -a|--asciidoc)
      MODE=adoc
      RESULT=${ADOC_RESULT}
      ;;
    -t|--text)
      MODE=text
      RESULT=${TEXT_RESULT}
      ;;
    -h|--help)
      usage 0;;
    *)
      usage 1;;
    esac
    shift
  done
}

function print_header() {
  local title="Non valid characters in Bash function names"
  case ${MODE} in
  text)
    printf "\n%s\n\n" "${title}"
    ;;
  adoc)
    printf ".%s\n" "${title}"
    printf '[cols="4",options="header"]\n'
    printf '|===\n'
    ;;
  esac
  printf "${RESULT}" "Name" "Symbol" "ASCII" "UTF-8"
}

function asciidoc_table_escape() {
  case ${MODE} in
  text) cat;; 
  adoc) sed 's/| |/| \\|/';;
  esac
}

function print_footer() {
  [[ ${MODE} == text ]] && return 0
  printf "|===\n"
}

function print_result() {
  local num=${1}; shift;
  local hex=${1}; shift;
  printf "${RESULT}" "${LOOKUP[${num}]:-}" "\\u${hex}" ${num} "\\u${hex}" | \
    asciidoc_table_escape
}

function find_disallowed_chars() {
  for num in {33..128}; do
    printf -v hex "%04x" ${num};
    printf -v func "${FUNCTION}" "\\u${hex}"{,,}
    # question mark must be escaped or it skips ?(){} function
    eval "${func//\?/\\?}" &>/dev/null || print_result $num ${hex}
  done
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
parse_options "${@}"
print_header
find_disallowed_chars
print_footer
