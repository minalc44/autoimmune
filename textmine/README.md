# PubMed text mining
This is the repository for PubMed text mining project\
All scripts were written in Python 2


## Usage

### 1. Download PubMed xml files
-baseline specifies whether annual baseline xml files should be downloaded\
-updatefiles specifies whether daily released xml files should be downloaded

```
python downloadxml.py -d /path/to/download_directory -baseline true -updatefiles true
```


### 2. Parse PubMed xml files and retrieve all abstracts that include at least one of the search terms in the searchterms.txt file
-d specifies the date of running the script\
-r specifies whether output files with the same prefix should be re-analyzed

```
python parsesearch.py -d 20200112 -r true -n outputfile_prefix -t searchterms.txt -wd /path/to/working_directory -xd /path/to/xml_directory
```


### 3. Retrieve abstracts that include specific combinations of the terms in the searchterms.txt file
-d specifies the date of running the script\
-i specifies input file, which corresponds to the output file from Step #2\
-first specifies the list of first category search terms; terms must be enclosed in double quotes and separated by comma\
-second specifies the list of second category search terms; terms must be enclosed in double quotes and separated by comma

```
python termmatch.py -wd /path/to/working_directory  -d 20200112 -i /path/to/inputfile.txt -first "genome-wide association,GWAS" -second "functional,causal,mechanisms,causative,mechanism,mechanistic"
```

### 4. Filter to retrieve abstracts that include at least one of the phenotypes in phenotype file
-d specifies the date of running the script\
-r specifies whether output files with the same prefix should be re-analyzed\
-i specifies input file, which corresponds to the output file from Step #3

```
python diseasefilter.py -d 20200112 -r true -n outputfile_prefix -t /path/to/phenotypes.txt -wd /path/to/working_directory -xd /path/to/xml_directory -i /path/to/inputfile.txt
```
