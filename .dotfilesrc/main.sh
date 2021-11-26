#
#
#	This file needs to be sourced to work
#
#

if [ -n "$DOTFILESRC_RUNONLYONCE_GUARD" ]; then
	return
fi
export DOTFILESRC_RUNONLYONCE_GUARD="There can be only one"


echo
echo "*** dotfilesrc ***"
echo

alias .f='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
