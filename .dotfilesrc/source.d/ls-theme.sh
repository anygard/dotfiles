# this is lifted from https://github.com/seebi/dircolors-solarized
tmp=$(mktemp)
cat <<EOT >> $tmp

eval $(dircolors $tmp)
rm $tmp

if config var not set nail out
if [ -z "$LS_COLORTHEME" ]; then
	return
fi
SUFFIX=.ls-theme
PREFIX=$DOTFIILES/source.d
THEME=$PREFIX/$LS_COLORTHEME$SUFFIX
if [ -f "$THEME" ]; 
	eval $(dircolors $THEME)
else
	echo ls-colortheme not found ($THEME)
        echo these are available
        pushd $PREFIX > /dev/null
	ls *$SUFFIX
        popd > /dev/null
fi

