

upload.cdh3:
	rsync --exclude=.git --delete -av . chen@cdh3:demo-nginx

nginx-version:
	docker run --rm -it nginx:1.21 nginx -V
