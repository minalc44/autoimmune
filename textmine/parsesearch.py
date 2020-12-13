import argparse
import glob
from collections import defaultdict
import gzip
import re
import os


def correlate(name, phenotype_infile, xd, wd, recorrelate):
    abstract_files = glob.glob(xd+'*.xml.gz')
    correlated = glob.glob(xd+'*'+name+'_pubmed_correlation_hits_regex.txt')

    if recorrelate == 'true':
        tocorrelate = abstract_files
    if recorrelate == 'false':
        tocorrelate = []
        for a in abstract_files:
            found = 0
            for c in correlated:
                if a.split('\\')[-1].split('.')[0] == c.split('\\')[-1].split('.')[0]:
                    found = 1
            if found == 0:
                tocorrelate.append(a)

    phenotypes = []
    with open(wd+phenotype_infile, 'rU') as phenotype_file:
        for line in phenotype_file:
            line = line.lower().strip('\n')
            try:
                phenotypes.append(line)
            except IndexError:
                pass

    for a in tocorrelate:
        print a
        puberrator_output = []
        outputfile = open(a+name+'_pubmed_correlation_hits_regex.txt','w')
        print 'the output has been written to the following location: ', a+name+'_pubmed_correlation_hits_regex.txt'
        outputfile.write('Input List\tPMID\tPublicationDate\tMatch #\tMatching terms\tArticle Title\n')

        abstract_file = gzip.open(a, 'rb')
        abstracts = abstract_file.read().split('<PubmedArticle>')
        abstract_file.close()
        for record in abstracts:
            matches = []
            hit = 0
            pubdate = ''
            try:
                pmid = record.split('<PMID Version=')[1].split('</PMID>')[0].split('>')[1]
            except IndexError:
                pmid = '.'

            try:
                title = record.split('<ArticleTitle>')[1].split('</ArticleTitle>')[0]
            except IndexError:
                title = '.'

            try:
                abstract = record.split('<Abstract>')[1].split('</Abstract>')[0]
            except IndexError:
                abstract = '.'

            try:
                temp = record.split('<PubMedPubDate PubStatus="entrez">')[1].split('</PubMedPubDate>')[0]
                year = temp.split('<Year>')[1].split('</Year>')[0]
                month = temp.split('<Month>')[1].split('</Month>')[0]
                if len(month) == 1:
                    month = '0' + month
                day = temp.split('<Day>')[1].split('</Day>')[0]
                if len(day) == 1:
                    day = '0' + day
                pubdate += year
                pubdate += month
                pubdate += day
            except IndexError:
                pass

            for t in phenotypes:
                if t in abstract.lower():
                    hit = 1
                    if len(t.split()) == 1:
                        for element in re.split('[^a-zA-Z0-9]',abstract.lower()):
                            if t == element:
                                if t not in matches:
                                    matches.append(t)
                    if len(t.split()) > 1:
                        if t not in matches:
                            matches.append(t)
                if t in title.lower():
                    hit = 1
                    if len(t.split()) == 1:
                        for element in re.split('[^a-zA-Z0-9]', abstract.lower()):
                            if t == element:
                                if t not in matches:
                                    matches.append(t)
                    if len(t.split()) > 1:
                        if t not in matches:
                            matches.append(t)
            if hit == 1:
                if len(matches) > 0:
                    out = [name, pmid, pubdate, str(len(matches)), ', '.join(list(set(matches))), title]
                    if out not in puberrator_output:
                        puberrator_output.append(out)
                        outputfile.write('\t'.join(out)+'\n')
        outputfile.close()

def hitsassemble(wd, name, date, xd):
    correlated = glob.glob(xd+'*'+name+'_pubmed_correlation_hits_regex.txt')
    print 'correlated', correlated
    outfile = open(wd+name+'_puberrator_regex_output_'+date+'.txt', 'w')
    dict = defaultdict(list)
    header = 'Input List\tPMID\tPublicationDate\tMatch #\tMatching terms\tArticle Title\n'
    outfile.write(header)
    for filename in correlated:
        print filename
        infile = open(filename,'rU')
        for line in infile:
            line = line.replace('\n', '')
            temp = line.split('\t')
            if 'Order_number' not in line:
                try:
                    dict[temp[2]].append(temp)
                except IndexError:
                    print temp
        infile.close()
    for h in dict:
        outstrings = []
        for entry in dict[h]:
            if '\t'.join(entry) not in outstrings and 'Input List\tGene\tPMID' not in '\t'.join(entry):
                entry[1] = entry[1].upper()
                outstrings.append('\t'.join(entry))
        for string in outstrings:
            outfile.write(string+'\n')
    outfile.close()


def run_pub_finder(wd, xd, term_infile, name, date, recorrelate):
    if not os.path.exists(wd + 'pm_xml/'):
        os.mkdir(wd + 'pm_xml/')
    correlate(name, term_infile, xd, wd, recorrelate)
    hitsassemble(wd, name, date, xd)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-wd", "--working_directory", action="store", dest="wd")
    parser.add_argument("-t", "--search_term_file", action="store", dest="term_infile")
    parser.add_argument("-n", "--name", action="store", dest="name")
    parser.add_argument("-r", "--recorrelate", action="store", dest="recorrelate")
    parser.add_argument('-d', "--date", action="store", dest="date")
    parser.add_argument("-xd", "--xml_directory", action="store", dest="xd")
    args = parser.parse_args()

    run_pub_finder(args.wd, args.xd, args.term_infile, args.name, args.date, args.recorrelate)



