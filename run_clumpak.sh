#!/usr/bin/env bash

WD=$1
TYPE=$2

if [ $TYPE = 'admixture' ]; then
	ZIPFILE=$(find ${WD} -name '*_Q.zip')
	POPFILE=$(find ${WD} -name '*clumpak_pop')
else
	ZIPFILE=$(find ${WD} -name '*.zip')
fi
echo $ZIPFILE

cd /Applications/CLUMPAK

ID=${RANDOM}
if [ $TYPE = 'admixture' ]; then
	perl CLUMPAK.pl --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} --inputtype ${TYPE} --podtopop ${POPFILE}
else
	perl CLUMPAK.pl --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} --inputtype ${TYPE}
fi

unzip ${WD}/tmp/1.zip -d ${WD}/
mv ${WD}/${ID} ${WD}/Clumpak
rm -r ${WD}/tmp
