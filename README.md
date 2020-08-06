# README

This is a repo for my dotfiles inspired by https://www.atlassian.com/git/tutorials/dotfiles if you wonder why you do all the below steps, read the article

1. echo ".gitcfg" >> .gitignore
2. git clone --bare <clone URL> $HOME/.gitcfg
3. alias gitcfg='/usr/bin/git --git-dir=$HOME/.gitcfg/ --work-tree=$HOME'

Instead of doing  a gitcfg checkout as the article suggest do

`gitcfg checkout trunk`

We ar going to use the branch trunk as the root branch, this README file will be the only file in the master branch, this way you get a little howto if you just clone the repo

The `checkout` command can fail due to git not wnating to overwrite existing files if this happens you can backup your existing files like this

	mkdir -p .config-backup && \
	config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
	xargs -I{} mv {} .config-backup/{}

Good luck and happy hackking
