name=$2

if [ -d docker/machines/$name ]; then
  echo "Manager already exists, exiting"
  exit 0
fi

if [ -f machines/$name.zip ]; then
  echo "Importing existing $name.zip"
  scripts/import-machine.sh $name
  exit 0
fi

docker-machine create \
  --driver digitalocean \
  --digitalocean-image ubuntu-16-04-x64 \
  --digitalocean-access-token $1 \
  --digitalocean-region fra1 \
  $name

docker-machine ssh $name mkdir /var/lib/registry

scripts/export-machine.sh $name