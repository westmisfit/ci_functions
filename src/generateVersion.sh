
function generateVersionHelp
{
  echo "Usage: generateVersion -f config/version.yml -b $TRAVIS_BRANCH -n $TRAVIS_BUILD_NUMBER [--debug]" 1>&2
}

function generateVersion
{
  # generateVersion -f config/version.yml -b $TRAVIS_BRANCH -n $TRAVIS_BUILD_NUMBER
  local filepath=""
  local branch=""
  local build_number=""
  local debug=""

  while [[ $# > 0 ]]
  do
    key="$1"
    case $key in
      -f|--file) filepath="$2"; shift;;
      -b|--branch) branch="$2"; shift;;
      -n|--build-number) build_number="$2"; shift;;
      --debug) debug="true";;
      *) generateVersionHelp; return 1;;
    esac
    shift
  done
  if [[ -z "$filepath" ]]; then generateVersionHelp; echo "required -f or --file." 1>&2; return 1; fi
  if [[ -z "$branch" ]]; then generateVersionHelp; echo "required -b or --branch." 1>&2; return 1; fi
  if [[ -z "$build_number" ]]; then generateVersionHelp; echo "required -n or --build_number." 1>&2; return 1; fi

  local filename=$(basename $filepath)
  local tempfile="/tmp/$filename"
  local branch_safe=${branch//\//\\/}
  local   commit_id=$(git log -n 1 | egrep -m 1 '^commit '  | sed -e 's/^commit[ ]*//' )
  local commit_user=$(git log -n 1 | egrep -m 1 '^Author: ' | sed -e 's/^Author:[ ]*//' )
  local commit_date=$(git log -n 1 --date=iso | egrep -m 1 '^Date: '   | sed -e 's/^Date:[ ]*//' )
  local  build_date=$(date +%FT%T%z)

  cat $filepath \
    | sed -e      "s/^build:.*$/build:      $build_number/" \
    | sed -e     "s/^branch:.*$/branch:     $branch_safe/" \
    | sed -e  "s/^committer:.*$/committer:  $commit_user/" \
    | sed -e "s/^build_date:.*$/build_date: $build_date/" \
    > $tempfile
  cat $tempfile
  if [[ "$debug" != "true" ]]; then
    mv $tempfile $filepath
  fi
}
