
![GitHub](https://img.shields.io/github/license/milescsmith/nf-rnaseq)
# nf-rnaseq

Nextflow script to process RNAseq reads.

This script in particular is designed to handle data generated from KAPA
Hyperprep RNA-seq libraries sequenced on Illumina Nextseq/Novaseq sequencers.

Currently performs quality control with [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/);
trimming, polyA removal, and ribosomal filtering with [BBMap](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmap-guide/);
and pseudoalignment and quantification with [Salmon](https://combine-lab.github.io/salmon/)

![Example](./pipeline_dag.svg)

## Usage

```
    Usage:

      The typical command for running the pipeline is as follows:
 
      nextflow run milescsmith/nf-rnaseq \\
        --project /path/to/project \\
        --profile slurm

    Mandatory arguments:
      --project             Directory to use as a base where raw files are 
                            located and results and logs will be written
      --profile             Configuration profile to use for processing.
                            Available: slurm, gcp, standard
      
    Optional parameters:

    Reference locations:
      --species             By default, uses "chimera" for a mixed human/viral
                            index.
      --genome
      --truseq_adapter
      --truseq_rna_adapter
      --rRNAs
      --polyA
      --salmon_index
    
    Results locations:      If not specified, these will be created relative to
                            the `project` argument
                            Note: if undefined, the pipeline expects the raw BAM
                            file to be located in `/path/to/project/01_raw`
      --logs                Default: project/logs
      --raw_data            Default: project/data/raw_data
      --bcls                Default: project/data/raw_data/bcls
      --raw_fastqs          Default: project/data/raw_data/fastqs
      --results             Default: project/data/raw_data/data/results
      --qc                  Default: project/data/raw_data/data/results/qc
      --trimmed             Default: project/data/raw_data/data/results/trimmed
      --aligned             Default: project/data/raw_data/data/results/aligned

    Other:
      --help                Show this message
```

By default, the pipeline assumes/creates a project directory layout as below:

```
project_root
├── analysis
├── data
│   ├── raw_data
│   │   ├── bcls
│   │   └── fastqs
│   └── results
│       ├── aligned
│       ├── qc
│       ├── salmon
│       └── trimmed
└── logs
│   ├── fastqc
│   ├── multiqc
│   ├── salmon
│   └── trimmed
```

Any of this can be customized using the arguments shown above.

### Updating

To update to the latest version of the pipeline, run

`nextflow pull milescsmith/nf-rnaseq`