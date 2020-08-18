#!/bin/bash
for i in "$@"
do
case $i in
    -i=*|--input=*)
    INPUT="${i#*=}"
    shift
    ;;
    -o=*|--output=*)
    OUTPUT="${i#*=}"
    shift
    ;;
    -m=*|--min_length=*)
    MIN="${i#*=}"
    shift
    ;;
    -s=*|--sample=*)
    SAMPLE="${i#*=}"
    shift
    ;;
esac
done

# print fasta to one lineage
/bin/awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' \
< ${INPUT} | /bin/awk -v min=${MIN} \
'BEGIN {RS = ">" ; ORS = ""} length($2) >= min {print ">"$0}' | \
/bin/sed "s/NODE_/${SAMPLE}-i1-1_scf/g" | \
/bin/sed 's/_length/ length/g' > ${OUTPUT}
