# Makefile -- PLTV-SPIN

run:
	grunt server

install:
	npm install
	php -r "readfile('https://getcomposer.org/installer');" | php
	grunt fetch

