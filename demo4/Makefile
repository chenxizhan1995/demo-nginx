SHELL:=/usr/bin/bash

recreate: down up
show-config:
	docker exec -it demo1-nginx-1 nginx -T
up:
	docker-compose up -d
down:
	- docker-compose down
logs:
	docker-compose logs
ps:
	docker-compose ps
################################

get post head:
	curl -w "\n" localhost/$@
