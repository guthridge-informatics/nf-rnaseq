nextflow.enable.dsl = 2

include { FASTQC } from './modules/nf-core/fastqc/main'
include { BBMAP_BBDUK } from './modules/nf-core/bbmap/bbduk/main'
include { STAR_ALIGN } from './modules/nf-core/star/align/main'
include { MULTIQC } from './modules/nf-core/multiqc/main'

params.input = "test_data/*_S*_L00*_R{1,2}_00*.fastq.gz"

raw_fastq_ch = 
    Channel
        .fromFilePairs( params.reads_pattern, checkIfExists: true, )
        .map{ meta, files -> [['id': meta, ], files]}

multiqc_config = 
    Channel
        .fromPath( "assets/multiqc_config.yml", checkIfExists: true)

if (params.chm13t2t) {
    reference_sequences = "${params.genomic}/homo_sapiens/sequences/chm13T2Tv2.0"
    gtf                 = "${params.reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf"
    fasta               = "${params.reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna"
    star_index          = "${params.genomic}/homo_sapiens/indices/star/chm13T2Tv2.0_star_2.7.10b"
    salmon_index        = "${params.genomic}/homo_sapiens/indices/salmon/chm13T2Tv2.0_star_2.7.10b"
}

if (params.pseudoalign){
    index_ch =
        Channel
            .fromPath( params.salmon_index, checkIfExists: true )
} else {
    index_ch =
        Channel
            .fromPath( params.star_index, checkIfExists: true )
}

workflow {
    FASTQC(raw_fastq_ch)
    BBMAP_BBDUK(raw_fastq_ch)
    STAR_ALIGN(
        BBMAP_BBDUK.out.reads, 
        index_ch,
        gtf_ch,
        false,
        "",
        ""
        )
    MULTIQC(
        FASTQC.out.zip.collect{it[1]}.mix(STAR_ALIGN.out.log_final.collect{it[1]}), 
        multiqc_config.collect().ifEmpty([]),
        [],
        []
        )
    MULTIQC.out.report.collectFile(name:"results/multiqc_report.html")
}