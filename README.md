
![GitHub](https://img.shields.io/github/license/milescsmith/nf-rnaseq)
# nf-rnaseq

Nextflow script to process RNAseq reads.

This script in particular is designed to handle data generated from KAPA
Hyperprep RNA-seq libraries sequenced on Illumina Nextseq/Novaseq sequencers.

Currently performs quality control with [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/);
trimming, polyA removal, and ribosomal filtering with [BBMap](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmap-guide/);
and pseudoalignment and quantification with [Salmon](https://combine-lab.github.io/salmon/)

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

# Usage

An example of use:
```
nextflow run main.nf \
    -profile slurm \
    -config rnaseq.config \
    -resume \
    --reads_pattern "*_S*_R{1,2}_00*.fastq.gz" \
    --project /scratch \
    --raw_fastqs /datasets/rnaseq/data/raw_data/fastqs/ \
    --refs /scratch/references/ \
    --species chimeras \
    --pseudoalign \
    --results /scratch/data
```

Currently, profiles are provided for running the pipeline using a SLURM-based job manager and Google Batch Runner (which can be found in the `conf` folder); you will probably need to create one for your own particular compute resources.

Because Google just has a seemingly compulsive and almost *pathogenic* love for changing things any documentation or advice someplace like StackOverflow is likely to no longer work. A guide to setting it up is [provided in the `run_nextflow_on_google_batch.md` file](run_nextflow_on_google_batch.md), but it too may be out of date by the time you attempt to use it.

> The nf-core framework for community-curated bioinformatics pipelines.
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> Nat Biotechnol. 2020 Feb 13. doi: 10.1038/s41587-020-0439-x.
> In addition, references of tools and data used in this pipeline are as follows:

<!-- ![Example](./pipeline_dag.svg) -->
