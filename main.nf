nextflow.enable.dsl = 2

include { FASTQC } from './modules/nf-core/fastqc/main'
include { BBMAP_BBDUK } from './modules/nf-core/bbmap/bbduk/main'
include { STAR_ALIGN } from './modules/nf-core/star/align/main'
include { STAR_GENOMEGENERATE } from './modules/nf-core/star/genomegenerate/main'
include { SALMON_INDEX } from './modules/nf-core/salmon/index/main'
include { SALMON_QUANT } from './modules/nf-core/salmon/quant/main'
include { MULTIQC } from './modules/nf-core/multiqc/main'

// def updateParams(){

// }

params.input = "${params.raw_fastqs}/*_S*_L00*_R{1,2}_00*.fastq.gz"

raw_fastq_ch = 
    Channel
        .fromFilePairs( params.input, checkIfExists: true, )
        .map{ meta, files -> [['id': meta, ], files]}

multiqc_config = 
    Channel
        .fromPath( "${params.multiqc_config}", checkIfExists: true)

if (params.chm13t2t) {
    println("using t2t")
    reference_sequences = "${params.genomic}/homo_sapiens/sequences/chm13T2T/GCF_009914755.1"
    gtf                 = "${reference_sequences}/genomic.gff"
    fasta               = "${reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna"
    star_index          = "${params.genomic}/homo_sapiens/indices/star/chm13T2T_ncbi_star_2.7.10"
    // salmon_index        = "${params.genomic}/homo_sapiens/indices/salmon/chm13T2Tv2.0_star_2.7.10b"
    salmon_index        = ""
    transcriptome       = "${reference_sequences}/rna.fna"
    gtf_ch =
        Channel
            .fromPath( gtf, checkIfExists: true)
            .collect()
    fasta_ch =
        Channel
            .fromPath( fasta, checkIfExists: true)
            .collect()
    transcriptome_ch =
        Channel
            .fromPath( transcriptome, checkIfExists: true)
            .collect()
} else {
    println("using old refs")
    gtf_ch =
        Channel
            .value( 
                file( params.gtf, checkIfExists: true ) 
            )
    fasta_ch =
        Channel
            .value(
                file( params.fasta, checkIfExists: true )
            )
    transcriptome_ch =
        Channel
            .value(
                file(params.transcriptome, checkIfExists: true)
            )
    star_index = params.star_index
    salmon_index = params.salmon_index
}
if (params.pseudoalign){
    if ( params.build_index ){
        index_ch = SALMON_INDEX(
            fasta_ch,
            gtf_ch
        ).out.index
    } else {
        index_ch =
            Channel
                .value( 
                    file(salmon_index, checkIfExists: true ) 
                )
    }
} else {
    if ( !file( star_index, checkIfExists: true ) | params.build_index ){
        index_ch = STAR_GENOMEGENERATE(
            fasta_ch,
            gtf_ch
        ).out.index
    } else {
        index_ch =
            Channel
                .value(
                    file( star_index, checkIfExists: true )
                )
    }
}
contaminants_ch =
    Channel
        .fromPath( params.contaminants )
        .collect()
params.result = "${params.project}/results"
workflow {
    FASTQC(raw_fastq_ch)
    BBMAP_BBDUK(
        raw_fastq_ch,
        contaminants_ch
    )
    // STAR_ALIGN(
    //     BBMAP_BBDUK.out.reads,
    //     index_ch,
    //     gtf_ch,
    //     false,
    //     "",
    //     ""
    // )
    SALMON_QUANT(
        // STAR_ALIGN.out.bam_transcript,
        BBMAP_BBDUK.out.reads,
        index_ch,
        gtf_ch,
        transcriptome_ch,
        params.salmon_alignment_mode,
        params.salmon_libtype
    )
    MULTIQC(
        FASTQC.out.zip.collect{it[1]}
            // .mix(STAR_ALIGN.out.log_final.collect{it[1]})
            .mix( BBMAP_BBDUK.out.log.collect{it[1]} )
            .mix( SALMON_QUANT.out.json_info.collect{it[1]} )
            .collect(),
        multiqc_config.collect().ifEmpty([]),
        [],
        []
        )
    MULTIQC.out.report.collectFile(name: "results/multiqc_report.html" )
    // STAR_ALIGN.out.bam_sorted.collectFile() { meta, file-> "./${meta.id}/" + file}
    SALMON_QUANT.out.results.collectFile()  { meta, file-> "${params.quant}/${meta.id}/" + file}
}
