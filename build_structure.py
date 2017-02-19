#!/usr/bin/env python3

#==============================================================================
# by Alexis Simon
# last modified: 13/04/2016
# Take a CSV file (with comma separation) as input and convert it to a
# structure input file.
# CSV file : 1st row -> marker names beginning at cell 3
#            1st column -> individuals names
#            2nd column -> populations
#            rest of the columns -> genotypes as nucleotides separated by '/'
#                                   e.g 'A/T' or 'AC/AG'
#==============================================================================
#==============================================================================

import argparse
import csv

parser = argparse.ArgumentParser(description='Transform csv file in nucleotide genotype format to a structure input file.')
parser.add_argument('infile', help='CSV file containing individuals index in 1st column, population id in 2nd column and genotypes after. 1st row is marker ids.')
parser.add_argument('outdir', help='output directory')
args = parser.parse_args()

outfile = args.outdir + args.infile[args.infile.rfind('/'):].replace('.csv', '.stru')
outpop = outfile.replace('.stru', '.pop')

with open(args.infile, newline='') as f:
    csvreader = csv.reader(f)
    data = [row for row in csvreader]

def unique(seq):
    # Order preserving
    seen = set()
    return [x for x in seq if x not in seen and not seen.add(x)]

names = [row[0].replace(' ','_') for row in data[1:]]
populations = [row[1] for row in data[1:]]
genotypes = [row[2:] for row in data[1:]]

#==================================
# Transform populations to numeric
#==================================
uniqPop = unique(populations)
newPop = populations
for index, pop in enumerate(uniqPop):
    newPop = [(index + 1) if x == pop else x for x in newPop]

#================================
# Transform genotypes to numeric
#================================
newGenotypes = []
for gen in genotypes:
    first = [item.split('/')[0] if item != 'NA' else '-9' for item in gen]
    second = [item.split('/')[1] if item != 'NA' else '-9' for item in gen]
    first = [string.replace('A', '1') for string in first]
    first = [string.replace('T', '2') for string in first]
    first = [string.replace('C', '3') for string in first]
    first = [string.replace('G', '4') for string in first]
    second = [string.replace('A', '1') for string in second]
    second = [string.replace('T', '2') for string in second]
    second = [string.replace('C', '3') for string in second]
    second = [string.replace('G', '4') for string in second]
    newGenotypes.append([first, second])

#============================
# Build and write the output
#============================

with open(outfile, 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter='\t')
    csvwriter.writerow(data[0][2:])
    for i in range(len(genotypes)):
        csvwriter.writerow([names[i], newPop[i], 0] + newGenotypes[i][0])
        csvwriter.writerow([names[i], newPop[i], 0] + newGenotypes[i][1])

with open(outpop, 'w', newline='') as popFile:
    csvwriter = csv.writer(popFile, delimiter='\t')
    for index, pop in enumerate(uniqPop):
        csvwriter.writerow([pop, index + 1])

#============================
print(args.infile[args.infile.rfind('/'):], 'converted to', outfile[outfile.rfind('/'):])
