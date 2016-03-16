##
# functions library, don't run this file directly
# auth: west@misfit.com
# created: 2015-11-02
# modified: 2016-03-04
##

function dockerLoginHelp
{
  echo "Usage: dockerLogin --email {email} --auth {auth}}" 1>&2
}

function dockerLogin
{
  local email=""
  local auth=""

  while [[ $# > 0 ]]
  do
    key="$1"
    case $key in
      --auth) auth="$2"; shift;;
      --email) email="$2"; shift;;
      *) dockerLoginHelp; return 1;;
    esac
    shift
  done

  # generate old version docker config file
  echo '{"https://index.docker.io/v1/":{"auth":"'$auth'","email":"'$email'"}}' > ~/.dockercfg

  # generate new version docker config file
  mkdir ~/.docker/
  echo '{"auths":{"https://index.docker.io/v1/":{"auth":"'$auth'","email":"'$email'"}}}' > ~/.docker/config.json
}

function loadDockerImages
{
  local root="${1-.}"
  local f
  for f in $( find "$root" -name *.tar )
  do
    if [[ -f $f ]]; then
      echo "load docker image from $f..."
      docker load --input "$f"
    fi
  done
}

function checkCommitUser
{
  local AUTHOR="${1}"
  if [[ "$AUTHOR" == "" ]]; then
    echo 'AUTHOR not set. Usage: checkCommitUser "{AUTHOR}"' 1>&2
    return 0
  fi
  if ! git log -1 | grep "Author: $AUTHOR" 1>&2; then
    return 0
  fi
  echo 'true'
}

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

# check health url
# usage: checkHealth $url
function checkHealth
{
  local url="$1"
  local response='000'
  local err=0
  echo "check health on $url..."
  for i in {1..50}
  do
    sleep 3
    echo "try $i..."
    response=$(curl --location --write-out %{http_code} --silent --output /tmp/curl.output "$url")
    err=$?
    # echo $err $response
    if [[ $response -ge 400 ]]; then
      echo state $response
      cat /tmp/curl.output
      echo ""
      return 1
    elif [[ $err -eq 0 ]]; then
      echo ok
      return 0
    fi
  done
  return 1
}

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

# wait for mongod started
# usage: waitForMongo $container_name
function waitForMongod
{
  local container_name="${1}"
  echo "wait for $container_name container's mongod started..."
  for i in {1..20}
  do
    sleep 3
    echo "try $i..."
    docker exec -it $container_name mongo --eval "printjson(db.serverStatus())" > /dev/null
    if [[ $? -eq 0 ]]; then
      echo ok
      break
    else
      false
    fi
  done
}
