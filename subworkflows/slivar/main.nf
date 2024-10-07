include { RUN_SLIVAR_TRIO_ANALYSIS } from "../../modules/slivar/trio_analysis/main.nf"

workflow SLIVAR_ANALYSIS {

  take:
  ch_decom_norm_vcf
  ref_genome
  ref_genome_index
  gff3_file
  pedfile
  slivar_gnomadpath
  slivar_jspath

  
  main:
  ch_versions = Channel.empty()

  SLIVAR_ANALYSIS(ch_decom_norm_vcf, ref_genome, ref_genome_index, gff3_file, pedfile, slivar_gnomadpath, slivar_jspath)
  ch_versions = ch_versions.mix(SLIVAR_ANALYSIS.out.versions)

  emit:
  versions                 = ch_versions
  
}
