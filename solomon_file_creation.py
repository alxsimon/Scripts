#!/usr/bin/env python3

# ==============================================================================
# by Alexis Simon
# last modified: 22/04/2016
# Take a CSV file (with comma separation) as input and convert it to a
# Plink format.
# CSV file : 1st row -> marker names beginning at cell 3
#            1st column -> individuals names
#            rest of the columns -> genotypes as nucleotides separated by '/'
#                                   e.g 'A/T' or 'AC/AG'
# ==============================================================================
# ==============================================================================

import argparse
import csv
import subprocess

parser = argparse.ArgumentParser(
    description="Transform csv file in nucleotide genotype format to a plink format."
)
parser.add_argument(
    "infile",
    help="CSV file containing individuals index in 1st column and genotypes after. 1st row is marker ids.",
)
parser.add_argument("outdir", help="output directory")
args = parser.parse_args()

outfileMoms = args.outdir + "moms.txt"
outfileDads = args.outdir + "dads.txt"
outfileF2 = args.outdir + "F2.txt"

with open(args.infile, newline="") as f:
    csvreader = csv.reader(f)
    data = [row for row in csvreader]

names = [row[0].replace(" ", "_") for row in data[1:]]
genotypes = [row[1:] for row in data[1:]]
markers = [col for col in data[0][1:]]


# =====================================
# Transform markers to double columns
# =====================================
newGenotypes = []
for gen in genotypes:
    newgen = [item.split("/") if item != "NA" else ["0", "0"] for item in gen]
    newGenotypes.append([item for sublist in newgen for item in sublist])

tmp = [[item, item] for item in markers]
newMarkers = [item for sublist in tmp for item in sublist]

# ================================
# Transform genotypes to numeric
# ================================
for cx in range(len(markers)):
    tmp = set(
        [row[2 * cx] for row in newGenotypes]
        + [row[2 * cx + 1] for row in newGenotypes]
    )
    alleles = [item for item in tmp if item != "0"]
    for rx in range(len(genotypes)):
        for index, A in enumerate(alleles):
            newGenotypes[rx][2 * cx] = newGenotypes[rx][2 * cx].replace(
                A, str(index + 1)
            )
            newGenotypes[rx][2 * cx + 1] = newGenotypes[rx][2 * cx + 1].replace(
                A, str(index + 1)
            )

# ============================
# Build and write the output
# ============================

with open(outfileMoms, "w", newline="") as out:
    csvwriter = csv.writer(out, delimiter="\t", lineterminator="\n")
    csvwriter.writerow(["Individuals"] + newMarkers)
    for i in range(5):
        csvwriter.writerow([names[0]] + newGenotypes[0])

with open(outfileDads, "w", newline="") as out:
    csvwriter = csv.writer(out, delimiter="\t", lineterminator="\n")
    csvwriter.writerow(["Individuals"] + newMarkers)
    for i in range(1, 6):
        csvwriter.writerow([names[i]] + newGenotypes[i])

with open(outfileF2, "w", newline="") as out:
    csvwriter = csv.writer(out, delimiter="\t", lineterminator="\n")
    csvwriter.writerow(["Individuals"] + newMarkers)
    for i in range(6, len(newGenotypes)):
        csvwriter.writerow([names[i]] + newGenotypes[i])
