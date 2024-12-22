import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import argparse 

parser = argparse.ArgumentParser()
parser.add_argument('-t', "--total", type=int)
parser.add_argument('-q', "--quality", type=int) 
parser.add_argument('-p', "--polya", type=int)
parser.add_argument('-l', "--length", type=int)
parser.add_argument('-a', "--alignment", type=int)  
parser.add_argument('-m', "--mapq", type=int) 
parser.add_argument('-c', "--cam_step", type=int)  
parser.add_argument('-o', "--outdir", type=str) 


args = parser.parse_args()

total=args.total
quality=args.quality
polya=args.polya
length=args.length
alignment=args.alignment
mapq=args.mapq
cam_step=args.cam_step
outdir=args.outdir

pre_processing={"Total": total,
"QC 20": quality, "Polya split":polya,
"Length trimming": length}
post_processing={"Total alignments": alignment, "MAPQ filtering":
mapq, "Primary and supplementary only":cam_step}

sns.barplot(pre_processing,color="lightseagreen",alpha=0.7)
sns.despine(top=True,right=True)
plt.title("Record counts following processing steps")
plt.ylabel("Number of records")
plt.xlabel("Processing of step")
plt.savefig(f"{outdir}/pre_processing.png")
plt.close()

sns.barplot(post_processing,color="lightseagreen",alpha=0.7)
sns.despine(top=True,right=True)
plt.title("Alignment counts following processing steps")
plt.ylabel("Number of records")
plt.xlabel("Processing of step")
plt.savefig(f"{outdir}/post_processing.png")
plt.close()