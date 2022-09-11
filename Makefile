# Makefile -- PLTV-SPIN

run:
	npx grunt server

install:
	yarn || npm install

push:
	heroku container:push web

deploy: push
	heroku container:release web
