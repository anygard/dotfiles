#/usr/bin/env bash
set -x
BARENAME=.dotfiles

REPO="https://github.com/anygard/dotfiles.git"
GITDIR="--git-dir=$HOME/$BARENAME"
WORKTREE="--work-tree=$HOME"

RCFILE=.dotfilesrc/main.sh

function phase2 {

        # this is a workspace wide setting, e.g only for this
        git --git-dir=$HOME/$BARENAME/ --work-tree=$HOME config status.showUntrackedFiles no

        git $GITDIR $WORKTREE checkout

        for target in .bash_profile .bashrc ; do

                #just in case
                cp $target ${target}.bak

                # I do know about HERE DOCS but something in my syntax was wrong, will fix later
                (echo
                echo # hook for .dotfiles
                echo "[ -f $RCFILE ] && source $RCFILE"
                echo) >> $target

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

echo "Installation"
pushd $HOME > /dev/null

case $1 in
        --online)
                [ -n "$2" ] && REPO=$2
                git clone --bare $REPO $BARENAME
                ;;
        --offline)
                if [ -n "$2" -a -f "$2"]; then
                        tar xzf $2
                else
                        echo "Required parameter missing or files does not exist"
                        exit 2
                fi
                ;;
        *)
                echo "$(basename $0) < --online [repo url] | --offline <tar fname> >"
                exit 2
                ;;
esac

phase2

echo Installation complete
echo
echo run this command
echo
echo "        alias .f='/usr/bin/git --git-dir=$HOME/$BARENAME/ --work-tree=$HOME'"
echo
echo and then run
echo
echo "        .f checkout main"
echo
echo and logout and in again

popd > /dev/null
set +x
