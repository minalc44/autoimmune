import gzip
import argparse
from collections import defaultdict


def main(args):

    with gzip.open(args.input_file, 'rb') as infile:
        with open(args.output_file, 'w') as outfile:
            for line in infile:
                temp = line.strip('\n').split('\t')
                if line[0] != '#':
                    if temp[2] == 'gene':
                        start = temp[3]
                        end = temp[4]
                        strand = temp[6]                    
                        for element in temp[-1].split(';'):
                            if 'gene_name ' in element:
                                hugo_gene = element.split(' ')[-1].replace('"','')
                            if 'gene_id ' in element:
                                ensembl_gene = element.split(' ')[-1].replace('"','')
                            if 'gene_type ' in element:
                                coding_status = element.split(' ')[-1].replace('"','')
                        if strand == '+':
                            tss = str(int(start) + 1)
                        if strand == '-':
                            tss = str(int(end) - 1)
                        outfile.write('\t'.join([hugo_gene, ensembl_gene, start, end, strand, coding_status, tss]) + '\n')


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_file", action="store", dest="input_file")
    parser.add_argument("-o", "--output_file", action="store", dest="output_file")
    args = parser.parse_args()
    main(args)

