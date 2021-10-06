#!/usr/bin/env bash 

set -o errexit
set -o nounset
set -o pipefail

declare -r FORMAT="<tr><td>%s</td><td>%s</td><td>%s</td><tr>\n"

printf "<table>\n"
printf "${FORMAT}" \
  "Frist Name"  "Last Name"    "Department" \
  "Joe"         "Sys"          "Systems" \
  "Mary"        "de Vops"      "DevOps" \
  "Maria"       "Uffico"       "Backoffice" \
  "Hans"        "Kette"        "Supplychain" \
  "Jaques"      "Avant"        "Frontoffice"
printf "</table>\n"
