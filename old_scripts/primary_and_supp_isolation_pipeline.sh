#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 8
#SBATCH --mem=190G

conda activate lizard_env

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <input_sam> <output_prefix> <min_read_size> <max_read_size>"
    exit 1
fi

# Input arguments
INPUT_SAM=$1
OUTPUT_PREFIX=$2
MIN_READ_SIZE=$3
MAX_READ_SIZE=$4

# Intermediate and output file names
PRIMARY_SUPP_SAM="${OUTPUT_PREFIX}_primary_supp.sam"
READSIZE_FILTERED_SAM="${OUTPUT_PREFIX}_rdsz_filt.sam"
OUTPUT_BAM="${OUTPUT_PREFIX}.bam"
OUTPUT_FASTQ="${OUTPUT_PREFIX}.fastq"

echo "Processing SAM file: $INPUT_SAM"

# Step 1: Filter to primary and supplementary alignments
echo "Filtering for primary and supplementary alignments..."
samtools view -q 10 -h -F 0x100 "$INPUT_SAM" > "$PRIMARY_SUPP_SAM"

# Step 2: Filter by read size
echo "Filtering by read size (min: $MIN_READ_SIZE, max: $MAX_READ_SIZE)..."
python filter_sam_by_readsize.py -f "$PRIMARY_SUPP_SAM" -o "$READSIZE_FILTERED_SAM" -l "$MIN_READ_SIZE" -u "$MAX_READ_SIZE"

# Step 3: Convert SAM to BAM
echo "Converting filtered SAM to BAM..."
samtools view -bS "$READSIZE_FILTERED_SAM" > "$OUTPUT_BAM"

# Step 4: Convert BAM to FASTQ
echo "Converting BAM to FASTQ..."
samtools fastq -F 0x100 "$OUTPUT_BAM" > "$OUTPUT_FASTQ"

# Remove all intermediate files
echo "Cleaning up intermediate files..."
rm -f "$PRIMARY_SUPP_SAM" "$READSIZE_FILTERED_SAM" "$OUTPUT_BAM"

echo "Processing complete!"
echo "Final output:"
echo "  FASTQ file: $OUTPUT_FASTQ"

