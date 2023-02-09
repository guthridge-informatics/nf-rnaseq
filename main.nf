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
    Channel.fromPath( "assets/multiqc_config.yml", checkIfExists: true)

workflow {
    FASTQC(raw_fastq_ch)
    MULTIQC(
        FASTQC.out.zip.collect{it[1]}, 
        multiqc_config.collect().ifEmpty([]),
        [],
        []
        )
    MULTIQC.out.report.collectFile(name:"results/multiqc_report.html")
}