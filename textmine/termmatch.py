import argparse


def main(args):

    one = args.first.split(',')
    two = args.second.split(',')

    pmids = []
    pmids.append('\t'.join(['Input List', 'PMID', 'Publication Date', 'Match #', 'Matching Terms', 'Article Title']))
    flist = []
    with open(args.working_directory + args.date + '_' + args.infilename.split('/')[-1], 'w') as outfile:
        with open(args.infilename, 'rU') as infile:
            for line in infile:
                line = line.split('\t')
                onefound = 0
                twofound = 0
                for element in line[4].split(', '):
                    if element in one:
                        onefound = 1
                    if element in two:
                        twofound = 1
                if onefound == twofound == 1:
                    if line[1] not in flist:
                        pmids.append('\t'.join([line[0], line[1], line[2], line[3], line[4], line[5]]))
                        flist.append(line[1])
                        print line[1]


        for p in pmids:
            outfile.write(p)
    print '%s papers found' % (len(pmids))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-wd", "--working_directory", action="store", dest="working_directory")
    parser.add_argument("-i", "--infilename", action="store", dest="infilename")
    parser.add_argument("-d", "--date", action="store", dest="date")
    parser.add_argument("-first", "--first", action="store", dest="first")
    parser.add_argument("-second", "--second", action="store", dest="second")
    args = parser.parse_args()
    main(args)
