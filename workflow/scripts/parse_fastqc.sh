#!/bin/bash
for i in "$@"
do
case $i in
	-s=*|--sample=*)
	SAMPLE="${i#*=}"
	shift
	;;
  -F=*|--forward=*)
  FORWARD="${i#*=}"
  shift
  ;;
  -R=*|--reverse=*)
  REVERSE="${i#*=}"
  shift
  ;;
	-o=*|--output_dir=*)
	OUT="${i#*=}"
	shift
esac
done

mkdir -p ${OUT}

# unzip files
echo "Out:" ${OUT}
echo "Forward: " ${FORWARD}
echo "Reverse: " ${REVERSE}
echo "Sample: " ${SAMPLE}

#mkdir -p ${OUT};
#mkdir -p ${OUT};
BASENAME_FORWARD=$(basename ${FORWARD} | sed 's/\.zip//g'); #)
BASENAME_REVERSE=$(basename ${REVERSE} | sed 's/\.zip//g'); # | sed 's/\.zip//g')


echo "Basenamen Forward: " ${BASENAME_FORWARD}
echo "Basenamen REVERSE: " ${BASENAME_REVERSE}


unzip ${FORWARD} -d ${OUT}/${BASENAME_FORWARD}
unzip ${REVERSE} -d ${OUT}/${BASENAME_REVERSE}

# Get summary of data

grep -E 'Filename|Total Sequences|Adapter Content|Total Deduplicated' \
 < ${OUT}/${BASENAME_FORWARD}/${BASENAME_FORWARD}/fastqc_data.txt | \
 awk '{print $NF}' | paste -sd '\t'| sed 's/.fastq//g' | \
 sed 's/FP//' | sed 's/$/   forward/g' | \
 sed 's/\.gz//g' > ${OUT}/${SAMPLE}_summary_fastqc_F.txt

grep -E 'Filename|Total Sequences|Adapter Content|Total Deduplicated' \
 < ${OUT}/${BASENAME_FORWARD}/${BASENAME_FORWARD}/fastqc_data.txt | \
 awk '{print $NF}' | paste -sd '\t'| sed 's/.fastq//g' | \
 sed 's/RP//' | sed 's/$/   reverse/g' | \
 sed 's/\.gz//g' > ${OUT}/${SAMPLE}_summary_fastqc_R.txt
