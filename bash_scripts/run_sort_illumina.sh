#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 8
#SBATCH --mem=100G

/usr/bin/time -v samtools sort /projects/bgmp/shared/groups/2024/lizards/calz/illumina_cleaned_alignment/imb_baumann_2023_03_21_D675_S21.R2.CLEANED.sam > /projects/bgmp/shared/groups/2024/lizards/calz/illumina_cleaned_alignment/imb_baumann_2023_03_21_D675_S21.R2.CLEANED.SORTED.sam 