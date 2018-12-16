name := jinx
pwd := $(shell pwd)
do_token := $(shell cat ./secrets/do-token)
yml := docker-compose.yml
manager_ip = $(shell docker-machine ip $(name))
registry_username = $(shell cut -d: -f1 secrets/registry-htpasswd)
registry_password = $(shell cat ./secrets/registry-admin)

SERVICES = $(wildcard services/*.yml)

.SUFFIXES: .yml

.EXPORT_ALL_VARIABLES:
  MACHINE_STORAGE_PATH=$(pwd)/docker

all: create-manager init

create-manager:
	scripts/create-manager.sh $(do_token) $(name)

init: init-swarm up first-time-setup
init-swarm:
	scripts/docker swarm init \
		--advertise-addr=$(manager_ip)
first-time-setup:
	echo $(registry_password) scripts/docker login registry.jinx.pro --username=$(registry_username) --password-stdin

reload: clean up

clean:
	scripts/docker stack rm $(name)

up:
	 scripts/docker stack deploy --with-registry-auth -c $(yml) $(name)

nuke:
	docker-machine rm $(name)
	rm -rf docker/machines
	rm -rf machines/*