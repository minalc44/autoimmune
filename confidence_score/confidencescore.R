#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
library(data.table)
library(dplyr)

d1 <- read.delim(args[1], header=TRUE,stringsAsFactors= FALSE)
output <- as.character(args[2])
d1$we <- d1$Method

## Assign weights based on type of evidence
d1 <- d1 %>% mutate (
  we <- recode(we, "eqtl" = "0.66"),
  we <- recode(we, "integrative" = "0.66"),
  we <- recode(we, "network" = "0.66"),
  we <- recode(we, "pc.damaging" = "1"),
  we <- recode(we, "func.exp" = "0.66"),
  we <- recode(we, "chr.int" = "0.66"),
  we <- recode(we, "gene.assoc" = "1"))


## Per gene total evidence score
total.ev <- function (df, d, g){
  target <- df %>% filter (Disease == d & Gene == g)
  ## Extract unique type of evidence
  target <- distinct (target, Method, .keep_all=TRUE)
  locus <- unique(target$Locus)
  ## Assign total weights based on unique type of evidence
  tot.we.ev <- sum(as.numeric(target$we))
  return(tot.we.ev)
}


## Confidence score
conf.score <- function (df, d, l, g){
  gene.ev <- df %>% filter (Disease == d & Locus == l & Gene == g)
  oth.ev <- df %>% filter (Disease == d & Locus == l & Gene != g)
  gene.sc <- as.numeric(gene.ev$Tot.we.ev)
  if (nrow(oth.ev)>0){
    max.oth <- as.numeric(max(oth.ev$Tot.we.ev))
    conf.sc <- gene.sc - max.oth
  }
  else{
    conf.sc <- gene.sc
  }
  return(conf.sc)
}


for (i in 1:nrow(d1)){
  d1$Tot.we.ev [i] <- total.ev(d1, d1$Disease[i], d1$Gene[i])
}

d1 <- d1 %>% distinct (Disease, Gene, .keep_all=TRUE)

for (i in 1:nrow(d1)){
  d1$Conf.sc [i] <- conf.score(d1, d1$Disease[i], d1$Locus[i], d1$Gene[i])
}

d1 <- d1 %>% select(Disease, Locus, Gene, Ensembl_ID, Tot.we.ev, Conf.sc)

write.table(d1, output, sep="\t",quote=FALSE,row.names=FALSE)

