CKAN_VERSION ?= 2.8
COMPOSE_FILE ?= docker-compose.yml
COMPOSE_2_8_FILE ?= docker-compose.2.8.yml

build: ## Build the docker containers
	CKAN_VERSION=$(CKAN_VERSION) docker-compose -f $(COMPOSE_FILE) build

lint: ## Lint the code
	@# our linting only runs with python3
	@# TODO use CKAN_VERSION make variable once 2.8 is deprecated
	CKAN_VERSION=2.9 docker-compose -f docker-compose.yml run --rm app bash -c "pip install flake8 && flake8 /srv/app/src/ckanext-envvars --count --show-source --statistics --exclude ckan,nose --max-line-length=127 --ignore=E402"

clean: ## Clean workspace and containers
	find . -name *.pyc -delete
	CKAN_VERSION=$(CKAN_VERSION) docker-compose -f $(COMPOSE_FILE) down -v --remove-orphan

test: ## Run tests in a new container
	CKAN_VERSION=$(CKAN_VERSION) docker-compose -f $(COMPOSE_FILE) run --rm app /srv/app/src/ckanext-envvars/test.sh

up: ## Start the containers
	CKAN_VERSION=$(CKAN_VERSION) docker-compose -f $(COMPOSE_FILE) up


.DEFAULT_GOAL := help
.PHONY: build clean help lint test up

# Output documentation for top-level targets
# Thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
