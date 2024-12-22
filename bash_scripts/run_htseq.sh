#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 8
#SBATCH --mem=100G

conda activate htseq_env

#/usr/bin/time -v htseq-count --type=transcript --idattr=gene_id "/projects/bgmp/shared/groups/2024/lizards/jujo/output/big_data_no_trim/big_data_no_trim_nano_v5_12_03_q20_trimmed_split_len_filt_mapq10.bam" "/projects/bgmp/shared/groups/2024/lizards/shared/ref_genome/a_neomexicanus_AspMarm2.0_AspAri2.0_Ari_no_Ino.gff" > nanopore_corrected_counts.txt

/usr/bin/time -v htseq-count -r name --type=gene --idattr=ID "/projects/bgmp/shared/groups/2024/lizards/calz/illumina_cleaned_alignment/imb_baumann_2023_03_21_D675_S21.R2.CLEANED.SORTED.bam" "/projects/bgmp/shared/groups/2024/lizards/shared/ref_genome/a_neomexicanus_AspMarm2.0_AspAri2.0_Ari_no_Ino.gff" > illumina_corrected_non_transcript_counts.txt