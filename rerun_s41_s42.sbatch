#! /bin/bash -l

#SBATCH -J nf-rnaseq
#SBATCH -o nfr.log
#SBATCH --mem=32
#SBATCH --partition=serial
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16

export APPTAINER_CACHEDIR=/s/guth-aci/apptainer/cache
export APPTAINER_TMPDIR=/s/guth-aci/apptainer/tmp/
export NXF_APPTAINER_CACHEDIR=$APPTAINER_CACHEDIR
export NXF_APPTAINER_TMPDIR=$APPTAINER_TMPDIR

unset _JAVA_OPTIONS
export _JAVA_OPTIONS='-Xmx128G -Xms4G -XX:+UseParallelGC -XX:ParallelGCThreads=16'
nextflow main.nf \
    -profile slurm \
    -config rnaseq.config \
    -resume \
    --reads_pattern "*_S*_R{1,2}_00*.fastq.gz" \
    --project /s/guth-aci/rerun \
    --raw_fastqs /archive/james-guthridge/datasets/rnaseq/novaseq/S4.1/data/raw_data/fastqs/s41 \
    --refs /Volumes/guth_aci_informatics/references/ \
    --species chimeras \
    --pseudoalign \
    --results /s/guth-aci/rerun/data