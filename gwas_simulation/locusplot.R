#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

#LocusZoom Plot
library(data.table)
library(dplyr)
library(ggplot2)

gwas <- fread(args[1],header=TRUE)
snp <- as.character(args[2])
pairwiseld <- read.delim(args[3],header=TRUE)
output <- as.character(args[4])

lead <- gwas %>% filter (SNP==snp)
pos1 <- lead$POS-50000
pos2 <- lead$POS+50000
gwas <- gwas[gwas$CHR==lead$chr & gwas$POS>pos1 & gwas$POS<pos2 & gwas$MAF>0.1, ]

gwas <- merge(gwas,pairwiseld, by="SNP", all.x=TRUE) 
gwas$ldcol <- "#3B9AB2"
gwas$ldcol[gwas$SNP==snp] <- "black"
gwas$ldcol[gwas$LD>0.8] <- "#F21A00"
gwas$ldcol[gwas$LD>0.6 & gwas$LD<0.8] <- "#E58601"
gwas$ldcol[gwas$LD>0.4 & gwas$LD<0.6] <- "#EBCC2A"
gwas$ldcol[gwas$LD>0.2 & gwas$LD<0.4] <- "#DCDCDC"
gwas$ldsh <- 16
gwas$ldsh[gwas$SNP==snp] <- 21

ggplot(gwas, aes(x=POS/1000000, y=-log10(PVAL))) +
geom_point(size=1.1, shape=as.numeric(ldsh), col=gwas$ldcol, fill=gwas$ldcol) +
theme_classic() + 
ggtitle("") +
xlab("") +
ylab("-Log10 P value") +
theme(legend.position="none") + 
theme(axis.text=element_text(size=8), axis.title=element_text(size=10), axis.line = element_line(colour='darkgray', size=0.3)) +
geom_hline(yintercept=-log10(5*10^-8), size=0.2)

ggsave(output, width=3.0, height=1.8, units="in", pointsize=12, dpi=600)

