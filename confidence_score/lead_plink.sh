#!/bin/bash

vcftools="$1"
vcf_file="$2"
id_list="$3"
plink="$4"
gwas_file="$5"


#1. Extract subset of individuals/ancestries, common, bi-allelic variants
$vcftools --gzvcf $file --keep $id_list --maf 0.01 --max-alleles 2 --recode --out $file


#2. Convert vcf to plink format
$plink2 --vcf $file --make-bed --out $file


#3. Use LD based clumping (clump-p1 = 0.00000005, clump-r2 = 0.001, clump-kb = 500)
$plink --vcf $file --clump $gwas_file --clump-snp-field variant_id --clump-field p_value --clump-p1 0.00000005 clump-r2 0.001 clump-kb 500 --out $file.ld.based


#4. Use distance based clumping (clump-p1 = 0.00000005, clump-r2 = 0, clump-kb = 500)
$plink --vcf $file --clump $gwas_file --clump-snp-field variant_id --clump-field p_value --clump-p1 0.00000005 clump-r2 0 clump-kb 500 --out $file.dist.based


