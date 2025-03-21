#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 8
#SBATCH --mem=190G

#stuff you change every run
OUTPUT_FILE="nano_12_03"
OUTPUT_DIR="big_data_output_no_len_filt/"
#INPUT_FILE="nanopore_5/122_VP_NEO_LIVER_TEST.dorado0.8.0.rna004_130bps_sup_v5.1.0.allReads.fastq.gz"
INPUT_FILE="/projects/bgmp/shared/groups/2024/lizards/shared/nanopore_big/124_VP_NEO_LIVER_D547_polyA.dorado0.8.0.rna004_130bps_sup_v5.1.0.allReads.fastq.gz"

#should always be the same
GENOME_FILE="ref_genome/a_neomexicanus_AspMarm2.0_AspAri2.0.fasta"

#stuff dependent on what you change
QC_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20.fastq.gz"
POLY_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya.fastq.gz"
LEN_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.fastq.gz"
ALN_FILE="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.sam"
ALN_BAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt.bam"
ALN_MAPQ="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_MAPQ10.bam"


PRIMARY_SUPP_SAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_MAPQ10_primsupp.sam"
READSIZE_FILTERED_SAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_MAPQ10_primsupp_rdsz_filt.sam"
OUTPUT_BAM="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_MAPQ10_primsupp_rdsz_filt.bam"
OUTPUT_FASTQ="${OUTPUT_DIR}${OUTPUT_FILE}_QC20_trimmed_polya_len_filt_MAPQ10_primsupp_rdsz_filt.fastq"


MIN_READ_SIZE=100
MAX_READ_SIZE=5300
#QUALITY TRIM 20
/usr/bin/time -v trimmomatic SE \
     -phred33 \
     -threads 8 $INPUT_FILE $QC_FILE \
     AVGQUAL:20

#split polyAs
/usr/bin/time -v python polyA_split.py -f $QC_FILE -o $POLY_FILE -c True


#cut badly sized reads
/usr/bin/time -v python filter_by_readsize2.py -f $POLY_FILE \
     -o $LEN_FILE \
     -l $MIN_READ_SIZE \
     -u $MAX_READ_SIZE


#actually align
conda activate alignment
minimap2 -ax lr:hq -k 28 -N 5 -t 8 -c $GENOME_FILE $LEN_FILE  > $ALN_FILE


conda activate base
#sort and make bam for downstream stuff



#MAPQ filtering
samtools view -h -q 10 $ALN_FILE > $ALN_MAPQ

#Cams filtering steps here
samtools view -h -F 0x100 $ALN_MAPQ > $PRIMARY_SUPP_SAM

# Step 2: Filter by read size

echo "Filtering by read size (min: $MIN_READ_SIZE, max: $MAX_READ_SIZE)..."
#python filter_sam_by_readsize.py -f $PRIMARY_SUPP_SAM -o $READSIZE_FILTERED_SAM -l $MIN_READ_SIZE -u $MAX_READ_SIZE

# Step 3: Convert SAM to BAM
echo "Converting filtered SAM to BAM..."
#samtools view -bS $READSIZE_FILTERED_SAM > $OUTPUT_BAM
samtools view -bS $PRIMARY_SUPP_SAM > $OUTPUT_BAM

# Step 4: Convert BAM to FASTQ
echo "Converting BAM to FASTQ..."
samtools fastq -F 0x100 $OUTPUT_BAM > $OUTPUT_FASTQ

# Remove all intermediate files
echo "Cleaning up intermediate files..."
rm -f $PRIMARY_SUPP_SAM $READSIZE_FILTERED_SAM $OUTPUT_BAM

echo "Processing complete!"
echo "Final output:"
echo "  FASTQ file: $OUTPUT_FASTQ"

#Stats
START_RECORD="$(zcat $INPUT_FILE| grep '^@' -A 1| grep -vE "^@" | wc -l)"
QC_20="$(zcat $QC_FILE | grep '^@' -A 1| grep -vE "^@" | wc -l)"
AFTER_POLYA="$(zcat $POLY_FILE| grep '^@' -A 1| grep -vE "^@" | wc -l)"
AFTER_LENGTH_TRIMMING="$(zcat $LEN_FILE | grep '^@' -A 1| grep -vE "^@" | wc -l)"
AFTER_MAPPING="$(samtools flagstat $ALN_FILE | grep 'total' | cut -d '+' -f1)"
AFTER_MAPQ="$(samtools flagstat $ALN_MAPQ | grep 'total' | cut -d '+' -f1)"
#add after cam here
AFTER_CAM="$(samtools flagstat $OUTPUT_FASTQ | grep 'total' | cut -d '+' -f1)"

echo Starting number of reads $START_RECORD
echo Reads after quality filtering $QC_20
echo Reads after polya splitting $AFTER_POLYA
echo Reads after length trimming $AFTER_LENGTH_TRIMMING
echo Alignments after mapping $AFTER_MAPPING
echo Alignments after MAPq filtering $AFTER_MAPQ
echo Alignments after Secondaries removed $AFTER_CAM

echo For visualizations see $OUTPUT_DIR pre_processing.png and $OUTPUT_DIR post_processing.png

python records_graph.py --total $START_RECORD --quality $QC_20 \
 --polya $AFTER_POLYA --length $AFTER_LENGTH_TRIMMING --alignment $AFTER_MAPPING\
 --mapq $AFTER_MAPQ --cam_step $AFTER_CAM --outdir $OUTPUT_DIR



