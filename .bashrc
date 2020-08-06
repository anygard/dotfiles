export NYGAS_BASHRC='NYGAS same as the OLDGAS'

export LC_ALL="en_US.utf8" 
export LANG="en_US.utf8" 

export PATH=$PATH:$HOME/bin

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/homenfs/nygas/build/libevent/lib
export PATH=$PATH:/homenfs/nygas/.local/bin

alias tmux=/homenfs/nygas/build/tmux/bin/tmux
alias _t=/homenfs/nygas/build/tmux/bin/tmux
alias _ta="/homenfs/nygas/build/tmux/bin/tmux attach"

# ls color theme
eval $(dircolors /homenfs/nygas/.config/themes/ls/ansi-solarized.dark)

#<homebrew>
eval $(/homenfs/nygas/.linuxbrew/bin/brew shellenv)
#</homebrew>

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
        BRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
        if [ ! "${BRANCH}" == "" ]; then
                STAT=$(if git status 2> /dev/null | grep -q "nothing to commit" ; then echo "" ; else echo "*" ; fi )
                echo -n "$label:[${BRANCH}${STAT}] "
        fi
}

function render_preprompt() {

	#this must be first
	EC=$?

	TF=$(mktemp)
        nonzero_return ec $EC >> $TF
        numjobs jobs >> $TF
        git_info git >> $TF
	if [ -s "$TF" ]; then
		cat $TF
		rm $TF
		echo
	fi

	# tmux winow name
        #printf "\ek %s@%s:%s \e\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"
        printf "\ek %s@%s \e\\" "${USER}" "${HOSTNAME%%.*}"

	# tmux pane title
        printf "\e]2; %s@%s \e\\" "${USER}" "${HOSTNAME%%.*}"
}

PROMPT_COMMAND=render_preprompt
#PS1="\e]2;\u2\h\a\A \u@\h \w \\$ "
PS1="\A \u@\h \w \\$ "

function for-snippet {
        if [ -z "$READLINE_LINE" ]; then
		READLINE_LINE='for a in  ; do ; done'
		READLINE_POINT=9
		exit
        else
		if [ $(echo $READLINE_LINE | wc -w) -eq 1 ] ; then
			if [ -f $READLINE_LINE ] ; then
				iter="\$( cat $READLINE_LINE )"
			elif [ -x $READLINE_LINE  ] ; then
				iter="\$( $READLINE_LINE )"
			fi
		else
			foo=( $READLINE_LINE )
			bar=$(which ${foo[0]} 2> /dev/null)
			if [ -x "$bar" ] ; then
				iter="\$( $READLINE_LINE )"
			else
				iter=$READLINE_LINE
			fi	
		fi
		RL_L="for a in $iter ; do ! ; done"
		READLINE_POINT=$(( $( echo "for a in $iter ; do ! ; done" | awk '{print index($0,"!")}' ) - 1 ))
		READLINE_LINE=$( echo $RL_L | tr -d '!' )
	fi
}

function test {
	echo "RLL>$READLINE_LINE<"
	echo "RLP>$READLINE_POINT<"
}

bind -x '"\C-gu":uptime'
bind -x '"\C-gf":for-snippet'
bind -x '"\C-gt":test'

test -f ~/nygas.sh && . ~/nygas.sh
alias config='/usr/bin/git --git-dir=.gitcfg/ --work-tree=/homenfs/nygas'
