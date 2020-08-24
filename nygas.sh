#alias ldaputil=/local/dsa/konf/bin/ldaputil
#
#alias lung="ldaputil netgroup"
#alias lug="ldaputil group"
#alias luu="ldaputil user"
#alias lus="ldaputil server"

alias .f='/usr/bin/git --git-dir=$HOME/.gitcf/ --work-tree=$HOME'

function log() {
        echo -e "$(date --rfc-3339=ns)\t${FUNCNAME[1]} $1" >> /tmp/nygas.log
}

function sysc() {
	log start
	systemctl $@
	log end
}

function ldaputil() {
	log start
	/local/dsa/konf/bin/ldaputil $@
	log end
}

function lung() {
	log start
	/local/dsa/konf/bin/ldaputil netgroup $@
	log end
}

function lug() {
	log start
	/local/dsa/konf/bin/ldaputil group $@
	log end
}

function luu() {
	log start
	/local/dsa/konf/bin/ldaputil user $@
	log end
}

function lursu() {
	log start
	/local/dsa/konf/bin/ldaputil server $@
	log end
}

function rpg() {
	log start
        tags=''
        hosts=$1
        test -n "$2" && tags="--tags $2"
	pushd ~ &> /dev/null
	~/bin/rex -s -t 30 $hosts "while true ; do sudo puppet agent -t $tags ; if [ $? -ne 4 ] ; then break; fi ;  done" 
	popd &> /dev/null
	log end
}

function envfilt() {
	log start
	hl=$1
        filter=$2

	delim=''
	for h in $(echo $hl | tr ',' ' ') ; do
		if [ "$(ci2env $h)" == "$2" ] ; then
			echo -n "$delim$h"
			delim=','
		fi
	done
	echo
	log end
}

function SSH() {
        echo "DEPRECATED use _s instead"
	log start
       	if which tmux &> /dev/null ; then
	        tmux rename-window $1
	fi
	ssh $(ci2fqdn $1)
	log end
}

function _s() {
	log start
       	if which tmux &> /dev/null ; then
	        tmux rename-window $1
	fi
	#ssh $(ci2fqdn $1)
	ssh $1
	log end
}

function newserver() {
	log start
        HOST=$(echo $1 |  tr '[:lower:]' '[:upper:]')
        ldaputil netgroup add $HOST
        ldaputil netgroup addmembergroup $HOST Unixgruppen
	ldaputil netgroup addserver ALL_SERVER_S $HOST
        if ci2env $HOST | grep "i1" &> /dev/null ; then
		sudodev-addserver $HOST
        fi
	log end
}

function sudodev() {
	log start
	if [ $# -ne 2 ]; then
		verb=borken
		subject=borken
		object=borken
	else
		verb=$1
		subject=$2
		object=$3
        fi        
	case $verb in
		add)
			sudodev-addserver $object
			sudodev-adduser $(hosts-fsn $subject | tr ' ' ',' | sed 's/,$//')
			;;
		*)
			echo "Usage: ${FUNCNAME[0]} (add) <server(s)> <username(s)>"
			;;
	esac
	log end
}
				

function sudodev-addserver() {
	log start
        HOST=$(echo $1 |  tr '[:lower:]' '[:upper:]')
	ldaputil netgroup addmembergroup $HOST ALL_IT_U
	ldaputil netgroup addserver i1_u1_S $HOST
	log end
}

function sudodev-adduser() {
	log start
	ldaputil netgroup adduser ALL_IT_U $1
	log end
}

function serverexists() {
	log start
        HOST=$(echo $1 |  tr '[:lower:]' '[:upper:]')
        ldaputil netgroup list $HOST
        ldaputil netgroup list i1_u1_S | grep $HOST
	log end
}


function hosts-fsn() {
	log start
	echo $1 | sed 's/,/ /g'
	log end
}

function users-fsn() {
	log start
        do_csv='no'
        if [ "$1" = "-s" ] ; then
		do_csv='yes'
                shift
        fi
	#res=$(echo $1 | tr "," "\n" | perl -ne '/\(([a-z]{5})\)/ && print "$1$ENV{CHR}"' | sed 's/[^a-z]$//')
	res=$(echo $1 | tr "," "\n" | perl -ne '/\(([a-z]{5})\)/ && print "$1 "' | sed 's/[^a-z]$//')
	if [ -z "$res" ]; then 
		res=$1 
	fi
	if [ "$do_csv" = 'yes' ]; then
		echo $res | tr ' ' ','
	else
		echo $res | tr ',' ' '
	fi
	log end
}

function sudorule() {
	log start
	HOSTS="$1"
	USERS=$(users-fsn -s "$2")
        SUU=$3
        CMD=$4

	echo "$USERS $HOSTS=($SUU) $CMD"
	
	log end
}

function isvirt() {
	log start
	var=''
	if sudo dmidecode | grep -i vmware > /dev/null ; then
		var="VIRTUAL"
	else
		var="PHYSICAL"
	fi
	echo "This machine is $var"
	log end
}

function hostusercmd() {
	log start
	HL=$1
        UL=$2

	HOSTS=$(hosts-fsn "$HL")
	USERS=$(users-fsn "$UL")
        
        CMD_L="$3"

	for H in $HOSTS ; do
		for U in $USERS ; do
			export H U
                        #echo "U: $U, H: $H"
			#echo "CMD_L: $CMD_L"
                        #echo "es: $( echo $CMD_L | envsubst)"
                        $(echo $CMD_L | envsubst)
			#$CMD_L
		done
	done
	log end
}

function usercmd() {
	log start

	USERS=$(users-fsn "$1")
        CMD_L="$2"

	for U in $USERS ; do
		export U
		$(echo $CMD_L | envsubst)
	done
	log end
}

function hostcmd() {
	log start
        if [ "$1" = "-f" ] ; then
		FQC=1
		shift
	fi
	HL=$1

	HOSTS=$(hosts-fsn "$HL")
        CMD_L="$2"

	for H in $HOSTS ; do
                if [ -n "$FQC" ] ; then
			I=$(ci2fqdn $H)
			H=$I
		fi
		export H
        	$(echo $CMD_L | envsubst)
	done
	log end
}

function userhaslogin() {
	log start
	lung list | awk "	/cn: / {cn=\$2}
				/$1/ {print cn}" | grep "^L"
	log end
}

function _h() {
	ci2fqdn $1	
}

function pupclean {
	if [ -z $1 ]; then
		echo "gotta specify target host"
		return 1
	fi
	fqdn=$(ci2fqdn $1)
	ssh -o StrictHostKeyChecking=no -t puppetca.ams.se "sudo puppet cert clean $fqdn"
}

function ci2fqdn() {
	CI=$1
	fqdn=$(sqlite3 ~/minicmdb/minicmdb.sqlite3 "select fqdn from minicmdb where fqdn like '%${CI}%';")
	if [ $(echo $fqdn | wc -w) -gt 1 ]; then
		echo $fqdn
		return 1
	fi
	if [ $(echo $fqdn | wc -c) -gt 2 ]; then
		echo $fqdn
		return 0
	fi	
        domains=""
        suffix=ams.se
        for a in wpa ata upa udmz admz wdmz wp wt wu ws tdm; do
                domains="$domains $a.$suffix"
        done
        domains="$domains i1.local u1.local dmz.i1.local"

        for d in $domains ; do
                FQDN="$CI.$d"
                if host $FQDN &> /dev/null ; then
                        echo $FQDN
			log end
                        return 0
                fi
        done
        echo "$CI.no.fqdn"
	return 2
}
function hlu {
	h=$1
	sqlite3 ~/minicmdb/minicmdb.sqlite3 "select fqdn from minicmdb where fqdn like '%${h}%';"
}

function ci2env() {
	log start
	case $(ci2fqdn $@ | cut -d'.' -f2,3) in
		wpa.ams|wp.ams|wdmz.ams)
			echo 'prod'
			;;
		ata.ams|wt.ams|admz.ams)
			echo 't2'
			;;
		wu.ams|upa.ams|udmz.ams)
			echo 't1'
			;;
		i1.local|dmz.i1|u1.local)
			echo 'i1'
			;;
		ws.ams)
			echo 'dev'
			;;
	esac
	log end
}

function frame() {
        SUBJ=$@
	PRE="--[ $SUBJ "
        L=$(echo "$PRE" | wc -c)
	PL=$((80-$L))
        echo $L $PL
        HEADER=$(printf "%s %.${PL}s" "$PRE" " ]------------------------------------------")
	echo 
	echo
	echo $HEADER
	$SUBJ
}

function xl2cshl() {
	log start
	echo "paste in contents of excel column end with ctrl-D"
	cat | sort -n | tr '\n' ','
	log end
}



# dynamic completions

function __minicmdb-fqdn-completion () {
  
  local cur

  # get word the cursor is at
  cur=${COMP_WORDS[COMP_CWORD]}

  # list of completions
  COMPREPLY=$(sqlite3 /homenfs/nygas/minicmdb/minicmdb.sqlite3 "select fqdn from minicmdb where fqdn like '%${cur}%';")

  return 0
}

complete -r _s &> /dev/null
complete -F __minicmdb-fqdn-completion _s
complete -r _h &> /dev/null
complete -F __minicmdb-fqdn-completion _h
