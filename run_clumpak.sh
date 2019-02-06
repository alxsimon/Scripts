#!/usr/bin/env bash

WD=$1
TYPE=$2
MCLT=$3

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
	perl CLUMPAK.pl --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} --inputtype ${TYPE} --podtopop ${POPFILE} --mclthreshold ${MCLT}
else
	perl CLUMPAK.pl --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} --inputtype ${TYPE} --mclthreshold ${MCLT}
fi

unzip ${WD}/tmp/${ID}.zip -d ${WD}/
mv ${WD}/${ID} ${WD}/Clumpak
rm -r ${WD}/tmp
