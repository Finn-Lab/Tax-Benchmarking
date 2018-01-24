Taxonomy benchmarking project
=============================

Scripts accompanying our manuscript on benchmarking taxonomy tools and databases.

Requirements:
* Python 2.7
* BioPython
* R version 3.4.1
* R libraries: ggplot2, phyloseq, vegan, scales, grid, ape, RColorBrewer, data.table 

## random_species.py

Python script for randomly selecting a set number of species from a taxonomy file.

<b>Usage:</b>
```
python random_species.py -i [tax.file] -s [number of species] -m [max species per genera]
```
Options:  
-h, --help; show this help message and exit  
-i  TAX; Input taxonomy file (see example below)  
-s  SPECIES; Number of species to select    
-m  MAXSPECIES; Maximum number of species allowed per genera

The taxonomy file should consist of two columns: the first with the sequence identifier and the second with the full taxonomy lineage.

e.g.
```
AWVO01000035.3882.5400	sk__Bacteria;k__;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Oscillospiraceae;g__Oscillibacter;s__Oscillibacter_sp._KLE_1745
ADLK01000048.472.1991	sk__Bacteria;k__;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__Lachnoclostridium;s__[Clostridium]_citroniae
CVPA01000001.8833.10362	sk__Bacteria;k__;p__Firmicutes;c__Bacilli;o__Bacillales;f__Bacillaceae;g__Bacillus;s__Bacillus_sp._Co1-6
KM360064.1.1408	sk__Bacteria;k__;p__Bacteroidetes;c__Bacteroidia;o__Bacteroidales;f__Porphyromonadaceae;g__Porphyromonas;s__Porphyromonas_katsikii
JUZZ01000099.289.1808	sk__Bacteria;k__;p__Proteobacteria;c__Gammaproteobacteria;o__Pasteurellales;f__Pasteurellaceae;g__Haemophilus;s__Haemophilus_parainfluenzae
ADCW01000016.45.1587	sk__Bacteria;k__;p__Firmicutes;c__Negativicutes;o__Veillonellales;f__Veillonellaceae;g__Veillonella;s__Veillonella_sp._6_1_27
```
## mutate_seqs.py

Python script for generating simulated sequence data with a certain percentage of nucleotide substitutions. 

<b>Usage:</b>
```
python mutate_seqs.py -i [in.fasta] -p [perc]
```
Options:  
-h, --help; show this help message and exit  
-i FASTA; Input FASTA file  
-p PERC; Base substitutions (in %)

## R scripts

* plot_ds.R : calculate dissimilarity scores and plot heatmap
* plot_f-score.R : calculate recall, precision and F-scores and plot scatterplot
* plot_pcoa.R : plot principal coordinates analysis (PCoA)
* plot_stack.R : plot stacked histogram with predicted genera
* plot_usage.R : plot bargraph with computational cost
