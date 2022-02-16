#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r TITLE="\nSplit string to variables with a multi-char delimiter\n"
declare -r LIST="root:T0pS3cr3t!:0:0:root-user;+1234;roo@mail.com:/root:/bin/bash"

function split-info() {
  printf "${TITLE}" 
  printf "String: ${LIST}\n" 
  IFS="[:;]" read login pw uid gid desc phone mail home shell <<< "${LIST}"
  typeset -p login pw uid gid desc phone mail home shell 
}

split-info
