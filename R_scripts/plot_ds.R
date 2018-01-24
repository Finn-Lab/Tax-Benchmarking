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

# group lineages of the same taxonomic rank
otus_tsmerge = tax_glom(otus_smerge, taxrank = rank)
potus_tmerge = tax_glom(potus, taxrank = rank)
potus_tsmerge = tax_glom(potus_smerge, taxrank = rank)

# select and prune lineages
control_samples = as.vector(sample_data(potus_tmerge)$Sample[
  which(sample_data(potus_tmerge)$Analysis=="Expected")])
potus_exp = prune_samples(control_samples, potus_tmerge)
otus_select = names(which(taxa_sums(potus_exp)>0))
otus_pruned = prune_taxa(otus_select, potus_tsmerge)

# order taxa by abundance
group = "Expected"
top_group = names(sort(as.data.frame(otu_table(potus_tsmerge)[group]), TRUE))

# calculate dissimilarity scores (DS)
ori_dset = otu_table(otus_pruned)
ds_analy = matrix(0,nrow(ori_dset)-1,ncol(ori_dset))
for (i in 2:nrow(ori_dset)){
   ds_analy[i-1,] = abs((ori_dset[i,]-ori_dset["Expected",])/ori_dset["Expected",])
}
row.names(ds_analy) = row.names(ori_dset)[2:nrow(ori_dset)]
colnames(ds_analy) = colnames(ori_dset)
ds_otus = otu_table(ds_analy, taxa_are_rows = FALSE)
ds_tax = tax_table(otus_pruned)
ds_phy = phyloseq(ds_otus, ds_tax)

# plot heatmap with DS
plot(plot_heatmap(ds_phy, taxa.label = "Genus", taxa.order=top_group, sample.order=rownames(ds_analy))
     + coord_flip()
     + scale_fill_continuous(name = "DS", high = "#000033", low = "#81a5ca", na.value="grey",
                            limits=c(0,3), breaks= c(0.0,1.0,2.0,3.0), labels=c("0.0", "1.0", "2.0", "3.0"))
     + theme(axis.text.y = element_text(face="plain", size=12, hjust = 1, vjust=0.5))
     + theme(axis.title.x = element_blank())
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
     + theme(axis.title.y = element_blank())
     + theme(legend.position="left"))
