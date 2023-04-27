nextflow.enable.dsl = 2

include { FASTQC } from './modules/nf-core/fastqc/main'
include { BBMAP_BBDUK } from './modules/nf-core/bbmap/bbduk/main'
include { STAR_ALIGN } from './modules/nf-core/star/align/main'
include { SALMON_QUANT } from './modules/nf-core/salmon/quant/main'
include { MULTIQC } from './modules/nf-core/multiqc/main'

<<<<<<< HEAD
// def updateParams(){

// }

=======
>>>>>>> a8ee02d36e2c0caeb7184fbadeaad56ece301c34
params.input = "${params.raw_fastqs}/*_S*_L00*_R{1,2}_00*.fastq.gz"

raw_fastq_ch = 
    Channel
        .fromFilePairs( params.input, checkIfExists: true, )
        .map{ meta, files -> [['id': meta, ], files]}

multiqc_config = 
    Channel
        .fromPath( "assets/multiqc_config.yml", checkIfExists: true)

if (params.chm13t2t) {
    println("using t2t")
    reference_sequences = "${params.genomic}/homo_sapiens/sequences/chm13T2Tv2.0"
<<<<<<< HEAD
    gtf                 = "${reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.gff"
    fasta               = "${reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna"
    star_index          = "${params.genomic}/homo_sapiens/indices/star/chm13T2Tv2.0_star_2.7.10b"
    salmon_index        = "${params.genomic}/homo_sapiens/indices/salmon/chm13T2Tv2.0_star_2.7.10b"
    transcriptome       = "${reference_sequences}/transcriptome.fa"
    
} else {
    println("using old refs")
    gtf = params.gtf
    fasta = params.fasta
    star_index = params.star_index
    salmon_index = params.salmon_index
    transcriptome = params.transcriptome
=======
    gtf                 = "${reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.gtf"
    fasta               = "${reference_sequences}/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna"
    star_index          = "${params.genomic}/homo_sapiens/indices/star/chm13T2Tv2.0_star_2.7.10b"
    salmon_index        = "${params.genomic}/homo_sapiens/indices/salmon/chm13T2Tv2.0_star_2.7.10b"
    gtf_ch =
        Channel
            .fromPath( gtf, checkIfExists: true)
            .collect()
    fasta_ch =
        Channel
            .fromPath( fasta, checkIfExists: true)
            .collect()
} else {
    println("using old refs")
    gtf_ch =
        Channel
            .fromPath( params.gtf, checkIfExists: true)
            .collect()
    fasta_ch =
        Channel
            .fromPath( params.fasta, checkIfExists: true)
            .collect()
    star_index = params.star_index
    salmon_index = params.salmon_index
>>>>>>> a8ee02d36e2c0caeb7184fbadeaad56ece301c34
}
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

if (params.pseudoalign){
    index_ch =
        Channel
            .fromPath( salmon_index, checkIfExists: true )
            .collect()
} else {
    index_ch =
        Channel
            .fromPath( star_index, checkIfExists: true )
            .collect()
}

contaminants_ch =
    Channel
        .fromPath( params.contaminants )
        .collect()
params.result = "${params.project}/results"
<<<<<<< HEAD

=======
println(params.result)
println(params.project)
>>>>>>> a8ee02d36e2c0caeb7184fbadeaad56ece301c34
workflow {
    FASTQC(raw_fastq_ch)
    BBMAP_BBDUK(
        raw_fastq_ch,
        contaminants_ch
<<<<<<< HEAD
    )
=======
        )
>>>>>>> a8ee02d36e2c0caeb7184fbadeaad56ece301c34
    STAR_ALIGN(
        BBMAP_BBDUK.out.reads,
        index_ch,
        gtf_ch,
        false,
        "",
        ""
    )
    SALMON_QUANT(
        STAR_ALIGN.out.bam_transcript,
        index_ch,
        gtf_ch,
        transcriptome_ch,
        params.salmon_alignment_mode,
        params.salmon_libtype
    )
    MULTIQC(
        FASTQC.out.zip.collect{it[1]}
            .mix(STAR_ALIGN.out.log_final.collect{it[1]})
            .mix(BBMAP_BBDUK.out.log.collect{it[1]})
<<<<<<< HEAD
            .mix(SALMON_QUANT.out.json_info.collect())
=======
>>>>>>> a8ee02d36e2c0caeb7184fbadeaad56ece301c34
            .collect(),
        multiqc_config.collect().ifEmpty([]),
        [],
        []
        )
    // MULTIQC.out.report.collectFile(name:"results/multiqc_report.html")
    // STAR_ALIGN.out.bam_sorted.collectFile() { meta, file-> "./${meta.id}/" + file}
    // STAR_ALIGN.out.
<<<<<<< HEAD
}
=======
}
>>>>>>> a8ee02d36e2c0caeb7184fbadeaad56ece301c34
