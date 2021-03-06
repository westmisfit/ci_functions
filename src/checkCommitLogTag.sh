
function checkCommitLogTag
{
  local KEYWORD="${1}"
  if [[ "$KEYWORD" == "" ]]; then
    echo 'KEYWORD not set. Usage: checkCommitLogTag "{KEYWORD}"' 1>&2
    return 0
  fi
  if ! git log -1 | grep "\[$KEYWORD\]" 1>&2; then
    return 0
  fi
  echo 'true'
}
