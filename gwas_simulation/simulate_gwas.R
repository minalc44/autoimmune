#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

library(data.table)
library(dplyr)
library(stringr)
library(simGWAS)
library(coloc)

haps <- fread(args[1],header=FALSE)
haps <- as.data.frame(haps)
snp <- as.character(args[2])
af <- read.delim(args[3],header=TRUE)
output <- as.character(args[4])

#Haplotypes need not be unique for simGWAS
snps <- haps$V2
haps <- haps[,-c(1:5)]
haps <- t(haps)
colnames(haps) <- snps
freq <- as.data.frame(haps+1)
freq$Probability <- 1/nrow(freq)
sum(freq$Probability)

af$MAF <- af$ALT_FREQS
ch <- which(af$MAF>0.5)
af$MAF[ch] <- 1-af$MAF[ch]

#Simulate GWAS Summary Statistics
CV <- snp
oddsratio <- c(1.1,1.2,1.3)
size <- c(5000,25000)

result <- matrix(NA)
for (i in 1:length(oddsratio)){
	g1 <- oddsratio[i]
	for (j in 1:length(size)){
		ssize <- size[j]
		FP <- make_GenoProbList(snps=snps,W=CV,freq=freq)
		zsim <- simulated_z_score(N0=ssize, N1=ssize, snps=snps, W=CV, gamma.W=log(g1), freq=freq, GenoProbList=FP, nrep=1000)
		psim <- 2*pnorm(-abs(zsim))
		simabf <- matrix(NA)
		for (k in 1:1000){
			pexp <- psim[k,]
			abfm <- coloc:::approx.bf.p(p=pexp, f=af$MAF, type="cc", N=ssize*2, s=0.5)
			abfm$snp=snps
			abfm$ABF <- 10^(abfm$lABF)
			ABFsum <- sum(abfm$ABF)
			abfm$PPi <- abfm$ABF/ABFsum
			abfm <- abfm[order(abfm$PPi, decreasing=TRUE),]
			PPi_sum = 0
			abfm$PPi_sum = 0
			for (o in 1:nrow(abfm)) {
				PPi_sum = PPi_sum+abfm$PPi[o]
				abfm$PPi_sum[o] = PPi_sum
				}
				cr95 = abfm[1:min(which(abfm[,"PPi_sum"] >= 0.95)), ]
				cmin = CV==snps[which(pexp==min(pexp))]
				simabf = paste(g1,2*ssize,nrow(cr95),cmin,k)
				result = rbind(result,simabf)
				}
				}	
				}
				
result <- as.data.frame(result[-1,])

write.table(result, output, sep="\t",quote=FALSE,row.names=FALSE,col.names=FALSE)

