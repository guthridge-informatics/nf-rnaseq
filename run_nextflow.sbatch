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
    --project /s/guth-aci/edp_transcriptomics \
    --raw_fastqs /archive/james-guthridge/datasets/amp_aim/data/raw/edp_transcriptomics/p1/22L7V3LT4/ \
    --refs /Volumes/guth_aci_informatics/references/ \
    --species chimeras \
    --pseudoalign \
    --results /s/guth-aci/edp/data

nextflow run main.nf \
    -profile google_batch \
    -config rnaseq.config \
    -resume \
    --reads_pattern "*_S*_R{1,2}_00*.fastq.gz" \
    --project gs://memory-alpha/analysis/edp \
    --raw_fastqs gs://memory-alpha/analysis/edp/p1/22L7V3LT4/ \
    --refs gs://memory-alpha/references/ \
    --species chimeras \
    --pseudoalign \
    --results gs://memory-alpha/analysis/edp/processed \
    --project_id guthridge-nih-strides-projects \
    --workdir_bucket "gs://memory-alpha/scratch" \
    --scratch "gs://memory-alpha/scratch"

nextflow run main.nf \
    -profile google_batch \
    -config rnaseq.config \
    -resume \
    --reads_pattern "*_S*_R{1,2}_00*.fastq.gz" \
    --project gs://memory-alpha/analysis/edp \
    --raw_fastqs gs://memory-alpha/analysis/edp/p1/22L7V3LT4/ \
    --refs gs://memory-alpha/references/ \
    --species chimeras \
    --pseudoalign \
    --results gs://memory-alpha/analysis/edp/processed \
    --project_id guthridge-nih-strides-projects \
    --workdir_bucket "gs://memory-alpha/scratch" \
    --scratch "gs://memory-alpha/scratch"

    /tmp/tmp.dYkaRlrShe/application_default_credentials.json

gcloud projects add-iam-policy-binding guthridge-nih-strides-projects  \
--member="serviceAccount:nextflow-batch-runner@guthridge-nih-strides-projects.iam.gserviceaccount.com" \
--role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding guthridge-nih-strides-projects \
--member="serviceAccount:nextflow-batch-runner@guthridge-nih-strides-projects.iam.gserviceaccount.com" \
--role="roles/batch.jobsEditor"

gcloud projects add-iam-policy-binding guthridge-nih-strides-projects \
--member="serviceAccount:nextflow-batch-runner@guthridge-nih-strides-projects.iam.gserviceaccount.com" \
--role="roles/logging.viewer"

gcloud projects add-iam-policy-binding guthridge-nih-strides-projects \
--member="serviceAccount:nextflow-batch-runner@guthridge-nih-strides-projects.iam.gserviceaccount.com" \
--role="roles/storage.admin"