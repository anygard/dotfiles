#
#
#	This file needs to be sourced to work
#
#

if [ -n "$DOTFILESRC_RUNONLYONCE_GUARD" ]; then
	return
fi
export DOTFILESRC_RUNONLYONCE_GUARD="There can be only one"

# temporary marker to visialize this is run
#echo
#echo "*** dotfilesrc ***"
#echo

# source .sh files in source.d
pushd ~/.dotfilesrc/source.d > /dev/null

for f in $(ls *.sh) ; do
	source $f
done

popd > /dev/null
