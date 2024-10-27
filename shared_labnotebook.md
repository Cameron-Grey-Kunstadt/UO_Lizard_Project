# Shared lab notebook

## 10/19/24: Julia 

### Fixing data downloads

Checked the original data download, genome fasta file was missing :exploding_head:

Noodled around for a bit and finally noticed small formatting issue preventing this from being downloaded in `get_data.sh`

- While doing this I accidentally deleted the shared logs :angel:. But the original run is in carters folder

I downloaded this fasta file only with `get_data.sh` and organized our starting data in shared as follows:

`illumina/`: paired end illumina data
`nanopore_3/`: nanopore v3 data
`nanopore_5/`: nanopore v5 data
`ref_genome/`: genome fasta and gtf
`logs/`: slurm logs

### Running FASTQC

Moved to my `jujo` to folder do this

installed fastqc on base env with `conda install fastqc`

started srun with 
srun -A bgmp -p bgmp -c4 --mem=16G --pty bash

/usr/bin/time -v fastqc -o fastqc_nanopore_v5/ -t 8 /projects/bgmp/shared/groups/2024/lizards/shared/nanopore_5/122_VP_NEO_LIVER_TEST.dorado0.8.0.rna004_130bps_sup_v5.1.0.allReads.fastq.gz

v3 nanopore data looks horrible
v5 nanopore data is better 

## 10/21/24: Julia

Noticed very high adapter content in both Illumina datasets
![](../jujo/fastqc_illumina/imb_baumann_2023_03_21_D675_S21.R1_fastqc/Images/adapter_content.png)

Noticed high polyA content in both nanopore datasets.

## 10/22/2024: Carter 

conda env: lizard _env 

installed: 
minimap for nanopore
```
 $ minimap2 --version
2.28-r1209                     
```

```
$ bowtie2 --version
/projects/bgmp/calz/miniforge3/envs/lizard_env/bin/bowtie2-align-s version 2.5.4
64-bit
Built on fv-az360-916
Tue Aug 20 13:56:21 UTC 2024
Compiler: gcc version 12.4.0 (conda-forge gcc 12.4.0-0) 
Options: -O3 -msse2 -funroll-loops -g3 -fvisibility-inlines-hidden -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /projects/bgmp/calz/miniforge3/envs/lizard_env/include -fdebug-prefix-map=/opt/conda/conda-bld/bowtie2_1724161881257/work=/usr/local/src/conda/bowtie2-2.5.4 -fdebug-prefix-map=/projects/bgmp/calz/miniforge3/envs/lizard_env=/usr/local/src/conda-prefix -O3
Sizeof {int, long, long long, void*, size_t, off_t}: {4, 8, 8, 8, 8, 8}
```
for today:\
julia ran of V5 ONT
run minimap2 on V3 ONT:\
```
$ sbatch v3_minimap2_run1.sh 
Submitted batch job 17754828
```
**download samtools and fastqc**
```
$ samtools --version                                                                                                   
samtools 1.21
Using htslib 1.21
```
```
$ fastqc --version                                                                                                          
FastQC v0.12.1                         
```
output sam file: /projects/bgmp/shared/groups/2024/lizards/calz/test_v3_aln.sam
run bowtie 2 on illumina 

make bam file: 
```
samtools view -bS /projects/bgmp/shared/groups/2024/lizards/calz/test_v3_aln.sam > /projects/bgmp/shared/groups/2024/lizards/calz/test_v3_aln.bam
```
samtools sort [test_v3_aln.sam](../calz/test_v3_aln.sam)

## 10/23/2024: Carter 

**1) Ran mapped percentages on V3 initial alignment sam file:**\
[test_v3_aln.sam](../calz/V3_alignment_files/test_v3_aln.sam)

```
Mapped Reads: 14691849
Unmapped Reads: 1051635
Percent of Mapped Reads: 93.32018884765279%
```

**2) Ran bowtie2 alignment  w default settings:**\
***bowtie2 indexing:***\
[bowtie_index.sh](../calz/bowtie_index.sh)

***bowtie2 alignment***\
[bowtie_illumina_align.sh](../calz/bowtie_illumina_align.sh)\
[Bowtie2_indexing_18960207.out](../calz/important_slurm_outs/Bowtie2_indexing_18960207.out)

Output SAM: 
/projects/bgmp/shared/groups/2024/lizards/calz/illumina_alignment_files/imb_baumann_2023_03_21_D675_S21.R1.sam

## 10-24-2024: Carter
samtools sort for illumina output sam file and create bam file for IGV: 

checked mapped reads: 
```
$ sbatch mapped_count.sh 
Submitted batch job 19746429
```
```
Mapped Reads: 33346530
Unmapped Reads: 600141
Percent of Mapped Reads: 98.23210647076411%
```