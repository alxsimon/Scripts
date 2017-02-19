#!/usr/bin/env python3

import xlrd
import csv

beadx = '/Users/Alexis/Cloud/Mytilus/data_kaspar/0-Compare_kaspar_beadexpress/2014_01_21_Moules_OK_LocusXDNA.xlsx'
Opa = '/Users/Alexis/Cloud/Mytilus/data_kaspar/0-Compare_kaspar_beadexpress/Opa_Moules.xlsx'

workbook = xlrd.open_workbook(beadx)
sheet = workbook.sheet_by_index(2)

markers = sheet.row_values(1)[1:]

genotypes = []
individuals = []
for rx in range(2, sheet.nrows):
    individuals.append(sheet.row_values(rx)[0])
    genotypes.append(sheet.row_values(rx)[1:])


#=====================
workbook = xlrd.open_workbook(Opa)
sheet = workbook.sheet_by_index(0)

SNPinfo = {}
for rx in range(13, sheet.nrows):
    SNPinfo[sheet.row_values(rx)[1]] = (sheet.row_values(rx)[7], sheet.row_values(rx)[14], sheet.row_values(rx)[8])
# Column 7 is the illumina strand (TOP/BOT illumina rule) and column 14 is the customer strand

#=====================
def complement(allele):
    if allele == 'A':
        allele = 'T'
    elif allele == 'T':
        allele = 'A'
    elif allele == 'C':
        allele = 'G'
    else:
        allele = 'C'
    return allele

for cx in range(len(markers)):
    if SNPinfo[markers[cx]][0] != SNPinfo[markers[cx]][1]:
        firstAllele = SNPinfo[markers[cx]][2][1]
        secondAllele = SNPinfo[markers[cx]][2][-2]
        firstComp = complement(firstAllele)
        secondComp = complement(secondAllele)
        homoFirst = firstComp + '/' + firstComp
        homoSecond = secondComp + '/' + secondComp
        hetero = firstComp + '/' + secondComp

        for rx in range(len(individuals)):
            gen = genotypes[rx][cx]
            if gen != 'N/N':
                if gen[0] == gen[2]:
                    if gen[0] == firstAllele:
                        genotypes[rx][cx] = homoFirst
                    else:
                        genotypes[rx][cx] = homoSecond
                else:
                    genotypes[rx][cx] = hetero

#==========================
for i in range(len(individuals)):
    for j in range(len(markers)):
        if genotypes[i][j] == 'N/N':
            genotypes[i][j] = 'NA'

#==========================
outfile = '/Users/Alexis/Dropbox/Mytilus/data_kaspar/0-Compare_kaspar_beadexpress/beadexpress_all_ind_ATCG_complement.csv'

with open(outfile, 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter=',')
    csvwriter.writerow([''] + markers)
    for rx in range(len(individuals)):
        csvwriter.writerow([individuals[rx]] + genotypes[rx])
