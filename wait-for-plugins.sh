#!/bin/bash -x

echo "Waiting for plugins to be ready..."
while ! [ -f "/usr/src/redmine/files/plugins-are-ready" ]; do
	sleep 1
done

exec /docker-entrypoint.sh "$@"
