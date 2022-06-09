

upload.cdh3:
	rsync --exclude=.git --delete -av . chen@cdh3:demo-nginx
