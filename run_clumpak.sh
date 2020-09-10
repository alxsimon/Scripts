#!/usr/bin/env bash

ZIPFILE_NAME=$1
WD=$2
cd ${WD}
TYPE=$3
MCLT=$4
# if using more than 5000 individuals: swith LN to 1
LN=${5:-0}
cp -r /opt/CLUMPAK/{CLUMPP,mcl,distruct} ${WD}/

# initial cleanup
[ -d Clumpak ] && rm -r Clumpak

# Get input files location
#if [ $TYPE = 'admixture' ]; then
#	ZIPFILE=$(find ${WD} -name '*.zip')
#	POPFILE=$(find ${WD} -name '*clumpak_pop')
#else
#	ZIPFILE=$(find ${WD} -name '*.zip')
#fi
echo $ZIPFILE

if [ $LN == 1 ]; then
	clumpak_command='/opt/CLUMPAK/CLUMPAK_large_number.pl'
else
	clumpak_command='/opt/CLUMPAK/CLUMPAK.pl'
fi

# run CLUMPAK
ID=${RANDOM}
perl ${clumpak_command} --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE_NAME} \
		--inputtype ${TYPE} --mclthreshold ${MCLT}
#if [ $TYPE = 'admixture' ]; then
#	perl ${clumpak_command} --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} \
#		--inputtype ${TYPE} --podtopop ${POPFILE} --mclthreshold ${MCLT}
#else
#	perl ${clumpak_command} --id ${ID} --dir ${WD}/tmp --file ${ZIPFILE} \
#		--inputtype ${TYPE} --mclthreshold ${MCLT}
#fi

# Cleanup
unzip ${WD}/tmp/${ID}.zip -d ${WD}/
mv ${WD}/${ID} ${WD}/Clumpak
rm -r ${WD}/{tmp,CLUMPP,mcl,distruct,arabid.perm_datafile}
