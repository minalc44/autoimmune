## Causal gene confidence score
This is the repository for prioritizing disease relevant genes based on genome-wide and locus-specific fine-mapping evidence


### Extract gencode gene TSS
Download gencode gtf file: ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_36/GRCh37_mapping/gencode.v36lift37.annotation.gtf.gz

```
python parse.gencode.py -i gencode.v36lift37.annotation.gtf.gz -o gencodeTSS.grch37.txt
```


### Extract lead SNP per locus using 1000 genomes data
make sure tabix, vcftools, plink2 are installed in your environment\
1000 Genomes datasets can be found at ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/

```
bash lead_plink.sh /path/to/vcftools ALL.chr20.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz /path/to/EUR.ids.txt /path/to/plink2 /path/to/gwas.txt
```

### Select tag SNPs

```
bash select_tag.sh /path/to/vcftools ALL.chr20.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz /path/to/EUR.ids.txt /path/to/plink2 /path/to/prune_files_dir/
```



### Find chromosome cytobands of lead variants
To download cytoband files, see the UCSC Table Browser https://genome.ucsc.edu/cgi-bin/hgTables, select Group="All Tables" and Table="cytoBand".

```
Rscript --vanilla cytoband.R /path/to/SNPs.txt /path/to/cytoband_hg19.txt /path/to/output.txt
```


### Calculate causal gene confidence score
/path/to/GeneEvidence.txt is a table, with the following columns - other columns may be present these are essential: 
- Disease
- Locus
- Gene
- Method

/path/to/ConfidenceScore.txt is the output table, with the following columns
- Disease
- Locus
- Gene
- Tot.we.ev (total weighted evidence supporting each gene)
- Conf.sc (causal gene confidence score)

```
Rscript --vanilla confidencescore.R /path/to/GeneEvidence.txt /path/to/ConfidenceScore.txt
```



