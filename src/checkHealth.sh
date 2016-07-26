
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
