import gzip
import argparse
# Cameron Kunstadt
# UO lizard project
# 10/21/2024


parser = argparse.ArgumentParser(description="Script filters input fastq.gz file to only the reads between the given lower and upper bounds, bounds are inclusive")
parser.add_argument('-f', "--file",)
parser.add_argument('-o', "--output",)  
parser.add_argument('-l', "--lower_bound")
parser.add_argument('-u', "--upper_bound",)      
args = parser.parse_args()

with gzip.open(args.file, 'rt') as infile, gzip.open(args.output, 'wt') as outfile:
    while True:
        header = infile.readline().strip()
        seq = infile.readline().strip()
        plus = infile.readline().strip()
        phred = infile.readline().strip()
        if header == "" or seq == "" or plus == "" or phred == "":
            break

        if (len(seq) <= int(args.upper_bound)) and (len(seq) >= int(args.lower_bound)):
            outfile.write(header + '\n' + seq + '\n' + plus + '\n' + phred + '\n')


