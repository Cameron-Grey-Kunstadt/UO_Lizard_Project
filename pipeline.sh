#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 8
#SBATCH --mem=120G

#Dependencies: pandas, seaborn, samtools, minimap2, trimmomatic

#TODO: parameterize files, change output directory, put intermediary files into a folder

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_sam> <output_prefix> "
    exit 1
fi

# Input arguments
INPUT_FILE=$1
OUTPUT_FILE=$2

# Genome File
GENOME_FILE="/projects/bgmp/shared/groups/2024/lizards/shared/ref_genome/a_neomexicanus_AspMarm2.0_AspAri2.0.fasta"

# Output Directory
OUTPUT_DIR=""

# Intermediary filenames
QC_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed.fastq.gz"
POLY_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya.fastq.gz"
LEN_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.fastq.gz"
ALN_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.sam"
ALN_PS="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps.sam"
ALN_LF="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt.sam"
ALN_LF_BAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt.bam"
ALN_LF_FQ="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_ps_len_filt.fastq"
ALN_2="${OUTPUT_DIR}${OUTPUT_FILE}_final.sam"

conda activate lizard_env

# Step 1: Trimmomatic
echo "Step 1"
/usr/bin/time -v trimmomatic SE \
     -phred33 \
     -threads 8 \
     $INPUT_FILE $QC_FILE\
     AVGQUAL:20

# Step 2: Split by PolyA
echo "Step 2"
/usr/bin/time -v python /projects/bgmp/shared/groups/2024/lizards/shared/python_scripts/polyA_split_shared.py -f  $QC_FILE -o $POLY_FILE -c True

# Step 3: Remove reads if they aren't inbetween 150-5300bp
echo "Step 3"
 /usr/bin/time -v python /projects/bgmp/shared/groups/2024/lizards/camk/scripts/filter_by_readsize.py -f $POLY_FILE \
    -o $LEN_FILE \
    -l 100 \
    -u 53000000

# Step 4: Initial Alignment
echo "Step 4"
minimap2 -ax lr:hq -k 28 -N 5 -t 8 -c $GENOME_FILE \
 $LEN_FILE  > $ALN_FILE

# Step 5: Exclude Secondaries
echo "Step 5"
samtools view -q 10 -h -F 0x100 $ALN_FILE > $ALN_PS

# Step 6: Filter SAM file by readsize
echo "Step 6"
python /projects/bgmp/shared/groups/2024/lizards/jujo/scripts/python_scripts/filter_sam_by_readsize.py \
 -f $ALN_PS \
 -o $ALN_LF -l 100 -u 5300000

# Step 7: Convert SAM to BAM
echo "Step 7"
samtools view -bS $ALN_LF > $ALN_LF_BAM

# Step 8: Convert BAM to FASTQ
echo "Step 8"
samtools fastq -F 0x100 $ALN_LF_BAM > $ALN_LF_FQ

# Step 9: Perform final alignment
echo "Step 9"
minimap2 -ax lr:hq -k 28 -N 5 -t 8 -c $GENOME_FILE $ALN_LF_FQ > $ALN_2