# UO_Lizard_Project

## Objective

Due to the nature of Direct RNA Nanopore Sequencing, the resulting data contains artificially long reads >300kb, and large amounts of Poly-A content. This can make downstream processing and comparisons difficult. This pipeline attempts to clean up some of those issues, while maintaining good quality alignments. This 

## Steps

1. Trimming
    - Trimmomatic is used for a first trimming step
2. Split on PolyAs
    - A custom PolyA Splitting Script searching for long stretches of As in series, with an adjustable amount of non-As also permitted, when these locations are found, the read is split into two sections along that point 
3. Filter by read size
    - Before the initial alignment, this simple filtering script can filter the fastq file by readsize, its purpose is to disallow small reads (~<100bp) from downstream steps.
4. Initial Alignment
    - Minimap 2 is used
    - minimap2 -ax lr:hq -k 28 -N 1 -t 8 -c $GENOME_FILE $ALN_LF_FQ > $ALN_2
5. Filter by read size
    - Another point to filter by readsize
6. Samtools filtering
    - Secondary alignments are removed, and other low-quality alignments can also be removed
7. Second Alignment
    - Now another alignment is used
8. Samtools filtering
    - Same samtools filtering steps
9. FASTQ Conversion
    - SAM file is converted into a FASTQ file, and this is now used as your dataset

## Performance

A test dataset showed a reduction in PolyA content from 60% to 20%, and a moderate increase in primary and supplementary alignments. The resulting dataset will be much more accurate for initial comparisons and statistics of interests such as number of reads, average length etc. An ideal version of this pipeline would have each read be one high-quality unique RNA strand per read.
