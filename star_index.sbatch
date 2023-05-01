#! /bin/bash -l

#SBATCH -J star_index
#SBATCH -o build_star_index.log
#SBATCH --mail-user=miles-smith@omrf.org
#SBATCH --mail-type=FAIL,END
#SBATCH --mem=128G
#SBATCH --partition=serial
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16

export _JAVA_OPTIONS='-Xmx128G -Xms4G -XX:+UseParallelGC -XX:ParallelGCThreads=16'
singularity exec \
    --bind /Volumes/guth_aci_informatics/references:/refs \
    docker://quay.io/biocontainers/star:2.7.10b--h9ee0642_0 \
    STAR \
        --runMode genomeGenerate \
        --runThreadN 16 \
        --genomeDir /refs/genomic/homo_sapiens/indices/star/chm13T2Tv2.0_star_2.7.10b \
        --genomeFastaFiles /refs/genomic/homo_sapiens/sequences/chm13T2Tv2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna \
        --sjdbGTFfile /refs/genomic/homo_sapiens/sequences/chm13T2Tv2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.gff \
        --sjdbGTFtagExonParentTranscript Parent \
        --sjdbOverhang 99