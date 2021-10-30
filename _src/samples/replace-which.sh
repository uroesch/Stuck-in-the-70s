#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r TITLE="\nFind full path with '%s' a 1000 times\n"
declare -r STRING="UPPER-lower"

function which-loop() {
  printf "${TITLE}" 'which'
  for i in {0..1000}; do
    which cp &>/dev/null
  done
}

function builtin-loop() {
  printf "${TITLE}" 'command -v'
  for i in {0..1000}; do
    command -v cp &> /dev/null 
  done 
}

time which-loop
time builtin-loop
