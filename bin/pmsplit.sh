#!/bin/bash

dates=$(csvtool col 2 $1 | sort -u)
dept=$(basename $1 .csv)

for date in $dates ; do
   csvtool cols 2,1 $1 | grep "^$date," | csvtool col 2 - |
	   sed 's/^"//;s/"$//' | unix2dos > $dept-$(date -d $date +"%b-%d").txt
done
