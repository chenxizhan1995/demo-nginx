recreate: down up
up:
	touch error.log
	docker-compose up -d
down:
	- docker-compose down
	rm -rf error.log
logs:
	docker-compose logs

ps:
	docker-compose ps
hello:
	curl -w "\n" localhost/hello
show-config:
	docker exec -it demo1-nginx-1 nginx -T

SHELL:=/usr/bin/bash
