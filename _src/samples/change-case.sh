#!/usr/bin/env bash 

declare -r TITLE="\nConvert string to lower case with '%s' a 1000 times\n"
declare -r STRING="UPPER-lower"

function tr-loop() {
  printf "${TITLE}" 'tr'
  for i in {0..1000}; do
    tr "[A-Z]" "[a-z]" <<< ${STRING} &>/dev/null
  done
}

function builtin-loop() {
  printf "${TITLE}" '${var,,}'
  for i in {0..1000}; do
    echo ${STRING,,} &> /dev/null 
  done 
}

time tr-loop
time builtin-loop
