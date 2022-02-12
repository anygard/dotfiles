# Save 5,000 lines of history in memory
HISTSIZE=10000
# Lines of history to disk (will have to grep ~/.bash_history for full listing)
HISTFILESIZE=500000
# Append to history instead of overwrite
shopt -s histappend
# Ignore redundant or space commands
HISTCONTROL=ignoreboth
# Ignore more
HISTIGNORE='ls:ll:ls -alh:pwd:clear:history'
# Set time format
HISTTIMEFORMAT='%F %T '
# Multiple commands on one line show up as a single line
shopt -s cmdhist
