
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
