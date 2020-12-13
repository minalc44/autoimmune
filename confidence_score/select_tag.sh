#!/bin/bash

vcftools="$1"
vcf_file="$2"
id_list="$3"
plink2="$4"
prune_files_dir="$5"



#1. Extract subset of individuals/ancestries, common, bi-allelic variants
$vcftools --gzvcf $vcf_file --keep $id_list --maf 0.01 --max-alleles 2 --recode --out 1000Genomes


#2. Extract genotype data for each list of variants
for file in $prune_files_dir/*.txt
do
$vcftools --vcf 1000Genomes.recode.vcf --snps $file --recode --out $file.subset
done


#3. Choose tag SNPs (~window of 50 snps, step by 1, min R2=0.001)
for file in $prune_files_dir/*subset.recode.vcf
do
$plink2 --vcf $file --indep-pairwise 50 1 0.001 --out $file.tag
done

