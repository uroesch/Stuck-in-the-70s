#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r TITLE="\nInteger calculation adding and substracting a 1000 times\n"

function bc-loop() {
  printf "${TITLE}" 'sed'
  for i in {0..1000}; do
    bc <<< "1+${i}"    &>/dev/null
    bc <<< "1001-${i}" &>/dev/null 
  done
}

function builtin-loop() {
  printf "${TITLE}" '${var//o/u}'
  local -i integer=1
  for i in {0..1000}; do
    integer=1+${i}
    integer=1001-${i}
  done 
}

time bc-loop
time builtin-loop
