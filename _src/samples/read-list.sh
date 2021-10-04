#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r TITLE="\nSplit string to variables with '%s' a 100 times\n"
declare -r LIST="root:T0pS3cr3t!:0:0:root:/root:/bin/bash"

function awk-loop() {
  printf "${TITLE}" 'awk -F : ...'
  for i in {0..100}; do
    login=$(echo ${LIST} | awk -F : '{ print $1 }')
    pw=$(echo ${LIST} | awk -F : '{ print $2 }')
    uid=$(echo ${LIST} | awk -F : '{ print $3 }')
    gid=$(echo ${LIST} | awk -F : '{ print $4 }')
    gecos=$(echo ${LIST} | awk -F : '{ print $5 }')
    home=$(echo ${LIST} | awk -F : '{ print $6 }')
    shell=$(echo ${LIST} | awk -F : '{ print $7 }')
  done
}

function read-loop() {
  printf "${TITLE}" 'IFS=: read ...' 
  for i in {0..100}; do
    IFS=: read login pw uid gid gecos home shell <<< "${LIST}"
  done
}

time awk-loop
time read-loop
