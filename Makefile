# Makefile -- PLTV-SPIN

run:
	grunt server

install:
	yarn || npm install
	grunt fetch

