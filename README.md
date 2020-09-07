
![GitHub](https://img.shields.io/github/license/milescsmith/nf-rnaseq)
# nf-rnaseq

Nextflow script to process RNAseq reads.

This script in particular is designed to handle data generated from KAPA
Hyperprep RNA-seq libraries sequenced on Illumina Nextseq/Novaseq sequencers.

Currently performs quality control with [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/);
trimming, polyA removal, and ribosomal filtering with [BBMap](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmap-guide/);
and pseudoalignment and quantification with [Salmon](https://combine-lab.github.io/salmon/)

![Example](./pipeline_dag.svg)
