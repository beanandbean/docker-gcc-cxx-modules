if [[ -z "$*" ]]; then
  docker run -v `pwd`:/project -w /project -it gcc-modules bash
else
  docker run -v `pwd`:/project -w /project gcc-modules bash -c "$*"
fi
