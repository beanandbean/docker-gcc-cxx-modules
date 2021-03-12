if [[ -z "$*" ]]; then
  docker run -v `pwd`:/project -w /project -it gcc-master bash
else
  docker run -v `pwd`:/project -w /project gcc-master bash -c "$*"
fi
