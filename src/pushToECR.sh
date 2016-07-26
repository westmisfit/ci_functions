
function pushToECRHelp()
{
  echo 'pushToECRHelp [options]

options:
--aws_access_key_id {aws_access_key_id}
--aws_secret_access_key {aws_secret_access_key}
--repository_name {repository_name}  docker repository name, e.g. misfit/test
--endpoint {endpoint}  registry endpoint, e.g. 315962882822.dkr.ecr.us-east-1.amazonaws.com
--tag_name {tag_name}  tag name of docker image
'
}

function pushToECR()
{
  local aws_access_key_id
  local aws_secret_access_key
  local repository_name
  local endpoint
  local tag_name

  while [[ $# > 0 ]]
  do
    key="$1"
    case $key in
      --aws_access_key_id) aws_access_key_id="$2"; shift;;
      --aws_secret_access_key) aws_secret_access_key="$2"; shift;;
      --repository_name) repository_name="$2"; shift;;
      --endpoint) endpoint="$2"; shift;;
      --tag_name) tag_name="$2"; shift;;
      *) pushToECRHelp; return 1;;
    esac
    shift
  done

  AWS_ACCESS_KEY_ID=$aws_access_key_id
  AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
  if aws ecr describe-repositories --repository-names=$repository_name > /dev/null; then
    eval $(aws ecr get-login)
    docker push $endpoint/$repository_name:$tag_name
  fi
}
