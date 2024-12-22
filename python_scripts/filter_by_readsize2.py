import argparse
import gzip

parser = argparse.ArgumentParser(description="Script filters input fastq.gz file to only the reads between the given lower and upper bounds (in terms of sequence length).")
parser.add_argument('-f', "--file", required=True, help="Input FASTQ file in gzipped format")
parser.add_argument('-o', "--output", required=True, help="Output FASTQ file in gzipped format")
parser.add_argument('-l', "--lower_bound", type=int, required=True, help="Lower bound of sequence length")
parser.add_argument('-u', "--upper_bound", type=int, required=True, help="Upper bound of sequence length")
args = parser.parse_args()

with gzip.open(args.file, 'rt') as infile, gzip.open(args.output, 'wt') as outfile:
    while True:
        header = infile.readline().strip()
        seq = infile.readline().strip()
        plus = infile.readline().strip()
        phred = infile.readline().strip()

        if not header or not seq or not plus or not phred:
            break

        assert plus.startswith('+'), "FASTQ format error: '+' line expected."

        if int(args.lower_bound) <= len(seq) <= int(args.upper_bound):
            outfile.write(f"{header}\n{seq}\n{plus}\n{phred}\n")

