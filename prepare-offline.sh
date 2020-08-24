#!/usr/bin/env bash


$DOTFILES_INSTALLER=$HOME/dotfiles-offline-installer.sh
$REPO="https://github.com/anygard/dotfiles.git"
TAR_ROOT=dotfiles
TMPDIR=$(mktemp -d)
$GITDIR="--git-dir=$TMPDIR/$TAR_ROOT/$BARENAME"
$WORKTREE="--work-tree=$TMPDIR"

pushd $TMPDIR

mkdir $TAR_ROOT
pushd $TAR_ROOT
git clone --bare $REPO
git $GITDIR $WORKTREE checkout install.sh

eat << EOI > $DOTFILES_INSTALLER
match=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
payload_start=$((match + 1))
tail -n +$payload_start $0 | tar -xzf -
bash $TAR_ROOT/install.sh --offline
PAYLOAD:
EOI

popd
tar czf - $TAR_ROOT >> $DOTFILES_INSTALLER

popd

rm -rf $TMPDIR
