#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

library(dplyr)

ped <- read.delim(args[1],header=TRUE)

EAS <- c("CHB","JPT","CHS","CDX","KHV")
EUR <- c("CEU","TSI","FIN","GBR","IBS")
AFR <- c("YRI","LWK","GWD","MSL","ESN","ASW","ACB")
AMR <- c("MXL","PUR","CLM","PEL")
SAS <- c("GIH","PJL","BEB","STU","ITU")

anc <- list(EAS,EUR,AFR,AMR,SAS)
ancestry <- c("EAS","EUR","AFR","AMR","SAS")

for (i in 1:5){
	ids <- ped %>% filter(Population %in% anc[[i]]) %>% select(Individual.ID)
	write.table(ids,paste(ancestry[i],".ids.txt",sep=""),sep="\t",quote=FALSE,row.names=FALSE)
	}

