#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

library(data.table)
library(dplyr)
library(coloc)

locus <- fread(args[1],header=TRUE)
locus <- as.data.frame(locus)
gwastype <- as.character(args[2])
ssize <- as.numeric(args[3])
prcase <- as.numeric(args[4])
output <- as.character(args[5])

locus$abfm <- coloc:::approx.bf.p(p=locus$PVAL, f=locus$MAF, type=gwastype, N=ssize*2, s=prcase)

#Extract 95% Credible Set of SNPs
locus$abf <- 10^(locus$abfm)
ABFsum <- sum(locus$abf)
locus$PPi <- locus$abf/ABFsum
locus <- locus[order(locus$PPi, decreasing=TRUE),]
PPi_sum = 0
locus$PPi_sum = 0
for (i in 1:nrow(locus)) {
    PPi_sum = PPi_sum+locus$PPi[i]
    locus$PPi_sum[i] = PPi_sum
}
cr95 <- locus[which(locus$PPi_sum>0.95)[1], ]

write.table(cr95, output, sep="\t", quote=FALSE, row.names=FALSE)


