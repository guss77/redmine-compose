#!/bin/bash

# run plugin migrations
gosu redmine rake redmine:plugins RAILS_ENV=production

# run rails
exec "$@"
