#!/bin/bash

#prepare output directory
if [ -d /tmp/icmdata ] ; then
   rm -rf /tmp/icmdata
fi
mkdir -p /tmp/icmdata/KMC

# Configure locale (optimizes performance of grep -f)
export LC_ALL=C

# Cleanup prod.global data
csvtool col 1 AD.csv | # extract email address
   grep -Ei '^[^@]+@([^@]+\.gc|canada)\.ca$' | # filter out bad addresses
   tr '[:upper:]' '[:lower:]' > /tmp/icmdata/AD.csv # Convert to lower case

echo "\"Department\",\"Filtered\",\"Matched\",\"Unmatched\",\"Final\"" >> /tmp/icmdata/counts.csv

# Generate ICM-managed schedules (General population)
IFS=','
while read ou acronym volume icmmanaged; do
    prefix=${acronym%/*}

    # Filter out all but employee certs
    # NOTE: Rrequires GNU Awk 5.3.0 or later!
    printf "Processing %-37s" "$prefix ($ou)... "
    gawk --csv -v "dept=@/^ou=${ou}$/" -f ../bin/cleanup.awk AllDepts.csv |
	   csvtool format '"%3","%5","%8"\n' - | tr '[:upper:]' '[:lower:]' |
	   sed -E 's/(@canada\.ca|@[^\.]*\.gc\.ca)/\1,/ig' | sed 's/,",/",/g' >> /tmp/icmdata/${prefix}-filtered.csv
    filtered=$(wc -l < /tmp/icmdata/${prefix}-filtered.csv)
    printf "Filtered: %'5d " $filtered

    # Match against AD (prod.global)
    grep -Ff /tmp/icmdata/AD.csv /tmp/icmdata/$prefix-filtered.csv > /tmp/icmdata/${prefix}-matching.csv
    matched=$(wc -l < /tmp/icmdata/${prefix}-matching.csv)
    printf "Matched: %'5d " $matched

    # Remaining certs are unmatched
    comm -23 <(sort /tmp/icmdata/${prefix}-filtered.csv) \
	     <(sort /tmp/icmdata/${prefix}-matching.csv) > /tmp/icmdata/${prefix}-unmatched.csv
    unmatched=$(wc -l < /tmp/icmdata/${prefix}-unmatched.csv)
    printf "Unmatched: %'5d " $unmatched

    # Filter out Pilot and VIP users for the final list
    csvtool col 2 AllVIPs.csv | cat - Pilot-DNs.txt | grep -Fivf - /tmp/icmdata/${prefix}-matching.csv > /tmp/icmdata/${prefix}-final.csv
    final=$(wc -l < /tmp/icmdata/${prefix}-final.csv)
    printf "Final: %'5d\n" $final

    # Split ICM-managed data into days based on requested volumes
    if [ $icmmanaged -eq 1 ]; then
       csvtool cols 3,1 /tmp/icmdata/${prefix}-final.csv | sort | csvtool col 2 - | sed 's/^"//;s/"$//' |
       	   split -d --numeric-suffixes=01 --additional-suffix=.txt -l $volume - /tmp/icmdata/KMC/${prefix}-day
       unix2dos -q /tmp/icmdata/kmc/${prefix}-day*.txt
    fi

    echo "\"$prefix\",\"$filtered\",\"$matched\",\"$unmatched\",\"$final\"" >> /tmp/icmdata/counts.csv

done < <(sed 1d Departments.csv)
unset IFS

# Generate VIP schedules
vipdates=$(csvtool col 1 AllVIPs.csv | sort -u)
for vipdate in $vipdates ; do
   grep "^$vipdate," AllVIPs.csv | csvtool col 2 - |
           sed 's/^"//;s/"$//' | unix2dos > /tmp/icmdata/KMC/VIP-$(date -d $vipdate +"%b-%d").txt
done

