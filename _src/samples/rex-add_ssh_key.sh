#!/usr/bin/env bash 

function add_ssh_key() {
  set -o errexit
  set -o nounset
  set -o pipefail

  declare -r SSH_TYPE=${1}; shift;
  declare -r SSH_KEY=${1}; shift;
  declare -r SSH_COMMENT=${1}; shift;
  declare -r AUTH_KEYS=${HOME}/.ssh/authorized_keys
  
  function key_already_in_place() {
    grep -q ${SSH_KEY} ${AUTH_KEYS}
  }

  function add_key() {
    key_already_in_place && { 
      echo "Key already exists in ${AUTH_KEYS}";
      return 0;
    }
    printf "%s %s %s\n" \
      ${SSH_TYPE} \
      ${SSH_KEY} \
      ${SSH_COMMENT} \
      >> ${AUTH_KEYS}
    echo "Key successfully added to ${AUTH_KEYS}"
  }
  add_key
}

ssh localhost \
  "$(declare -f add_ssh_key);" \
  "add_ssh_key ssh-ed25519 AAAAC3N..7mG testkey"
