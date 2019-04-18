#! /bin/bash

# Declare variables
INFILE="$1"
OUTFILE="$2"

#If the file exists, recode the data
if [ -a ${INFILE} ];
    then
        echo "Processing ${INFILE} and writing to ${OUTFILE}"

        tail -n +8 ${INFILE} | awk 'BEGIN{FS=OFS=","}; {if (FNR==1) $1=""}1' | sed -e 's/?/NA/g' -e 's/Uncallable/NA/g' -e 's/Bad/NA/g' -e 's/Missing/NA/g' -e 's/:/\//g' -e 's/,,/,NA,/g' > ${OUTFILE}

    else
        echo "Cannot find ${INFILE}"
        exit 1
fi

echo "Finished"
