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

test1.demo1:
	$(curl) "http://localhost/test1/demo1/hello?name=jack"

test1.demo2:
	$(curl) "http://localhost/test1/demo2/hello?name=jack"
test1.demo3:
	$(curl) "http://localhost/test1/demo3/hello?name=jack"
test1.demo4:
	$(curl) "http://localhost/test1/demo4/hello?name=jack"

test1.demo1.p :
	$(curl) "http://localhost/test1/demo1.11/hello?name=jack"
	$(curl) "http://localhost/test1/demo1.10/hello?name=jack"
	$(curl) "http://localhost/test1/demo1.01/hello?name=jack"
	$(curl) "http://localhost/test1/demo1.00/hello?name=jack"

test2:
	$(curl) "http://localhost/test2/demo1/hello"
	$(curl) "http://localhost/test2/demo2/hello"
