#!/bin/bash
# Setup and run extension tests. This script should be run in a _clean_ CKAN
# environment. e.g.:
#
#     $ docker-compose run --rm app ./test.sh
#

set -o errexit
set -o pipefail

TEST_CONFIG=/srv/app/src/ckanext-envvars/test.ini
pip install -e /srv/app/src/ckanext-envvars
pip install pytest pycodestyle pytest-ckan pytest-cov

# Wrapper for paster/ckan.
# CKAN 2.9 replaces paster with ckan CLI. This wrapper abstracts which comand
# is called.
#
# In order to keep the parsing simple, the first argument MUST be
# --plugin=plugin-name. The config option -c is assumed to be
# test.ini because the argument ordering matters to paster and
# ckan, and again, we want to keep the parsing simple.
function ckan_wrapper () {
  if command -v ckan > /dev/null; then
    shift  # drop the --plugin= argument
    ckan -c $TEST_CONFIG "$@"
  else
    paster "$@" -c $TEST_CONFIG
  fi
}


# Database is listening, but still unavailable. Just keep trying...
while ! ckan_wrapper --plugin=ckan db init; do 
  echo Retrying in 5 seconds...
  sleep 5
done

# start_ckan_development.sh &
pytest --ckan-ini=$TEST_CONFIG --cov=ckanext.envvars --disable-warnings /srv/app/src/ckanext-envvars/ckanext/envvars/tests_2_8_and_above.py