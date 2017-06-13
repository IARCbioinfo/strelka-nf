#! /usr/bin/env nextflow

/*vim: syntax=groovy -*- mode: groovy;-*- */

// Copyright (C) 2017 IARC/WHO

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

params.help           = null
params.ref            = null
params.tn_pairs       = null
params.input_folder   = "./"
params.strelka        = null
params.config         = null
params.cpu            = "2"
params.output_folder  = "strelka_output"

log.info ""
log.info "--------------------------------------------------------"
log.info "  Strelka 1.0.1 : variant calling with Strelka workflow "
log.info "--------------------------------------------------------"
log.info "Copyright (C) IARC/WHO"
log.info "This program comes with ABSOLUTELY NO WARRANTY; for details see LICENSE"
log.info "This is free software, and you are welcome to redistribute it"
log.info "under certain conditions; see LICENSE for details."
log.info "--------------------------------------------------------"
log.info ""

if (params.help) {
    log.info "--------------------------------------------------------"
    log.info "  USAGE                                                 "
    log.info "--------------------------------------------------------"
    log.info ""
    log.info "nextflow run iarcbioinfo/strelka-nf --ref hg38.fa --tn_pairs pairs.txt --input_folder path/to/bam/ --strelka path/to/strelka/ --config strelka/1.0.15/etc/strelka_config_bwa_default.ini"
    log.info ""
    log.info "Mandatory arguments:"
    log.info "--ref                  FILE                 Genome reference file"
    log.info "--tn_pairs             FILE                 Tab delimited text file with two columns called normal and tumor"
    log.info "--input_folder         FOLDER               Folder containing BAM files to analyse"
    log.info "--strelka              PATH                 configureStrelkaWorkflow.pl explicit path"
    log.info "--config               FILE                 strelka configuration file"
    log.info ""
    log.info "Optional arguments:"
    log.info "--cpu                  INTEGER              Number of cpu to use (default=2)"
    log.info "--output_folder        PATH                 Output directory for vcf files (default=strelka_ouptut)"
    log.info ""
    log.info "Flags:"
    log.info "--help                                      Display this message"
    log.info ""
    exit 1
} else {


strelka = params.strelka + "./configureStrelkaWorkflow.pl"

/* Software information */
log.info ""
log.info "ref           = params.ref"
log.info "tn_pairs      = params.tn_pairs"
log.info "input_folder  = params.input_folder"
log.info "strelka       = params.strelka"
log.info "config        = params.config"
log.info "cpu           = params.cpu"
log.info "output_folder = params.output_folder"
log.info ""
}

fasta_ref = file(params.ref)
fasta_ref_fai = file( params.ref+'.fai' )

pairs = Channel.fromPath(params.tn_pairs).splitCsv(header: true, sep: '\t', strip: true)
.map{ row -> [ file(params.input_folder + "/" + row.tumor), file(params.input_folder + "/" + row.tumor+'.bai'), file(params.input_folder + "/" + row.normal), file(params.input_folder + "/" + row.normal+'.bai') ] }


process run_strelka {

  publishDir params.output_folder, mode: 'move'

  input:
  file pair from pairs
  val strelka

  output:
  file 'strelkaAnalysis/results/*.vcf' into vcffiles

  shell:
  '''
  !{strelka} --tumor !{pair[0]} --normal !{pair[2]} --ref=!{params.ref} --config !{params.config}
  cd strelkaAnalysis
  make -j !{params.cpu}
  cd results
  mv all.somatic.indels.vcf !{pair[0]}_vs_!{pair[2]}.all.somatic.indels.vcf
  mv all.somatic.snvs.vcf !{pair[0]}_vs_!{pair[2]}.all.somatic.snvs.vcf
  mv passed.somatic.indels.vcf !{pair[0]}_vs_!{pair[2]}.passed.somatic.indels.vcf
  mv passed.somatic.snvs.vcf !{pair[0]}_vs_!{pair[2]}.passed.somatic.snvs.vcf
  '''
}
