# README

These are my dot files, Linux/UNIX CLI settings i prefer and want to bring with me. You are encouraged to use it for your self. It is recommended that you fork the repo and make any changes/improvements to there. It is then trivial to make a PR against my repo if you feel you have created something of general interest and utility.


# Features

* elaborate "prompt" with exensible notification framwork
* themed ls
* all os, hardware and other specific parts are only loaded if they apply
* number of utility script


# Installation

## Plan A (online)

The easiest way to use this repo is to go to your home directory on the server you want to install this on run this command.

	curl https://raw.githubusercontent.com/anygard/dotfiles/install/install.sh | bash --online

I too despice downloading and running unknown code like this, but if you consider using this you probably know how to examine it before executing. I mostly added this command so I will have an easy copy&paste for my own needs. 


## Plan B (offline) 

If you cannot clone this repo from github for whatever reason this is how you do

First you need to prepare on one server with access

1. create a directory 'foo', cd into it 
2. git clone --bare https://github.com/anygard/dotfiles.git .dotfiles
2. git checkout install.sh
4. cd .. ; tar czf foo.tar.gz foo

Bring the tar file to where you need to install 

1. tar xzf foo.tar.gz
1. cd foo ; install.sh --offline

After the installation is successful there is no further need for the foo directory.


# Offline maintenance

If you in your offline bubble have a git server it is recommended that you setup a remote repo there. You can use it for managing the changes and additions you make and it is also very helpfull to be able to do online installs from there to other machines in the bubble. If you want to 'export' the version in the bubble you can do a regular clone of the repo and make a tar file of it and bring it to a machine with online access and there unpack it and merge the changes to the upstram repo.
 

# Design

Most files are going to be your own dotfiles so there is not much i can say about that but there is a .dotfilesrc directory which is the where a framework of bash files to be sourced reside


# Source

This where i got the inspiration for this setup https://www.atlassian.com/git/tutorials/dotfiles it is also a good read if you want to know how you should use this repo. 
The canonical location to find this repo in is https://github.com/anygard/dotfiles

# Usage

I keep separate local branches for day to day work, changes i want to "publish" are cherrypicked into the main branch, some times through several branches aliong the way. 

Good luck and happy hacking
