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
curl:=curl -w "\n"
hello http_browser http_core:
	$(curl) http://localhost/$@

http_browser2:
	$(curl) http://localhost/http_browser \
		-H "User-Agent:	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0"

http_core2:
	$(curl) http://localhost/$@ -d foo=name -d name=Jack

http_core3:
	$(curl) http://localhost/$@ -G -d foo=name -d name=Jack
