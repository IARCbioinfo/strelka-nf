#!/usr/bin/env nextflow


params.help           = null
params.ref            = null
params.strelka        = "./"
params.config         = null
params.bam_path       = "./"
params.tn_file        = null
params.ncpu           = "2"
params.out            = "strelka_output"


params.help = null

if (params.help) {
    log.info ''
    log.info '--------------------------------------------------'
    log.info '                 NEXTFLOW STRELKA                  '
    log.info '--------------------------------------------------'
    log.info ''
    log.info 'Usage: '
    log.info 'nextflow run strelka.nf --tn_file pairs.txt --bam_folder BAM/ --ref ref.fasta --out out_PATH/ --config strelka_config.ini'
    log.info ''
    log.info 'Mandatory arguments:'
    log.info '    --bam_folder         FOLDER                  Folder containing BAM files to be called.'
    log.info '    --tn_file            FILE                    Tab delimited text file with two columns called tumor and normal'
    log.info '                                                 where each line contains the path of two matched BAM files.'
    log.info '    --ref                FILE (with index)       Reference fasta file.'
    log.info '    --config             FILE                    strelka configuration file.'   
    log.info 'Optional arguments:'
    log.info '    --ncpu               INTEGER                 Number of cpu to use.'
    log.info '    --strelka            PATH                    configureStrelkaWorkflow.pl explicit path.'
    log.info ''
    log.info ''
    exit 1
}

strelka = params.strelka + "./configureStrelkaWorkflow.pl"

fasta_ref = file(params.ref)
fasta_ref_fai = file( params.ref+'.fai' )

pairs = Channel.fromPath(params.tn_file).splitCsv(header: true, sep: '\t', strip: true)
.map{ row -> [ file(params.bam_path + "/" + row.tumor), file(params.bam_path + "/" + row.tumor+'.bai'), file(params.bam_path + "/" + row.normal), file(params.bam_path + "/" + row.normal+'.bai') ] }


process run_strelka {

  publishDir params.out, mode: 'move'

  input:
  file pair from pairs
  val strelka

  output:
  file 'strelkaAnalysis/results/*.vcf' into vcffiles

  shell:
  '''
  !{strelka} --tumor !{pair[0]} --normal !{pair[2]} --ref=!{params.ref} --config !{params.config}
  cd strelkaAnalysis
  make -j !{params.ncpu}
  cd results
  mv all.somatic.indels.vcf !{pair[0]}_vs_!{pair[2]}.all.somatic.indels.vcf
  mv all.somatic.snvs.vcf !{pair[0]}_vs_!{pair[2]}.all.somatic.snvs.vcf
  mv passed.somatic.indels.vcf !{pair[0]}_vs_!{pair[2]}.passed.somatic.indels.vcf
  mv passed.somatic.snvs.vcf !{pair[0]}_vs_!{pair[2]}.passed.somatic.snvs.vcf
  '''
}
