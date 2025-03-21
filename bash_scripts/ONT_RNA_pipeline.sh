#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 8
#SBATCH --mem=230G

INPUT_FILE=/projects/bgmp/shared/groups/2024/lizards/shared/nanopore_big/124_VP_NEO_LIVER_D547_polyA.dorado0.8.0.rna004_130bps_sup_v5.1.0.allReads.fastq.gz

#/projects/bgmp/shared/groups/2024/lizards/camk/final_pipeline/test_input.fastq
#INPUT_FILE=/projects/bgmp/shared/groups/2024/lizards/shared/nanopore_5/122_VP_NEO_LIVER_TEST.dorado0.8.0.rna004_130bps_sup_v5.1.0.allReads.fastq.gz
#INPUT_FILE=/projects/bgmp/shared/groups/2024/lizards/jujo/output/small_test.fastq.gz
#INPUT_FILE=/projects/bgmp/shared/groups/2024/lizards/jujo/big_file_subs.fastq.gz
#conda activate lizard_env
# # Quality filter to remove any read w an average q score lower than 20 - trimmomatic
OUTPUT_FILE="big_nano_v5_03_04_diffsamtools"
OUTPUT_DIR="/projects/bgmp/shared/groups/2024/lizards/jujo/output/"

#should always be the same
GENOME_FILE="/projects/bgmp/shared/groups/2024/lizards/shared/ref_genome/a_neomexicanus_AspMarm2.0_AspAri2.0.fasta"

#stuff dependent on what you change
#qc
QC_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed.fastq.gz"
#polya
POLY_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya.fastq.gz"

#len filt before alignment
LEN_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.fastq.gz"

#alignment file
ALN_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.sam"

#len filtering on alignment
ALN_LF="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt.sam"

#to convert to fastq
ALN_LF_BAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt.bam"

#fastq for second alignment
ALN_LF_FQ="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt.fastq"

#second alignment
ALN_2="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt_aln2.sam"

#to convert to bam
ALN_2_BAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt_aln2.bam"

#to check quality (prob could be optional)
ALN_2_FQ="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt_aln2.fastq"






  #conda activate base

  /usr/bin/time -v trimmomatic SE \
       -phred33 \
       -threads 8 \
       $INPUT_FILE $QC_FILE AVGQUAL:20 MINLEN:100
  

# # #split polyAs
/usr/bin/time -v python ../python_scripts/NEW_POLY.py -f  $QC_FILE -o $POLY_FILE -c True


# # # # Remove reads if they arent inbetween 150-5300bp - Cams script
 /usr/bin/time -v python /projects/bgmp/shared/groups/2024/lizards/camk/scripts/filter_by_readsize.py -f $POLY_FILE \
       -o $LEN_FILE \
       -l 100 \
       -u 53000000

# # # echo "Length Filtering Complete"
  conda activate alignment
  minimap2 -ax lr:hq -k 28 -N 5 -t 8 -c $GENOME_FILE \
  $POLY_FILE  > $ALN_FILE


 python /projects/bgmp/shared/groups/2024/lizards/jujo/scripts/python_scripts/filter_sam_by_readsize.py \
   -f $ALN_FILE \
   -o $ALN_LF -l 100 -u 53000000

#get primaries
samtools view -h -q 10 -F 0x100 -bS $ALN_LF > $ALN_LF_BAM
samtools fastq -F 0x100 $ALN_LF_BAM > $ALN_LF_FQ

#get sups
samtools view -q 10 -f 0x800 -bS $ALN_LF> $ALN_LF_BAM
samtools fastq -F 0x4 $ALN_LF_BAM >> $ALN_LF_FQ

 conda activate alignment
 #allow less secondaries because we trash them 
 minimap2 -ax lr:hq -k 28 -N 1 -t 8 -c $GENOME_FILE $ALN_LF_FQ > $ALN_2

#primary reads
samtools view -h -q 10 -bS $ALN_2 > $ALN_2_BAM
samtools fastq -F 0x100 $ALN_2_BAM > $ALN_2_FQ

#supp reads
samtools view -q 10 -f 0x800 -bS $ALN_2 > $ALN_2_BAM
samtools fastq -F 0x4 $ALN_2_BAM >> $ALN_2_FQ






