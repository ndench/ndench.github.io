.PHONY: serve
serve: install
	bundle exec jekyll serve

.PHONY: install
install:
	bundle install
