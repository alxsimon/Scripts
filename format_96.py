#!/usr/bin/env python3

#==============================================================================
# by Alexis Simon
# last modified: 18/04/2016
# Format a list of samples to 96 well plates
#==============================================================================
#==============================================================================

import argparse
import csv
import math

parser = argparse.ArgumentParser(description='Format a list of samples to 96 well plates.')
parser.add_argument('list', help='list of samples (txt file)')
args = parser.parse_args()

outfile = args.list.replace('.txt', '_96.txt')

with open(args.list, newline='') as f:
    samples = f.read().splitlines()

#============================
# Build and write the output
#============================

with open(outfile, 'w', newline='') as out:
    csvwriter = csv.writer(out, delimiter='\t')
    for plate in range(math.ceil(len(samples)/95)):
        csvwriter.writerow(["P" + str(plate+1)])
        for l in range(8):
            if l != 7:
                line = samples[plate*95 + l*12 : plate*95 + l*12 + 12]
                csvwriter.writerow(line)
            else:
                line = samples[plate*95 + l*12 : plate*95 + l*12 + 11]
                csvwriter.writerow(line)
        csvwriter.writerow("")
