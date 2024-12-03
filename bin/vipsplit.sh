#!/bin/bash

dates=$(csvtool col 1 AllVIPs.csv | sort -u)

mkdir -p /tmp/icmdata/VIP

for date in $dates ; do
   grep "^$date," AllVIPs.csv | csvtool col 2 - |
	   sed 's/^"//;s/"$//' | unix2dos > /tmp/icmdata/KMC/VIP-$(date -d $date +"%b-%d").txt
done
