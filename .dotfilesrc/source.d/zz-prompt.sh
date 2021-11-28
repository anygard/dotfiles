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

	tmp=$(mktemp)
	git status --porcelain --branch > $tmp 2> /dev/null || return 0
	header=$(head -1 $tmp)
	tail=$(mktemp)
	tail -n +2 $tmp > $tail
	branch=$(echo $header | cut -d' ' -f2 | cut -d'.' -f1)
	behind=$(echo $header | grep -o 'behind')
	ahead=$(echo $header | grep -o 'ahead')
	cleanws=$(cat $tail | wc -l)
	rm $tmp
	rm $tail

	WM='-'
	AM='-'
	BM='-'
	[ -n "$ahead" ] && AM='A'
	[ -n "$behind" ] && BM='B'
	[ "$cleanws" != 0 ] && WM='*'

	echo -n "${label}:${branch}[${WM}${AM}${BM}] "

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

	source $DOTFILESRC/source.d/00-config.sh

        TF=$(mktemp)
        git_info git >> $TF
        numjobs jobs >> $TF
        nonzero_return ec $EC >> $TF
        tmux
        #set -x
        if [ -s "$TF" ]; then
                [ -n "$PROMPT_EXTRANL" -a "$PROMPT_EXTRANL" = Yes ] && echo
                if [ -n "$PROMPT_COLOR" -a "$PROMPT_COLOR" = Yes ]; then
			tput setaf 7
			reset=$RESET
		else
			reset=
		fi
                cat $TF
                rm $TF
                echo
        fi
	if [ -n "$ORIGINAL_PREPROMT_COMMAND" ]; then
		$ORIGINAL_PREPROMT_COMMAND
	fi
        #set +x
}

# place code here that should only run on setup

export ORIGINAL_PREPROMPT_COMMAND=$PREPROMPT_COMMAND
PROMPT_COMMAND=render_preprompt
#PS1="\e]2;\u2\h\a\A \u@\h \w \\$ "
PS1="\A \u@\h \w \\$ $reset"

