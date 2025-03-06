import gzip
import pandas as pd
import seaborn as sns
import argparse as ag
import matplotlib.pyplot as plt
header=""
quality=""
sequence=""
index=-1
not_a_threshold=2
polya_size=50
total_read_number=0
read_size=1
import argparse

def get_args():
    parser = argparse.ArgumentParser(description="split reads on polya content")
    parser.add_argument("-f", "--file",
                     help="Path to input fastq file.",
                     required=True, type=str)
    parser.add_argument("-o", "--outfile",
                     help="Path to output fastq file with our polyas removed.",
                     required=True, type=str)
    parser.add_argument("-c", "--compressed",
                     help="specify if input file is compressed",
                     required=True, type=bool)
    return parser.parse_args()
args = get_args()
outfile=args.outfile
infile=args.file
is_compressed=args.compressed
print(is_compressed,"gz" not in infile)
if "gz" not in infile:
    output=open(outfile,"w")
    input=open(infile,"r")
elif is_compressed:
    output=gzip.open(outfile,"wt")
    input=gzip.open(infile,"rt")


splits_per_read={}
total_number_of_splits=0 #not including splits of lt 150
for line in input:
    index+=1    
    if index%4==0:
        total_read_number+=1
        header=line
    elif index%4==1:
        sequence=line
    elif index%4==3:
        split_counter=0
        quality=line
        polya_counter=0
        nota_counter=0
        new_line_start=0
        clip_start=0

        for i, char in enumerate(sequence):
            if char=="A":
                polya_counter+=1
            #not A
            else:
                nota_counter+=1

            #if time to split
            if nota_counter>not_a_threshold and polya_counter>polya_size or \
                polya_counter>polya_size and i==len(line)-1:
                #left string
                if new_line_start!=0:
                    clip_start=new_line_start
                #only write reads of significant size
                if (i-polya_counter)-clip_start>1:
                    split_counter+=1
                    output.write(f"{header[:-1]}_0{split_counter}\n")
                    output.write(sequence[clip_start:i-polya_counter]+"\n")
                    output.write("+\n")
                    output.write(quality[clip_start:i-polya_counter]+"\n")
                
                new_line_start=i
                polya_counter=0
                nota_counter=0
            elif nota_counter>not_a_threshold:
                nota_counter=0
                polya_counter=0
        #no point in writing tiny af read
        if split_counter!=0:
            output.write(f"{header[:-1]}_0{split_counter+1}\n")
            output.write(sequence[new_line_start:])
            output.write("+\n")
            output.write(quality[new_line_start:])
        if split_counter==0:
            output.write(header.strip()+"\n")
            output.write(sequence.strip()+"\n")
            output.write("+\n")
            output.write(quality.strip()+"\n")
        #update split count
        if split_counter in splits_per_read:
            splits_per_read[split_counter]+=1
        else:
            splits_per_read[split_counter]=1
        #update total number of splits
        total_number_of_splits+=split_counter
        
print(f"There were {total_number_of_splits} splits total in our {total_read_number} reads")
