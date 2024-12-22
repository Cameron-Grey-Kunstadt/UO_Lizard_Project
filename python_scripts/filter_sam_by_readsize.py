import argparse
# Cameron Kunstadt
# UO lizard project
# 11/18/2024


parser = argparse.ArgumentParser(description="Script filters input SAM file to only the reads between the given lower and upper bounds, bounds are inclusive")
parser.add_argument('-f', "--file",)
parser.add_argument('-o', "--output",)  
parser.add_argument('-l', "--lower_bound")
parser.add_argument('-u', "--upper_bound",)      
args = parser.parse_args()

with open(args.file, 'rt') as infile, open(args.output, 'wt') as outfile:
    while True:
        line = infile.readline()
        if line == "": # Break if EOF
            break
        elif line[0] == "@": # Write out all header lines regardless
            outfile.write(line)
        else:
            groups = line.split('\t')
        
            if int(len(groups[9])) <= int(args.upper_bound) and int(len(groups[9])) >= int(args.lower_bound):
                outfile.write(line)



