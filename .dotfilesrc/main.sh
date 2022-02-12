#
#
#	This file needs to be sourced to work
#
#

export LC_ALL="en_US.utf8"
export LANG="en_US.utf8"

export PATH=$PATH:$HOME/bin

# source .sh files in source.d
pushd ~/.dotfilesrc/source.d > /dev/null

for f in $(ls *.sh) ; do
	source $f
done

popd > /dev/null
