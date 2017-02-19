#!/usr/bin/env python3

#==============================================================================
# by Alexis Simon
# last modified: 02/05/2016
#==============================================================================
#==============================================================================

import argparse
import os.path
import subprocess

parser = argparse.ArgumentParser(description='')
parser.add_argument('dir', help='Directory containing the run outputs.')
parser.add_argument('prefix', help='Prefix of the runs.')
parser.add_argument('N', type = int, help='Number of best runs to select.')
args = parser.parse_args()

def extractNumber(string):
    return float(string[string.index('= ') + 2:].rstrip())

loglike = {}
r = 1
while os.path.isfile(args.dir + '/' + args.prefix + '_run_' + str(r) + '_f'):
    fileName = args.prefix + '_run_' + str(r) + '_f'
    with open(args.dir + '/' + fileName) as file:
        for line in file:
            if 'Estimated Ln Prob of Data' in line:
                loglike[fileName] = extractNumber(line)
        r += 1

ordered = []
for output in sorted(loglike, key = loglike.get, reverse = True):
    ordered.append(output)

subprocess.run('mkdir ' + args.dir + '/best/', shell = True)
i = 0
while i < args.N:
    subprocess.run('cp ' + args.dir + '/' + ordered[i] + ' ' + args.dir + '/best/', shell = True)
    i += 1
