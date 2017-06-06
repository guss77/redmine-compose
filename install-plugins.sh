#!/bin/bash -ex

cd /redmine/plugins

[ -d "redmine_omniauth_google" ] || (
	curl -L https://github.com/twinslash/redmine_omniauth_google/archive/master.tar.gz | tar -zx --xform=s,redmine_omniauth_google-master,redmine_omniauth_google,
	cd redmine_omniauth_google
	rm Gemfile.lock
	bundle
)

touch /redmine/files/plugins-are-ready
