#!/usr/bin/env bash

WD=$1
cd ${WD}
TYPE=$2
MCLT=$3
# if using more than 5000 individuals: swith LN to 1
LN=${4:-0}
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

if [ $LN == 1 ]; then
	clumpak_command='/opt/CLUMPAK/CLUMPAK_large_number.pl'
else
	clumpak_command='/opt/CLUMPAK/CLUMPAK.pl'
fi

# run CLUMPAK
ID=${RANDOM}
if [ $TYPE = 'admixture' ]; then
	perl ${clumpak_command} --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} \
		--inputtype ${TYPE} --podtopop ${POPFILE} --mclthreshold ${MCLT}
else
	perl ${clumpak_command} --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} \
		--inputtype ${TYPE} --mclthreshold ${MCLT}
fi

# Cleanup
unzip ${WD}/tmp/${ID}.zip -d ${WD}/
mv ${WD}/${ID} ${WD}/Clumpak
rm -r ${WD}/{tmp,CLUMPP,mcl,distruct,arabid.perm_datafile}
