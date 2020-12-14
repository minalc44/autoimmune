## GWAS Simulation
This is the repository for GWAS simulation and credible SNP set calculation\
All R scripts were written in R version 3.3.3


### Identify credible SNP set variants in each significant locus
cc (or quant) is the type of GWAS phenotype\
40266 specifies the sample size\
0.30 is the proportion of cases to total sample size

```
Rscript --vanilla extract_crediblesnps.R /path/to/Locus.txt cc 40266 0.30 /path/to/CredibleSNPSet.txt
```


### Extract 1000 Genomes subject IDs of each ancestry population
download 1000 genomes pedigree file

```
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_g1k.ped

Rscript --vanilla 1000genoms_ids.R /path/to/20130606_g1k.ped
```


### Extract 1000 Genomes haplotypes and allele frequencies
make sure tabix, vcftools, plink2 are installed in your environment\
1000 Genomes datasets can be found at ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/

```
bash 1000genomes_haps.sh /path/to/tabix ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz /path/to/vcftools /path/to/EUR.ids.txt /path/to/plink2 EUR.final EUR_AF
```


### GWAS simulation in select locus
snp is the specified causal variant

```
Rscript --vanilla simulate_gwas.R /path/to/1000GHaps_EUR.haps.gz snp /path/to/EUR.AF.afreq /path/to/EUR_SimulationResult.txt
```