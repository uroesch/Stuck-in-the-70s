#i!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

declare -A BASH_VERSION=(
  [3.0]=2004-08-03
  [3.1]=2005-12-08
  [3.2]=2006-10-11
  [4.0]=2009-02-20
  [4.1]=2009-12-31 
  [4.2]=2011-02-13
  [4.3]=2014-02-26 
  [4.4]=2016-09-15 
  [5.0]=2019-01-07 
  [5.1]=2020-12-07 
)

declare -a LOADABLE_BUILTINS=(
  accept
  basename
  cut
  dirname
  finfo
  head
  id
  ln
  logname
  mkdir
  mkfifo
  mktemp
#  mypid
  pathchk
  print
  printenv
  push
  realpath
  rm
  rmdir
  seq
  setpgid
  sleep
  strftime
  sync
  tee
#  truefalse
  tty
  uname
  unlink
  whoami
)

declare -a BUILTINS=(
  . 
  alias
  bg
  bind
  break
  builtin
  cd
  command
  compgen
  complete
  compopt
  continue
  declare
  dirs
  disown
  echo
  enable
  eval
  exec
  exit
  export
  fc
  fg
  getopts
  hash
  help
  history
  jobs
  kill
  let
  local
  logout
  mapfile
  popd
  printf
  pushd
  pwd
  read
  readarray
  readonly
  return
  set
  shift
  shopt
  source
  suspend
  test
  times
  trap
  type
  typeset
  ulimit
  umask
  unalias
  unset
  wait
)

#declare -a KEYS
declare -A TEST=(
  ['`declare -a` (Array)']='declare -a foo=( foo )'
  ['`declare -A` (Hash)']='declare -A foo=( [1]=foo )'
  ['`declare -f` (Function)']='foo() { :; }; declare -f foo'
##  ['`declare -F` (????)']='declare -r foo=foo'
  ['`declare -g` (Global)']='declare -g foo=foo'
  ['`declare -i` (Integer)']='declare -i foo=1'
  ['`declare -l` (Lowercase)']='declare -l foo=lower'
##  ['`declare -n` (???)']='declare -n foo'
  ['`declare -r` (Readonly)']='declare -r foo'
##  ['declare -t (trace)']='declare -r foo'
  ['`declare -u` (Uppercase)']='declare -u foo=upper'
  ['`declare -x` (Export)']='declare -x foo=export'
  ['`declare -I` (Export)']='declare -I foo=export'

  ['Operator `+=` (Append)']='foo=foo; foo+=bar'
  ['Operator `=~` (Regex)']='[[ foo =~ foo ]]'
  ['Redirect `&>`']='echo foo &>/dev/null'
  ['Redirect `|&`']='echo foo 1>&2 |& cat'

  ['Parameter expansion `${foo,}` (Lowercase)']='foo=bar; echo ${foo,}'
  ['Parameter expansion `${foo^}` (Uppercase)']='foo=bar; echo ${foo^}'
  ['Parameter expansion `${!f*}` (Partial)']='foo=bar; echo ${!f*}'
  ['Parameter expansion `${f/p/}` (Partial)']='foo=bar; echo ${foo/a/}'

  ['printf Variable assignment `printf -v`']='printf -v foo "foo"' 
  ['printf timestamp `printf %(%F)T`']='printf "%(%F)T" -1' 
  ['printf shell escape `printf %q`']='printf "%q" "cat foo | grep foo"' 

  ['Empty array is *not* an unset variable']='set -o nounset; declare -a ary=(); echo ${ary[@]}' 
  ['`read -a var` (Array)']='IFS=: read -a arr <<< "foo:bar:batz"'

)

# aAfFgilnrtux

function hash::sort_keys() {
  local array_name=${1}; shift;
  local -a keys=( "${@}" )
  readarray -d $'\n' -t ${array_name} <<< $(printf "%s\n" "${keys[@]}" | sort)
}

function test::run_docker() {
  local version=${1}; shift;
  local command=${1}; shift;
  local -i exit_code
  set +o errexit
  docker run -ti --rm bash:${version} bash -c "${command}" &>/dev/null
  echo $?
  set -o errexit
}

function adoc::header() {
  echo "= Bash Compatibility Matrix"
  echo ":icons: font"
  echo
}

function adoc::table_header() {
  hash::sort_keys versions "${!BASH_VERSION[@]}"
  printf '[cols="80%%,%d*", options="header"]\n' $(( ${#BASH_VERSION[@]} ))
  echo '|==='
  echo '| Feature / Version'
  for key in "${versions[@]//$/}"; do 
    printf "^a|\n%s\n[small]#^%s^#\n" "${key}" "${BASH_VERSION[${key}]}"
  done
  echo
}

function adoc::table_footer() {
  echo '|==='
}

function check_command() { 
  local label="${1}"; shift
  local command="${1}"; shift
  echo "h| ${label//|/\\|}"
  for version in "${versions[@]}"; do
    result=$(test::run_docker ${version} "${command}")
    case ${result} in
    0) echo "^| icon:check-square[]";;
    *) echo "|";;
    esac
  done
  echo 
}

hash::sort_keys test_names "${!TEST[@]}"
hash::sort_keys version "${!BASH_VERSION[@]}"
adoc::header
adoc::table_header

# list others
for key in "${test_names[@]}"; do
  check_command "${key}" "${TEST[${key}]}"
done

# list builtins
for builtin in "${BUILTINS[@]}"; do
  printf -v label 'Builtin `%s`' "${builtin}"
  printf -v command 'type %s | grep builtin' "${builtin}"
  check_command "${label}" "${command}"
done

# list loadable builtins
for builtin in "${LOADABLE_BUILTINS[@]}"; do
  printf -v label 'Loadable Builtin `%s`' "${builtin}"
  printf -v command 'enable -f /usr/local/lib/bash/%s %s' "${builtin}" "${builtin}"
  check_command "${label}" "${command}"
done

adoc::table_footer
