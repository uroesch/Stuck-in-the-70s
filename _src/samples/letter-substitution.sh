#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r TITLE="\nSubstitute 'o' for 'u' in string with '%s' a 1000 times\n"
declare -r STRING="lagoon racoon spoon loon"

function sed-loop() {
  printf "${TITLE}" 'sed'
  for i in {0..1000}; do
    sed 's/o/u/g' <<< ${STRING} &>/dev/null
  done
}

function builtin-loop() {
  printf "${TITLE}" '${var//o/u}'
  for i in {0..1000}; do
    echo ${STRING//o/u} &> /dev/null 
  done 
}

time sed-loop
time builtin-loop
