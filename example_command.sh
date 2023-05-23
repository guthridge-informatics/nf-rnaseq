export GOOGLE_APPLICATION_CREDENTIALS=/home/milo/guthridge-nih-strides-projects-nextflow-lf-runner.json
nextflow run main.nf \                                                                                                                                                                              ─╯
    -profile google_batch \
    -config rnaseq.config \
    --project gs://memory-alpha/analysis/LRA-BMS-IFC5 \
    --refs gs://memory-alpha/references \
    --scratch gs://memory-alpha/scratch \
    --google.project guthridge-nih-strides-projects \
    --species "chimeras" \
    --pseudoalign \
    --workdir_bucket gs://memory-alpha/scratch \
    --raw_fastqs gs://memory-alpha/analysis/LRA-BMS-IFC5/data/raw/fastqs/IFC5