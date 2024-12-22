#!/bin/bash
#SBATCH --account=bgmp
#SBATCH --partition=bgmp
#SBATCH -c 10
#SBATCH --nodes=1

/usr/bin/time -v \
python remove_over10k.py -f /projects/bgmp/shared/groups/2024/lizards/camk/nanopore_3/122_VP_NEO_LIVER_TEST.rna004_130bps_sup_v3.0.1.allReads.fastq.gz -o under_10k_122_VP_NEO_LIVER_TEST.rna004_130bps_sup_v3.0.1.allReads.fastq.gz  -m 10000
