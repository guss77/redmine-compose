#!/bin/bash -ex

cd /redmine/plugins

[ -d "redmine_omniauth_google" ] || (
	curl -L https://github.com/twinslash/redmine_omniauth_google/archive/master.tar.gz | tar -zx --xform=s,redmine_omniauth_google-master,redmine_omniauth_google,
	cd redmine_omniauth_google
	rm Gemfile.lock
	bundle
)

[ -d "redmine_git_remote" ] || (
	git clone https://github.com/dergachev/redmine_git_remote
	mkdir redmine_git_remote/repos
	chown redmine:redmine redmine_git_remote/repos
)

touch /redmine/files/plugins-are-ready
