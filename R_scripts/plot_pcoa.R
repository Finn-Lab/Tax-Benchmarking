# load necessary libraries
library("phyloseq")
library("ggplot2")
library("scales")
library("grid")
library("vegan")
library("ape")
library("RColorBrewer")
library("data.table")

# load input files (biom, metadata) and merge them into a phyloseq object
biom_file = import_biom("benchm_biome.biom")
colnames(tax_table(biom_file)) = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus")
metadata_file = import_qiime_sample_data("metadata.tab")
otus_in = merge_phyloseq(biom_file, metadata_file)

# define taxonomic rank
rank = "Genus"

# add unclassified sequences
otu_df = otu_table(otus_in)
unclass_otu = rep(0,ncol(otu_df))
miss_id = which(sample_data(otus_in)$Tool=="QIIME")
for (i in miss_id){
  unclass_otu[i] = sum(otu_df[,gsub('_qiime.*', '_exp', colnames(otu_df[,i]))])-sum(otu_df[,i])
}
miss_id = which(sample_data(otus_in)$Database=="NCBI")
for (i in miss_id){
  unclass_otu[i] = sum(otu_df[,gsub('_mapseq_ncbi', '_exp', colnames(otu_df[,i]))])-sum(otu_df[,i])
}
ren = rbind(otu_df, unclass_otu)
rownames(ren) = c(rownames(ren)[1:nrow(ren)-1], "0")
otu_fi = otu_table(ren, taxa_are_rows = TRUE)
tax_df = tax_table(otus_in)
unclass_tax = c("Unclass", rep(" ", ncol(tax_df)-1))
ren = rbind(tax_df, unclass_tax)
rownames(ren) = c(rownames(ren)[1:nrow(ren)-1], "0")
tax_fi = tax_table(ren, unclass_tax)
newphylo = phyloseq(otu_fi, tax_fi)
otus = merge_phyloseq(newphylo, metadata_file)

# prepare tables (counts, percentages, ind, merged)
vari1 = as.character(get_variable(otus, "Patient"))
vari2 = as.character(get_variable(otus, "Analysis"))
sample_data(otus)$NewPastedVar = mapply(paste, vari1, vari2, sep="_")
otus_smerge = merge_samples(otus, "NewPastedVar")

# group OTUs of the same taxonomic rank (family or genus recommended)
otus_tsmerge = tax_glom(otus_smerge, taxrank = rank)
analy = levels(sample_data(otus)$Analysis)
pati = levels(sample_data(otus)$Patient)
tools = levels(sample_data(otus)$Tool)
db = levels(sample_data(otus)$Database)
sample_data(otus_smerge)$Analysis = factor(sample_data(otus_smerge)$Analysis, labels = analy)
sample_data(otus_smerge)$Patient = factor(sample_data(otus_smerge)$Patient, labels = pati)
sample_data(otus_smerge)$Tool = factor(sample_data(otus_smerge)$Tool, labels = tools)
sample_data(otus_smerge)$Database = factor(sample_data(otus_smerge)$Database, labels = db)
sample_data(otus_tsmerge)$Analysis = factor(sample_data(otus_tsmerge)$Analysis, labels = analy)
sample_data(otus_tsmerge)$Patient = factor(sample_data(otus_tsmerge)$Patient, labels = pati)
sample_data(otus_tsmerge)$Tool = factor(sample_data(otus_tsmerge)$Tool, labels = tools)
sample_data(otus_tsmerge)$Database = factor(sample_data(otus_tsmerge)$Database, labels = db)

# plot PCoA
pcoa_dset = ordinate(otus_tsmerge, method="PCoA", distance="bray") # prepare distance matrix with PCoA or NMDS (default: bray)
print(plot_ordination(otus_tsmerge, pcoa_dset, color = "Tool", shape = "Database") 
      + scale_shape_manual(values=c(19,17,15,4,5))
      + theme_bw()
      + facet_wrap(~Patient, ncol=4)
      + geom_point(size=1)
      + theme(legend.title = element_blank(), legend.position="right")
      + theme(strip.background=element_rect(fill=NA, color=NA),
              strip.text=element_text(size=12)))
