// created using the modules from nf-core/rnaseq as a guide/template

// Use BBmap to trim known adaptors, low quality reads, and
// polyadenylated sequences and filter out ribosomal reads

include { initOptions; saveFiles; getSoftwareName } from './functions'

param.options = [:]
def options = initOptions(params.options)

def VERSION = "33.86"

process bbmap_trim {

    tag "$meta.id"
    label "trim"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }
    
    container "registry.gitlab.com/milothepsychic/rnaseq_pipeline/bbmap:38.86"

    input:
        tuple val(sample_id), file(read1), file(read2)

    output:
        path "*.trimmed.R1.fq.gz",  emit: read1
        path "*.trimmed.R2.fq.gz",  emit: read2
        val sample_id,              emit: sample_id
        path "*.csv",               emit: contamination
    
    script:
    """
    bbduk.sh \
        in=${read1} \
        in2=${read2} \
        outu=${sample_id}.trimmed.R1.fq.gz \
        out2=${sample_id}.trimmed.R2.fq.gz \
        outm=removed_${sample_id}.R1.fq.gz \
        outm2=removed_${sample_id}.R2.fq.gz \
        ref=${params.polyA},${params.truseq_adapter},${params.truseq_rna_adapter},${params.rRNAs} \
        stats=contam_${sample_id}.csv \
        statscolumns=3 \
        k=13 \
        ktrim=r \
        useshortkmers=t \
        mink=5 \
        qtrim=r \
        trimq=10 \
        minlength=20
    """
}