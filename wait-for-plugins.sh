#!/bin/bash -xe

echo "Waiting for plugins to be ready..."
while ! [ -f "/usr/src/redmine/files/plugins-are-ready" ]; do
	sleep 1
done

sed -i 's,http://deb.debian.org/debian,http://cloudfront.debian.net/debian,' /etc/apt/sources.list
while ! apt-get update; do sleep 5; done
apt-get install -qy make gcc

for dir in /usr/src/redmine/plugins/*; do
        [ -d "$dir" ] || continue
        (cd "$dir"; bundle install)
done

chown redmine:redmine /home/redmine -R

(cd /usr/src/redmine; bundle install)

/docker-entrypoint.sh "$@" &

sleep 20 # wait for entrypoint to setup the database
# run plugin migrations
gosu redmine rake redmine:plugins RAILS_ENV=production

wait # wait for rails to finish

