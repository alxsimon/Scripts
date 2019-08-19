#!/usr/bin/env python3

# ==============================================================================
# by Alexis Simon
# last modified: 18/04/2016
# Take a CSV file (with comma separation) as input and convert it to a
# Plink format.
# CSV file : 1st row -> marker names beginning at cell 3
#            1st column -> individuals names
#            2nd column -> populations
#            3rd column -> popflag as in the Structure fromat
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
    help="CSV file containing individuals index in 1st column,\
        population id in 2nd column, popflag in 3rd column and genotypes after. 1st row is marker ids.",
)
parser.add_argument("outdir", help="output directory")
args = parser.parse_args()

outfilePed = args.outdir + args.infile[args.infile.rfind("/") :].replace(".csv", ".ped")
outfileMap = args.outdir + args.infile[args.infile.rfind("/") :].replace(".csv", ".map")
outfilePop = args.outdir + args.infile[args.infile.rfind("/") :].replace(".csv", ".pop")

with open(args.infile, newline="") as f:
    csvreader = csv.reader(f)
    data = [row for row in csvreader]


def unique(seq):
    # Order preserving
    seen = set()
    return [x for x in seq if x not in seen and not seen.add(x)]


names = [row[0].replace(" ", "_") for row in data[1:]]
populations = [row[1].replace(" ", "") for row in data[1:]]
popflag = [row[2] for row in data[1:]]
genotypes = [row[3:] for row in data[1:]]
markers = [col for col in data[0][3:]]

popfile = populations[:]
for pi, p in enumerate(populations):
    if popflag[pi] == "0":
        popfile[pi] = "-"

# =====================================
# Transform markers to double columns
# =====================================
newGenotypes = []
for gen in genotypes:
    newgen = [item.split("/") if item != "NA" else ["0", "0"] for item in gen]
    newGenotypes.append([item for sublist in newgen for item in sublist])

# ============================
# Build and write the output
# ============================

with open(outfilePed, "w", newline="") as out:
    csvwriter = csv.writer(out, delimiter="\t", lineterminator="\n")
    for i in range(len(genotypes)):
        csvwriter.writerow(
            [populations[i], names[i], "0", "0", "0", "-9"] + newGenotypes[i]
        )

with open(outfileMap, "w", newline="") as out:
    csvwriter = csv.writer(out, delimiter="\t", lineterminator="\n")
    for i in range(len(markers)):
        csvwriter.writerow(["0", markers[i], "0", "0"])

with open(outfilePop, "w", newline="") as out:
    out.write("\n".join(popfile))

# ===========================
# Produce binary plink file
# ===========================

subprocess.run(
    "plink --file "
    + outfilePed.replace(".ped", "")
    + " --out "
    + outfilePed.replace(".ped", "")
    + " --make-bed",
    shell=True,
)
