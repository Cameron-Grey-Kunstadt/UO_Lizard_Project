import gzip
import pandas as pd
import seaborn as sns
import argparse as ag
import matplotlib.pyplot as plt
header=""
quality=""
sequence=""
index=0
not_a_threshold=2
polya_size=50
reasonable_read_size=149
total_read_number=0
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
                     required=True, default=True,type=bool)
    return parser.parse_args()
#output=gzip.open('remove_fragments_nano_v5.fastq.gz', 'wt')
args = get_args()
output=args.outfile
input=args.file
is_compressed=args.compressed
if is_compressed:
    output=gzip.open(output,"wt")
    input=gzip.open(input,"rt")
else:
    output=open(output,"w")
    input=open(input,"r")
#input=gzip.open("../../shared/nanopore_5/122_VP_NEO_LIVER_TEST.dorado0.8.0.rna004_130bps_sup_v5.1.0.allReads.fastq.gz"
#,"rt")
splits_per_read={}
total_number_of_splits=0 #not including splits of lt 150
for line in input:
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

            #if time to reset
            if nota_counter>not_a_threshold and polya_counter>polya_size or \
                polya_counter>polya_size and i==len(line):
                #left string
                if new_line_start!=0:
                    clip_start=new_line_start
                #only write reads of significant size
                if (i-polya_counter)-clip_start>reasonable_read_size:
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
        if new_line_start!=i and len(line) - new_line_start>reasonable_read_size:
            output.write(f"{header[:-1]}_0{split_counter}\n")
            output.write(sequence[new_line_start:])
            output.write("+\n")
            output.write(quality[new_line_start:])
        #update split count
        if split_counter in splits_per_read:
            splits_per_read[split_counter]+=1
        else:
            splits_per_read[split_counter]=1
        #update total number of splits
        total_number_of_splits+=split_counter
    index+=1

print(f"There were {total_number_of_splits} splits total in our {total_read_number} reads")
#print(f"There were: ", sep="")
#for key, value in splits_per_read.items():
#    print(f"{value} reads with {key} split(s)")


df=pd.DataFrame({"Reads":list(splits_per_read.values()),"Splits":list(splits_per_read.keys())})
fig=sns.barplot(df,x="Splits",y="Reads",color="mediumseagreen",alpha=0.7)
sns.despine(right=True,top=True)
plt.title("Number of reads with N polyA tail splits")
plt.savefig("nanov5_splits.png")
df.to_csv("nanov5_splits.csv",index=False)
output.close()
input.close()