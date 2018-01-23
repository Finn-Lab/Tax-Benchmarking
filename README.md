# random_species.py

Python script for randomly selecting a set number of species from a taxonomy file.

Requires Python 2.7

<b>Usage:</b>

> python random_select.py -i tax.file -s [number of species] -m [max species per genera]

Options:  
-h, --help      show this help message and exit  
-i  TAX         Input taxonomy file (see below for example)  
-s  SPECIES     Number of species to select    
-m  MAXSPECIES  Maximum number of species allowed per genera  

# mutate_seqs.py

Python script for generating simulated sequence data with a certain percentage of nucleotide substitutions. 

Requires Python 2.7 and BioPython.

<b>Usage:</b>
> python mutate_seqs.py -i [in.fasta] -p [perc]

Options:  
-h, --help	show this help message and exit  
-i FASTA		Input FASTA file  
-p PERC			Nucleotide diversity (in %)  
