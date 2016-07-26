
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
