#!/bin/bash

tabix="$1"
vcf_file="$2"
vcftools="$3"
id_list="$4"
plink2="$5"
haps_file="$6"
af_file="$7"
ld_file="$8"


#Download locus of interest from the 1000 Genomes ftp site
$tabix -h $vcf_file 1:172837910-172937910  > 1000Genomes.vcf

#Extract subset of individuals/ancestries, common, bi-allelic variants
$vcftools --vcf 1000Genomes.vcf --keep $id_list --maf 0.01 --max-alleles 2 --recode --out 1000Genomes

#Convert vcf to haplotype format
$plink2 --vcf 1000Genomes.recode.vcf --export haps --out $haps_file

#Extract allele frequencies
$plink2 --vcf 1000Genomes.recode.vcf --freq --out $af_file

#Extract pairwise LD
$vcftools --vcf 1000Genomes.recode.vcf --hap-r2 --ld-window-bp 500000 --out $ld_file


