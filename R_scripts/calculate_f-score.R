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
otus = prune_samples(names(which(sample_sums(otus)>1)), otus)
otus_smerge = merge_samples(otus, "Analysis")
potus = transform_sample_counts(otus, function(x) 100 * x/sum(x))
potus_smerge = merge_samples(potus, "Analysis")
potus_smerge = transform_sample_counts(potus_smerge, function(x) 100 * x/sum(x))

# group lineages of the same taxonomic rank (family or genus recommended)
otus_tsmerge = tax_glom(otus_smerge, taxrank = rank)
potus_tmerge = tax_glom(potus, taxrank = rank)
potus_tsmerge = tax_glom(potus_smerge, taxrank = rank)

# select expected lineages
control_samples = as.vector(sample_data(potus_tmerge)$Sample[
  which(sample_data(potus_tmerge)$Analysis=="Expected")])
potus_exp = prune_samples(control_samples, potus_tmerge)
otus_select = names(which(taxa_sums(potus_exp)>0))
otus_pruned = prune_taxa(otus_select, potus_tsmerge)

# calculate metrics
Precision = (sample_sums(otus_pruned)/sample_sums(potus_tsmerge)*100)[-1]
Recall = (sample_sums(otus_pruned))[-1]
F.score = 2*(Precision*Recall)/(Precision+Recall)

df = data.frame(Recall, Precision, F.score)
df$id = rownames(df)
df.fi = melt(df, id="id")

# plot
print(ggplot(data=df.fi, aes(x=id, y=value, colour=variable, group=variable))
  + geom_point() 
  + theme_bw()
  + theme(axis.text.x = element_text(size=12, angle=270, hjust = 0, vjust=0.5))
  + theme(axis.text.y = element_text(size=12))
  + scale_x_discrete(name="",
                     labels=c("mapseq_gg"="MAPseq (GG)",
                              "mapseq_ncbi"="MAPseq (NCBI)",
                              "mapseq_silva"="MAPseq (SILVA)",
                              "mothur_rdp"="mothur (RDP)",
                              "mothur_silva"="mothur (SILVA)",
                              "qiime2_gg"="QIIME 2 (GG)",
                              "qiime2_silva"="QIIME 2 (SILVA)",
                              "qiime_gg"="QIIME (GG)",
                              "qiime_silva"="QIIME (SILVA)"))
  + ylab("%")
  + guides(colour=FALSE)
  + theme(legend.title = element_blank())
  + theme(axis.title.x = element_blank())
  + theme(axis.title.y = element_text(size=12))
  + theme(legend.text = element_text(size = 12))
  + ylim(0,100))