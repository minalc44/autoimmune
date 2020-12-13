#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

#Extract Lead SNP Per Locus
library(data.table)
library(dplyr)

gwas <- fread(args[1],header=TRUE,stringsAsFactors=FALSE)
gwas <- as.data.frame(gwas)
sig_p <- as.numeric(args[2])
distance <- as.numeric(args[3])
output <- as.character(args[4])

# Prune by distance
sig_gwas <- gwas[gwas$PVAL<sig_p,]
sig_gwas <- sig_gwas[order(sig_gwas$PVAL),]

final <- matrix(NA,nrow=1,ncol=8)
for (i in 1:length(unique(sig_gwas$CHR))){
  chr <- unique(sig_gwas$CHR)[i]
  pos <- unique(sig_gwas$POS)[i]
  target <- sig_gwas %>% filter (CHR==chr)
  for (j in 1:nrow(target)){
    lead_snp <- target$SNP[1]
    lead_chr <- target$CHR[1]
    lead_pos <- target$POS[1]
    lead_pval <- target$PVAL[1]
    if (!is.na(lead_snp)){
      inc <- which(abs(target$POS-target$POS[1])>distance)
      exc <- which(abs(target$POS-target$POS[1])<distance)
      exc_snp <- target$SNP[exc]
      exc_chr <- target$CHR[exc]
      exc_pos <- target$POS[exc]
      exc_pval <- target$PVAL[exc]
      final <- rbind(final,cbind(lead_snp,lead_chr,lead_pos,lead_pval,exc_snp,exc_chr, exc_pos,exc_pval))
      target <- target[inc,]
    }
  }
}

final <- as.data.frame(final[-1,])
final$lead_pos <- as.numeric(as.character(final$lead_pos))
final$exc_pos <- as.numeric(as.character(final$exc_pos))
final$lead_pval <- as.numeric(as.character(final$lead_pval))
final$exc_pval <- as.numeric(as.character(final$exc_pval))

# Check overlapping loci
final$ch="NA"
for (j in 1:22){
  tar <- final %>% filter (lead_chr==j)
  if (nrow(tar)>0){
    for (i in 1: nrow(tar)){
      snp <- tar$exc_snp[i]
      dist1 <- abs(tar$exc_pos[i]-tar$lead_pos[i])
      dist2 <- abs(tar$exc_pos[i]-tar$lead_pos)
      pexc <- tar$exc_pval[i]
      pori <- tar$lead_pval[which(dist2==min(dist2))][1]
      sori <- tar$lead_snp[which(dist2==min(dist2))][1]
      if (dist1>min(dist2) & pori>pexc){
        final$ch[match(snp,final$exc_snp)] <- as.character(sori)
        final$ch[match(sori,final$lead_snp)] <- as.character(sori)
      }		
    }
  }
}
final.cl <- final %>% filter (ch=="NA")
final.ch <- final %>% filter (ch!="NA")
if (nrow(final.ch)>0){
  final.up <- matrix(NA,ncol=ncol(final.ch),nrow=1)
  colnames(final.up)=colnames(final.ch)
  for (i in 1:length(unique(final.ch$ch))){
    tar <- final.ch %>% filter (ch == unique(final.ch$ch)[i])
    nl <- tar %>% filter (exc_pval == min(tar$exc_pval))
    if (max(tar$exc_pos)-min(tar$exc_pos)<distance){
      tar$lead_snp <- nl$exc_snp
      tar$lead_pos <- nl$exc_pos
      tar$lead_pval <- nl$exc_pval
    }
    final.up <- rbind(final.up,tar)
  }
  total <- rbind(final.cl[,-9], final.up[-1,-9])
} else {
  total <- final.cl[,-9]
}

write.table(total, output, sep="\t",quote=FALSE,row.names=FALSE)

