#!/bin/bash

while read -r dn ; do
   encoded_dn=$(urlencode $dn)
   curl --fail --silent -f "ldap://ldap.gss-spg.gc.ca/$encoded_dn?dn?sub" > /dev/null
   if [ $? -ne 0 ] ; then
      echo "Certificate not found: $dn"
   fi

done < <(csvtool col 1 $1 | sed 's/^"//;s/"$//')

