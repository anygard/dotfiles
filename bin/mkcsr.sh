#!/bin/bash

C="SE"
O="Arbetsförmedlingen"

if [ $# -lt 1 ] ; then
        echo "Usage: $(basename $0) <fqdn> [<fqdn> [<fqdn>] ... ]"
        exit 1
fi

primdom=$1
altdom=$@

keyfname="$primdom-key.pem"
csrfname="$primdom-csr.pem"

for f in $keyfname $csrfname ; do
        if [ -e $f ]; then
                echo "Found file: $f, will not overwrite"
                exit 2
        fi
done

altnamos=''
i=1
for a in $altdom ; do
        altnames="${altnames}DNS.$i = $a\n"
        i=$((i+1))
done
alts=$(echo -e $altnames)

tmp=$(mktemp)

cat << EOH > $tmp
[req]
distinguished_name = dn
req_extensions = req_ext
prompt = no
encryptkey = no

[dn]
C=$C
O=$O
CN = $primdom

[req_ext]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
$alts
EOH

openssl req -out $csrfname -newkey rsa:4096 -sha256 -nodes -keyout $keyfname -config $tmp

rm $tmp

openssl rsa -in $keyfname -check

openssl req -in $csrfname -text -noout -verify
