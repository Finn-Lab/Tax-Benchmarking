#!/usr/bin/env python

import argparse
import random
import sys

def main(args):
    gdone = {}
    sdone = set()
    sel = []

    for line in open(args.tax, "r"):
        line = line.strip("\n")
        columns = line.split("\t")
        taxonomy = columns[-1].split(";")
        king = taxonomy[0].split("__")[-1]
        family = taxonomy[5].split("__")[-1]
        genus = taxonomy[6].split("__")[-1]
        species = taxonomy[7].split("__")[-1]
        # if lineage contains family, genus and species info and belongs to bacteria
	if species and species not in sdone and king == "Bacteria"\
        and genus and family and "ales" not in family:
            sdone.add(species)
            if genus not in gdone.keys():
                gdone[genus] = 1
                sel.append(line)
            else:
                gdone[genus] += 1
                # if there are fewer than the max number of species
                if gdone[genus] <= int(args.maxspec):
                    sel.append(line)

    # randomly select a set number of species
    rsel = random.sample(sel, int(args.species))
    for ele in rsel:
        print ele

# parse arguments
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Randomly select taxonomic lineages')
    parser.add_argument('-i', dest='tax', help='Input taxonomy file')
    parser.add_argument('-s', dest='species', help='Number of species', type=int)
    parser.add_argument('-m', dest='maxspec', help='Maximum number of species per genera', type=int)
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit()
    else:
        args = parser.parse_args()
        main(args)
