include { RUN_SLIVAR_TRIO_ANALYSIS } from "../../modules/slivar/trio_analysis/main.nf"
include { ANNOTATE_VEP_SLIVAR } from "../../modules/vep_annotate_slivar/main.nf"

workflow SLIVAR_ANALYSIS {

  take:
  ch_decom_norm_vcf
  ref_genome
  ref_genome_index
  gff3_file
  pedfile
  slivar_gnomadpath
  slivar_jspath
  vep_cache_files
  vep_plugin_files
  

  
  main:
  ch_versions = Channel.empty()

  RUN_SLIVAR_TRIO_ANALYSIS(ch_decom_norm_vcf, ref_genome, ref_genome_index, gff3_file, pedfile, slivar_gnomadpath, slivar_jspath)
  ch_versions = ch_versions.mix(SLIVAR_ANALYSIS.out.versions)

  ANNOTATE_VEP_SLIVAR(RUN_SLIVAR_TRIO_ANALYSIS.out[0].flatten(), vep_cache_files, vep_plugin_files)

  emit:
  slivar_trio_analysis_output_raw_vcf    = RUN_SLIVAR_TRIO_ANALYSIS.out[0]
  annotated_slivar_output                = ANNOTATE_VEP_SLIVAR.out[0]

  versions                 = ch_versions
  
}
