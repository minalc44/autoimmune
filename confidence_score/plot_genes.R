#!/usr/bin/env Rscript
args <- commandArgs(TRUE)
library(data.table)
library(dplyr)
library(ggplot2)

d1 <- read.delim(args[1], header=TRUE,stringsAsFactors= FALSE)
n <- as.numeric(args[2])
output <- as.character(args[3])

d1 <- d1[order(d1$Conf.sc,decreasing = TRUE)[1:n],]
d1$Gene <- factor(d1$Gene, level = rev(sort(unique(d1$Gene))))
d1$Disease <- factor(d1$Disease, level=sort(unique(d1$Disease)))


ggplot(d1, aes(x=Disease, y=Gene)) +
  geom_tile(col="white",fill="white") +
  geom_point(size=1.2,shape=3,color="#d33682") +
  theme_classic() +
  xlab("") +
  ylab("") +
  scale_x_discrete(expand=c(0,0)) +
  scale_y_discrete(expand=c(0,0)) +
  theme(axis.line=element_blank(),panel.border=element_blank(),panel.grid.major=element_line(color='#eeeeee')) + 
  theme(axis.text=element_text(size=7),axis.title=element_text(size=7), legend.title = element_blank(), axis.line = element_line(colour = 'darkgray', size =0.3),legend.text = element_text(size=6)) + 
  theme(legend.key.width=unit(0.4,"cm"),legend.key.height = unit(0.3,"cm"))

ggsave(output, width = 3, height = 3.3, units = "in", pointsize = 12, dpi=600)

