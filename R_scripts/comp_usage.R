# load necessary libraries
library(reshape2)
library(ggplot2)

Sys.setlocale('LC_ALL','C') # correct warning message

# plot cpu time
cpu.mapseq1 = (20048.72/60)/60
cpu.mapseq2 = (20704.52/60)/60
cpu.mapseq3 = (21630.30/60)/60
cpu.mapseq = mean(cpu.mapseq1, cpu.mapseq2, cpu.mapseq3)
sd.cpu.mapseq = sd(c(cpu.mapseq1, cpu.mapseq2, cpu.mapseq3))

cpu.mothur1 = ((47.30+18.93+2433.84+609.97+416.95+50.20+0.13+28.17+0.20+42.63+13.20+2106.37+588.98)/60)/60
cpu.mothur2 = ((72.80+20.99+2355.31+575.95+414.56+48.17+0.13+15.55+0.23+44.86+14.47+2307.82+639.43)/60)/60
cpu.mothur3 = ((53.09+15.69+2310.90+599.05+469.67+46.14+0.13+28.14+0.25+56.11+13.94+2307.02+557.03)/60)/60
cpu.mothur = mean(cpu.mothur1, cpu.mothur2, cpu.mothur3)
sd.cpu.mothur = sd(c(cpu.mothur1, cpu.mothur2, cpu.mothur3))

#cpu.qiime1.1 = (160.27/60)/60 # SILVA 97%
#cpu.qiime1.2 = (87.86/60)/60 # SILVA 97%
#cpu.qiime1.3 = (93.75/60)/60 # SILVA 97%
cpu.qiime1.1 = (397.87/60)/60 # SILVA 99%
cpu.qiime1.2 = (431.05/60)/60 # SILVA 99%
cpu.qiime1.3 = (493.00/60)/60 # SILVA 99%
cpu.qiime = mean(cpu.qiime1.1, cpu.qiime1.2, cpu.qiime1.3)
sd.cpu.qiime = sd(c(cpu.qiime1.1, cpu.qiime1.2, cpu.qiime1.3))

cpu.qiime2.1 = ((69.55+39050.95)/60)/60
cpu.qiime2.2 = ((55.10+38226.38)/60)/60
cpu.qiime2.3 = ((67.38+40246.38)/60)/60
cpu.qiime2 = mean(cpu.qiime2.1, cpu.qiime2.2, cpu.qiime2.3)
sd.cpu.qiime2 = sd(c(cpu.qiime2.1, cpu.qiime2.2, cpu.qiime2.3))

cpu.df = data.frame(cpu.qiime2, cpu.qiime, cpu.mothur, cpu.mapseq)
cpu.df = melt(cpu.df)
cpu.df = cbind(cpu.df, c(sd.cpu.qiime2, sd.cpu.qiime, sd.cpu.mothur, sd.cpu.mapseq))
colnames(cpu.df) = c("variable", "value", "sd")

# plot bargraph cpu time
print(ggplot(cpu.df, aes(x=variable, y=value))
      + geom_bar(stat="identity", fill="darkgray", alpha=0.7, colour="black", size=0.2)
      + geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=0.5, alpha=0.7)
      + scale_x_discrete(labels=c("cpu.qiime2"="QIIME 2","cpu.qiime"="QIIME",
                                  "cpu.mothur"="mothur", "cpu.mapseq"="MAPseq"))
      + theme_bw() + coord_flip()
      + ylab("CPU time (h)")
      + ylim(0,12)
      + theme(axis.text.x = element_text(face="plain", size=12))
      + theme(axis.text.y = element_text(face="plain", size=12))
      + theme(axis.title.y = element_blank())
      + theme(axis.title.x = element_text(size=14)))

# plot memory usage
mem.mapseq1 = (2743)/1024
mem.mapseq2 = (2744)/1024
mem.mapseq3 = (2747)/1024
mem.mapseq = mean(mem.mapseq1, mem.mapseq2, mem.mapseq3)
sd.mem.mapseq = sd(c(mem.mapseq1, mem.mapseq2, mem.mapseq3))

mem.mothur1 = (476+607+88188+3386+13316+74+8+443+5+88188+3099)/1024
mem.mothur2 = (475+626+88164+3456+13300+309+10+418+67+88188+3239)/1024
mem.mothur3 = (451+630+88172+3447+13316+68+9+494+630+88188+3182)/1024
mem.mothur = mean(mem.mothur1, mem.mothur2, mem.mothur3)
sd.mem.mothur = sd(c(mem.mothur1, mem.mothur2, mem.mothur3))

#mem.qiime1.1 = (16462)/1024 # SILVA 97%
#mem.qiime1.2 = (18761)/1024 # SILVA 97%
#mem.qiime1.3 = (15171)/1024 # SILVA 97%
mem.qiime1.1 = (41550)/1024 # SILVA 99%
mem.qiime1.2 = (41554)/1024 # SILVA 99%
mem.qiime1.3 = (41565)/1024 # SILVA 99%
mem.qiime = mean(mem.qiime1.1, mem.qiime1.2, mem.qiime1.3)
sd.mem.qiime = sd(c(mem.qiime1.1, mem.qiime1.2, mem.qiime1.3))

mem.qiime2.1 = (1677+72885)/1024
mem.qiime2.2 = (1709+75273)/1024
mem.qiime2.3 = (1714+75150)/1024
mem.qiime2 = mean(mem.qiime2.1, mem.qiime2.2, mem.qiime2.3)
sd.mem.qiime2 = sd(c(mem.qiime2.1, mem.qiime2.2, mem.qiime2.3))

mem.df = data.frame(mem.qiime2, mem.qiime, mem.mothur, mem.mapseq)
mem.df = melt(mem.df)
mem.df = cbind(mem.df, c(sd.mem.qiime2, sd.mem.qiime, sd.mem.mothur, sd.mem.mapseq))
colnames(mem.df) = c("variable", "value", "sd")

# plot bargraph mem usage
print(ggplot(mem.df, aes(x=variable, y=value))
      + geom_bar(stat="identity", fill="darkgray", alpha=0.8, colour="black", size=0.2)
      + geom_errorbar(aes(ymin=value-sd, ymax=value+sd), width=0.5, alpha=0.7)
      + scale_x_discrete(labels=c("mem.qiime2"="QIIME 2","mem.qiime"="QIIME",
                                  "mem.mothur"="mothur", "mem.mapseq"="MAPseq"))
      + theme_bw() + coord_flip()
      + ylab("Memory usage (GB)")
      + theme(axis.text.x = element_text(face="plain", size=12))
      + theme(axis.text.y = element_text(face="plain", size=12))
      + theme(axis.title.y = element_blank())
      + theme(axis.title.x = element_text(size=14)))