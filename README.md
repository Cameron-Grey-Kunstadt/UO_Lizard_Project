# UO_Lizard_Project

## Objective

Due to the nature of Direct RNA Nanopore Sequencing, the resulting data contains artificially long reads >300kb, and large amounts of Poly-A content. This can make downstream processing and comparisons difficult. This pipeline attempts to clean up some of those issues, while maintaining good quality alignments. This 

## Steps

1. Trimming with trimmomatic
2. Split on PolyAs
3. Filter by read size
4. Initial Alignment
5. Filter by read size
6. Samtools filtering
7. Second Alignment
8. Samtools filtering
9. FASTQ Conversion 
