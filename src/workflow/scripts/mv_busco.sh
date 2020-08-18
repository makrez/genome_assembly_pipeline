#!/bin/bash
for i in "$@"
do
case $i in
  -i=*|--input_dir=*)
  IN="${i#*=}"
  shift
  ;;
	-o=*|--output_dir=*)
	OUT="${i#*=}"
	shift
esac
done

# unzip files#

echo "Out:" ${IN}
echo "Forward: " ${OUT}

for file in $(ls ${IN} | grep 'short_summary'); do cp $file ${OUT}/. ; done
