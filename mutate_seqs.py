#!/usr/bin/env python2

import random
from random import choice
import sys
from itertools import groupby
import argparse

# create tuple from fasta file
def fasta_gen(fasta_file):
    f_file = open(fasta_file)
    faiter = (x[1] for x in groupby(f_file, lambda line: line[0] == ">"))
    for header in faiter:
        header = header.next()[1:].strip()
        seq = "".join(s.strip() for s in faiter.next())
        yield header, seq

# generate mutations on seqs
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

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='Substitute bases at a certain percentage')
        parser.add_argument('-i', dest='fasta', help='Input FASTA file')
	parser.add_argument('-p', dest='perc', help='Nucleotide diversity (%%)', type=int)
        if len(sys.argv) == 1:
                parser.print_help()
                sys.exit()
        else:
                args = parser.parse_args()
    		main(args.fasta, args.perc)
