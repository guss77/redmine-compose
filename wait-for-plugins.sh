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


exec /docker-entrypoint.sh /finish-setup "$@"
