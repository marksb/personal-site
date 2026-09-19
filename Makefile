.PHONY: dev build check

dev:
	hugo server -D

build:
	hugo --minify

check: build
	lychee --offline --no-progress --root-dir "$(CURDIR)/public" './public/**/*.html'
