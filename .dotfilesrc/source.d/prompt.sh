#
# This is an simple elaborate propmt easily extendable. It does not depend
# on advanced terminals with fancy prompts, it will work everywhere.
#
# Technically the prompt is pretty much a regular prompt the extra stuff
# is rendered by the PREPROMT_COMMAND on a line by itself.
#
# TODO: if needed the component functions can be placed in separate files and
# recognized by a common name prefix. And an array of unctin names prepared
# at setup for the render_preprompt to digest on each redraw
# 



function numjobs() {
        label=$1
        NJ=$(jobs | wc -l)
        [ $NJ -gt 0 ] && echo -n "$label:$NJ "
}

function nonzero_return() {
        label=$1
        RETVAL=$2
        [ $RETVAL -ne 0 ] && echo -n "$label:$RETVAL "
}

function git_info() {
        label=$1

        local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)"
	[ -n "$branch" ] || return  # git branch not found

        # how many commits local branch is ahead/behind of remote?
        local gstat=$(git status --porcelain --branch)
        local stat="$(echo $gstat | grep '^##' | grep -o '\[.\+\]$')"
        local aheadN="$(echo $stat | grep -o 'ahead \d\+' | grep -o '\d\+')"
        local behindN="$(echo $stat | grep -o 'behind \d\+' | grep -o '\d\+')"
        local cleanws="$(echo $gstat | grep -v '^##')"

        WM='-'
	AM='-'
        BM='-'
	[ -n "$aheadN" ] && AM='A'
        [ -n "$behindN" ] && BM='B'
	[ -z "$cleanws" ] && WM='*'

        WS=$(if git status 2> /dev/null | grep -q "nothing to commit" ; then echo "-" ; else echo "*" ; fi )
        echo -n "$label:${branch}[${WS}${AM}${BM}] "
}

function tmux() {

        # tmux winow name
        #printf "\ek %s@%s:%s \e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"
        printf "\ek %s@%s \e\\" "${USER}" "${HOSTNAME%%.*}"

        # tmux pane title
        printf "\e]2; %s@%s \e\\" "${USER}" "${HOSTNAME%%.*}"
}


function render_preprompt() {

        #this must be first
        EC=$?

        TF=$(mktemp)
        git_info git >> $TF
        numjobs jobs >> $TF
        nonzero_return ec $EC >> $TF
        tmux
        if [ -s "$TF" ]; then
                echo
                cat $TF
                rm $TF
                echo
        fi
	if [ -n "$ORIGINAL_PREPROMT_COMMAND" ]; then
		$ORIGINAL_PREPROMT_COMMAND
	fi
}

# place code here that should only run on setup

export ORIGINAL_PREPROMPT_COMMAND=$PREPROMPT_COMMAND
PROMPT_COMMAND=render_preprompt
#PS1="\e]2;\u2\h\a\A \u@\h \w \\$ "
PS1="\A \u@\h \w \\$ "

