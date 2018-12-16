name := jinx
pwd := $(shell pwd)
do_token := $(shell cat ./secrets/do-token)
yml := docker-compose.yml

.EXPORT_ALL_VARIABLES:
  MACHINE_STORAGE_PATH=$(pwd)/docker

all: create-manager init-swarm reload

create-manager:
	scripts/create-manager.sh $(do_token) $(name)

init-swarm:
	docker-machine ip $(name) | xargs -I {} scripts/docker swarm init \
		--advertise-addr={}

reload: clean up

clean:
	scripts/docker stack rm $(name)

up:
	 scripts/docker stack deploy --with-registry-auth -c $(yml) $(name)

nuke:
	docker-machine rm $(name)
	rm -rf docker/machines
	rm -rf machines/*