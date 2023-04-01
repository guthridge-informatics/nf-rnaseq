#!/usr/bin/env nextflow
/*
 * Copyright (c) 2020, Oklahoma Medical Research Foundation (OMRF).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This Source Code Form is "Incompatible With Secondary Licenses", as
 * defined by the Mozilla Public License, v. 2.0.
 *
 */

// Nextflow pipeline for processing PacBio IsoSeq runs
// Author: Miles Smith <miles-smith@omrf.org>
// Date: 2020/09/04
// Version: 0.1.0

// File locations and program parameters

def helpMessage() {
    log.info nfcoreHeader()
    log.info """
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
    """.stripIndent()
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

params.input = "${params.raw_fastqs}/*_S*_L00*_R{1,2}_00*.fastq.gz"

Channel
    .fromFilePairs( params.reads, checkIfExists: true, flat: true )
    .set{ raw_fastq_fastqc_reads_ch }

Channel
    .fromFilePairs( params.reads, checkIfExists: true, flat: true )
    .set{ raw_fastq_to_trim_ch }

process initial_qc {
    //Use Fastqc to examine fastq quality

    tag "FastQC"
    
    publishDir "${params.qc}/${sample_id}", mode: "copy", pattern: "*.html", overwrite: false
    publishDir "${params.qc}/${sample_id}", mode: "copy", pattern: "*.zip", overwrite: false

    input:
        tuple val(sample_id), file(read1), file(read2) from raw_fastq_fastqc_reads_ch

    output:
        file "*.html" into fastqc_results_ch
        // tuple val(sample_id), file(read1), file(read2) into raw_fastq_to_trim_ch

    script:
        """
        falco \
            --noextract \
            --format fastq \
            --threads ${task.cpus} \
            ${read1} ${read2}
        """
}

process perfom_trimming {
    /* Use BBmap to trim known adaptors, low quality reads, and
       polyadenylated sequences and filter out ribosomal reads */

    tag "trim"
    // container "registry.gitlab.com/milothepsychic/rnaseq_pipeline/bbmap:38.86"

    input:
        tuple val(sample_id), file(read1), file(read2) from raw_fastq_to_trim_ch
        path polyA from params.polyA
        path truseq_adapter from params.truseq_adapter
        path truseq_rna_adapter from params.truseq_rna_adapter
        path rRNAs from params.rRNAs

    output:
        file "*.trimmed.R1.fq.gz" into trimmed_read1_ch
        file "*.trimmed.R2.fq.gz" into trimmed_read2_ch
        val sample_id into trimmed_sample_name_ch
        file "*.csv" into contamination_ch
    
    script:
    """
    bbduk.sh \
        -Xmx24G \
        in=${read1} \
        in2=${read2} \
        outu=${sample_id}.trimmed.R1.fq.gz \
        out2=${sample_id}.trimmed.R2.fq.gz \
        outm=removed_${sample_id}.R1.fq.gz \
        outm2=removed_${sample_id}.R2.fq.gz \
        ref=${polyA},${truseq_adapter},${truseq_rna_adapter},${rRNAs} \
        stats=contam_${sample_id}.csv \
        statscolumns=3 \
        k=13 \
        ktrim=r \
        useshortkmers=t \
        mink=5 \
        qtrim=r \
        trimq=10 \
        minlength=20 \
        threads=4 \
        prealloc=t
    """
}

process star_align {
    tag "star align"
    maxErrors 10
    errorStrategy "ignore"
    // container "combinelab/salmon:1.3.0"
    publishDir path: "${params.aligned}/${sample_id}", mode: "copy", pattern: "*.bam", overwrite: true
    publishDir path: "${params.aligned}/${sample_id}", mode: "copy", pattern: "*.tab", overwrite: true

    input:
        val sample_id from trimmed_sample_name_ch
        file trimmed_read1 from trimmed_read1_ch
        file trimmed_read2 from trimmed_read2_ch
        path star_index from params.star_index

    output:
        file "*.bam" into aligned_ch
        file "*.tab" into counts_ch
        val sample_id into quant_name

    script:
    """
    star \
        --quantMode TranscriptomeSAM GeneCounts \
        --runThreadN {task.cpus} \
        --genomeDir {input.star_index} \
        --readFilesIn {input.trimmed_read1} {input.trimmed_read2} \
        --readFilesCommand zcat \
        --outFileNamePrefix {input.sample_id} \
        --outReadsUnmapped Fastx \
        --outBAMcompression -1 \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMattributes All
    """
}

process multiqc {
    /* collect all qc metrics into one report */
    
    tag "multiqc"
    // container "ewels/multiqc:1.9"
    
    input:
        val sample_id from quant_name
        file ("${sample_id}/*.bam") from aligned_ch.collect().ifEmpty([])
        file ("${sample_id}/*_fastqc.html") from fastqc_results_ch.collect().ifEmpty([])
        file ("${sample_id}/contam.csv") from contamination_ch.collect().ifEmpty([])
        file ("${sample_id}/*.tab") from counts_ch.collect().ifEmpty([])
    
    output:
        file "*.html" into multiqc_ch
    
    script:
    """
    multiqc \
        -m fastqc \
        -m bbmap \
        -m salmon \
        -d \
        -ip \
        . \
    """
}


def nfcoreHeader() {
    // Log colors ANSI codes
    c_reset = params.monochrome_logs ? '' : "\033[0m";
    c_dim = params.monochrome_logs ? '' : "\033[2m";
    c_black = params.monochrome_logs ? '' : "\033[0;30m";
    c_green = params.monochrome_logs ? '' : "\033[0;32m";
    c_yellow = params.monochrome_logs ? '' : "\033[0;33m";
    c_blue = params.monochrome_logs ? '' : "\033[0;34m";
    c_purple = params.monochrome_logs ? '' : "\033[0;35m";
    c_cyan = params.monochrome_logs ? '' : "\033[0;36m";
    c_white = params.monochrome_logs ? '' : "\033[0;37m";

    return """    -${c_dim}--------------------------------------------------${c_reset}-
                                            ${c_green},--.${c_black}/${c_green},-.${c_reset}
    ${c_blue}        ___     __   __   __   ___     ${c_green}/,-._.--~\'${c_reset}
    ${c_blue}  |\\ | |__  __ /  ` /  \\ |__) |__         ${c_yellow}}  {${c_reset}
    ${c_blue}  | \\| |       \\__, \\__/ |  \\ |___     ${c_green}\\`-._,-`-,${c_reset}
                                            ${c_green}`._,._,\'${c_reset}
    ${c_purple}  milescsmith/rnaseq v${workflow.manifest.version}${c_reset}
    -${c_dim}--------------------------------------------------${c_reset}-
    """.stripIndent()
}
