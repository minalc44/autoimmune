#!/usr/bin/env Rscript
args <- commandArgs(TRUE)

#Manhattan Plot
library(data.table)
library(dplyr)
library(ggrepel)
library(ggplot2)

gwasstats <- fread(args[1],header=TRUE)
gwasstats <- as.data.frame(gwasstats)
gwasstats <- gwasstats [gwasstats$PVAL<0.01, ]
snplist <- read.delim(args[2],header=TRUE)
output <- as.character(args[3])

gwas <- gwasstats %>% 
group_by(CHR) %>% summarise(totalPOS=max(POS)) %>%
mutate(total=cumsum(as.numeric(totalPOS))-as.numeric(totalPOS)) %>% select(-totalPOS) %>%
left_join(gwasstats, ., by=c("CHR"="CHR")) %>%
arrange(CHR, POS) %>% mutate(POStotal=POS+total) %>%
mutate(is_label=ifelse(SNP %in% snplist[,1], "yes", "no"))
gwas <- merge(gwas,snplist, by="SNP", all.x=TRUE) 
xaxis <- gwas %>% group_by(CHR) %>% summarize(center=( max(total) + min(total))/2)

ggplot(gwas, aes(x=POStotal, y=-log10(PVAL))) +
geom_point(aes(color=as.factor(CHR)), size=0.1) +
scale_color_manual(values = rep(c("gray", "gray36"), 22)) +
scale_x_continuous(label = xaxis$CHR, breaks= xaxis$center ) + 
scale_y_continuous(expand = c(0,0)) + 
theme_classic() + 
xlab("") +
ylab("-Log10 P value") +
theme(legend.position="none") + 
theme(axis.text=element_text(size=8), axis.title=element_text(size=10), axis.line = element_line(colour = 'darkgray', size =0.3)) +
geom_hline(yintercept=-log10(5*10^-8), size=0.2) +
theme(axis.text.x=element_blank(), axis.ticks.x=element_blank()) +
geom_label_repel (data=subset(gwas, is_label="yes"),aes(label=Gene),size=1)

ggsave(output, width=4.3, height=1.83, units="in", pointsize=12, dpi=600)

