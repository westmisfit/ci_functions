
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
