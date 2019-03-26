#!/bin/bash -x

echo "Waiting for plugins to be ready..."
while ! [ -f "/usr/src/redmine/files/plugins-are-ready" ]; do
	sleep 1
done

apt-get update && apt-get install -qy make gcc

for dir in /usr/src/redmine/plugins/*; do
        [ -d "$dir" ] || continue
        (cd "$dir"; bundle)
done

(cd /home/redmine; bundle install)

/docker-entrypoint.sh "$@" &

sleep 20 # wait for entrypoint to setup the database
# run plugin migrations
gosu redmine rake redmine:plugins RAILS_ENV=production

wait # wait for rails to finish

