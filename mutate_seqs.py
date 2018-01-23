#!/usr/bin/env python2

import sys
import argparse
import Bio
from Bio import SeqIO
import random
from random import choice

# create tuple with header and seq
def fasta_gen(fasta_file):
    f_file = open(fasta_file)
    for record in SeqIO.parse(f_file, "fasta"):
        yield record.id, record.seq

# generate mutated sequence
def main(fasta_file, mutation_freq):
    for header, seq in fasta_gen(fasta_file):
        seq = list(seq)
	length = len(seq)
	pos = range(len(seq))
	muts = int(round(float(mutation_freq)/100*length))
	mutpos = random.sample(pos, muts)
        for i, s in enumerate(seq):
            if i in mutpos:
                seq[i] = choice([x for x in "ACTG" if x != s.upper()])
        print ">%s\n%s" % (header, "".join(seq))

# parse arguments
if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='Substitute bases at a certain percentage')
        parser.add_argument('-i', dest='fasta', help='Input FASTA file')
	parser.add_argument('-p', dest='perc', help='Base substitutions (%%)', type=int)
        if len(sys.argv) == 1:
                parser.print_help()
                sys.exit()
        else:
                args = parser.parse_args()
    		main(args.fasta, args.perc)
