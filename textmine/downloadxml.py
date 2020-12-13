import os
import glob
from ftplib import FTP
import argparse

def main(args):

	def download_files(file_list, args):
		xmldir = args.download_directory
		print xmldir
		xmldir_filelist = glob.glob(xmldir+'*')
		print xmldir_filelist
		xmldir_files = [x.split('/')[-1] for x in xmldir_filelist]

		for f in [x for x in files if 'gz' in x]:
		    if f in xmldir_files:
		        print 'found: ', f
		    if f not in xmldir_files:
		        ftp.retrbinary("RETR " + f, open(xmldir+f, 'wb').write)
		        print 'Downloaded: ', f
		ftp.quit()

	ftp = FTP("ftp.ncbi.nlm.nih.gov")
	ftp.login()
	
	
	if args.baseline == 'true':
		ftp.cwd('pubmed/baseline')
		files = ftp.nlst()
		download_files(files, args)
	
	if args.updatefiles == 'true':
		ftp.cwd('pubmed/updatefiles')
		files = ftp.nlst()
		download_files(files, args)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-d", "--download_directory", action="store", dest="download_directory")
    parser.add_argument("-baseline", "--baseline", action="store", dest="baseline")
    parser.add_argument("-updatefiles", "--updatefiles", action="store", dest="updatefiles")
    args = parser.parse_args()
    main(args)
