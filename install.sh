#/usr/bin/env bash

$BARENAME=.dotfiles

$REPO="https://github.com/anygard/dotfiles.git"
$GITDIR="--git-dir=$HOME/$BARENAME"
$WIRKTREE="--work-tree=$HOME"

RCDIR=.dotfilesrc

function phase2 {
	git config -f .gitconfig status.showUntrackedFiles no

	git checkout $GITDIR $WORKTRE

	for target in ".bash_profile .bashrc" ; do
	    
	    cat "<<-EOP" >> $target

	    # hook for .dotfiles
	    if [ -f $RCDIR/entrypoint.sh ]; then
		source .dotfilerc
	    fi
	    EOP

	done

}

echo "Prerequisite check"

PREREQS="git"
abort=false
for pr in $PREREQS ; do
	if [ -x $(which $pr) ]; then
		echo "OK $pr"
	else
		abort=true
	fi
	if [ "$abort" == "true" ]; then
                curl 
		echo "One or more prerequisits were not met. Aborting."
		echo
		echo "Resolv the issues and try again"
		exit 1
	fi

	if [ -e $BARENAME ]; then
		echo "There already exists an entity called: ${BARENAME}. Aborting"
		echo
		echo "Resolv the issue and try again"
		exit 3
	fi
done

pushd $HOME

if [ "$#" -ne 0 ]; then

	# no parameters -> default online procedure

	git clone --bare $REPO $BARENAME
	
	phase2

elif [ -n "$1" -a -f "$1" ]; then

	# offline install
	tar xzf $1 

	phase2
else
	echo "No such file: $1"
	exit 2
fi

popd
