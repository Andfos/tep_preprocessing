#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/fastqtobam
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

nextflow.enable.dsl = 2

// import modules available in nf-core
include { TRIMMOMATIC } from './modules/nf-core/trimmomatic/main.nf'
include { STAR_ALIGN } from './modules/nf-core/star/align/main.nf'
include { PICARD_ADDORREPLACEREADGROUPS } from './modules/nf-core/picard/addorreplacereadgroups/main.nf'
include { SAMTOOLS_SORT } from './modules/nf-core/samtools/sort/main.nf'
include { SAMTOOLS_VIEW } from './modules/nf-core/samtools/view/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    All input parameters here
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

println "Starting workflow"

process DECOMPRESS {
    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq"), emit: fastq

    script:
    """
    gunzip -c ${reads[0]} > ${meta.id}_1.fastq
    gunzip -c ${reads[1]} > ${meta.id}_2.fastq
    """
}

//     assert file(params.adapter_file).exists() : "Adapter file is '${params.adapter_file}'"


workflow {
    // Create a channel for input reads
    read_pairs_ch = Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .map { tuple(it[0], it[1]) }

    // Trimmomatic
    TRIMMOMATIC(read_pairs_ch.map { sample_id, files -> [[id:sample_id], files]}, file(params.adapter_file))
    //DECOMPRESS(TRIMMOMATIC.out.trimmed_reads)

    // STAR alignment
    STAR_ALIGN(
        TRIMMOMATIC.out.trimmed_reads,
        //DECOMPRESS.out.fastq,
        Channel.value(file(params.index)).map{ it -> [[id: 'index'], it] },
        Channel.value(file(params.gtf)).map{ it -> [[id: 'gtf'], it] },
        "false", // to not ignore gtf file
        "illumina",
        "seq_center" // can be renamed to seq center name if necessary
    )

    // Add or replace read groups
    PICARD_ADDORREPLACEREADGROUPS(
    STAR_ALIGN.out.bam,
    Channel.value(file(params.genome)).map{ it -> [[id: 'genome'], it] },
    Channel.value(file(params.genome_index)).map{ it -> [[id: 'genome_index'], it] }
    )

    // SAMTOOLS_VIEW(
    //     PICARD_ADDORREPLACEREADGROUPS.out.bam,
    //     Channel.value(file(params.genome)).map{ it -> [[id: 'genome'], it] },
    //     [],
    //     "bai",
    // )

    // Sort BAM file
    SAMTOOLS_SORT(
        PICARD_ADDORREPLACEREADGROUPS.out.bam,
        Channel.value(file(params.genome)).map{ it -> [[id: 'genome'], it] }
    )

}

