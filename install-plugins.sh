#!/bin/bash -ex

function install_from_github() {
	local repo="$1" bundler="$2"
	read username reponame <<<"${repo/\// }"
	[ -d "$reponame" ] && return 0
	(
		curl -L https://api.github.com/repos/"$repo"/tarball | tar -zx --xform="s,$username-$reponame-[[:alnum:]]*,$reponame,"
		cd "$reponame"
		[ -n "$bundler" ] && rm -f Gemfile.lock && bundle
	)
}

cd /redmine/plugins

install_from_github twinslash/redmine_omniauth_google yes

install_from_github dergachev/redmine_git_remote
mkdir redmine_git_remote/repos
chown redmine:redmine redmine_git_remote/repos

install_from_github woblavobla/redmine_changeauthor

touch /redmine/files/plugins-are-ready
