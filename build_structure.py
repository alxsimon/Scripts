#!/usr/bin/env python3

#==============================================================================
# by Alexis Simon
# last modified: 20/12/2016
# Take a CSV file (with comma separation) as input and convert it to a
# structure input file.
# CSV file : 1st row -> marker names beginning at cell 3
#            1st column -> individuals names
#            2nd column -> populations
#            3rd column -> optional popflag, will be defined as 0 if not present
#            rest of the columns -> genotypes as nucleotides separated by '/'
#                                   e.g 'A/T' or 'AC/AG'
#==============================================================================
#==============================================================================

import argparse
import csv

parser = argparse.ArgumentParser(description='Transform csv file in nucleotide genotype format to a structure input file.')
parser.add_argument('infile', help='CSV file containing individuals index in 1st column, population id in 2nd column and genotypes after. 1st row is marker ids.')
parser.add_argument('--outfile', help='Output directory')
parser.add_argument('--recodepop', help='Recode populations or not (default 1)', type=int, default=1)
parser.add_argument('--usepopinfo', help='Define the USEPOPINFO parameter in Structure', type=int, default=0)
parser.add_argument('--pfrompopflagonly', help='Define the PFROMPOPFLAGONLY parameter in Structure', type=int, default=0)
parser.add_argument('--burnin', help='Define the BURNIN parameter in Structure', type=int, default=20000)
parser.add_argument('--numreps', help='Define the NUMREPS parameter in Structure', type=int, default=80000)
args = parser.parse_args()

if args.outfile is None:
    outfile = args.infile.replace('.csv', '.stru')
else:
    outfile = args.outfile
outpop = outfile.replace('.stru', '.pop')

with open(args.infile, newline='') as f:
    csvreader = csv.reader(f)
    data = [row for row in csvreader]

def unique(seq):
    # Order preserving
    seen = set()
    return [x for x in seq if x not in seen and not seen.add(x)]

if 'popflag' in data[0]:
    startMarkers = 3
    popflag = [row[2] for row in data[1:]]
else:
    startMarkers = 2
    popflag = [0] * (len(data) - 1)

names = [row[0].replace(' ','_') for row in data[1:]]
populations = [row[1] for row in data[1:]]
genotypes = [row[startMarkers:] for row in data[1:]]

Ngen = len(names)
Nloc = len(genotypes[1])

#==================================
# Transform populations to numeric
#==================================
uniqPop = unique(populations)
newPop = populations
if args.recodepop == 1:
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
    first = [string.replace('T', '4') for string in first]
    first = [string.replace('C', '2') for string in first]
    first = [string.replace('G', '3') for string in first]
    second = [string.replace('A', '1') for string in second]
    second = [string.replace('T', '4') for string in second]
    second = [string.replace('C', '2') for string in second]
    second = [string.replace('G', '3') for string in second]
    newGenotypes.append([first, second])

#============================
# Build and write the output
#============================

with open(outfile, 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter='\t')
    csvwriter.writerow(data[0][startMarkers:])
    for i in range(len(genotypes)):
        csvwriter.writerow([names[i], newPop[i], popflag[i]] + newGenotypes[i][0])
        csvwriter.writerow([names[i], newPop[i], popflag[i]] + newGenotypes[i][1])
if args.recodepop == 1:
    with open(outpop, 'w', newline='') as popFile:
        csvwriter = csv.writer(popFile, delimiter='\t')
        for index, pop in enumerate(uniqPop):
            csvwriter.writerow([pop, index + 1])

#============================
# Parameter files
#============================

mainparNames = [
    "NUMINDS",
    "NUMLOCI",
    "LABEL",
    "POPDATA", 
    "POPFLAG", 
    "LOCDATA", 
    "PHENOTYPE", 
    "MARKERNAMES", 
    "MAPDISTANCES", 
    "ONEROWPERIND", 
    "PHASEINFO",
    "PHASED",
    "RECESSIVEALLELES", 
    "EXTRACOLS",
    "MISSING",
    "PLOIDY",
    "BURNIN",
    "NUMREPS"
]

mainparValues = [
    Ngen,
    Nloc,
    1,
    1, 
    1, 
    0, 
    0,
    1, 
    0, 
    0, 
    0, 
    0, 
    0, 
    0,
    -9,
    2,
    args.burnin,
    args.numreps
]

extraparNames = [
    "NOADMIX",
    "LINKAGE",
    "USEPOPINFO",
    "LOCPRIOR",
    "INFERALPHA",
    "ALPHA",
    "POPALPHAS",
    "UNIFPRIORALPHA",
    "ALPHAMAX",
    "ALPHAPROPSD",
    "FREQSCORR",
    "LAMBDA",
    "COMPUTEPROB",
    "PFROMPOPFLAGONLY",
    "ANCESTDIST",
    "STARTATPOPINFO",
    "METROFREQ",
    "UPDATEFREQ",
    "RANDOMIZE"
]

extraparValues = [
    0,
    0,
    args.usepopinfo,
    0,
    1,
    0.3,
    1,
    1,
    10.0,
    0.05,
    0,
    1.0,
    1,
    args.pfrompopflagonly,
    0,
    0,
    10,
    1,
    0
]

with open(outfile.replace(".stru", "_mainparams"), 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter=' ')
    for i in range(len(mainparNames)):
        csvwriter.writerow(["#define", mainparNames[i], mainparValues[i]])

with open(outfile.replace(".stru", "_extraparams"), 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter=' ')
    for i in range(len(extraparNames)):
        csvwriter.writerow(["#define", extraparNames[i], extraparValues[i]])

#============================
print(args.infile, 'converted to', outfile)
