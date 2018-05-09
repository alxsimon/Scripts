#!/usr/bin/env python3

#==============================================================================
# by Alexis Simon
# last modified: 11/07/2016
# Take a CSV file (with comma separation) as input and convert it to a
# genepop format.
# CSV file : 1st row -> marker names beginning at cell 3
#            1st column -> individuals names
#            2nd column -> populations
#            rest of the columns -> genotypes as nucleotides separated by '/'
#                                   e.g 'A/T' or 'AC/AG'
#==============================================================================
#==============================================================================

import argparse
import csv
import pandas as pd

parser = argparse.ArgumentParser(description='Transform csv file in nucleotide genotype format to a genepop format.')
parser.add_argument('infile', help='CSV file containing individuals index in 1st column, population id in 2nd column and genotypes after. 1st row is marker ids.')
parser.add_argument('outdir', help='output directory')
args = parser.parse_args()

outfile = args.outdir + args.infile[args.infile.rfind('/'):].replace('.csv', '_genepop.txt')

#with open(args.infile, newline='') as f:
#    csvreader = csv.reader(f)
#    data = [row for row in csvreader]

#==============
# Functions
#==============

def unique(seq):
    # Order preserving
    seen = set()
    return [x for x in seq if x not in seen and not seen.add(x)]

def get_alleles(column_id, dataframe):
    genotypes = list(dataframe[column_id].values)
    alleles = unique([item for sublist in [x.split('/') for x in genotypes] for item in sublist])
    alleles = [a for a in alleles if a != 'NA']
    return alleles


#===============

df = pd.read_csv(args.infile)
#df.rename(columns={'Unnamed: 0': 'id'}, inplace=True)
df = df.fillna('NA')

#
names = df.iloc[:,0].tolist()
populations = df.iloc[:,1].tolist()
markers = list(df.columns.values[2:])

uniqPop = unique(populations)

#==================
# Transform data
#==================
newGenotypes = []
for m in markers:
    alleles = get_alleles(m, df)
    newgen = list(df[m].values)
    newgen = [string.replace('NA', '000000') for string in newgen]
    newgen = [string.replace('/', '') for string in newgen]
    if len(alleles) == 2:
        newgen = [string.replace(alleles[0], '100') for string in newgen]
        newgen = [string.replace(alleles[1], '200') for string in newgen]
    elif len(alleles) == 1:
        newgen = [string.replace(alleles[0], '100') for string in newgen]
    newGenotypes.append(newgen)

outgen = []
for xi in range(len(names)):
    outgen.append(" ".join([col[xi] for col in newGenotypes]))

#============================
# Build and write the output
#============================

with open(outfile, 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter=',')
    csvwriter.writerow(['**Genepop format**'])
    for xi in range(len(markers)):
        csvwriter.writerow([markers[xi]])
    for pop in uniqPop:
        csvwriter.writerow(['POP'])
        indices = [index for index, item in enumerate(populations) if item == pop]
        for xi in indices:
            csvwriter.writerow([names[xi] + ' '] + ['  ' + outgen[xi]])
