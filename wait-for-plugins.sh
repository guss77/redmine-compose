#!/bin/bash -x

echo "Waiting for plugins to be ready..."
while ! [ -f "/usr/src/redmine/files/plugins-are-ready" ]; do
	sleep 1
done

cp /usr/src/redmine/config/configuration.yml{.example,}

exec /docker-entrypoint.sh "$@"
