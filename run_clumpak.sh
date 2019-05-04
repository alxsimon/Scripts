#!/usr/bin/env bash

WD=$1
cd ${WD}
TYPE=$2
MCLT=$3
cp -r /opt/CLUMPAK/{CLUMPP,mcl,distruct} ${WD}/

# initial cleanup
[ -d Clumpak ] && rm -r Clumpak

# Get input files location
if [ $TYPE = 'admixture' ]; then
	ZIPFILE=$(find ${WD} -name '*_Q.zip')
	POPFILE=$(find ${WD} -name '*clumpak_pop')
else
	ZIPFILE=$(find ${WD} -name '*.zip')
fi
echo $ZIPFILE

# run CLUMPAK
ID=${RANDOM}
if [ $TYPE = 'admixture' ]; then
	perl /opt/CLUMPAK/CLUMPAK.pl --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} \
		--inputtype ${TYPE} --podtopop ${POPFILE} --mclthreshold ${MCLT}
else
	perl /opt/CLUMPAK/CLUMPAK.pl --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} \
		--inputtype ${TYPE} --mclthreshold ${MCLT}
fi

# Cleanup
unzip ${WD}/tmp/${ID}.zip -d ${WD}/
mv ${WD}/${ID} ${WD}/Clumpak
rm -r ${WD}/{tmp,CLUMPP,mcl,distruct,arabid.perm_datafile}
