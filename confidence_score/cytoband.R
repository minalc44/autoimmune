#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
library(data.table)
library(dplyr)

# SNP list
d1 <- read.delim(args[1], header=TRUE, stringsAsFactors= FALSE)

# Cytoband data downloaded from UCSC
d2 <- read.delim(args[2], header=TRUE, stringsAsFactors= FALSE)

output <- as.character(args[3])


d1$Chr <- paste("chr",d1$Chr,sep="")
d2$name <- paste(d2$chrom,d2$name,sep="")

for (i in 1:nrow(d1)){
	target <- d2 %>% filter (d1$Chr[i]==d2$chrom & d1$Pos[i]>d2$chromStart & d1$Pos[i]<d2$chromEnd) %>% select (name)
	d1$Cytoband[i] <- target$name
	}
	
d1$Cytoband <- gsub("chr","", d1$Cytoband)

write.table(d1, output, sep="\t",quote=FALSE,row.names=FALSE)

