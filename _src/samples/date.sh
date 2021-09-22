#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r TITLE="\nExecuting '%s' a 1000 times\n"
declare -r FORMAT="%F %T %Z"

function date-loop() {
  printf "${TITLE}" 'date'
  for i in {0..1000}; do
    date +"${FORMAT}" &>/dev/null
  done
}

function printf-loop() {
  printf "${TITLE}" 'printf %()T'
  for i in {0..1000}; do
    printf "%(${FORMAT})T\n" -1 &>/dev/null
  done 
}

time date-loop
time printf-loop
