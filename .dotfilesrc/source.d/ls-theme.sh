# this is lifted from https://github.com/seebi/dircolors-solarized

# if config var not set bail out
if [ -z "$LS_COLORTHEME" ]; then
	return
fi
SUFFIX=.ls-theme
PREFIX=$DOTFILESRC/source.d
THEME=$PREFIX/$LS_COLORTHEME$SUFFIX
if [ -f "$THEME" ]; then
	eval $(dircolors $THEME)
else
	echo "ls-colortheme not found $LS_COLORTHEME ($THEME)"
        echo "These are available"
        pushd $PREFIX > /dev/null
	ls *$SUFFIX
        popd > /dev/null
fi
